# coding: utf-8
$:.unshift "."
require 'spec_helper'
require 'rdf/reasoner/owl'

describe RDF::Reasoner::RDFS do
  let(:ex) {RDF::URI("http://example/")}

  describe :equivalentClass do
    {
      RDF::FOAF.Agent => [RDF::DC.Agent],
      RDF::DC.Agent => [RDF::FOAF.Agent],
      RDF::CERT.PGPCertificate => [RDF::WOT.PubKey],
      RDF::WOT.PubKey => [RDF::CERT.PGPCertificate],
    }.each do |cls, entails|
      context cls.pname do
        describe RDF::Vocabulary::Term do
          specify {expect(cls.entail(:equivalentClass).map(&:pname)).to include(*entails.map(&:pname))}
          specify {expect {|b| cls.entail(:equivalentClass, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Statement do
          subject {RDF::Statement.new(RDF::URI("a"), RDF.type, cls)}
          let(:results) {entails.map {|r| RDF::Statement.new(RDF::URI("a"), RDF.type, r)}}
          specify {expect(subject.entail(:equivalentClass)).to include(*results)}
          specify {expect {|b| subject.entail(:equivalentClass, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Enumerable do
          subject {[RDF::Statement.new(RDF::URI("a"), RDF.type, cls)].extend(RDF::Enumerable)}
          let(:results) {entails.map {|r| RDF::Statement.new(RDF::URI("a"), RDF.type, r)}}
          specify {expect(subject.entail(:equivalentClass)).to be_a(RDF::Enumerable)}
          specify {expect(subject.entail(:equivalentClass).to_a).to include(*results)}
          specify {expect {|b| subject.entail(:equivalentClass, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Mutable do
          subject {RDF::Graph.new << RDF::Statement.new(RDF::URI("a"), RDF.type, cls)}
          let(:results) {
            subject.dup.insert(*entails.map {|r| RDF::Statement.new(RDF::URI("a"), RDF.type, r)})
          }
          specify {expect(subject.entail(:equivalentClass)).to be_a(RDF::Graph)}
          specify {expect(subject.entail(:equivalentClass)).to be_equivalent_graph(results)}
          specify {expect(subject.entail!(:equivalentClass)).to equal subject}
        end
      end
    end
  end

  describe :equivalentProperty do
    {
      RDF::DC.creator => [RDF::FOAF.maker],
      RDF::FOAF.maker => [RDF::DC.creator],
      RDF::SCHEMA.description => [RDF::DC.description],
      RDF::DC.description => [RDF::SCHEMA.description],
    }.each do |prop, entails|
      context prop.pname do
        describe RDF::Vocabulary::Term do
          specify {expect(prop.entail(:equivalentProperty).map(&:pname)).to include(*entails.map(&:pname))}
          specify {expect {|b| prop.entail(:equivalentProperty, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Statement do
          subject {RDF::Statement.new(RDF::URI("a"), prop, RDF::URI("b"))}
          let(:results) {entails.map {|r| RDF::Statement.new(RDF::URI("a"), r, RDF::URI("b"))}}
          specify {expect(subject.entail(:equivalentProperty)).to include(*results)}
          specify {expect {|b| subject.entail(:equivalentProperty, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Enumerable do
          subject {[RDF::Statement.new(RDF::URI("a"), prop, RDF::URI("b"))].extend(RDF::Enumerable)}
          let(:results) {entails.map {|r| RDF::Statement.new(RDF::URI("a"), r, RDF::URI("b"))}}
          specify {expect(subject.entail(:equivalentProperty)).to be_a(RDF::Enumerable)}
          specify {expect(subject.entail(:equivalentProperty).to_a).to include(*results)}
          specify {expect {|b| subject.entail(:equivalentProperty, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Mutable do
          subject {RDF::Graph.new << RDF::Statement.new(RDF::URI("a"), prop, RDF::URI("b"))}
          let(:results) {
            subject.dup.insert(*entails.map {|r| RDF::Statement.new(RDF::URI("a"), r, RDF::URI("b"))})
          }
          specify {expect(subject.entail(:equivalentProperty)).to be_a(RDF::Graph)}
          specify {expect(subject.entail(:equivalentProperty)).to be_equivalent_graph(results)}
          specify {expect(subject.entail!(:equivalentProperty)).to equal subject}
        end
      end
    end
  end
end
