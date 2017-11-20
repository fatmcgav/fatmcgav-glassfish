require 'spec_helper'

# Start to describe glassfish::path class
describe 'glassfish::path' do
  
  on_supported_os({
    :hardwaremodels => ['x86_64'],
    :supported_os => [
      {
        'operatingsystem' => 'CentOS',
        'operatingsystemrelease' => ['7'],
      }
    ]
  }).each do |os, facts|

    context "on #{os}" do
      # Set the osfamily fact
      let(:facts) {
        facts
      }

      # Include required classes
      let(:pre_condition) { 'include glassfish' }
      
      it do 
        should contain_file('/etc/profile.d/glassfish.sh').with({
          'ensure'  => 'present',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' =>  /glassfish/
        }).that_requires('Class[glassfish::install]')
      end
    end # context 'on #{os}'
  end # on_supported_os
  
  on_supported_os({
    :hardwaremodels => ['x86_64'],
    :supported_os => [
      {
        'operatingsystem' => 'Debian',
        'operatingsystemrelease' => ['7'],
      }
    ]
  }).each do |os, facts|

    context "on #{os}" do
      # Set the osfamily fact
      let(:facts) {
        facts
      }
    
      # Include required classes
      let(:pre_condition) { 'include glassfish' }

      it do 
        should contain_file('/etc/profile.d/glassfish.sh').with({
          'ensure'  => 'present',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' =>  /glassfish/
        }).that_requires('Class[glassfish::install]')
      end
    end # context 'on #{os}'
  end # on_supported_os
  
  context 'on an unsupported OSFamily' do
    # Set the osfamily fact
    let(:facts) { {
      :osfamily => 'Suse',
      :os =>{
        :name => 'Suse'
      }
    } }
    
    it do 
      should compile.and_raise_error(/OSFamily Suse is not currently supported./)
    end
  end # context 'on an unsupported OSFamily'
  
end
