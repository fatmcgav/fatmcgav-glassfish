require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'

# Set default task so that TravisCI can run tests
task :default => [:spec, :lint]
  
# Tweak Puppet-lint config
require 'puppet-lint/tasks/puppet-lint'
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.ignore_paths = ["spec/**/*.pp"]