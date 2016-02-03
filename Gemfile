source "http://rubygems.org"

gemspec

gem "rdf",        github: "ruby-rdf/rdf",       branch: "develop"
gem "rdf-vocab",  github: "ruby-rdf/rdf-vocab", branch: "develop"

group :development, :test do
  gem 'ebnf',           github: "gkellogg/ebnf",            branch: "develop"
  gem 'json-ld',        github: "ruby-rdf/json-ld",         branch: "develop"
  gem 'rdf-isomorphic', github: "ruby-rdf/rdf-isomorphic",  branch: "develop"
  gem 'rdf-turtle',     github: "ruby-rdf/rdf-turtle",      branch: "develop"
  gem 'rdf-xsd',        github: "ruby-rdf/rdf-xsd",         branch: "develop"
  gem 'sxp',            github: "gkellogg/sxp-ruby"
  gem 'rake'
  gem 'simplecov',  require: false
  gem 'ruby-prof',  platform: :mri
end

group :debug do
  gem "wirble"
  gem "redcarpet", platforms: :ruby
  gem "byebug", platforms: :mri
end

platforms :rbx do
  gem 'rubysl', '~> 2.0'
  gem 'rubinius', '~> 2.0'
end
