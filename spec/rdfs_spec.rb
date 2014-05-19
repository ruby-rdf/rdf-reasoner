# coding: utf-8
$:.unshift "."
require 'spec_helper'
require 'rdf/reasoner/rdfs'

describe RDF::Reasoner::RDFS do
  let(:ex) {RDF::URI("http://example/")}

  describe :subClassOf do
    {
      RDF::FOAF.Group => [RDF::FOAF.Group, RDF::FOAF.Agent].map(&:pname),
      RDF::CC.License => [RDF::CC.License, RDF::DC.LicenseDocument].map(&:pname),
      RDF::DC.Location => [RDF::DC.Location, RDF::DC.LocationPeriodOrJurisdiction].map(&:pname),
    }.each do |cls, entails|
      describe cls.pname do
        specify {expect(cls.entail(:subClassOf).map(&:pname)).to include(*entails)}
        it "raises error on subPropertyOf" do
          expect {cls.entail(:subPropertyOf)}.to raise_error(RDF::Reasoner::Error)
        end
      end
    end
  end

  describe :subPropertyOf do
    {
      RDF::FOAF.aimChatID => [RDF::FOAF.aimChatID, RDF::FOAF.nick].map(&:pname),
      RDF::FOAF.name => [RDF::FOAF.name, RDF::RDFS.label].map(&:pname),
      RDF::CC.license => [RDF::CC.license, RDF::DC.license].map(&:pname),
      RDF::DC.date => [RDF::DC.date, RDF::DC11.date].map(&:pname),
    }.each do |cls, entails|
      describe cls.pname do
        specify {expect(cls.entail(:subPropertyOf).map(&:pname)).to include(*entails)}
        it "raises error on subClassOf" do
          expect {cls.entail(:subClassOf)}.to raise_error(RDF::Reasoner::Error)
        end
      end
    end
  end

  describe :domain_compatible? do
    let!(:queryable) {RDF::Graph.new << RDF::Statement(ex+"a", RDF.type, RDF::FOAF.Person)}
    context "domain and no provided types" do
      it "uses entailed types of resource" do
        expect(RDF::FOAF.familyName).to be_domain_compatible(ex+"a", queryable)
      end
    end

    it "returns true with no domain and no type" do
      expect(RDF::DC.date).to be_domain_compatible(ex+"b", queryable)
    end

    it "returns true with no domain and type" do
      expect(RDF::DC.date).to be_domain_compatible(ex+"a", queryable)
    end

    it "uses supplied types" do
      expect(RDF::FOAF.based_near).not_to be_domain_compatible(ex+"a", queryable)
      expect(RDF::FOAF.based_near).to be_domain_compatible(ex+"a", queryable, types: [RDF::GEO.SpatialThing])
    end

    context "domain violations" do
      {
        "subject of wrong type" => %(
          @prefix foaf: <http://xmlns.com/foaf/0.1/> .
          <foo> a foaf:Person; foaf:depicts [a foaf:Image] .
        ),
      }.each do |name, input|
        it name do
          graph = RDF::Graph.new << RDF::Turtle::Reader.new(input)
          statement = graph.to_a.reject {|s| s.predicate == RDF.type}.first
          expect(RDF::Vocabulary.find_term(statement.predicate)).not_to be_domain_compatible(statement.subject, graph)
        end
      end
    end
  end

  describe :range_compatible? do
    context "objects in range" do
      {
        "object of right type" => %(
          @prefix foaf: <http://xmlns.com/foaf/0.1/> .
          <foo> a foaf:Image; foaf:depicts [a foaf:Person] .
        ),
      }.each do |name, input|
        it name do
          graph = RDF::Graph.new << RDF::Turtle::Reader.new(input)
          statement = graph.to_a.reject {|s| s.predicate == RDF.type}.first
          expect(RDF::Vocabulary.find_term(statement.predicate)).to be_range_compatible(statement.object, graph)
        end
      end
    end
    context "object range violations" do
      {
        "object of wrong type" => %(
          @prefix foaf: <http://xmlns.com/foaf/0.1/> .
          <foo> a foaf:Person; foaf:holdsAccount [a foaf:Image] .
        ),
        "object range with literal" => %(
          @prefix foaf: <http://xmlns.com/foaf/0.1/> .
          <foo> a foaf:Person; foaf:homepage "Document" .
        ),
      }.each do |name, input|
        it name do
          graph = RDF::Graph.new << RDF::Turtle::Reader.new(input)
          statement = graph.to_a.reject {|s| s.predicate == RDF.type}.first
          expect(RDF::Vocabulary.find_term(statement.predicate)).not_to be_range_compatible(statement.object, graph)
        end
      end
    end

    context "literal range violations" do
      {
        "xsd:nonNegativeInteger expected with conforming plain literal" => %(
          @prefix sioc: <http://rdfs.org/sioc/ns#> .
          <foo> sioc:num_authors "bar" .
        ),
        "xsd:nonNegativeInteger expected with non-equivalent datatyped literal" => %(
          @prefix sioc: <http://rdfs.org/sioc/ns#> .
          <foo> sioc:num_authors 1 .
        ),
        "xsd:anyURI with language-tagged literal" => %(
          @prefix ma: <http://www.w3.org/ns/ma-ont#> .
          <foo> a ma:MediaResource; ma:locator "http://example/"@en .
        ),
        "xsd:anyURI with non-conforming plain literal" => %(
          @prefix ma: <http://www.w3.org/ns/ma-ont#> .
          <foo> a ma:MediaResource; ma:locator "foo" .
        ),
        "xsd:boolean with non-conforming plain literal" => %(
          @prefix wrds: <http://www.w3.org/2007/05/powder-s#> .
          <foo> a wrds:Document; wrds:certified "bar" .
        ),
      }.each do |name, input|
        it name do
          graph = RDF::Graph.new << RDF::Turtle::Reader.new(input)
          statement = graph.to_a.reject {|s| s.predicate == RDF.type}.first
          expect(RDF::Vocabulary.find_term(statement.predicate)).not_to be_range_compatible(statement.object, graph)
        end
      end
    end
  end
end
