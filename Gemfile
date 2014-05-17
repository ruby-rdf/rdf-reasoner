source "http://rubygems.org"

gemspec

gem 'rdf', git: "git://github.com/ruby-rdf/rdf.git", :branch => "develop"

group :debug do
  gem "wirble"
  gem "redcarpet", platforms: :ruby
  gem "debugger", platforms: :mri_19
  gem "byebug", platforms: [:mri_20, :mri_21]
  gem "ruby-debug", platforms: :jruby
  gem "pry", platforms: :rbx
end

platforms :rbx do
  gem 'rubysl', '~> 2.0'
  gem 'rubinius', '~> 2.0'
end
