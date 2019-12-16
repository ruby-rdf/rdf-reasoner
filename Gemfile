source "https://rubygems.org"

gemspec

gem "rdf",              github: "ruby-rdf/rdf",         branch: "develop"
gem "rdf-vocab",        github: "ruby-rdf/rdf-vocab",   branch: "develop"
gem 'rdf-xsd',          github: "ruby-rdf/rdf-xsd",     branch: "develop"

group :development, :test do
  gem 'ebnf',           github: "dryruby/ebnf",             branch: "develop"
  gem 'json-ld',        github: "ruby-rdf/json-ld",         branch: "develop"
  gem "rdf-aggregate-repo", git: "https://github.com/ruby-rdf/rdf-aggregate-repo",  branch: "develop"
  gem 'rdf-isomorphic', github: "ruby-rdf/rdf-isomorphic",  branch: "develop"
  gem "rdf-rdfa",       github: "ruby-rdf/rdf-rdfa",        branch: "develop"
  gem "rdf-spec",       github: "ruby-rdf/rdf-spec",        branch: "develop"
  gem 'rdf-turtle',     github: "ruby-rdf/rdf-turtle",      branch: "develop"
  gem 'sxp',            github: "dryruby/sxp.rb",           branch: "develop"
  gem 'rake'
  gem 'simplecov',      require: false
  gem 'ruby-prof',      platform: :mri
end

group :debug do
  gem "redcarpet",      platforms: :ruby
  gem "byebug",         platforms: :mri
end
