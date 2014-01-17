require 'spec_helper'

# Start to describe glassfish::path class
describe 'glassfish::path' do
  
  context 'on a RedHat OSFamily' do
    # Set the osfamily fact
    let(:facts) { {
      :osfamily => 'RedHat'
    } }

    # Include required classes
    let(:pre_condition) { 'class {"glassfish": 
      domain_asadmin_passfile => "/tmp/asadmin.pass"}' 
    }
    
    it do 
      should contain_file('/etc/profile.d/glassfish.sh').with({
        'ensure'  => 'present',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'content' =>  /glassfish/
      }).that_requires('Class[glassfish::install]')
    end
  end
  
  context 'on a Debian OSFamily' do
    # Set the osfamily fact
    let(:facts) { {
      :osfamily => 'Debian'
    } }
    
    it do 
      expect { subject }.to raise_error(Puppet::Error, /Debian doesn't support profile.d/)
    end
  end
  
  context 'on an unsupport OSFamily' do
    # Set the osfamily fact
    let(:facts) { {
      :osfamily => 'Suse'
    } }
    
    it do 
      expect { subject }.to raise_error(Puppet::Error, /OSFamily Suse is not currently supported./)
    end
  end
  
end
