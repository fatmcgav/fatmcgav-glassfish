require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'

# Tweak Puppet-lint config
require 'puppet-lint/tasks/puppet-lint'
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.ignore_paths = ["spec/**/*.pp"]
  
# use librarian-puppet to manage fixtures instead of .fixtures.yml
# offers more possibilities like explicit version management, forge downloads,...
task :librarian_spec_prep do
 sh "librarian-puppet install --path=spec/fixtures/modules/"
end
task :spec_prep => :librarian_spec_prep