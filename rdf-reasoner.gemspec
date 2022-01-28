#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = "rdf-reasoner"
  gem.homepage           = "https://github.com/ruby-rdf/rdf-reasoner"
  gem.license            = 'Unlicense'
  gem.summary            = "RDFS/OWL Reasoner for RDF.rb"
  gem.metadata           = {
    "documentation_uri" => "https://ruby-rdf.github.io/rdf-reasoner",
    "bug_tracker_uri"   => "https://github.com/ruby-rdf/rdf-reasoner/issues",
    "homepage_uri"      => "https://github.com/ruby-rdf/rdf-reasoner",
    "mailing_list_uri"  => "https://lists.w3.org/Archives/Public/public-rdf-ruby/",
    "source_code_uri"   => "https://github.com/ruby-rdf/rdf-reasoner",
  }

  gem.authors            = ['Gregg Kellogg']
  gem.email              = 'public-rdf-ruby@w3.org'

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS README.md UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  gem.require_paths      = %w(lib)
  gem.description        = %(Reasons over RDFS/OWL vocabularies to generate statements
                             which are entailed based on base RDFS/OWL rules along with
                             vocabulary information. It can also be used to ask specific
                             questions, such as if a given object is consistent with
                             the vocabulary ruleset. This can be used to implement
                             SPARQL Entailment Regimes.).gsub(/\s+/m, ' ')

  gem.required_ruby_version      = '>= 2.6'
  gem.requirements               = []
  gem.add_runtime_dependency     'rdf',             '~> 3.2'
  gem.add_runtime_dependency     'rdf-xsd',         '~> 3.2'

  gem.add_development_dependency 'rdf-spec',        '~> 3.2'
  gem.add_development_dependency 'rdf-vocab',       '~> 3.2'
  gem.add_development_dependency 'rdf-turtle',      '~> 3.2'
  gem.add_development_dependency 'json-ld',         '~> 3.2'
  gem.add_development_dependency 'equivalent-xml',  '~> 0.6'
  gem.add_development_dependency 'rspec',           '~> 3.10'
  gem.add_development_dependency 'yard' ,           '~> 0.9'
  gem.post_install_message       = nil
end
