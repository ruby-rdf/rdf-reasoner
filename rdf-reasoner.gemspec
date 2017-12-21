#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = "rdf-reasoner"
  gem.homepage           = "http://github.com/gkellogg/rdf-reasoner"
  gem.license            = 'Unlicense'
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

  gem.required_ruby_version      = '>= 2.2.2'
  gem.requirements               = []
  #gem.add_runtime_dependency     'rdf',             '~> 3.0'
  #gem.add_runtime_dependency     'rdf-vocab',       '~> 3.0'
  #gem.add_runtime_dependency     'rdf-xsd',         '~> 3.0'
  gem.add_runtime_dependency     'rdf',             '>= 2.2', '< 4.0'
  gem.add_runtime_dependency     'rdf-vocab',       '>= 2.2', '< 4.0'
  gem.add_runtime_dependency     'rdf-xsd',         '>= 2.2', '< 4.0'

  #gem.add_development_dependency 'rdf-spec',        '~> 3.0'
  #gem.add_development_dependency 'json-ld',         '~> 3.0'
  #gem.add_development_dependency 'rdf-turtle',      '~> 3.0'
  gem.add_development_dependency 'rdf-spec',        '>= 2.2', '< 4.0'
  gem.add_development_dependency 'json-ld',         '>= 2.2', '< 4.0'
  gem.add_development_dependency 'rdf-turtle',      '>= 2.2', '< 4.0'
  gem.add_development_dependency 'equivalent-xml',  '~> 0.6'
  gem.add_development_dependency 'rspec',           '~> 3.7'
  gem.add_development_dependency 'yard' ,           '~> 0.9.12'
  gem.post_install_message       = nil
end
