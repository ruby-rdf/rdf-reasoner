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
  # Perform an entailment on this term
  #
  # @param [Symbol] method A registered entailment method
  # @return [Array<Term>]
  def entail(method)
    self.send @@entailments.fetch(method)
  end

  ##
  # Determine if the domain of a property term is consistent with the specified resource in `queryable`.
  #
  # Specific entailment regimes should insert themselves before this to apply the appropriate semantic condition
  #
  # @param [RDF::Resource] resource
  # @param [RDF::Queryable] queryable
  def domain_acceptable?(resource, queryable, options = {})
    true &&
    (!respond_to?(:domain_acceptable_owl?)    || domain_acceptable_owl?(resource, queryable, options)) &&
    (!respond_to?(:domain_acceptable_rdfs?)   || domain_acceptable_rdfs?(resource, queryable, options)) &&
    (!respond_to?(:domain_acceptable_schema?) || domain_acceptable_schema?(resource, queryable, options))
  end
end
