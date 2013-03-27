require 'rdf'

module RDF
  ##
  # Entailment for RDF.rb.
  #
  # @see http://www.w3.org/TR/2013/REC-sparql11-entailment-20130321/
  # @author [Gregg Kellogg](http://greggkellogg.net/)
  module Entailment
    autoload :OWL, 'rdf/entailment/owl'
  end
end
