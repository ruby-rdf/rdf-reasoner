# coding: utf-8
$:.unshift "."
require 'spec_helper'
require 'rdf/reasoner/owl'

describe RDF::Reasoner::OWL do
  before(:all) {RDF::Reasoner.apply(:owl)}
  let(:ex) {RDF::URI("http://example/")}

  describe :equivalentClass do
    {
      RDF::Vocab::FOAF.Agent => [RDF::Vocab::DC.Agent],
      RDF::Vocab::DC.Agent => [RDF::Vocab::FOAF.Agent],
      RDF::Vocab::CERT.PGPCertificate => [RDF::Vocab::WOT.PubKey],
      RDF::Vocab::WOT.PubKey => [RDF::Vocab::CERT.PGPCertificate],
    }.each do |cls, entails|
      context cls.pname do
        describe RDF::Vocabulary::Term do
          specify {expect(cls.entail(:equivalentClass).map(&:pname)).to include(*entails.map(&:pname))}
          specify {expect {|b| cls.entail(:equivalentClass, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Statement do
          subject {RDF::Statement(RDF::URI("a"), RDF.type, cls)}
          let(:results) {entails.map {|r| RDF::Statement(RDF::URI("a"), RDF.type, r)}}
          specify {expect(subject.entail(:equivalentClass)).to include(*results)}
          specify {expect(subject.entail(:equivalentClass)).to all(be_inferred)}
          specify {expect {|b| subject.entail(:equivalentClass, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Enumerable do
          subject {[RDF::Statement(RDF::URI("a"), RDF.type, cls)].extend(RDF::Enumerable)}
          let(:results) {entails.map {|r| RDF::Statement(RDF::URI("a"), RDF.type, r)}}
          specify {expect(subject.entail(:equivalentClass)).to be_a(RDF::Enumerable)}
          specify {expect(subject.entail(:equivalentClass).to_a).to include(*results)}
          specify {expect {|b| subject.entail(:equivalentClass, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Mutable do
          subject {RDF::Graph.new << RDF::Statement(RDF::URI("a"), RDF.type, cls)}
          let(:results) {
            subject.dup.insert(*entails.map {|r| RDF::Statement(RDF::URI("a"), RDF.type, r)})
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
      RDF::Vocab::DC.creator => [RDF::Vocab::FOAF.maker],
      RDF::Vocab::FOAF.maker => [RDF::Vocab::DC.creator],
      RDF::Vocab::SCHEMA.description => [RDF::Vocab::DC.description],
      RDF::Vocab::DC.description => [RDF::Vocab::SCHEMA.description],
    }.each do |prop, entails|
      context prop.pname do
        describe RDF::Vocabulary::Term do
          specify {expect(prop.entail(:equivalentProperty).map(&:pname)).to include(*entails.map(&:pname))}
          specify {expect {|b| prop.entail(:equivalentProperty, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Statement do
          subject {RDF::Statement(RDF::URI("a"), prop, RDF::URI("b"))}
          let(:results) {entails.map {|r| RDF::Statement(RDF::URI("a"), r, RDF::URI("b"))}}
          specify {expect(subject.entail(:equivalentProperty)).to include(*results)}
          specify {expect(subject.entail(:equivalentProperty)).to all(be_inferred)}
          specify {expect {|b| subject.entail(:equivalentProperty, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Enumerable do
          subject {[RDF::Statement(RDF::URI("a"), prop, RDF::URI("b"))].extend(RDF::Enumerable)}
          let(:results) {entails.map {|r| RDF::Statement(RDF::URI("a"), r, RDF::URI("b"))}}
          specify {expect(subject.entail(:equivalentProperty)).to be_a(RDF::Enumerable)}
          specify {expect(subject.entail(:equivalentProperty).to_a).to include(*results)}
          specify {expect {|b| subject.entail(:equivalentProperty, &b)}.to yield_control.at_least(entails.length)}
        end

        describe RDF::Mutable do
          subject {RDF::Graph.new << RDF::Statement(RDF::URI("a"), prop, RDF::URI("b"))}
          let(:results) {
            subject.dup.insert(*entails.map {|r| RDF::Statement(RDF::URI("a"), r, RDF::URI("b"))})
          }
          specify {expect(subject.entail(:equivalentProperty)).to be_a(RDF::Graph)}
          specify {expect(subject.entail(:equivalentProperty)).to be_equivalent_graph(results)}
          specify {expect(subject.entail!(:equivalentProperty)).to equal subject}
        end
      end
    end
  end
end
