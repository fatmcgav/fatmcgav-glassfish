require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

include RspecPuppetFacts

# Set systemd facts
add_custom_fact :systemd, ->(os,facts) {
  case facts[:osfamily]
  when 'RedHat'
    case facts[:operatingsystemmajrelease]
    when '5','6'
      false
    when '7'
      true
    end
  when 'Debian'
    case facts[:lsbdistcodename]
    when 'jessie'
      true
    else
      false
    end
  else
    false
  end
}

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

Dir[File.join(File.dirname(__FILE__), 'support', '*.rb')].each do |support_file|
  require support_file
end
