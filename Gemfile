#!/usr/bin/env ruby

source "https://rubygems.org"

gem 'rake', '<11.0'
gem 'puppet', ENV["PUPPET_VERSION"] || "~> 5"

group :test do
  # gem 'rspec-core', '< 3.0.1'
  # gem 'rspec', '< 3.0.0'
  # gem 'highline', '~> 1.6.0' # Pin to support Ruby 1.8.7
  gem 'rspec'
  gem 'rspec-puppet', '~>2.0'
  gem 'puppetlabs_spec_helper'
  #gem 'puppet-lint', '~>1.1.0'
  gem 'puppet-lint', '< 3.0'
  gem 'puppet-syntax'
  gem 'rspec-puppet-facts'
  gem 'librarian-puppet', '< 2.0'
  gem 'simplecov', :platforms => [:ruby_20]
  gem 'coveralls', :platforms => [:ruby_20]
  gem 'codeclimate-test-reporter', :platforms => [:ruby_19, :ruby_20]
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "puppet-blacksmith"
end

group :system_tests do
  gem "beaker"
  gem "beaker-rspec"
  gem "beaker-puppet_install_helper"
  gem "beaker-module_install_helper"
  gem "serverspec"
  gem "vagrant-wrapper"
end

# json_pure 2.0.2 added a requirement on ruby >= 2. We pin to json_pure 2.0.1
# if using ruby 1.x
gem 'json_pure', '<=2.0.1', :require => false if RUBY_VERSION =~ /^1\./
