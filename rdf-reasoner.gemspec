#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = "rdf-reasoner"
  gem.homepage           = "http://github.com/gkellogg/rdf-reasoner"
  gem.license            = 'Public Domain' if gem.respond_to?(:license=)
  gem.summary            = "RDFS/OWL Reasoner for RDF.rb"

  gem.authors            = ['Gregg Kellogg']
  gem.email              = 'public-rdf-ruby@w3.org'

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS README.md UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  gem.require_paths      = %w(lib)
  gem.has_rdoc           = false
  gem.description        = %(Reasons over RDFS/OWL vocabularies to generate statements
                             which are entailed based on base RDFS/OWL rules along with
                             vocabulary information. It can also be used to ask specific
                             questions, such as if a given object is consistent with
                             the vocabulary ruleset. This can be used to implement
                             SPARQL Entailment Regimes.).gsub(/\s+/m, ' ')

  gem.required_ruby_version      = '>= 1.9.3'
  gem.requirements               = []
  gem.add_runtime_dependency     'rdf',             '~> 1.1', '>= 1.1.4.2'
  gem.add_runtime_dependency     'rdf-xsd',         '~> 1.1'

  gem.add_runtime_dependency     'rdf-turtle',      '~> 1.1'
  gem.add_runtime_dependency     'rdf-vocab',       '~> 0.8'
  gem.add_development_dependency 'linkeddata',      '~> 1.1'
  gem.add_development_dependency 'equivalent-xml',  '~> 0.4'
  gem.add_development_dependency 'rspec',           '~> 3.0'
  gem.add_development_dependency 'yard' ,           '~> 0.8'
  gem.post_install_message       = nil
end