require 'spec_helper'

# Start to describe glassfish::create_domain define
describe 'glassfish::create_domain' do
  
  # Set the osfamily fact
  let(:facts) { {
    :osfamily => 'RedHat'
  } }
  
  # Set-up default params values
  let :default_params do 
    {
      :asadmin_path        => '/usr/local/glassfish3.1.2.2/bin/asadmin',
      :asadmin_user        => 'admin',
      :asadmin_passfile    => '/tmp/asadmin.pass',
      :domain_user         => 'gfuser',
      :portbase            => '8000',
      :start_domain        => true,
      :enable_secure_admin => true,
      :create_service      => true
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
        'enablesecureadmin' => true
      })
    end
    
    it do
      should contain_glassfish__create_service('test').with_running('true').that_requires('Domain[test]')
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
        'enablesecureadmin' => true
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
      should contain_glassfish__create_service('test').with_running('false').that_requires('Domain[test]')
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
      should contain_glassfish__create_service('test').with_running('true').that_requires('Domain[test]')
    end
  end
  
end
