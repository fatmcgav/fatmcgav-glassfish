#!/usr/bin/env ruby

source "https://rubygems.org"

if ENV.key?('PUPPET_VERSION')
	puppetversion = ENV['PUPPET_VERSION']
else
	puppetversion = ['~> 3.6.0']
end

gem 'rake'

group :test do
  gem 'puppet', puppetversion
  gem 'rspec', '~> 2.0'
  gem 'rspec-puppet', :git => 'https://github.com/rodjek/rspec-puppet.git', :ref => '891c5794' # Known working commit SHA
  gem 'puppetlabs_spec_helper', '~> 0.4.0'
  gem 'puppet-lint'
  gem 'puppet-syntax'
  gem 'librarian-puppet', '~> 1.0.0'
  gem 'simplecov', :require => false
  gem 'coveralls', :require => false
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
