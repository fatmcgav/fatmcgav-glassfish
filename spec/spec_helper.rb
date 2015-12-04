require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'

# Code Climate loading
begin
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
rescue Exception => e
  warn "CodeClimate disabled - #{e}"
end

# Coveralls loading 
begin
  require 'simplecov'
  require 'coveralls'
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  SimpleCov.start do
    add_filter '/spec/'
  end
rescue Exception => e
  warn "Coveralls disabled - #{e}"
end

# Enable future parser
if ENV['PARSER'] == 'future'
  RSpec.configure do |c|
    c.parser = 'future'
  end
end

Dir[File.join(File.dirname(__FILE__), 'support', '*.rb')].each do |support_file|
  require support_file
end
