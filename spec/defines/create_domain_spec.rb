require 'spec_helper'

# Start to describe glassfish::create_domain define
describe 'glassfish::create_domain' do
  
  # Set the osfamily fact
  let(:facts) { {
    :osfamily => 'RedHat'
  } }
  
  # Include Glassfish class 
  let (:pre_condition) { "include glassfish" }
  
  # Set-up default params values
  let :default_params do 
    {
      :asadmin_path        => '/usr/local/glassfish3.1.2.2/bin/asadmin',
      :asadmin_user        => 'admin',
      :asadmin_passfile    => '/tmp/asadmin.pass',
      :domain_user         => 'gfuser',
      :portbase            => '8000'
    }
  end
  
  context 'with default params' do 
    # Set the title
    let(:title) { 'test' }
      
    # Set the params
    let(:params) { default_params }
    
    it do
      should contain_domain('test').with({
        'ensure'            => 'present',
        'user'              => 'gfuser',
        'asadminuser'       => 'admin',
        'passwordfile'      => '/tmp/asadmin.pass',
        'portbase'          => '8000',
        'startoncreate'     => true,
        'enablesecureadmin' => true,
        'template'          => nil
      })
    end
    
    it do
      should contain_glassfish__create_service('test').with({
        'running'      => 'true',
        'mode'         => 'domain', 
        'domain_name'  => 'test', 
        'service_name' => 'glassfish_test'
      }).that_requires('Domain[test]')
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
      should contain_domain('test').with({
        'ensure'            => 'present',
        'user'              => 'gfuser',
        'asadminuser'       => 'admin',
        'passwordfile'      => '/tmp/asadmin.pass',
        'portbase'          => '8000',
        'startoncreate'     => true,
        'enablesecureadmin' => true,
        'template'          => nil
      })
    end
    
    it do
      should_not contain_glassfish__create_service('test')
    end
  end
  
  context 'with startoncreate => false' do
    # Set the title
    let(:title) { 'test' }
      
    # Set the params
    let(:params) do 
      default_params.merge({
        :start_domain => false
      })
    end
    
    it do
      should contain_domain('test').with({
        'ensure'            => 'present',
        'user'              => 'gfuser',
        'asadminuser'       => 'admin',
        'passwordfile'      => '/tmp/asadmin.pass',
        'portbase'          => '8000',
        'startoncreate'     => false,
        'enablesecureadmin' => true
      })
    end
    
    it do
      should contain_glassfish__create_service('test').with({
        'running'      => 'false',
        'mode'         => 'domain', 
        'domain_name'  => 'test', 
        'service_name' => 'glassfish_test'
      }).that_requires('Domain[test]')
    end
  end
  
  context 'with an invalid boolean' do
    # Set the title
    let(:title) { 'test' }
      
    # Set the params
    let(:params) do 
      default_params.merge({
        :start_domain => 'no'
      })
    end
    
    it do 
      expect { subject }.to raise_error(Puppet::Error, /is not a boolean/)
    end
  end
  
  context 'with a domain template file specified' do
    # Set the title
    let(:title) { 'test' }
      
    # Set the params
    let(:params) do 
      default_params.merge({
        :domain_template => '/tmp/template.xml'
      })
    end
    
    it do
      should contain_domain('test').with({
        'ensure'            => 'present',
        'user'              => 'gfuser',
        'asadminuser'       => 'admin',
        'passwordfile'      => '/tmp/asadmin.pass',
        'portbase'          => '8000',
        'startoncreate'     => true,
        'enablesecureadmin' => true,
        'template'          => '/tmp/template.xml'
      })
    end
    
    it do
      should contain_glassfish__create_service('test').with({
        'running'      => 'true',
        'mode'         => 'domain', 
        'domain_name'  => 'test', 
        'service_name' => 'glassfish_test'
      }).that_requires('Domain[test]')
    end
  end
  
  context 'with a service_name specified' do
    # Set the title
    let(:title) { 'test' }
      
    # Set the params
    let(:params) do 
      default_params.merge({
        :service_name => 'glassfish'
      })
    end
    
    it do
      should contain_domain('test').with({
        'ensure'            => 'present',
        'user'              => 'gfuser',
        'asadminuser'       => 'admin',
        'passwordfile'      => '/tmp/asadmin.pass',
        'portbase'          => '8000',
        'startoncreate'     => true,
        'enablesecureadmin' => true,
        'template'          => nil
      })
    end
    
    it do
      should contain_glassfish__create_service('test').with({
        'running'      => 'true',
        'mode'         => 'domain', 
        'domain_name'  => 'test', 
        'service_name' => 'glassfish'
      }).that_requires('Domain[test]')
    end
  end
  
end
