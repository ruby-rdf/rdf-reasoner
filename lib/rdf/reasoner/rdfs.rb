# coding: utf-8

module RDF::Reasoner
  ##
  # Rules for generating RDFS entailment triples
  #
  # Extends `RDF::Vocabulary::Term` with specific entailment capabilities
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
    def subPropertyOf_cache
      @@subPropertyOf_cache ||= RDF::Util::Cache.new(-1)
    end

    ##
    # Return inferred subClassOf relationships by recursively applying to named super classes to get a complete set of classes in the ancestor chain of this class
    def _entail_subClassOf
      raise RDF::Reasoner::Error, "#{self} Can't entail subClassOf" unless class?
      subClassOf_cache[self] ||= begin
        (Array(self.subClassOf).map {|c| c._entail_subClassOf}.flatten + Array(self.subClassOf) + Array(self)).compact
      end
    end

    ##
    # Return inferred subPropertyOf relationships by recursively applying to named super classes to get a complete set of classes in the ancestor chain of this class
    def _entail_subPropertyOf
      raise RDF::Reasoner::Error, "#{self} Can't entail subPropertyOf" unless property?
      subPropertyOf_cache[self] ||= begin
        (Array(self.subPropertyOf).map {|c| c._entail_subPropertyOf}.flatten + Array(self.subPropertyOf) + Array(self)).compact
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
        domains = Array(self.domain) - [RDF::OWL.Thing]

        # Fully entailed types of the resource
        types = options.fetch(:types) do
          queryable.query(:subject => resource, :predicate => RDF.type).
            map {|s| (t = RDF::Vocabulary.find_term(s.object)) && t.entail(:subClassOf)}.
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
      if respond_to?(:range) && !(ranges = Array(self.range) - [RDF::OWL.Thing]).empty?
        if resource.literal?
          ranges.all? do |range|
            case range
            when RDF::RDFS.Literal, RDF.XMLLiteral, RDF.HTML  then true
            else
              if range.start_with?(RDF::XSD)
                resource.datatype == range ||
                resource.simple? && RDF::Literal::Boolean.new(resource.value).valid?
              else
                false
              end
            end
          end
        else
          # Fully entailed types of the resource
          types = options.fetch(:types) do
            queryable.query(:subject => resource, :predicate => RDF.type).
              map {|s| (t = RDF::Vocabulary.find_term(s.object)) && t.entail(:subClassOf)}.
              flatten.
              uniq.
              compact
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
      mod.add_entailment :subPropertyOf, :_entail_subPropertyOf
    end
  end

  # Extend the Term with this methods
  ::RDF::Vocabulary::Term.send(:include, RDFS)
end