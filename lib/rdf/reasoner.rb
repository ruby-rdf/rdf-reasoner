require 'rdf'
require 'rdf/reasoner/extensions'

module RDF
  ##
  # RDFS/OWL reasonsing for RDF.rb.
  #
  # @see http://www.w3.org/TR/2013/REC-sparql11-entailment-20130321/
  # @author [Gregg Kellogg](http://greggkellogg.net/)
  module Reasoner
    autoload :OWL,     'rdf/reasoner/owl'
    autoload :RDFS,    'rdf/reasoner/rdfs'
    autoload :Schema,  'rdf/reasoner/schema'
    autoload :VERSION, 'rdf/reasoner/version'

    ##
    # Add entailment support for the specified regime
    #
    # @param [Array<:owl, :rdfs, :schema>] regime
    def apply(*regime)
      regime.each {|r| require "rdf/reasoner/#{r.downcase}"}
    end
    module_function :apply

    ##
    # A reasoner error
    class Error < RuntimeError; end
  end
end
