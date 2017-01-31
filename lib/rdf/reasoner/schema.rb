# coding: utf-8

# Also requires RDFS reasoner
require 'rdf/reasoner/rdfs'

module RDF::Reasoner
  ##
  # Rules for generating RDFS entailment triples
  #
  # Extends `RDF::Vocabulary::Term` with specific entailment capabilities
  module Schema

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
      types = entailed_types(resource, queryable, options) unless domains.empty?

      # Every domain must match some entailed type
      resource_acceptable = Array(types).empty? || domains.any? {|d| types.include?(d)}

      # Resource may still be acceptable if types include schema:Role, and any any other resource references `resource` using this property
      resource_acceptable ||
        types.include?(RDF::Vocab::SCHEMA.Role) &&
          !queryable.query(predicate: self, object: resource).empty?
    end

    ##
    # Schema.org requires that if the property has a range, and the resource has a type that some type matches some range. If the resource is a datatyped Literal, and the range includes a datatype, the resource must be consistent with that.
    #
    # If `resource` is of type `schema:Role`, it is range acceptable if it has the same property with an acceptable value.
    #
    # If `resource` is of type `rdf:List` (must be previously entailed), it is range acceptable if all members of the list are otherwise range acceptable on the same property.
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
            when RDF::Vocab::SCHEMA.Text   then resource.plain? || resource.datatype == RDF::Vocab::SCHEMA.Text
            when RDF::Vocab::SCHEMA.Boolean
              [RDF::Vocab::SCHEMA.Boolean, RDF::XSD.boolean].include?(resource.datatype) ||
              resource.plain? && RDF::Literal::Boolean.new(resource.value).valid?
            when RDF::Vocab::SCHEMA.Date
              # Schema.org date based on ISO 8601, mapped to appropriate XSD types for validation
              case resource
              when RDF::Literal::Date, RDF::Literal::Time, RDF::Literal::DateTime, RDF::Literal::Duration
                resource.valid?
              else
                ISO_8601.match(resource.value)
              end
            when RDF::Vocab::SCHEMA.DateTime
              resource.datatype == RDF::Vocab::SCHEMA.DateTime ||
              resource.is_a?(RDF::Literal::DateTime) ||
              resource.plain? && RDF::Literal::DateTime.new(resource.value).valid?
            when RDF::Vocab::SCHEMA.Duration
              value = resource.value
              value = "P#{value}" unless value.start_with?("P")
              resource.datatype == RDF::Vocab::SCHEMA.Duration ||
              resource.is_a?(RDF::Literal::Duration) ||
              resource.plain? && RDF::Literal::Duration.new(value).valid?
            when RDF::Vocab::SCHEMA.Time
              resource.datatype == RDF::Vocab::SCHEMA.Time ||
              resource.is_a?(RDF::Literal::Time) ||
              resource.plain? && RDF::Literal::Time.new(resource.value).valid?
            when RDF::Vocab::SCHEMA.Number
              resource.is_a?(RDF::Literal::Numeric) ||
              [RDF::Vocab::SCHEMA.Number, RDF::Vocab::SCHEMA.Float, RDF::Vocab::SCHEMA.Integer].include?(resource.datatype) ||
              resource.plain? && RDF::Literal::Integer.new(resource.value).valid? ||
              resource.plain? && RDF::Literal::Double.new(resource.value).valid?
            when RDF::Vocab::SCHEMA.Float
              resource.is_a?(RDF::Literal::Double) ||
              [RDF::Vocab::SCHEMA.Number, RDF::Vocab::SCHEMA.Float].include?(resource.datatype) ||
              resource.plain? && RDF::Literal::Double.new(resource.value).valid?
            when RDF::Vocab::SCHEMA.Integer
              resource.is_a?(RDF::Literal::Integer) ||
              [RDF::Vocab::SCHEMA.Number, RDF::Vocab::SCHEMA.Integer].include?(resource.datatype) ||
              resource.plain? && RDF::Literal::Integer.new(resource.value).valid?
            when RDF::Vocab::SCHEMA.URL
              resource.datatype == RDF::Vocab::SCHEMA.URL ||
              resource.datatype == RDF::XSD.anyURI ||
              resource.plain? && RDF::Literal::AnyURI.new(resource.value).valid?
            else
              # If may be an XSD range, look for appropriate literal
              if range.start_with?(RDF::XSD.to_s)
                if resource.datatype == RDF::URI(range)
                  true
                else
                  # Valid if cast as datatype
                  resource.plain? && RDF::Literal(resource.value, datatype: RDF::URI(range)).valid?
                end
              else
                # Otherwise, presume that the range refers to a typed resource. This is allowed if the value is a plain literal
                resource.plain?
              end
            end
          end
        elsif %w(True False).map {|v| RDF::Vocab::SCHEMA[v]}.include?(resource) && ranges.include?(RDF::Vocab::SCHEMA.Boolean)
          true # Special case for schema boolean resources
        elsif ranges.include?(RDF::Vocab::SCHEMA.URL) && resource.uri?
          true # schema:URL matches URI resources
        elsif ranges == [RDF::Vocab::SCHEMA.Text] && resource.uri?
          # Allowed if resource is untyped
          entailed_types(resource, queryable, options).empty?
        elsif literal_range?(ranges)
          false # If resource isn't literal, this is a range violation
        else
          # Fully entailed types of the resource
          types = entailed_types(resource, queryable, options)

          # Every range must match some entailed type
          resource_acceptable = Array(types).empty? || ranges.any? {|d| types.include?(d)}

          # Resource may still be acceptable if it has the same property with an acceptable value
          resource_acceptable ||

          # Resource also acceptable if it is a Role, and the Role object contains the same predicate having a compatible object
          types.include?(RDF::Vocab::SCHEMA.Role) &&
            queryable.query(subject: resource, predicate: self).any? do |stmt|
              acc = self.range_compatible_schema?(stmt.object, queryable)
              acc
            end ||
          # Resource also acceptable if it is a List, and every member of the list is range compatible with the predicate
          (list = RDF::List.new(subject: resource, graph: queryable)).valid? && list.all? do |member|
            self.range_compatible_schema?(member, queryable)
          end
        end
      else
        true
      end
    end

    # Are all ranges literal?
    # @param [Array<RDF::UR>] ranges
    # @return [Boolean]
    def literal_range?(ranges)
      ranges.all? do |range|
        case range
        when RDF::RDFS.Literal, RDF::Vocab::SCHEMA.Text, RDF::Vocab::SCHEMA.Boolean, RDF::Vocab::SCHEMA.Date,
             RDF::Vocab::SCHEMA.DateTime, RDF::Vocab::SCHEMA.Time, RDF::Vocab::SCHEMA.URL,
             RDF::Vocab::SCHEMA.Number, RDF::Vocab::SCHEMA.Float, RDF::Vocab::SCHEMA.Integer
          true
        else
          # If this is an XSD range, look for appropriate literal
          range.start_with?(RDF::XSD.to_s)
        end
      end
    end

    def self.included(mod)
    end

    private
    # Fully entailed types
    def entailed_types(resource, queryable, options = {})
      options.fetch(:types) do
        queryable.query(subject: resource, predicate: RDF.type).
          map {|s| (t = (RDF::Vocabulary.find_term(s.object) rescue nil)) && t.entail(:subClassOf)}.
          flatten.
          uniq.
          compact
      end
    end
  end

  # Extend the Term with this methods
  ::RDF::Vocabulary::Term.send(:include, Schema)
end