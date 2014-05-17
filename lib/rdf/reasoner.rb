require 'rdf'
require 'rdf/reasoner/extensions'

module RDF
  ##
  # RDFS/OWL reasonsing for RDF.rb.
  #
  # @see http://www.w3.org/TR/2013/REC-sparql11-entailment-20130321/
  # @author [Gregg Kellogg](http://greggkellogg.net/)
  module Reasoner
    autoload :OWL,    'rdf/reasoner/owl'
    autoload :RDFS,   'rdf/reasoner/rdfs'
    autoload :SCHEMA, 'rdf/reasoner/schema'

    ##
    # Add entailment support for the specified regime
    #
    # @param [:OWL, :RDFS, :SCHEMA] regime
    def apply(regime)
      require "rdf/reasoner/#{regime.downcase}"
    end
    module_function :apply

    ##
    # A reasoner error
    class Error < RuntimeError; end
  end
end
