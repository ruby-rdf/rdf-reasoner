# coding: utf-8
$:.unshift "."
require 'spec_helper'
require 'rdf/spec/format'

describe RDF::Reasoner::Format do
  it_behaves_like 'an RDF::Format' do
    let(:format_class) {RDF::Reasoner::Format}
  end

  describe ".for" do
    formats = [
      :reasoner,
    ].each do |arg|
      it "discovers with #{arg.inspect}" do
        expect(RDF::Format.for(arg)).to eq described_class
      end
    end
  end

  describe "#to_sym" do
    specify {expect(described_class.to_sym).to eq :reasoner}
  end

  describe ".cli_commands" do
    require 'rdf/cli'
    let(:ttl) {File.expand_path("../../etc/doap.ttl", __FILE__)}

    it "entails" do
      expect {RDF::CLI.exec(["entail", "serialize", ttl], format: :ttl)}.to write.to(:output)
    end

    it "lints" do
      expect {RDF::CLI.exec(["lint", ttl], format: :ttl)}.to write(/Linter responded with no messages/).to(:output)
    end
  end
end
