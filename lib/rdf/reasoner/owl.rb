# coding: utf-8

module RDF::Reasoner
  ##
  # Rules for generating OWL entailment triples
  #
  # Create instances for each owl:Class, owl:ObjectProperty, owl:DatatypeProperty, owl:DataType and owl:Restriction. This allows querying for querying specific entailed relationships of each instance.
  class OWL
    # Base class for OWL classes
    class Base
      # resource attribute, the IRI or BNode subject of the class
      # #!attribute [r] resource
      # @return [RDF::Resource]
      attr_reader :resource

      # RDF::Enumerable containing entity definition
      #
      # #!attribute [r] enumerable
      # @return [RDF::Enumerable]
      attr_reader :enumerable

      class << self
        # Class reader for all defined entities
        # @!attribute [r] all
        # @return [Array<Property>]
        attr_reader :all
      end

      # Find instance based on this resource
      # @param [RDF::Resource] resource
      # @return [Base]
      def self.find(resource)
        all.detect {|r| r.resource == resource}
      end

      ##
      # Create a new entity based on resource within enumerable
      #
      # @param [RDF::Resource] resource
      # @param [RDF::Enumerable] enumerable
      def initialize(resource, enumerable)
        @resource, @enumerable = resource, enumerable
        (Base.all ||= []) << self
      end

      # Human label of this class
      # @return [String]
      def label
        @label || @resource.split(/\/\#/).last
      end

      # Infered ranges of the {Restriction} or {Property}
      # FIXME: This does not account for intersection/union
      # @return [Array<OwlClass,DataType>]
      def ranges
        values = @on_class || @all_values_from || @some_values_from || @on_data_range || @range
        return [] unless values
        values.map do |v|
          v.one_of || v.union_of || ([v] + v.descendant_classes)
        end.flatten
      end

      # Is this entity the same as `cls`, or is it a union containing `cls`?
      # @param [OwlClass] cls
      # @return [TrueClass, FalseClass]
      def class_of?(cls)
        cls == self or union_of.include?(cls)
      end

      # Override for actual descendant classes
      # @return [Array]
      def descendant_classes; []; end

      # Is this a named entity (i.e., not some OWL construction)
      # @return [TrueClass, FalseClass]
      def named?
        @resource.iri?
      end

      ##
      # Accessors for entity fields
      #
      # @overload all_values_from
      #   @return [Array<Base>] reflects owl:allValuesFrom
      # @overload _cardinality
      #   @return [Integer]
      #     reflects owl:cardinality and owl:qualifiedCardinality.
      #     @see {Restriction#cardinality}
      #  @overload equivalent_property
      #     @return [Array<Property>] reflects owl:equivalentProperty
      # ...
      def method_missing(meth, *args)
        def _access(preds, how)
          @access ||= {}
          # Memoize result
          @access[meth] ||= begin
            values = []
            preds.each do |pred|
              enumerable.query(:subject => resource, :predicate => pred) do |statement|
                values << statement.object
              end
            end
            case how
            when true
              # Value is simply true
              true
            when :ary
              # Translate IRIs into instances of Base
              values.map {|v| Base.find(v) || v}
            when :list
              # Access as list and translate IRIs into instances of Base
              RDF::List(values.first, enumerable).to_a.map {|v| Base.find(v) || v}
            when :obj, :int
              # Take first element of array, and optionally translate to integer
              how == :int ? values.first.to_i : values.first
            end
          end
        end

        case :meth
        when :all_values_from then _access([RDF::OWL::allValuesFrom], :ary)
        when :_cardinality then _access([RDF::OWL::cardinality, RDF::OWL::qualifiedCardinality], :int)
        when :domain then _access([RDF::RDFS::domain], :ary)
        when :equivalent_property then _access([RDF::OWL::equivalentProperty], :ary)
        when :has_self then _access([RDF::OWL::hasSelf], true)
        when :has_value then _access([RDF::OWL::hasValue], :ary)
        when :intersection_of then _access([RDF::OWL::hasSelf], true)
        when :inverse_of then _access([RDF::OWL::inverseOf], :obj)
        when :max_cardinality then _access([RDF::OWL::maxCardinality, RDF::OWL::maxQualifiedCardinality], :int)
        when :min_cardinality then _access([RDF::OWL::minCardinality, RDF::OWL::minQualifiedCardinality], :int)
        when :one_of then _access([RDF::OWL::oneOf], :list)
        when :on_class then _access([RDF::OWL::onClass], :obj)
        when :on_datarange then _access([RDF::OWL::onDatatype], :obj)
        when :on_property then _access([RDF::OWL::onProperty], :obj)
        when :range then _access([RDF::RDFS::range], :ary)
        when :some_values_from then _access([RDF::OWL::someValuesFrom], :ary)
        when :sub_class_of then _access([RDF::RDFS::subClassOf], :ary)
        when :sub_property_of then _access([RDF::RDFS::subPropertyOf], :ary)
        when :union_of then _access([RDF::OWL::unionOf], :list)
        when :with_restrictions then _access([RDF::OWL::withRestrictions], :list)
        else
          super
        end
      end
    end

    # Entries for owl objects which are Object or Datatype Properties
    class Property < Base
      class << self
        # Class reader for all defined properties
        # @!attribute [r] all
        # @return [Array<Property>]
        attr_reader :all
      end

      ##
      # Create a new property based on resource within enumerable
      #
      # @param [RDF::Resource] resource
      # @param [RDF::Enumerable] enumerable
      def initialize(resource, enumerable)
        super
        (Property.all ||= []) << self
      end

      # Infered domains of this property
      # FIXME: does not account for intersection/union, which is uncomon in domains
      # @return [Array<OwlClass>]
      def domains
        self.domain.map do |v|
          v.one_of || v.union_of || ([v] + v.descendant_classes)
        end.flatten.uniq
      end


      # Does this property have a domain including cls?
      # The JSON is defined to always represent domain as an array
      # FIXME: this doesn't deal with intersection
      # @param [OwlClass] cls
      # @return [TrueClass, FalseClass]
      def domain_of?(cls)
        domain.any? {|dom| dom.class_of?(cls)}
      end
    end


    # OWL Restrictions are similar to classes. They impose a restriction on
    # values of some property, such as cardinality
    class Restriction < Base
      # For restrictions, return any defined cardinality
      # as an array of \[min, max\] where either max may be `nil`.
      # Min will always be an integer.
      # @return [Array<(Integer, Integer)>]
      def cardinality
        [(@cardinality || @min_cardinality || 0), (@cardinality || @max_cardinality)]
      end
    end

    # Entries for owl objects wich are classes
    class OwlClass < Base
      class << self
        # Class accessor for all defined classes
        # @!attribute [r] all
        # @return [Array<OwlClass>]
        attr_reader :all
      end

      ##
      # Create a new class based on resource within enumerable
      #
      # @param [RDF::Resource] resource
      # @param [RDF::Enumerable] enumerable
      def initialize(resource, enumerable)
        super
        (OwlClass.all ||= []) << self
      end

      # Return super classes as an S-Expression
      # @return [Array<OwlClass>]
      def super_classes
        @super_class_cache ||= begin
          # Note in super-class, that this is a direct sub-class
          sup = self.sub_class_of

          anded_classes = sup.map do |cls|
            if cls.is_a?(OwlClass) and cls.named?
              cls
            elsif cls.unionOf
              ored_classes = cls.union_of.select {|c2| c2.is_a?(OwlClass)}.compact
              case ored_classes.length
              when 0 then nil
              when 1 then ored_classes.first
              else        (%w(|) + ored_classes).freeze
              end
            end
          end.compact

          case anded_classes.length
          when 0 then [].freeze
          when 1 then anded_classes.first
          else        (%w(&) + anded_classes).freeze
          end
        end
      end

      # Return all direct sub-classes
      # This counts on each class having had superClasses calculated to
      # inject the sub-class relation
      # @return [Array<OwlClass>]
      def sub_classes
        @sub_classes_cache ||= OwlClass.all.select do |c|
          c.sub_class_of.any? {|cl| cl.class_of?(self)}
        end
      end

      # Return all descendant classes
      # @return [Array<OwlClass>]
      def descendant_classes
        @descendant_classes ||= begin
          (sub_classes + sub_classes.map {|cls| cls.descendant_classes}.flatten).compact.freeze
        end
      end

      # Return a list of all property restrictions on this class and super-classes
      # @return [Array<Restriction>]
      def property_restrictions
        @property_restrictions_cache ||= begin
          restrictions = evaluate_sexp(self.super_classes) {|c| c.property_restrictions}.dup
          restrictions = [restrictions].compact unless restrictions.is_a?(Array)
          # Add restrictions defined on this class
          self.sub_class_of.select {|r| r.is_a?(Restriction)}.each do |restriction|
            prop = restriction.on_property
            # Remove any existing restriction on the same property
            restrictions.reject! {|r| r.on_property == prop}
            #puts "#{resource}: add local restriction: #{restriction.on_property.resource}"
            restrictions << restriction
          end

          restrictions.freeze
        end
      end

      # Return a list of all properties on this class and super-classes
      # @return [Array<Property>]
      def properties
        @properties_cache ||= begin
          # Inherited properties
          props = evaluate_sexp(super_classes) {|c| c.properties}

          # Add properties directly referencing this class
          direct_props = Property.all.select do |prop|
            prop.domain_of?(self) and
            !props.include?(prop)
          end

          (props + direct_props).sort.freeze
        end
      end

      private
      # Evaluate a subclass S-Expression
      def evaluate_sexp(classes)
        case classes
        when OWL then yield classes
        when Array
          case classes.first
          when '|' # Union of classes
            cls = yield(classes[1]).dup
            classes[2..-1].each {|cls2| cls = cls | yield(cls2)}
            cls
          when '&' # Intersection of classes
            cls = yield(classes[1]).dup
            classes[2..-1].each {|cls2| cls = cls & yield(cls2)}
            cls
          else
            $logger.error "Unexpected operator in S-Exp for #{@resource}: #{classes.inspect}" unless classes.empty?
            classes.dup
          end
        else
          $logger.error "Unexpected value in S-Exp for #{@resource}: #{classes.inspect}" if classes
          nil
        end
      end
    end

    # Entries for XSD and RDF datatypes
    class DataType < Base
      attr_accessor :rdf_literal_class
      
      def initialize(object)
        super
        @rdf_literal_class = RDF::Literal
      end

      def validate(value)
        if (rdf_literal_class.new(value).valid? rescue false)
          case
          when one_of
            "#{value.inspect} must be one of #{one_of.inspect}" unless one_of.include?(value)
          end
        else
          "#{value.inspect} is not a valid #{label}(#{resource})"
        end
      end
    end
  end
end