require 'spec_helper'

# Start to describe glassfish::create_instance define
describe 'glassfish::create_instance' do
  
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
      :cluster           => 'test',
      :instance_portbase => '28000'
    }
  end
  
  context 'with default params' do 
    # Set the title
    let(:title) { 'test' }
      
    # Set the params
    let(:params) { default_params }
    
    it do
      should contain_cluster_instance('test').with({
        'ensure'       => 'present',
        'user'         => 'glassfish',
        'asadminuser'  => 'admin',
        'passwordfile' => '/home/glassfish/asadmin.pass',
        'dasport'      => '4848',
        'nodename'     => 'testhost',
        'cluster'      => 'test',
        'portbase'     => '28000'
      })
    end
    
    it do
      should contain_glassfish__create_service('test').with({
        'mode'          => 'instance', 
        'instance_name' => 'test',
        'node_name'     => 'testhost',  
      }).that_requires('Cluster_Instance[test]')
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
      should contain_cluster_instance('test').with({
        'ensure'       => 'present',
        'user'         => 'glassfish',
        'asadminuser'  => 'admin',
        'passwordfile' => '/home/glassfish/asadmin.pass',
        'dasport'      => '4848',
        'nodename'     => 'testhost',
        'cluster'      => 'test',
        'portbase'     => '28000'
      })
    end
    
    it do
      should_not contain_glassfish__create_service('test')
    end
  end
  
  context 'with a das_host provided' do 
    # Set the title
    let(:title) { 'test' }

    # Set the params
    let(:params) do 
      default_params.merge({
        :das_host => 'otherhost'
      })
    end
    
    it do
      should contain_cluster_instance('test').with({
        'ensure'       => 'present',
        'user'         => 'glassfish',
        'asadminuser'  => 'admin',
        'passwordfile' => '/home/glassfish/asadmin.pass',
        'dashost'      => 'otherhost',
        'dasport'      => '4848',
        'nodename'     => 'testhost',
        'cluster'      => 'test',
        'portbase'     => '28000'
      })
    end
    
    it do
      should contain_glassfish__create_service('test').with({
        'mode'          => 'instance', 
        'instance_name' => 'test',
        'node_name'     => 'testhost',  
      }).that_requires('Cluster_Instance[test]')
    end
  end
  
end