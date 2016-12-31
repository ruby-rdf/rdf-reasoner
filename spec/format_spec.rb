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
    let(:capture) {StringIO.new}

    it "entails" do
      expect {RDF::CLI.exec(["entail", "serialize", ttl], format: :ttl, output: capture)}.to write.to(:output)
      expect(capture.string).not_to be_empty
    end

    it "lints" do
      expect {RDF::CLI.exec(["lint", ttl], format: :ttl, output: capture)}.to write.to(:output)
      expect(capture.string).not_to be_empty
    end
  end
end
