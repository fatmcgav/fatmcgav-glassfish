require 'spec_helper'

# Start to describe glassfish::create_node define
describe 'glassfish::create_node' do
  
  # Set the osfamily fact
  let(:facts) { {
    :osfamily => 'RedHat',
    :hostname => 'testhost'
  } }
  
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
  
end