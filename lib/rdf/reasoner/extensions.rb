# Extensions to RDF core classes to support reasoning
require 'rdf'

class RDF::Vocabulary::Term
  class << self
    @@entailments = {}

    ##
    # Add an entailment method. The method accepts no arguments, and returns an array of values associated with the particular entailment method
    # @param [Symbol] method
    # @param [Proc] proc
    def add_entailment(method, proc)
      @@entailments[method] = proc
    end
  end

  ##
  # Perform an entailment on this term. Entailments defined within this module are `:subClassOf`, `:subPropertyOf`, and `:subClass`.
  #
  # @param [Symbol] method A registered entailment method
  # @return [Array<Term>]
  def entail(method)
    self.send @@entailments.fetch(method)
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
