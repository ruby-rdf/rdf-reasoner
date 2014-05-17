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

  describe :domain_acceptable? do
    let!(:queryable) {RDF::Graph.new << RDF::Statement(ex+"a", RDF.type, RDF::FOAF.Person)}
    context "domain and no provided types" do
      it "uses entailed types of resource" do
        expect(RDF::FOAF.familyName).to be_domain_acceptable(ex+"a", queryable)
      end
    end

    it "returns true with no domain and no type" do
      expect(RDF::DC.date).to be_domain_acceptable(ex+"b", queryable)
    end

    it "returns true with no domain and type" do
      expect(RDF::DC.date).to be_domain_acceptable(ex+"a", queryable)
    end

    it "uses supplied types" do
      expect(RDF::FOAF.based_near).not_to be_domain_acceptable(ex+"a", queryable)
      expect(RDF::FOAF.based_near).to be_domain_acceptable(ex+"a", queryable, types: [RDF::GEO.SpatialThing])
    end
  end
end
