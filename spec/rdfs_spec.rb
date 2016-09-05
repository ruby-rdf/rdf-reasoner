# coding: utf-8
$:.unshift "."
require 'spec_helper'
require 'rdf/reasoner/rdfs'
require 'rdf/vocab'

describe RDF::Reasoner::RDFS do
  before(:all) {RDF::Reasoner.apply(:rdfs)}
  let(:ex) {RDF::URI("http://example/")}

  describe :subClassOf do
    {
      RDF::Vocab::FOAF.Group => [RDF::Vocab::FOAF.Group, RDF::Vocab::FOAF.Agent],
      RDF::Vocab::CC.License => [RDF::Vocab::CC.License, RDF::Vocab::DC.LicenseDocument],
      RDF::Vocab::DC.Location => [RDF::Vocab::DC.Location, RDF::Vocab::DC.LocationPeriodOrJurisdiction],
    }.each do |cls, entails|
      context cls.pname do
        describe RDF::Vocabulary::Term do
          specify {expect(cls.entail(:subClassOf).map(&:pname)).to include(*entails.map(&:pname))}
          specify {expect {|b| cls.entail(:subClassOf, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Statement do
          subject {RDF::Statement(RDF::URI("a"), RDF.type, cls)}
          let(:results) {entails.map {|r| RDF::Statement(RDF::URI("a"), RDF.type, r)}}
          specify {expect(subject.entail(:subClassOf)).to include(*results)}
          specify {expect(subject.entail(:subClassOf)).to all(be_inferred)}
          specify {expect {|b| subject.entail(:subClassOf, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Enumerable do
          subject {[RDF::Statement(RDF::URI("a"), RDF.type, cls)].extend(RDF::Enumerable)}
          let(:results) {entails.map {|r| RDF::Statement(RDF::URI("a"), RDF.type, r)}}
          specify {expect(subject.entail(:subClassOf)).to be_a(RDF::Enumerable)}
          specify {expect(subject.entail(:subClassOf).to_a).to include(*results)}
          specify {expect {|b| subject.entail(:subClassOf, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Mutable do
          subject {RDF::Graph.new << RDF::Statement(RDF::URI("a"), RDF.type, cls)}
          let(:results) {
            subject.dup.insert(*entails.map {|r| RDF::Statement(RDF::URI("a"), RDF.type, r)})
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
      RDF::Vocab::FOAF.Group => [RDF::Vocab::FOAF.Group, RDF::Vocab::MO.MusicGroup],
      RDF::Vocab::FOAF.Agent => [RDF::Vocab::FOAF.Group, RDF::Vocab::MO.MusicGroup, RDF::Vocab::FOAF.Organization, RDF::Vocab::FOAF.Person, RDF::Vocab::FOAF.Agent],
      RDF::Vocab::CC.License => [RDF::Vocab::CC.License],
      RDF::Vocab::SCHEMA.Event => [RDF::Vocab::SCHEMA.Event, RDF::Vocab::SCHEMA.Festival, RDF::Vocab::SCHEMA.SportsEvent, RDF::Vocab::SCHEMA.UserLikes],
    }.each do |cls, entails|
      context cls.pname do
        describe RDF::Vocabulary::Term do
          specify {expect(cls.entail(:subClass).map(&:pname)).to include(*entails.map(&:pname))}
          specify {expect {|b| cls.entail(:subClass, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Statement do
          subject {RDF::Statement(RDF::URI("a"), RDF.type, cls)}
          let(:results) {entails.map {|r| RDF::Statement(RDF::URI("a"), RDF.type, r)}}
          specify {expect(subject.entail(:subClass)).to be_empty}
          specify {expect(subject.entail(:subClass)).to all(be_inferred)}
          specify {expect {|b| subject.entail(:subClass, &b)}.not_to yield_control}
        end

        describe RDF::Enumerable do
          subject {[RDF::Statement(RDF::URI("a"), RDF.type, cls)].extend(RDF::Enumerable)}
          specify {expect(subject.entail(:subClass)).to be_a(RDF::Enumerable)}
          specify {expect(subject.entail(:subClass).to_a).to be_empty}
          specify {expect {|b| subject.entail(:subClass, &b)}.not_to yield_control}
        end

        describe RDF::Mutable do
          subject {RDF::Graph.new << RDF::Statement(RDF::URI("a"), RDF.type, cls)}
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
      RDF::Vocab::FOAF.aimChatID => [RDF::Vocab::FOAF.aimChatID, RDF::Vocab::FOAF.nick],
      RDF::Vocab::FOAF.name => [RDF::Vocab::FOAF.name, RDF::RDFS.label],
      RDF::Vocab::CC.license => [RDF::Vocab::CC.license, RDF::Vocab::DC.license],
      RDF::Vocab::DC.date => [RDF::Vocab::DC.date, RDF::Vocab::DC11.date],
    }.each do |prop, entails|
      context prop.pname do
        describe RDF::Vocabulary::Term do
          specify {expect(prop.entail(:subPropertyOf).map(&:pname)).to include(*entails.map(&:pname))}
          specify {expect {|b| prop.entail(:subPropertyOf, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Statement do
          subject {RDF::Statement(RDF::URI("a"), prop, RDF::URI("b"))}
          let(:results) {entails.map {|r| RDF::Statement(RDF::URI("a"), r, RDF::URI("b"))}}
          specify {expect(subject.entail(:subPropertyOf)).to include(*results)}
          specify {expect(subject.entail(:subPropertyOf)).to all(be_inferred)}
          specify {expect {|b| subject.entail(:subPropertyOf, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Enumerable do
          subject {[RDF::Statement(RDF::URI("a"), prop, RDF::URI("b"))].extend(RDF::Enumerable)}
          let(:results) {entails.map {|r| RDF::Statement(RDF::URI("a"), r, RDF::URI("b"))}}
          specify {expect(subject.entail(:subPropertyOf)).to be_a(RDF::Enumerable)}
          specify {expect(subject.entail(:subPropertyOf).to_a).to include(*results)}
          specify {expect {|b| subject.entail(:subPropertyOf, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Mutable do
          subject {RDF::Graph.new << RDF::Statement(RDF::URI("a"), prop, RDF::URI("b"))}
          let(:results) {
            subject.dup.insert(*entails.map {|r| RDF::Statement(RDF::URI("a"), r, RDF::URI("b"))})
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
      RDF::Vocab::FOAF.account => [RDF::Vocab::FOAF.Agent],
      RDF::Vocab::DOAP.os => [RDF::Vocab::DOAP.Project, RDF::Vocab::DOAP.Version],
      RDF::Vocab::CC.attributionName => [RDF::Vocab::CC.Work],
    }.each do |prop, entails|
      context prop.pname do
        describe RDF::Vocabulary::Term do
          specify {expect(prop.entail(:domain)).to be_empty}
          specify {expect {|b| prop.entail(:domain, &b)}.not_to yield_control}
        end

        describe RDF::Statement do
          subject {RDF::Statement(RDF::URI("a"), prop, RDF::URI("b"))}
          let(:results) {entails.map {|r| RDF::Statement(RDF::URI("a"), RDF.type, r)}}
          specify {expect(subject.entail(:domain)).to include(*results)}
          specify {expect(subject.entail(:domain)).to all(be_inferred)}
          specify {expect {|b| subject.entail(:domain, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Enumerable do
          subject {[RDF::Statement(RDF::URI("a"), prop, RDF::URI("b"))].extend(RDF::Enumerable)}
          let(:results) {entails.map {|r| RDF::Statement(RDF::URI("a"), RDF.type, r)}}
          specify {expect(subject.entail(:domain)).to be_a(RDF::Enumerable)}
          specify {expect(subject.entail(:domain).to_a).to include(*results)}
          specify {expect {|b| subject.entail(:domain, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Mutable do
          subject {RDF::Graph.new << RDF::Statement(RDF::URI("a"), prop, RDF::URI("b"))}
          let(:results) {
            subject.dup.insert(*entails.map {|r| RDF::Statement(RDF::URI("a"), RDF.type, r)})
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
      RDF::Vocab::CC.jurisdiction => [RDF::Vocab::CC.Jurisdiction],
      RDF::Vocab::CERT.key => [RDF::Vocab::CERT.Key, RDF::Vocab::CERT.PublicKey],
      RDF::Vocab::DOAP.helper => [RDF::Vocab::FOAF.Person],
    }.each do |prop, entails|
      context prop.pname do
        describe RDF::Vocabulary::Term do
          specify {expect(prop.entail(:range)).to be_empty}
          specify {expect {|b| prop.entail(:range, &b)}.not_to yield_control}
        end

        describe RDF::Statement do
          subject {RDF::Statement(RDF::URI("a"), prop, RDF::URI("b"))}
          let(:results) {entails.map {|r| RDF::Statement(RDF::URI("b"), RDF.type, r)}}
          specify {expect(subject.entail(:range)).to include(*results)}
          specify {expect(subject.entail(:range)).to all(be_inferred)}
          specify {expect {|b| subject.entail(:range, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Enumerable do
          subject {[RDF::Statement(RDF::URI("a"), prop, RDF::URI("b"))].extend(RDF::Enumerable)}
          let(:results) {entails.map {|r| RDF::Statement(RDF::URI("b"), RDF.type, r)}}
          specify {expect(subject.entail(:range)).to be_a(RDF::Enumerable)}
          specify {expect(subject.entail(:range).to_a).to include(*results)}
          specify {expect {|b| subject.entail(:range, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Mutable do
          subject {RDF::Graph.new << RDF::Statement(RDF::URI("a"), prop, RDF::URI("b"))}
          let(:results) {
            subject.dup.insert(*entails.map {|r| RDF::Statement(RDF::URI("b"), RDF.type, r)})
          }
          specify {expect(subject.entail(:range)).to be_a(RDF::Graph)}
          specify {expect(subject.entail(:range)).to be_equivalent_graph(results)}
          specify {expect(subject.entail!(:range)).to equal subject}
        end
      end
    end
  end

  describe :domain_compatible? do
    let!(:queryable) {RDF::Graph.new << RDF::Statement(ex+"a", RDF.type, RDF::Vocab::FOAF.Person)}

    context "domain and no provided types" do
      it "uses entailed types of resource" do
        expect(RDF::Vocab::FOAF.familyName).to be_domain_compatible(ex+"a", queryable)
      end
    end

    it "returns true with no domain and no type" do
      expect(RDF::Vocab::DC.date).to be_domain_compatible(ex+"b", queryable)
    end

    it "returns true with no domain and type" do
      expect(RDF::Vocab::DC.date).to be_domain_compatible(ex+"a", queryable)
    end

    it "uses supplied types" do
      expect(RDF::Vocab::FOAF.based_near).not_to be_domain_compatible(ex+"a", queryable, types: [RDF::Vocab::FOAF.Agent])
      expect(RDF::Vocab::FOAF.based_near).to be_domain_compatible(ex+"a", queryable, types: [RDF::Vocab::GEO.SpatialThing])
      expect(RDF.type).to be_domain_compatible(ex+"a", queryable, types: [RDF::Vocab::SCHEMA.Thing])
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
    let!(:queryable) {RDF::Graph.new << RDF::Statement(ex+"a", RDF.type, RDF::Vocab::FOAF.Person)}

    context "objects in range" do
      {
        "object of right type" => %(
          @prefix foaf: <http://xmlns.com/foaf/0.1/> .
          <foo> a foaf:Image; foaf:depicts [a foaf:Person] .
        ),
        "xsd:anyURI with language-tagged literal" => %(
          @prefix ma: <http://www.w3.org/ns/ma-ont#> .
          <foo> a ma:MediaResource; ma:locator "http://example/"@en .
        ),
      }.each do |name, input|
        it name do
          graph = RDF::Graph.new << RDF::Turtle::Reader.new(input)
          statement = graph.to_a.reject {|s| s.predicate == RDF.type}.first
          expect(RDF::Vocabulary.find_term(statement.predicate)).to be_range_compatible(statement.object, graph)
        end
      end

      context "OGP literal datatypes" do
        {
          #"boolean_str" => %(
          #  <bool> a rdf:Property; rdfs:range; ogc:boolean_str
          #  <foo> <bool>
          #    "true"^^ogc:boolean_str, "false"^^ogc:boolean_str,
          #    true, false
          #    "true", "false", "1", "0",
          #    "true"@en, "false"@en, "1"@en, "0"@en .
          #),
          #"date_time_str" => %(
          #  <date_time> a rdf:Property; rdfs:range; ogc:date_time_str
          #  <foo> <date_time>
          #    "2009-12T12:34"^^ogc:date_time_str,
          #    "2009-12T12:34",
          #    "2009-12T12:34"^^xsd:dateTime .
          #),
          "determiner_str" => %(
            <foo> og:determiner "", "a", "the", "an", "auto" .
          ),
          #"float_str" => %(
          #  <float> a rdf:Property; rdfs:range; ogc:float_str .
          #  <foo> <float>
          #    "1.1"^^xsd:float, "1.1e1"^^xsd:double,
          #    "1.1", "1.1e1",
          #    "1.1"@en, "1.1e1"@en .
          #),
          "integer_str" => %(
            <foo> og:image:height 1, "1", "1"@en .
          ),
          "image_type" => %(
            <foo> og:image:type "application1+a-b/2foo+bar-baz" .
          ),
          "string" => %(
            <foo> og:description "a", "b"@en .
          ),
          "url" => %(
            <foo> og:image "http://example.com", <https://example.org> .
          ),
        }.each do |name, input|
          it name do
            input = %(
              @prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
              @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
              @prefix xsd:  <http://www.w3.org/2001/XMLSchema#> .
              @prefix og: <http://ogp.me/ns#> .
              @prefix ogc: <http://ogp.me/ns/class#> .
            ) + input
            graph = RDF::Graph.new << RDF::Turtle::Reader.new(input)
            statement = graph.to_a.reject {|s| s.predicate == RDF.type}.first
            expect(RDF::Vocabulary.find_term(statement.predicate)).to be_range_compatible(statement.object, graph)
          end
        end
      end
    end

    it "uses supplied types" do
      expect(RDF::Vocab::FOAF.based_near).not_to be_range_compatible(ex+"a", queryable, types: [RDF::Vocab::FOAF.Agent])
      expect(RDF::Vocab::FOAF.based_near).to be_range_compatible(ex+"a", queryable, types: [RDF::Vocab::GEO.SpatialThing])
      expect(RDF.type).to be_range_compatible(ex+"a", queryable, types: [RDF::Vocab::SCHEMA.Thing])
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

      context "OGP literal datatypes" do
        {
          #"boolean_str" => %(
          #  <bool> a rdf:Property; rdfs:range; ogc:boolean_str
          #  <foo> <bool>
          #    "true"^^ogc:boolean_str, "false"^^ogc:boolean_str,
          #    true, false
          #    "true", "false", "1", "0",
          #    "true"@en, "false"@en, "1"@en, "0"@en .
          #),
          #"date_time_str" => %(
          #  <date_time> a rdf:Property; rdfs:range; ogc:date_time_str
          #  <foo> <date_time>
          #    "2009-12T12:34"^^ogc:date_time_str,
          #    "2009-12T12:34",
          #    "2009-12T12:34"^^xsd:dateTime .
          #),
          "determiner_str" => %(
            <foo> og:determiner "foo" .
          ),
          #"float_str" => %(
          #  <float> a rdf:Property; rdfs:range; ogc:float_str .
          #  <foo> <float>
          #    "1.1"^^xsd:float, "1.1e1"^^xsd:double,
          #    "1.1", "1.1e1",
          #    "1.1"@en, "1.1e1"@en .
          #),
          "integer_str" => %(
            <foo> og:image:height 1.1, "1.1", "1.1"@en .
          ),
          "image_type" => %(
            <foo> og:image:type "application" .
          ),
          "string" => %(
            <foo> og:description 1 .
          ),
          "url" => %(
            <foo> og:image "foo" .
          ),
        }.each do |name, input|
          it name do
            input = %(
              @prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
              @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
              @prefix xsd:  <http://www.w3.org/2001/XMLSchema#> .
              @prefix og: <http://ogp.me/ns#> .
              @prefix ogc: <http://ogp.me/ns/class#> .
            ) + input
            graph = RDF::Graph.new << RDF::Turtle::Reader.new(input)
            statement = graph.to_a.reject {|s| s.predicate == RDF.type}.first
            expect(RDF::Vocabulary.find_term(statement.predicate)).not_to be_range_compatible(statement.object, graph)
          end
        end
      end
    end
  end
end
