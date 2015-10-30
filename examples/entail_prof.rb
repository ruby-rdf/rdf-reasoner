#!/usr/bin/env ruby
$:.unshift(File.expand_path("../../lib", __FILE__))
require 'rubygems'
require 'ruby-prof'
require 'rdf/reasoner'

output_dir = File.expand_path("../../doc/profiles/#{File.basename __FILE__, ".rb"}", __FILE__)
FileUtils.mkdir_p(output_dir)

RDF::Reasoner.apply(:rdfs)

result = RubyProf.profile do
  RDF::Vocab::SCHEMA.Event.entail(:subClass).map(&:pname)
end

# Print a graph profile to text
printer = RubyProf::MultiPrinter.new(result)
printer.print(path: output_dir, profile: "profile")
puts "output saved in #{output_dir}"
