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

  describe :domain_compatible? do
    let!(:queryable) {RDF::Graph.new << RDF::Statement(ex+"a", RDF.type, RDF::SCHEMA.Person)}
    context "domain and no provided types" do
      it "uses entailed types of resource" do
        expect(RDF::SCHEMA.familyName).to be_domain_compatible(ex+"a", queryable)
      end
    end

    it "returns true with no domain and no type" do
      expect(RDF::SCHEMA.dateCreated).to be_domain_compatible(ex+"b", queryable)
    end

    it "uses supplied types" do
      expect(RDF::SCHEMA.dateCreated).not_to be_domain_compatible(ex+"a", queryable)
      expect(RDF::SCHEMA.dateCreated).to be_domain_compatible(ex+"a", queryable, types: [RDF::SCHEMA.CreativeWork])
    end

    context "domain violations" do
      {
        "subject of wrong type" => %(
          @prefix schema: <http://schema.org/> .
          <foo> a schema:Person; schema:acceptedOffer [a schema:Offer] .
        ),
      }.each do |name, input|
        it name do
          graph = RDF::Graph.new << RDF::Turtle::Reader.new(input)
          statement = graph.to_a.reject {|s| s.predicate == RDF.type}.first
          expect(RDF::Vocabulary.find_term(statement.predicate)).not_to be_domain_compatible(statement.object, graph)
        end
      end
    end
  end

  describe :range_compatible? do
    context "objects in range" do
      {
        "object of right type" => %(
          @prefix schema: <http://schema.org/> .
          <foo> a schema:Order; schema:acceptedOffer [a schema:Offer] .
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
          @prefix schema: <http://schema.org/> .
          <foo> a schema:Order; schema:acceptedOffer [a schema:Thing] .
        ),
        "object range with literal" => %(
          @prefix schema: <http://schema.org/> .
          <foo> a schema:Order; schema:acceptedOffer "foo" .
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
        "schema:Number expected with conforming plain literal" => %(
          @prefix schema: <http://schema.org/> .
          <foo> schema:amountOfThisGood "bar" .
        ),
        "schema:Integer expected with conforming plain literal" => %(
          @prefix schema: <http://schema.org/> .
          <foo> schema:answerCount "bar" .
        ),
        "schema:Date expected with conforming plain literal" => %(
          @prefix schema: <http://schema.org/> .
          <foo> schema:birthDate "bar" .
        ),
        "schema:DateTime expected with conforming plain literal" => %(
          @prefix schema: <http://schema.org/> .
          <foo> schema:checkinTime "bar" .
        ),
        "schema:Text with datatyped literal" => %(
          @prefix schema: <http://schema.org/> .
          @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
          <foo> a schema:Thing; schema:activeIngredient "foo"^^xsd:token .
        ),
        "schema:URL with language-tagged literal" => %(
          @prefix schema: <http://schema.org/> .
          <foo> a schema:Thing; schema:url "http://example/"@en .
        ),
        "schema:URL with non-conforming plain literal" => %(
          @prefix schema: <http://schema.org/> .
          <foo> a schema:Thing; schema:url "foo" .
        ),
        "schema:Boolean with non-conforming plain literal" => %(
          @prefix schema: <http://schema.org/> .
          <foo> a schema:CreativeWork; schema:isFamilyFriendly "bar" .
        ),
      }.each do |name, (input, errors)|
        it name do
          graph = RDF::Graph.new << RDF::Turtle::Reader.new(input)
          statement = graph.to_a.reject {|s| s.predicate == RDF.type}.first
          expect(RDF::Vocabulary.find_term(statement.predicate)).not_to be_range_compatible(statement.object, graph)
        end
      end
    end
  end


  describe "Roles" do
    {
      "Cryptography Users" => {
        input: %(
          @prefix schema: <http://schema.org/> .
          <http://example/foo> a schema:Organization;
            schema:name "Cryptography Users";
            schema:member [
              a schema:OrganizationRole, schema:Role;
              schema:member [
                a schema:Person;
                schema:name "Alice"
              ];
              schema:startDate "1977"
            ] .
        ),
        predicate: RDF::SCHEMA.member,
        result: :domain_range
      },
      "Cryptography Users (not domain)" => {
        input: %(
          @prefix schema: <http://schema.org/> .
          <http://example/foo> a schema:Organization;
            schema:name "Cryptography Users";
            schema:alumni [
              a schema:OrganizationRole, schema:Role;
              schema:member [
                a schema:Person;
                schema:name "Alice"
              ];
              schema:startDate "1977"
            ] .
        ),
        predicate: RDF::SCHEMA.member,
        result: :not_domain
      },
      "Cryptography Users (not range)" => {
        input: %(
          @prefix schema: <http://schema.org/> .
          <http://example/foo> a schema:Organization;
            schema:name "Cryptography Users";
            schema:alumni [
              a schema:OrganizationRole, schema:Role;
              schema:member [
                a schema:Person;
                schema:name "Alice"
              ];
              schema:startDate "1977"
            ] .
        ),
        predicate: RDF::SCHEMA.alumni,
        result: :not_range
      },
      "University of Cambridge" => {
        input: %(
          @prefix schema: <http://schema.org/> .
          <http://example/foo> a schema:CollegeOrUniversity;
            schema:name "University of Cambridge";
            schema:sameAs <http://en.wikipedia.org/wiki/University_of_Cambridge>;
            schema:alumni [
              a schema:OrganizationRole, schema:Role;
              schema:alumni [
                a schema:Person;
                schema:name "Delia Derbyshire";
                schema:sameAs <http://en.wikipedia.org/wiki/Delia_Derbyshire>
              ];
              schema:startDate "1957"
            ] .
        ),
        predicate: RDF::SCHEMA.alumni,
        result: :domain_range
      },
      "Delia Derbyshire" => {
        input: %(
          @prefix schema: <http://schema.org/> .
          <http://example/foo> a schema:Person;
            schema:name "Delia Derbyshire";
            schema:sameAs <http://en.wikipedia.org/wiki/Delia_Derbyshire>;
            schema:alumniOf [
              a schema:OrganizationRole, schema:Role;
              schema:alumniOf [
                a schema:CollegeOrUniversity;
                schema:name "University of Cambridge";
                schema:sameAs <http://en.wikipedia.org/wiki/University_of_Cambridge>
              ];
              schema:startDate "1957"
            ] .
        ),
        predicate: RDF::SCHEMA.alumniOf,
        result: :domain_range
      },
      "San Francisco 49ers" => {
        input: %(
          @prefix schema: <http://schema.org/> .
          <http://example/foo> a schema:SportsTeam;
            schema:name "San Francisco 49ers";
            schema:member [
              a schema:PerformanceRole, schema:Role;
              schema:member [
                a schema:Person;
                schema:name "Joe Montana"
              ];
              schema:startDate "1979";
              schema:endDate "1992";
              schema:namedPosition "Quarterback"
            ] .
        ),
        predicate: RDF::SCHEMA.member,
        result: :domain_range
      },
    }.each do |name, params|
      context name do
        let(:graph) {RDF::Graph.new << RDF::Turtle::Reader.new(params[:input])}
        let(:resource) {graph.first_subject(predicate: RDF.type, object: RDF::SCHEMA.Role)}

        it "allows role in domain", if: params[:result] == :domain_range do
          expect(params[:predicate]).to be_domain_compatible(resource, graph)
        end

        it "allows role in range", if: params[:result] == :domain_range  do
          expect(params[:predicate]).to be_range_compatible(resource, graph)
        end

        it "does not allow role in domain", if: params[:result] == :not_domain do
          expect(params[:predicate]).not_to be_domain_compatible(resource, graph)
        end

        it "does not allow role in range", if: params[:result] == :not_range do
          expect(params[:predicate]).not_to be_range_compatible(resource, graph)
        end
      end
    end
  end

end
