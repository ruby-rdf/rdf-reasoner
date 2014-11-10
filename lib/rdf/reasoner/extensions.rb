# Extensions to RDF core classes to support reasoning
require 'rdf'

module RDF
  class Vocabulary::Term
    class << self
      @@entailments = {}

      ##
      # Add an entailment method. The method accepts no arguments, and returns or yields an array of values associated with the particular entailment method
      # @param [Symbol] method
      # @param [Proc] proc
      def add_entailment(method, proc)
        @@entailments[method] = proc
      end
    end

    ##
    # Perform an entailment on this term.
    #
    # @param [Symbol] method A registered entailment method
    # @yield term
    # @yieldparam [Term] term
    # @return [Array<Term>]
    def entail(method, &block)
      self.send(@@entailments.fetch(method), &block)
    end

    ##
    # Determine if the domain of a property term is consistent with the specified resource in `queryable`.
    #
    # @param [RDF::Resource] resource
    # @param [RDF::Queryable] queryable
    # @param [Hash{Symbol => Object}] options ({})
    # @option options [Array<RDF::Vocabulary::Term>] :types
    #   Fully entailed types of resource, if not provided, they are queried
    def domain_compatible?(resource, queryable, options = {})
      %w(owl rdfs schema).map {|r| "domain_compatible_#{r}?".to_sym}.all? do |meth|
        !self.respond_to?(meth) || self.send(meth, resource, queryable, options)
      end
    end

    ##
    # Determine if the range of a property term is consistent with the specified resource in `queryable`.
    #
    # Specific entailment regimes should insert themselves before this to apply the appropriate semantic condition
    #
    # @param [RDF::Resource] resource
    # @param [RDF::Queryable] queryable
    # @param [Hash{Symbol => Object}] options ({})
    # @option options [Array<RDF::Vocabulary::Term>] :types
    #   Fully entailed types of resource, if not provided, they are queried
    def range_compatible?(resource, queryable, options = {})
      %w(owl rdfs schema).map {|r| "range_compatible_#{r}?".to_sym}.all? do |meth|
        !self.respond_to?(meth) || self.send(meth, resource, queryable, options)
      end
    end
  end

  class Statement
    class << self
      @@entailments = {}

      ##
      # Add an entailment method. The method accepts no arguments, and returns or yields an array of values associated with the particular entailment method
      # @param [Symbol] method
      # @param [Proc] proc
      def add_entailment(method, proc)
        @@entailments[method] = proc
      end
    end

    ##
    # Perform an entailment on this term.
    #
    # @param [Symbol] method A registered entailment method
    # @yield term
    # @yieldparam [Term] term
    # @return [Array<Term>]
    def entail(method, &block)
      self.send(@@entailments.fetch(method), &block)
    end
  end

  module Enumerable
    class << self
      @@entailments = {}

      ##
      # Add an entailment method. The method accepts no arguments, and returns or yields an array of values associated with the particular entailment method
      # @param [Symbol] method
      # @param [Proc] proc
      def add_entailment(method, proc)
        @@entailments[method] = proc
      end
    end

    ##
    # Perform entailments on this enumerable in a single pass, yielding entailed statements.
    #
    # For best results, either run rules separately expanding the enumberated graph, or run repeatedly until no new statements are added to the enumerable containing both original and entailed statements. As `:subClassOf` and `:subPropertyOf` entailments are implicitly recursive, this may not be necessary except for extreme cases.
    #
    # @overload entail
    #   @param [Array<Symbol>] *rules Registered entailment method(s)
    #   @yield statement
    #   @yieldparam [RDF::Statement] statement
    #   @return [void]
    #
    # @overload entail
    #   @param [Array<Symbol>] *rules Registered entailment method(s)
    #   @return [Enumerator]
    def entail(*rules, &block)
      if block_given?
        rules = @@entailments.keys if rules.empty?

        self.each do |statement|
          rules.each {|rule| statement.entail(rule, &block)}
        end
      else
        # Otherwise, return an Enumerator with the entailed statements
        this = self
        RDF::Queryable::Enumerator.new do |yielder|
          this.entail(*rules) {|y| yielder << y}
        end
      end
    end
  end

  module Mutable
    class << self
      @@entailments = {}

      ##
      # Add an entailment method. The method accepts no arguments, and returns or yields an array of values associated with the particular entailment method
      # @param [Symbol] method
      # @param [Proc] proc
      def add_entailment(method, proc)
        @@entailments[method] = proc
      end
    end

    # Return a new mutable, composed of original and entailed statements
    #
    # @param [Array<Symbol>] *rules Registered entailment method(s)
    # @return [RDF::Mutable]
    # @see [RDF::Enumerable#entail]
    def entail(*rules, &block)
      self.dup.entail!(*rules)
    end

    # Add entailed statements to the mutable
    #
    # @param [Array<Symbol>] *rules Registered entailment method(s)
    # @return [RDF::Mutable]
    # @see [RDF::Enumerable#entail]
    def entail!(*rules, &block)
      rules = @@entailments.keys if rules.empty?
      statements = []

      self.each do |statement|
        rules.each do |rule|
          statement.entail(rule) do |st|
            statements << st
          end
        end
      end
      self.insert *statements
      self
    end
  end
end