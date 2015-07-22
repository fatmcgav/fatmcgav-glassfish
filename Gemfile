#!/usr/bin/env ruby

source "https://rubygems.org"

if ENV.key?('PUPPET_VERSION')
	puppetversion = ENV['PUPPET_VERSION']
else
	puppetversion = ['~> 3.8.0']
end

gem 'rake'

group :test do
  gem 'puppet', puppetversion
  gem 'rspec', '< 3.x'
  gem 'highline', '~>1.6.0' # Pin to support Ruby 1.8.7
  gem 'rspec-puppet', '~>2.0.0'
  gem 'puppetlabs_spec_helper', '~>0.8.0'
  #gem 'puppet-lint', '~>1.1.0'
  gem 'puppet-lint', :git => 'https://github.com/rodjek/puppet-lint.git'
  gem 'puppet-syntax', '~>1.0'
  gem 'librarian-puppet', '~> 1.4.0'
  gem 'simplecov', :platforms => [:ruby_19, :ruby_20]
  gem 'coveralls', :platforms => [:ruby_19, :ruby_20]
  gem 'codeclimate-test-reporter', :platforms => [:ruby_19, :ruby_20]
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "beaker"
  gem "beaker-rspec"
  gem "vagrant-wrapper"
  gem "puppet-blacksmith"
  gem "guard-rake"
end
