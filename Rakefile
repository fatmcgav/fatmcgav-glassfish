require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'

# These two gems aren't always present, for instance
# # on Travis with --without development
begin
  require 'rspec-system/rake_task'
rescue LoadError
end

# Tweak Puppet-lint config
require 'puppet-lint/tasks/puppet-lint'
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.send('disable_80chars')
  
exclude_paths = [
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.exclude_paths = exclude_paths

# use librarian-puppet to manage fixtures instead of .fixtures.yml
# offers more possibilities like explicit version management, forge downloads,...
task :librarian_spec_prep do
 sh "librarian-puppet install --path=spec/fixtures/modules/"
end
task :spec_prep => :librarian_spec_prep

desc "Run syntax, lint, and spec tests."
task :test => [
  :syntax,
  :lint,
  :spec,
]
