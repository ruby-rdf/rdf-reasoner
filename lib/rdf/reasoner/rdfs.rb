# coding: utf-8

module RDF::Reasoner
  ##
  # Rules for generating RDFS entailment triples
  #
  # Extends `RDF::Vocabulary::Term` and `RDF::Statement` with specific entailment capabilities
  module RDFS
    ##
    # @return [RDF::Util::Cache]
    # @private
    def subClassOf_cache
      @@subClassOf_cache ||= RDF::Util::Cache.new(-1)
    end

    ##
    # @return [RDF::Util::Cache]
    # @private
    def subClass_cache
      @@subClass_cache_cache ||= RDF::Util::Cache.new(-1)
    end

    ##
    # @return [RDF::Util::Cache]
    # @private
    def descendant_cache
      @@descendant_cache ||= RDF::Util::Cache.new(-1)
    end

    ##
    # @return [RDF::Util::Cache]
    # @private
    def subPropertyOf_cache
      @@subPropertyOf_cache ||= RDF::Util::Cache.new(-1)
    end

    ##
    # For a Term: yield or return inferred subClassOf relationships by recursively applying to named super classes to get a complete set of classes in the ancestor chain of this class
    # For a Statement: if predicate is `rdf:types`, yield or return inferred statements having a subClassOf relationship to the type of this statement
    # @private
    def _entail_subClassOf
      case self
      when RDF::Vocabulary::Term
        unless class? && respond_to?(:subClassOf)
          yield self if block_given?
          return Array(self)
        end
        terms = subClassOf_cache[self] ||= (
          Array(self.subClassOf).
            map {|c| c._entail_subClassOf rescue c}.
            flatten +
          Array(self)
        ).compact
        terms.each {|t| yield t} if block_given?
        terms
      when RDF::Statement
        statements = []
        if self.predicate == RDF.type
          if term = (RDF::Vocabulary.find_term(self.object) rescue nil)
            term._entail_subClassOf do |t|
              statements << RDF::Statement(self.to_h.merge(object: t, inferred: true))
            end
          end
          #$stderr.puts("subClassf(#{self.predicate.pname}): #{statements.map(&:object).map {|r| r.respond_to?(:pname) ? r.pname : r.to_ntriples}}}")
        end
        statements.each {|s| yield s} if block_given?
        statements
      else []
      end
    end

    ##
    # For a Term: yield or return inferred subClass relationships by recursively applying to named sub classes to get a complete set of classes in the descendant chain of this class
    # For a Statement: this is a no-op, as it's not useful in this context
    # @private
    def _entail_subClass
      case self
      when RDF::Vocabulary::Term
        unless class?
          yield self if block_given?
          return Array(self)
        end
        terms = descendant_cache[self] ||= (
          Array(self.subClass).
            map {|c| c._entail_subClass rescue c}.
            flatten +
          Array(self)
        ).compact
        terms.each {|t| yield t} if block_given?
        terms
      else []
      end
    end

    ##
    # Get the immediate subclasses of this class.
    #
    # This iterates over terms defined in the vocabulary of this term, as well as the vocabularies imported by this vocabulary.
    # @return [Array<RDF::Vocabulary::Term>]
    def subClass
      raise RDF::Reasoner::Error, "#{self} Can't entail subClass" unless class?
      subClass_cache[self] ||= ([self.vocab] + self.vocab.imported_from).map do |v|
        Array(v.properties).select {|p| p.class? && Array(p.subClassOf).include?(self)}
      end.flatten.compact
    end

    ##
    # For a Term: yield or return inferred subPropertyOf relationships by recursively applying to named super classes to get a complete set of classes in the ancestor chain of this class
    # For a Statement: yield or return inferred statements having a subPropertyOf relationship to predicate of this statement
    # @private
    def _entail_subPropertyOf
      case self
      when RDF::Vocabulary::Term
        unless property? && respond_to?(:subPropertyOf)
          yield self if block_given?
          return Array(self)
        end
        terms = subPropertyOf_cache[self] ||= (
          Array(self.subPropertyOf).
            map {|c| c._entail_subPropertyOf rescue c}.
            flatten +
          Array(self)
        ).compact
        terms.each {|t| yield t} if block_given?
        terms
      when RDF::Statement
        statements = []
        if term = (RDF::Vocabulary.find_term(self.predicate) rescue nil)
          term._entail_subPropertyOf do |t|
            statements << RDF::Statement(self.to_h.merge(predicate: t, inferred: true))
          end
          #$stderr.puts("subPropertyOf(#{self.predicate.pname}): #{statements.map(&:object).map {|r| r.respond_to?(:pname) ? r.pname : r.to_ntriples}}}")
        end
        statements.each {|s| yield s} if block_given?
        statements
      else []
      end
    end

    ##
    # For a Statement: yield or return inferred statements having an rdf:type of the domain of the statement predicate
    # @private
    def _entail_domain
      case self
      when RDF::Statement
        statements = []
        if term = (RDF::Vocabulary.find_term(self.predicate) rescue nil)
          term.domain.each do |t|
            statements << RDF::Statement(self.to_h.merge(predicate: RDF.type, object: t, inferred: true))
          end
        end
        #$stderr.puts("domain(#{self.predicate.pname}): #{statements.map(&:object).map {|r| r.respond_to?(:pname) ? r.pname : r.to_ntriples}}}")
        statements.each {|s| yield s} if block_given?
        statements
      else []
      end
    end

    ##
    # For a Statement: if object is a resource, yield or return inferred statements having an rdf:type of the range of the statement predicate
    # @private
    def _entail_range
      case self
      when RDF::Statement
        statements = []
        if object.resource? && term = (RDF::Vocabulary.find_term(self.predicate) rescue nil)
          term.range.each do |t|
            statements << RDF::Statement(self.to_h.merge(subject: self.object, predicate: RDF.type, object: t, inferred: true))
          end
        end
        #$stderr.puts("range(#{self.predicate.pname}): #{statements.map(&:object).map {|r| r.respond_to?(:pname) ? r.pname : r.to_ntriples}}")
        statements.each {|s| yield s} if block_given?
        statements
      else []
      end
    end

    ##
    # RDFS requires that if the property has a domain, and the resource has a type that some type matches every domain.
    #
    # Note that this is different than standard entailment, which simply asserts that the resource has every type in the domain, but this is more useful to check if published data is consistent with the vocabulary definition.
    #
    # @param [RDF::Resource] resource
    # @param [RDF::Queryable] queryable
    # @param [Hash{Symbol => Object}] options ({})
    # @option options [Array<RDF::Vocabulary::Term>] :types
    #   Fully entailed types of resource, if not provided, they are queried
    def domain_compatible_rdfs?(resource, queryable, options = {})
      raise RDF::Reasoner::Error, "#{self} can't get domains" unless property?
      if respond_to?(:domain)
        domains = Array(self.domain) - [RDF::OWL.Thing, RDF::RDFS.Resource]

        # Fully entailed types of the resource
        types = options.fetch(:types) do
          queryable.query(subject: resource, predicate: RDF.type).
            map {|s| (t = (RDF::Vocabulary.find_term(s.object)) rescue nil) && t.entail(:subClassOf)}.
            flatten.
            uniq.
            compact
        end unless domains.empty?

        # Every domain must match some entailed type
        Array(types).empty? || domains.all? {|d| types.include?(d)}
      else
        true
      end
    end

    ##
    # RDFS requires that if the property has a range, and the resource has a type that some type matches every range. If the resource is a datatyped Literal, and the range includes a datatype, the resource must be consistent with that.
    #
    # Note that this is different than standard entailment, which simply asserts that the resource has every type in the range, but this is more useful to check if published data is consistent with the vocabulary definition.
    #
    # @param [RDF::Resource] resource
    # @param [RDF::Queryable] queryable
    # @param [Hash{Symbol => Object}] options ({})
    # @option options [Array<RDF::Vocabulary::Term>] :types
    #   Fully entailed types of resource, if not provided, they are queried
    def range_compatible_rdfs?(resource, queryable, options = {})
      raise RDF::Reasoner::Error, "#{self} can't get ranges" unless property?
      if respond_to?(:range) && !(ranges = Array(self.range) - [RDF::OWL.Thing, RDF::RDFS.Resource]).empty?
        if resource.literal?
          ranges.all? do |range|
            if [RDF::RDFS.Literal, RDF.XMLLiteral, RDF.HTML].include?(range)
              true  # Don't bother checking for validity
            elsif range.start_with?(RDF::XSD)
              # XSD types are valid if the datatype matches, or they are plain and valid according to the grammar of the range
                resource.datatype == range ||
                resource.plain? && RDF::Literal.new(resource.value, datatype: range).valid?
            elsif range.start_with?(RDF::Vocab::OGC)
              case range
              when RDF::Vocab::OGC.boolean_str
                [RDF::Vocab::OGC.boolean_str, RDF::XSD.boolean].include?(resource.datatype) ||
                resource.plain? && RDF::Literal::Boolean.new(resource.value).valid?
              when RDF::Vocab::OGC.date_time_str
                # Schema.org date based on ISO 8601, mapped to appropriate XSD types for validation
                case resource
                when RDF::Literal::Date, RDF::Literal::Time, RDF::Literal::DateTime, RDF::Literal::Duration
                  resource.valid?
                else
                  ISO_8601.match(resource.value)
                end
              when RDF::Vocab::OGC.determiner_str
                # The lexical space: "", "the", "a", "an", and "auto".
                resource.plain? && (%w(the a an auto) + [""]).include?(resource.value)
              when RDF::Vocab::OGC.float_str
                # A string representation of a 64-bit signed floating point number.  Example lexical values include "1.234", "-1.234", "1.2e3", "-1.2e3", and "7E-10".
                [RDF::Vocab::OGC.float_str, RDF::Literal::Double, RDF::Literal::Float].include?(resource.datatype) ||
                resource.plain? && RDF::Literal::Double.new(resource.value).valid?
              when RDF::Vocab::OGC.integer_str
                resource.is_a?(RDF::Literal::Integer) ||
                [RDF::Vocab::OGC.integer_str].include?(resource.datatype) ||
                resource.plain? && RDF::Literal::Integer.new(resource.value).valid?
              when RDF::Vocab::OGC.mime_type_str
                # Valid mime type strings \(e.g., "application/mp3"\).
                [RDF::Vocab::OGC.mime_type_str].include?(resource.datatype) ||
                resource.plain? && resource.value =~ %r(^[\w\-\+]+/[\w\-\+]+$)
              when RDF::Vocab::OGC.string
                resource.plain?
              when RDF::Vocab::OGC.url
                # A string of Unicode characters forming a valid URL having the http or https scheme.
                u = RDF::URI(resource.value)
                resource.datatype == RDF::Vocab::OGC.url ||
                resource.datatype == RDF::XSD.anyURI ||
                resource.simple? && u.valid? && u.scheme.to_s =~ /^https?$/
              else
                # Unknown datatype
                false
              end
            else
              false
            end
          end
        else
          # Fully entailed types of the resource
          types = options.fetch(:types) do
            queryable.query(subject: resource, predicate: RDF.type).
              map {|s| (t = (RDF::Vocabulary.find_term(s.object) rescue nil)) && t.entail(:subClassOf)}.
              flatten.
              uniq.
              compact
          end

          # If any type is a class, add rdfs:Class
          if types.any? {|t| t.is_a?(RDF::Vocabulary::Term) && t.class?} && !types.include?(RDF::RDFS.Class)
            types << RDF::RDFS.Class
          end

          # Every range must match some entailed type
          Array(types).empty? || ranges.all? {|d| types.include?(d)}
        end
      else
        true
      end
    end
    
    def self.included(mod)
      mod.add_entailment :subClassOf, :_entail_subClassOf
      mod.add_entailment :subClass, :_entail_subClass
      mod.add_entailment :subPropertyOf, :_entail_subPropertyOf
      mod.add_entailment :domain, :_entail_domain
      mod.add_entailment :range, :_entail_range
    end
  end

  # Extend Term with these methods
  ::RDF::Vocabulary::Term.send(:include, RDFS)

  # Extend Statement with these methods
  ::RDF::Statement.send(:include, RDFS)

  # Extend Enumerable with these methods
  ::RDF::Enumerable.send(:include, RDFS)

  # Extend Mutable with these methods
  ::RDF::Mutable.send(:include, RDFS)
end