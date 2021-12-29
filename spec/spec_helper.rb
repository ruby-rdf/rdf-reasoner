$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift File.dirname(__FILE__)

require "bundler/setup"
require 'rspec'
require 'matchers'
require 'rdf/spec/matchers'
require 'json/ld'
require 'rdf/reasoner'
require 'rdf/turtle'
require 'rdf/vocab'
require 'rdf/xsd'

begin
  require 'simplecov'
  require 'simplecov-lcov'

  SimpleCov::Formatter::LcovFormatter.config do |config|
    #Coveralls is coverage by default/lcov. Send info results
    config.report_with_single_file = true
    config.single_report_path = 'coverage/lcov.info'
  end

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter
  ])
  SimpleCov.start do
    add_filter "/spec/"
  end
rescue LoadError
end

::RSpec.configure do |c|
  c.filter_run focus: true
  c.run_all_when_everything_filtered = true
  c.exclusion_filter = {
    ruby: lambda { |version| !(RUBY_VERSION.to_s =~ /^#{version.to_s}/) },
  }
end

# Remove vocabulary from RDF::Vocabulary
class RDF::Vocabulary
  class << self
    def remove(vocab)
      @@subclasses.delete_if {|klass| klass = vocab}
      @@uris.delete(vocab)
    end
  end
end
