require 'spec_helper'

# Start to describe glassfish::create_node define
describe 'glassfish::create_node' do

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
        facts.merge({
          :hostname => 'testhost'
        })
      } 
  
      # Include Glassfish class 
      let (:pre_condition) { "include glassfish" }
      
      # Set-up default params values
      let :default_params do 
        {
          :das_host => 'otherhost'
        }
      end
      
      context 'with default params' do 
        # Set the title
        let(:title) { 'test' }
          
        # Set the params
        let(:params) { default_params }
        
        it do
          should contain_cluster_node('test').with({
            'ensure'       => 'present',
            'user'         => 'glassfish',
            'asadminuser'  => 'admin',
            'passwordfile' => '/home/glassfish/asadmin.pass',
            'host'         => 'testhost',
            'dashost'      => 'otherhost',
            'dasport'      => '4848'
          })
        end
      end
  
    end # context 'on #{os}'
  end # on_supported_os
end
