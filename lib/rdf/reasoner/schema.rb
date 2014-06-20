# coding: utf-8

# Also requires RDFS reasoner
require 'rdf/reasoner/rdfs'

module RDF::Reasoner
  ##
  # Rules for generating RDFS entailment triples
  #
  # Extends `RDF::Vocabulary::Term` with specific entailment capabilities
  module SCHEMA
    # domain_includes accessor
    # @return [Array<RDF::Vocabulary::Term>]
    def domain_includes
      Array(@attributes["schema:domainIncludes"]).map {|v| RDF::Vocabulary.expand_pname(v)}
    end
    alias_method :domainIncludes, :domain_includes

    # range_includes accessor
    # @return [Array<RDF::Vocabulary::Term>]
    def range_includes
      Array(@attributes["schema:rangeIncludes"]).map {|v| RDF::Vocabulary.expand_pname(v)}
    end
    alias_method :rangeIncludes, :range_includes

    ##
    # Schema.org requires that if the property has a domain, and the resource has a type that some type matches some domain.
    #
    # Note that this is different than standard entailment, which simply asserts that the resource has every type in the domain, but this is more useful to check if published data is consistent with the vocabulary definition.
    #
    # If `resource` is of type `schema:Role`, `resource` is domain acceptable if any other resource references `resource` using this property.
    #
    # @param [RDF::Resource] resource
    # @param [RDF::Queryable] queryable
    # @param [Hash{Symbol => Object}] options
    # @option options [Array<RDF::Vocabulary::Term>] :types
    #   Fully entailed types of resource, if not provided, they are queried
    def domain_compatible_schema?(resource, queryable, options = {})
      raise RDF::Reasoner::Error, "#{self} can't get domains" unless property?
      domains = Array(self.domainIncludes) - [RDF::OWL.Thing]

      # Fully entailed types of the resource
      types = options.fetch(:types) do
        queryable.query(:subject => resource, :predicate => RDF.type).
          map {|s| (t = RDF::Vocabulary.find_term(s.object)) && t.entail(:subClassOf)}.
          flatten.
          uniq.
          compact
      end unless domains.empty?

      # Every domain must match some entailed type
      resource_acceptable = Array(types).empty? || domains.any? {|d| types.include?(d)}

      # Resource may still be acceptable if types include schema:Role, and any any other resource references `resource` using this property
      resource_acceptable ||
        types.include?(RDF::SCHEMA.Role) &&
          !queryable.query(predicate: self, object: resource).empty?
    end

    ##
    # Schema.org requires that if the property has a range, and the resource has a type that some type matches some range. If the resource is a datatyped Literal, and the range includes a datatype, the resource must be consistent with that.
    #
    # If `resource` is of type `schema:Role`, it is range acceptable if it has the same property with an acceptable value.
    #
    # Also, a plain literal (or schema:Text) is always compatible with an object range.
    #
    # @param [RDF::Resource] resource
    # @param [RDF::Queryable] queryable
    # @param [Hash{Symbol => Object}] options ({})
    # @option options [Array<RDF::Vocabulary::Term>] :types
    #   Fully entailed types of resource, if not provided, they are queried
    def range_compatible_schema?(resource, queryable, options = {})
      raise RDF::Reasoner::Error, "#{self} can't get ranges" unless property?
      if respond_to?(:rangeIncludes) && !(ranges = Array(self.rangeIncludes) - [RDF::OWL.Thing]).empty?
        if resource.literal?
          ranges.any? do |range|
            case range
            when RDF::RDFS.Literal  then true
            when RDF::SCHEMA.Text   then resource.plain? || resource.datatype == RDF::SCHEMA.Text
            when RDF::SCHEMA.Boolean
              [RDF::SCHEMA.Boolean, RDF::XSD.boolean].include?(resource.datatype) ||
              resource.simple? && RDF::Literal::Boolean.new(resource.value).valid?
            when RDF::SCHEMA.Date
              resource.datatype == RDF::SCHEMA.Date ||
              resource.is_a?(RDF::Literal::Date) ||
              resource.simple? && RDF::Literal::Date.new(resource.value).valid?
            when RDF::SCHEMA.DateTime
              resource.datatype == RDF::SCHEMA.DateTime ||
              resource.is_a?(RDF::Literal::DateTime) ||
              resource.simple? && RDF::Literal::DateTime.new(resource.value).valid?
            when RDF::SCHEMA.Duration
              value = resource.value
              value = "P#{value}" unless value.start_with?("P")
              resource.datatype == RDF::SCHEMA.Duration ||
              resource.is_a?(RDF::Literal::Duration) ||
              resource.simple? && RDF::Literal::Duration.new(value).valid?
            when RDF::SCHEMA.Time
              resource.datatype == RDF::SCHEMA.Time ||
              resource.is_a?(RDF::Literal::Time) ||
              resource.simple? && RDF::Literal::Time.new(resource.value).valid?
            when RDF::SCHEMA.Number
              resource.is_a?(RDF::Literal::Numeric) ||
              [RDF::SCHEMA.Number, RDF::SCHEMA.Float, RDF::SCHEMA.Integer].include?(resource.datatype) ||
              resource.simple? && RDF::Literal::Integer.new(resource.value).valid? ||
              resource.simple? && RDF::Literal::Double.new(resource.value).valid?
            when RDF::SCHEMA.Float
              resource.is_a?(RDF::Literal::Double) ||
              [RDF::SCHEMA.Number, RDF::SCHEMA.Float].include?(resource.datatype) ||
              resource.simple? && RDF::Literal::Double.new(resource.value).valid?
            when RDF::SCHEMA.Integer
              resource.is_a?(RDF::Literal::Integer) ||
              [RDF::SCHEMA.Number, RDF::SCHEMA.Integer].include?(resource.datatype) ||
              resource.simple? && RDF::Literal::Integer.new(resource.value).valid?
            when RDF::SCHEMA.URL
              resource.datatype == RDF::SCHEMA.URL ||
              resource.datatype == RDF::XSD.anyURI ||
              resource.simple? && RDF::Literal::AnyURI.new(resource.value).valid?
            else
              # If this is an XSD range, look for appropriate literal
              if range.start_with?(RDF::XSD.to_s)
                if resource.datatype == RDF::URI(range)
                  true
                else
                  # Valid if cast as datatype
                  resource.simple? && RDF::Literal(resource.value, :datatype => RDF::URI(range)).valid?
                end
              else
                # Otherwise, presume that the range refers to a typed resource
                false
              end
            end
          end
        elsif %w(True False).map {|v| RDF::SCHEMA[v]}.include?(resource) && ranges.include?(RDF::SCHEMA.Boolean)
          true # Special case for schema boolean resources
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
          resource_acceptable = Array(types).empty? || ranges.any? {|d| types.include?(d)}

          # Resource may still be acceptable if it has the same property with an acceptable value
          resource_acceptable ||
            types.include?(RDF::SCHEMA.Role) &&
              queryable.query(subject: resource, predicate: self).any? do |stmt|
                acc = self.range_compatible_schema?(stmt.object, queryable)
                acc
              end
        end
      else
        true
      end
    end
  
    def self.included(mod)
    end
  end

  # Extend the Term with this methods
  ::RDF::Vocabulary::Term.send(:include, SCHEMA)
end