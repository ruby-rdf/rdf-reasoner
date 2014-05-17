# coding: utf-8
$:.unshift "."
require 'spec_helper'
require 'rdf/reasoner/schema'

describe RDF::Reasoner::SCHEMA do
  let(:ex) {RDF::URI("http://example/")}

  describe :domainIncludes do
    {
      RDF::SCHEMA.about => [RDF::SCHEMA.CreativeWork].map(&:pname),
    }.each do |cls, entails|
      describe cls.pname do
        specify {expect(cls.domain_includes.map(&:pname)).to include(*entails)}
        specify {expect(cls.domainIncludes.map(&:pname)).to include(*entails)}
      end
    end
  end

  describe :rangeIncludes do
    {
      RDF::SCHEMA.about => [RDF::SCHEMA.Thing].map(&:pname),
      RDF::SCHEMA.event => [RDF::SCHEMA.Event].map(&:pname),
    }.each do |cls, entails|
      describe cls.pname do
        specify {expect(cls.range_includes.map(&:pname)).to include(*entails)}
        specify {expect(cls.rangeIncludes.map(&:pname)).to include(*entails)}
      end
    end
  end

  describe :domain_acceptable? do
    let!(:queryable) {RDF::Graph.new << RDF::Statement(ex+"a", RDF.type, RDF::SCHEMA.Person)}
    context "domain and no provided types" do
      it "uses entailed types of resource" do
        expect(RDF::SCHEMA.familyName).to be_domain_acceptable(ex+"a", queryable)
      end
    end

    it "returns true with no domain and no type" do
      expect(RDF::SCHEMA.dateCreated).to be_domain_acceptable(ex+"b", queryable)
    end

    it "uses supplied types" do
      expect(RDF::SCHEMA.dateCreated).not_to be_domain_acceptable(ex+"a", queryable)
      expect(RDF::SCHEMA.dateCreated).to be_domain_acceptable(ex+"a", queryable, types: [RDF::SCHEMA.CreativeWork])
    end
  end
end
