require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'

# Coveralls
require 'simplecov'
require 'coveralls'
#Coveralls.wear!
SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter 'spec/fixtures/modules/'
end

Dir[File.join(File.dirname(__FILE__), 'support', '*.rb')].each do |support_file|
  require support_file
end