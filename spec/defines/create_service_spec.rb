require 'spec_helper'

# Start to describe glassfish::create_service define
describe 'glassfish::create_service' do
  
  # Set-up default params values
  let :default_params do 
    {
      :runuser => 'gfuser'
    }
  end
  
  context 'on a RedHat osfamily' do
  
    # Set the osfamily fact
    let(:facts) { {
      :osfamily => 'RedHat'
    } }
    
    # Test RedHat osfamily behaviour
    context 'with a title' do
      let(:title) { 'test' }
      
      # Setup params
      let(:params) { default_params }
        
      # Should create the init.d file
      it do 
        should contain_file('test_servicefile').with({
          'ensure'  => 'present',
          'path'    => '/etc/init.d/glassfish_test',
          'mode'    => '0755',
          'content' => /chkconfig:[\s\S]+="gfuser"/
        })
      end
      
      # Shouldn't contain a stop_domain exec with default params
      it { should_not contain_exec('stop_test') }
      
      # Test running behaviour
      context 'with running => true' do
        
        let(:params) do
          default_params.merge( { :running => 'true' } )
        end
          
        it do
          should contain_exec('stop_test').with({
            'command' => /stop-domain test$/,
            'user'    => 'gfuser'
          }).that_comes_before('Service[glassfish_test]')
        end
        
      end
      
      # Should start the service and enable it
      it do
        should contain_service('glassfish_test').with({
          'ensure'     => 'running',
          'enable'     => true,
          'hasstatus'  => true,
          'hasrestart' => true
        }).that_requires('File[test_servicefile]')
      end
      
    end
    
  end
  
  context 'on a Debian osfamily' do
    
    # Set the osfamily fact
    let(:facts) { {
      :osfamily => 'Debian'
    } }
    
    # Test Debian osfamily behaviour
    context 'with a title' do
      let(:title) { 'test' }
      
      # Setup params
      let(:params) { default_params }
        
      # Should create the init.d file
      it do 
        should contain_file('test_servicefile').with({
          'ensure' => 'present',
          'path'   => '/etc/init.d/glassfish_test',
          'mode'   => '0755',
          'content' => /Provides:[\s\S]+=gfuser/
        })
      end
      
      # Shouldn't contain a stop_domain exec with default params
      it { should_not contain_exec('stop_test') }
      
      # Test running behaviour
      context 'with running => true' do
        
        let(:params) do
          default_params.merge( { :running => 'true' } )
        end
          
        it do
          should contain_exec('stop_test').with({
            'command' => /stop-domain test$/,
            'user'    => 'gfuser'
          }).that_comes_before('Service[glassfish_test]')
        end
        
      end
      
      # Should start the service and enable it
      it do
        should contain_service('glassfish_test').with({
          'ensure'     => 'running',
          'enable'     => true,
          'hasstatus'  => true,
          'hasrestart' => true
        }).that_requires('File[test_servicefile]')
      end
      
    end
    
  end
    
  context 'with an unsupported osfamily' do
    
    # Set the osfamily fact
    let(:facts) { {
      :osfamily => 'Suse'
    } }
    
    # Test unsupported osfamily behaviour
    context 'with a title to fail' do
      let(:title) { 'test' }
       
      # Setup params
      let(:params) { default_params }
        
      it do
        expect { subject }.to raise_error(Puppet::Error, /OSFamily Suse not supported/)
      end
         
    end
    
  end
  
end
