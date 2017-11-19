require 'beaker-rspec/spec_helper'
# require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'glassfish')
    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => 0 }
      on host, puppet('module', 'install', 'puppet-archive'), { :acceptable_exit_codes => 0 }
      on host, puppet('module', 'install', 'camptocamp-systemd'), { :acceptable_exit_codes => 0 }

      # Copy hiera data into default puppet location
      copy_hiera_data_to(host, 'spec/fixtures/hiera/hieradata/')
    end
  end
end

def apply(pp, options = {})
  if ENV.key?('PUPPET_DEBUG')
    options[:debug] = true
  end

  apply_manifest(pp, options)
end

# Run it twice and test for idempotency
def apply2(pp)
  apply(pp, :catch_failures => true)
  apply(pp, :catch_changes => true)
end

# probe stolen from:
# https://github.com/camptocamp/puppet-systemd/blob/master/lib/facter/systemd.rb#L26
#
# See these issues for an explination of why this is nessicary rather than
# using fact() from beaker-facter in the DSL:
#
# https://tickets.puppetlabs.com/browse/BKR-1040
# https://tickets.puppetlabs.com/browse/BKR-1041
#
if shell('ps -p 1 -o comm=').stdout =~ /systemd/
  $systemd = true
else
  $systemd = false
end
