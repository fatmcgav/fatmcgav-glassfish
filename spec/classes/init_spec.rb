require 'spec_helper'

# Start to describe glassfish::init class
describe 'glassfish' do
  
  context 'on a RedHat OSFamily' do
    # Set the osfamily fact
    let(:facts) { {
      :osfamily => 'RedHat'
    } }
    
    describe 'with default param values' do
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
        
        # Should include path class
        should contain_class('glassfish::path').that_requires('Class[glassfish::install]')
      end
    end
    
    describe 'with manage_java => false' do
      # Set relevant params
      let(:params) do {
          :manage_java => false
        }
      end
      
      # Shouldn't include glassfish::java class
      it { should_not contain_class('glassfish::java') }
    end
    
    describe 'with create_domain => true' do
      # Set relevant params
      let(:params) do  {
          :create_domain => true,
          :domain_name   => 'domain1'
        }
      end
      
      it do
        # Should include create_domain resource
        should contain_glassfish__create_domain('domain1').that_requires('Class[glassfish::install]')
         
        # Should not include install_jars resource
        should_not contain_install_jars('[]')
        
        # Should include create_service resource
        should contain_glassfish__create_service('domain1')
      end
    end
    
    describe 'with add_path => false' do
      # Set relevant params
      let(:params) do {
          :add_path => false
        }
      end
      
      # Shouldn't contain glassfish::path class
      it do
        should_not contain_class('glassfish::path')
      end 
    end
    
    describe 'with invalid param' do
      # Set relevant params
      let(:params) do {
          :create_domain => 'blah'
        }
      end
      
      # Should  fail due to invalid boolean
      it do
        should compile.and_raise_error(/is not a boolean/)
      end 
    end
  end
end
