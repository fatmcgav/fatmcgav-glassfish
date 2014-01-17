require 'spec_helper'

# Start to describe glassfish::init class
describe 'glassfish' do
  
  # Setup default params
  let :default_params do 
    {
      :domain_asadmin_passfile    => '/tmp/asadmin.pass'
    }
  end
  
  context 'on a RedHat OSFamily' do
    # Set the osfamily fact
    let(:facts) { {
      :osfamily => 'RedHat'
    } }
    
    describe 'with default param values' do
      # Include required classe with default param values
      let(:params) { default_params }
      
      #
      ## Test default behaviour
      #
      it do
        # Parent dir 
        should contain_file('/usr/local').with_ensure('directory')
        
        # Manage_java defaults to false
        should contain_class('glassfish::java').that_comes_before('Class[glassfish::install]')
        
        # Should include install
        should contain_class('glassfish::install').that_requires('File[/usr/local]')
        
        # Create_domain defaults to false
        should_not contain_create_domain('domain1')
        should_not contain_create_service('domain1')
        
        # Should include path class
        should contain_class('glassfish::path').that_requires('Class[glassfish::install]')
      end
    end
    
    describe 'with manage_java => false' do
      # Include required classe with manage_java set to false
      let(:params) do
        default_params.merge( {
          :manage_java => false
        } )
      end
      
      # Shouldn't include glassfish::java class
      it { should_not contain_class('glassfish::java') }
    end
    
    describe 'with create_domain => true' do
      # Include required classe with create_domain set to false
      let(:params) do
        default_params.merge( {
          :create_domain => true
        } )
      end
      
      it do
        # Should include create_domain resource
        should contain_glassfish__create_domain('domain1').that_requires('Class[glassfish::install]')
         
        # Should not include install_jars resource
        should_not contain_install_jars('[]')
        
        # Shouldn't include create_service resource
        should_not contain_glassfish__create_service('domain1')
      end
    end
    
    describe 'with create_domain => true and create_service => true' do
      # Include required classe with create_domain set to false
      let(:params) do
        default_params.merge( {
          :create_domain  => true,
          :create_service => true
        } )
      end
      
      it do
        # Should include create_domain resource
        should contain_glassfish__create_domain('domain1').that_requires('Class[glassfish::install]')
         
        # Should not include install_jars resource
        should_not contain_install_jars('[]')
        
        # Should include create_service resource
        should contain_glassfish__create_service('domain1').with_runuser('glassfish').that_requires('Create_domain[domain1]')
      end
    end
  end
end