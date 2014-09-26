require 'spec_helper'

# Start to describe glassfish::create_asadmin_passfile define
describe 'glassfish::create_asadmin_passfile' do
  
  # Set the osfamily fact
  let(:facts) { {
    :osfamily => 'RedHat'
  } }
  
  # Include Glassfish class 
  let (:pre_condition) { "include glassfish" }
  
  # Set-up default params values
  let :default_params do 
    {
      :asadmin_master_pass => 'changeit',
      :asadmin_password    => 'adminadmin',
      :group               => 'glassfish',
      :path                => '/tmp/asadmin.pass',
      :user                => 'glassfish'
    }
  end
  
  context 'with default params' do 
    # Set the title
    let(:title) { 'glassfish_asadmin_passfile' }
      
    # Set the params
    let(:params) { default_params }
    
    it do
      should contain_file('glassfish_asadmin_passfile').with({
        'ensure' => 'present',
        'path'   => '/tmp/asadmin.pass',
        'owner'  => 'glassfish',
        'group'  => 'glassfish',
        'mode'   => '0644'
      }).with_content(/AS_ADMIN_PASSWORD=adminadmin/).
      with_content(/AS_ADMIN_MASTERPASSWORD=changeit/)
    end
  end
  
  context 'with a different master and asadmin password' do
    # Set the title
    let(:title) { 'glassfish_asadmin_passfile' }
      
    # Set the params
    let(:params) do 
      default_params.merge({
        :asadmin_master_pass => 'different',
        :asadmin_password    => 'password'
      })
    end
    
    it do
      should contain_file('glassfish_asadmin_passfile').with({
        'ensure' => 'present',
        'path'   => '/tmp/asadmin.pass',
        'owner'  => 'glassfish',
        'group'  => 'glassfish',
        'mode'   => '0644'
      }).with_content(/AS_ADMIN_PASSWORD=password/).
      with_content(/AS_ADMIN_MASTERPASSWORD=different/)
    end
  end
  
  context 'with a different path' do
    # Set the title
    let(:title) { 'glassfish_asadmin_passfile' }
      
    # Set the params
    let(:params) do 
      default_params.merge({
        :path => '/tmp/asadmin.pass2'
      })
    end
    
    it do
      should contain_file('glassfish_asadmin_passfile').with({
        'ensure' => 'present',
        'path'   => '/tmp/asadmin.pass2',
        'owner'  => 'glassfish',
        'group'  => 'glassfish',
        'mode'   => '0644'
      }).with_content(/AS_ADMIN_PASSWORD=adminadmin/).
      with_content(/AS_ADMIN_MASTERPASSWORD=changeit/)
    end
  end
  
end