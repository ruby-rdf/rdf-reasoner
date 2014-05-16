#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = "rdf-entailment"
  gem.homepage           = "http://github.com/gkellogg/rdf-entailment"
  gem.license            = 'Public Domain' if gem.respond_to?(:license=)
  gem.summary            = "Vocabulary entailment for RDF"

  gem.authors            = ['Gregg Kellogg']
  gem.email              = 'public-rdf-ruby@w3.org'

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS README.md UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  gem.require_paths      = %w(lib)
  gem.has_rdoc           = false
  gem.description        = %(Creates triples for various entailment regimes of
                             a vocabulary for enabling SPARQL 1.1 Entailment.).gsub(/\s+/m, ' ')

  gem.required_ruby_version      = '>= 1.9.3'
  gem.requirements               = []
  gem.add_runtime_dependency     'rdf',             '>= 1.0.1'
  gem.add_runtime_dependency     'rdf-xsd',         '>= 1.0.0'

  gem.add_development_dependency 'linkeddata'
  gem.add_development_dependency 'equivalent-xml'
  gem.add_development_dependency 'rspec',           '>= 2.12.0'
  gem.add_development_dependency 'yard' ,           '>= 0.8.3'
  gem.post_install_message       = nil
end