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
    
    it do
      should contain_glassfish__create_service('test').with({
        'mode'         => 'cluster', 
        'cluster_name' => 'test',
        'das_port'     => '8048',
        'status_cmd'   => '/usr/local/glassfish-3.1.2.2/bin/asadmin --port 8048 --passwordfile /tmp/asadmin.pass list-clusters |grep \'test running\''  
      }).that_requires('Cluster[test]')
    end
  end
  
  context 'with create_service => false' do 
    # Set the title
    let(:title) { 'test' }
      
    # Set the params
    let(:params) do 
      default_params.merge({
        :create_service => false
      })
    end
    
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
    
    it do
      should_not contain_glassfish__create_service('test')
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
      expect { subject }.to raise_error(Puppet::Error, /is not a boolean/)
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
    
    it do
      should contain_glassfish__create_service('test').with({
        'mode'         => 'cluster', 
        'cluster_name' => 'test',
        'das_port'     => '8048',
        'status_cmd'   => '/usr/local/glassfish-3.1.2.2/bin/asadmin --port 8048 --passwordfile /tmp/asadmin.pass list-clusters |grep \'test running\''  
      }).that_requires('Cluster[test]')
    end
  end
  
end