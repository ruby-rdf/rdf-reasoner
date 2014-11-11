# coding: utf-8
$:.unshift "."
require 'spec_helper'
require 'rdf/reasoner/rdfs'

describe RDF::Reasoner::RDFS do
  let(:ex) {RDF::URI("http://example/")}

  describe :subClassOf do
    {
      RDF::FOAF.Group => [RDF::FOAF.Group, RDF::FOAF.Agent],
      RDF::CC.License => [RDF::CC.License, RDF::DC.LicenseDocument],
      RDF::DC.Location => [RDF::DC.Location, RDF::DC.LocationPeriodOrJurisdiction],
    }.each do |cls, entails|
      context cls.pname do
        describe RDF::Vocabulary::Term do
          specify {expect(cls.entail(:subClassOf).map(&:pname)).to include(*entails.map(&:pname))}
          specify {expect {|b| cls.entail(:subClassOf, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Statement do
          subject {RDF::Statement.new(RDF::URI("a"), RDF.type, cls)}
          let(:results) {entails.map {|r| RDF::Statement.new(RDF::URI("a"), RDF.type, r)}}
          specify {expect(subject.entail(:subClassOf)).to include(*results)}
          specify {expect {|b| subject.entail(:subClassOf, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Enumerable do
          subject {[RDF::Statement.new(RDF::URI("a"), RDF.type, cls)].extend(RDF::Enumerable)}
          let(:results) {entails.map {|r| RDF::Statement.new(RDF::URI("a"), RDF.type, r)}}
          specify {expect(subject.entail(:subClassOf)).to be_a(RDF::Enumerable)}
          specify {expect(subject.entail(:subClassOf).to_a).to include(*results)}
          specify {expect {|b| subject.entail(:subClassOf, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Mutable do
          subject {RDF::Graph.new << RDF::Statement.new(RDF::URI("a"), RDF.type, cls)}
          let(:results) {
            subject.dup.insert(*entails.map {|r| RDF::Statement.new(RDF::URI("a"), RDF.type, r)})
          }
          specify {expect(subject.entail(:subClassOf)).to be_a(RDF::Graph)}
          specify {expect(subject.entail(:subClassOf)).to be_equivalent_graph(results)}
          specify {expect(subject.entail!(:subClassOf)).to equal subject}
        end
      end
    end
  end

  describe :subClass do
    {
      RDF::FOAF.Group => [RDF::FOAF.Group, RDF::MO.MusicGroup],
      RDF::FOAF.Agent => [RDF::FOAF.Group, RDF::MO.MusicGroup, RDF::FOAF.Organization, RDF::FOAF.Person, RDF::FOAF.Agent],
      RDF::CC.License => [RDF::CC.License],
      RDF::SCHEMA.Event => [RDF::SCHEMA.Event, RDF::SCHEMA.Festival, RDF::SCHEMA.SportsEvent, RDF::SCHEMA.UserLikes],
    }.each do |cls, entails|
      context cls.pname do
        describe RDF::Vocabulary::Term do
          specify {expect(cls.entail(:subClass).map(&:pname)).to include(*entails.map(&:pname))}
          specify {expect {|b| cls.entail(:subClass, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Statement do
          subject {RDF::Statement.new(RDF::URI("a"), RDF.type, cls)}
          let(:results) {entails.map {|r| RDF::Statement.new(RDF::URI("a"), RDF.type, r)}}
          specify {expect(subject.entail(:subClass)).to be_empty}
          specify {expect {|b| subject.entail(:subClass, &b)}.not_to yield_control}
        end

        describe RDF::Enumerable do
          subject {[RDF::Statement.new(RDF::URI("a"), RDF.type, cls)].extend(RDF::Enumerable)}
          specify {expect(subject.entail(:subClass)).to be_a(RDF::Enumerable)}
          specify {expect(subject.entail(:subClass).to_a).to be_empty}
          specify {expect {|b| subject.entail(:subClass, &b)}.not_to yield_control}
        end

        describe RDF::Mutable do
          subject {RDF::Graph.new << RDF::Statement.new(RDF::URI("a"), RDF.type, cls)}
          let(:results) {subject.dup}
          specify {expect(subject.entail(:subClass)).to be_a(RDF::Graph)}
          specify {expect(subject.entail(:subClass)).to be_equivalent_graph(results)}
          specify {expect(subject.entail!(:subClass)).to equal subject}
        end
      end
    end
  end unless ENV['CI']

  describe :subPropertyOf do
    {
      RDF::FOAF.aimChatID => [RDF::FOAF.aimChatID, RDF::FOAF.nick],
      RDF::FOAF.name => [RDF::FOAF.name, RDF::RDFS.label],
      RDF::CC.license => [RDF::CC.license, RDF::DC.license],
      RDF::DC.date => [RDF::DC.date, RDF::DC11.date],
    }.each do |prop, entails|
      context prop.pname do
        describe RDF::Vocabulary::Term do
          specify {expect(prop.entail(:subPropertyOf).map(&:pname)).to include(*entails.map(&:pname))}
          specify {expect {|b| prop.entail(:subPropertyOf, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Statement do
          subject {RDF::Statement.new(RDF::URI("a"), prop, RDF::URI("b"))}
          let(:results) {entails.map {|r| RDF::Statement.new(RDF::URI("a"), r, RDF::URI("b"))}}
          specify {expect(subject.entail(:subPropertyOf)).to include(*results)}
          specify {expect {|b| subject.entail(:subPropertyOf, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Enumerable do
          subject {[RDF::Statement.new(RDF::URI("a"), prop, RDF::URI("b"))].extend(RDF::Enumerable)}
          let(:results) {entails.map {|r| RDF::Statement.new(RDF::URI("a"), r, RDF::URI("b"))}}
          specify {expect(subject.entail(:subPropertyOf)).to be_a(RDF::Enumerable)}
          specify {expect(subject.entail(:subPropertyOf).to_a).to include(*results)}
          specify {expect {|b| subject.entail(:subPropertyOf, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Mutable do
          subject {RDF::Graph.new << RDF::Statement.new(RDF::URI("a"), prop, RDF::URI("b"))}
          let(:results) {
            subject.dup.insert(*entails.map {|r| RDF::Statement.new(RDF::URI("a"), r, RDF::URI("b"))})
          }
          specify {expect(subject.entail(:subPropertyOf)).to be_a(RDF::Graph)}
          specify {expect(subject.entail(:subPropertyOf)).to be_equivalent_graph(results)}
          specify {expect(subject.entail!(:subPropertyOf)).to equal subject}
        end
      end
    end
  end

  describe :domain do
    {
      RDF::FOAF.account => [RDF::FOAF.Agent],
      RDF::DOAP.os => [RDF::DOAP.Project, RDF::DOAP.Version]
    }.each do |prop, entails|
      context prop.pname do
        describe RDF::Vocabulary::Term do
          specify {expect(prop.entail(:domain)).to be_empty}
          specify {expect {|b| prop.entail(:domain, &b)}.not_to yield_control}
        end

        describe RDF::Statement do
          subject {RDF::Statement.new(RDF::URI("a"), prop, RDF::URI("b"))}
          let(:results) {entails.map {|r| RDF::Statement.new(RDF::URI("a"), RDF.type, r)}}
          specify {expect(subject.entail(:domain)).to include(*results)}
          specify {expect {|b| subject.entail(:domain, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Enumerable do
          subject {[RDF::Statement.new(RDF::URI("a"), prop, RDF::URI("b"))].extend(RDF::Enumerable)}
          let(:results) {entails.map {|r| RDF::Statement.new(RDF::URI("a"), RDF.type, r)}}
          specify {expect(subject.entail(:domain)).to be_a(RDF::Enumerable)}
          specify {expect(subject.entail(:domain).to_a).to include(*results)}
          specify {expect {|b| subject.entail(:domain, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Mutable do
          subject {RDF::Graph.new << RDF::Statement.new(RDF::URI("a"), prop, RDF::URI("b"))}
          let(:results) {
            subject.dup.insert(*entails.map {|r| RDF::Statement.new(RDF::URI("a"), RDF.type, r)})
          }
          specify {expect(subject.entail(:domain)).to be_a(RDF::Graph)}
          specify {expect(subject.entail(:domain)).to be_equivalent_graph(results)}
          specify {expect(subject.entail!(:domain)).to equal subject}
        end
      end
    end
  end

  describe :range do
    {
      RDF::CC.jurisdiction => [RDF::CC.Jurisdiction],
      RDF::CERT.key => [RDF::CERT.Key, RDF::CERT.PublicKey],
      RDF::DOAP.helper => [RDF::FOAF.Person],
    }.each do |prop, entails|
      context prop.pname do
        describe RDF::Vocabulary::Term do
          specify {expect(prop.entail(:range)).to be_empty}
          specify {expect {|b| prop.entail(:range, &b)}.not_to yield_control}
        end

        describe RDF::Statement do
          subject {RDF::Statement.new(RDF::URI("a"), prop, RDF::URI("b"))}
          let(:results) {entails.map {|r| RDF::Statement.new(RDF::URI("b"), RDF.type, r)}}
          specify {expect(subject.entail(:range)).to include(*results)}
          specify {expect {|b| subject.entail(:range, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Enumerable do
          subject {[RDF::Statement.new(RDF::URI("a"), prop, RDF::URI("b"))].extend(RDF::Enumerable)}
          let(:results) {entails.map {|r| RDF::Statement.new(RDF::URI("b"), RDF.type, r)}}
          specify {expect(subject.entail(:range)).to be_a(RDF::Enumerable)}
          specify {expect(subject.entail(:range).to_a).to include(*results)}
          specify {expect {|b| subject.entail(:range, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Mutable do
          subject {RDF::Graph.new << RDF::Statement.new(RDF::URI("a"), prop, RDF::URI("b"))}
          let(:results) {
            subject.dup.insert(*entails.map {|r| RDF::Statement.new(RDF::URI("b"), RDF.type, r)})
          }
          specify {expect(subject.entail(:range)).to be_a(RDF::Graph)}
          specify {expect(subject.entail(:range)).to be_equivalent_graph(results)}
          specify {expect(subject.entail!(:range)).to equal subject}
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
      expect(RDF::FOAF.based_near).not_to be_domain_compatible(ex+"a", queryable, types: [RDF::FOAF.Agent])
      expect(RDF::FOAF.based_near).to be_domain_compatible(ex+"a", queryable, types: [RDF::GEO.SpatialThing])
      expect(RDF.type).to be_domain_compatible(ex+"a", queryable, types: [RDF::SCHEMA.Thing])
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
    let!(:queryable) {RDF::Graph.new << RDF::Statement(ex+"a", RDF.type, RDF::FOAF.Person)}

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

    it "uses supplied types" do
      expect(RDF::FOAF.based_near).not_to be_range_compatible(ex+"a", queryable, types: [RDF::FOAF.Agent])
      expect(RDF::FOAF.based_near).to be_range_compatible(ex+"a", queryable, types: [RDF::GEO.SpatialThing])
      expect(RDF.type).to be_range_compatible(ex+"a", queryable, types: [RDF::SCHEMA.Thing])
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
