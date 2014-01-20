#!/usr/bin/env ruby

source "https://rubygems.org"

if ENV.key?('PUPPET_VERSION')
	puppetversion = "#{ENV['PUPPET_VERSION']}"
else
	puppetversion = ['>= 2.7']
end

gem 'rake'

group :test do
  gem 'puppet', puppetversion
  gem 'rspec-puppet', '>=1.0.1'
  gem 'puppetlabs_spec_helper'
  gem 'puppet-lint'
  gem 'puppet-syntax'
  gem 'librarian-puppet'
end

group :development do
  gem 'rspec-system-puppet'
  gem 'vagrant-wrapper'
end
