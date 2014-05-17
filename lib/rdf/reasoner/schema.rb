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
    # @param [RDF::Resource] resource
    # @param [RDF::Queryable] queryable
    # @param [Hash{Symbol => Object}] options
    # @option options [Array<RDF::Vocabulary::Term>] :types
    #   Fully entailed types of resource, if not provided, they are queried
    def domain_acceptable_schema?(resource, queryable, options = {})
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
      Array(types).empty? || domains.any? {|d| types.include?(d)}
    end
    
    def self.included(mod)
    end
  end

  # Extend the Term with this methods
  ::RDF::Vocabulary::Term.send(:include, SCHEMA)
end