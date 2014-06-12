require 'spec_helper'

# Start to describe glassfish::create_cluster define
describe 'glassfish::create_cluster' do
  
  # Set the osfamily fact
  let(:facts) { {
    :osfamily => 'RedHat'
  } }
  
  # Include Glassfish class 
  let (:pre_condition) { "include glassfish" }
  
  # Set-up default params values
  let :default_params do 
    {
      :asadmin_user     => 'admin',
      :asadmin_passfile => '/tmp/asadmin.pass',
      :cluster_user     => 'gfuser',
      :das_port         => '8048'
    }
  end
  
  context 'with default params' do 
    # Set the title
    let(:title) { 'test' }
      
    # Set the params
    let(:params) { default_params }
    
    it do
      should contain_cluster('test').with({
        'ensure'       => 'present',
        'user'         => 'gfuser',
        'asadminuser'  => 'admin',
        'passwordfile' => '/tmp/asadmin.pass',
        'dasport'      => '8048',
        'gmsenabled'   => true
      })
    end
  end
  
  context 'with an invalid boolean' do
    # Set the title
    let(:title) { 'test' }
      
    # Set the params
    let(:params) do 
      default_params.merge({
        :gms_enabled => 'nope'
      })
    end
    
    it do 
      should compile.and_raise_error(/is not a boolean/)
    end
  end
  
  context 'with multicast details provided' do 
    # Set the title
    let(:title) { 'test' }
      
    # Set the params
    let(:params) do 
      default_params.merge({
        :gms_multicast_port    => '30000',
        :gms_multicast_address => '228.9.00.00'
      })
    end
    
    it do
      should contain_cluster('test').with({
        'ensure'           => 'present',
        'user'             => 'gfuser',
        'asadminuser'      => 'admin',
        'passwordfile'     => '/tmp/asadmin.pass',
        'dasport'          => '8048',
        'gmsenabled'       => true,
        'multicastport'    => '30000',
        'multicastaddress' => '228.9.00.00'
      })
    end
  end
  
end