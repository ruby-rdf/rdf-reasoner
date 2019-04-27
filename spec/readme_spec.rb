# coding: utf-8
$:.unshift "."
require 'spec_helper'
require 'rdf/reasoner'

describe RDF::Reasoner do
  describe "Examples" do
    it "Determine super-classes of a class" do
      RDF::Reasoner.apply(:rdfs)
      term = RDF::Vocabulary.find_term("http://xmlns.com/foaf/0.1/Person")
      expect(term.entail(:subClassOf)).to include *[
          RDF::Vocab::FOAF.Agent,
          RDF::URI("http://www.w3.org/2000/10/swap/pim/contact#Person"),
          RDF::Vocab::GEO.SpatialThing,
          RDF::Vocab::FOAF.Person
        ]
    end

    it "Determine sub-classes of a class" do
      RDF::Reasoner.apply(:rdfs)
      term = RDF::Vocab::FOAF.Person
      expect(term.entail(:subClass)).to include *[RDF::Vocab::FOAF.Person, RDF::Vocab::MO.SoloMusicArtist]
    end

    it "Determine if a resource is compatible with the domains of a property" do
      RDF::Reasoner.apply(:rdfs)
      graph = RDF::Graph.load("etc/doap.ttl")
      subj = RDF::URI("https://rubygems.org/gems/rdf-reasoner")
      expect(RDF::Vocab::DOAP.name).to be_domain_compatible(subj, graph)
    end

    it "Determine if a resource is compatible with the ranges of a property" do
      RDF::Reasoner.apply(:rdfs)
      graph = RDF::Graph.load("etc/doap.ttl")
      obj = RDF::Literal(Date.new)
      expect(RDF::Vocab::DOAP.created).to be_range_compatible(obj, graph)
    end

    it "Perform equivalentClass entailment on a graph" do
      RDF::Reasoner.apply(:owl)
      graph = RDF::Graph.load("etc/doap.ttl")
      graph.entail!(:equivalentClass)
      expect(graph).to have_statement(RDF::Statement(RDF::URI("https://greggkellogg.net/foaf#me"), RDF.type, RDF::Vocab::DC.Agent))
    end

    it "Yield all entailed statements for all entailment methods" do
      RDF::Reasoner.apply(:rdfs, :owl)
      graph = RDF::Graph.load("etc/doap.ttl")
      enumerable = graph.enum_statement
      entailed = enumerable.entail
      expect(entailed.count).to be > 1
    end

    it "Lints a graph" do
      RDF::Reasoner.apply(:rdfs, :owl)
      graph = RDF::Graph.load("etc/doap.ttl")
      graph.entail!
      messages = graph.lint
      expect(messages).to be_empty
    end
  end
end
