require 'spec_helper'

# Start to describe glassfish::service define
describe 'glassfish::create_service' do
  
  context 'on a RedHat osfamily' do
  
    # Set the osfamily fact
    let(:facts) { {
      :osfamily => 'RedHat'
    } }
    
    # Test RedHat osfamily behaviour
    context 'with a title' do
      let(:title) { 'test' }
      
      # Should create the init.d file
      it do 
        should contain_file('test_servicefile').with({
          'ensure' => 'present',
          'path'   => '/etc/init.d/glassfish_test',
          'mode'   => '0755',
        })
      end
      
      # Shouldn't contain a stop_domain exec with default params
      it { should_not contain_exec('stop_test') }
      
      # Test running behaviour
      context 'with running => true' do
        
        let(:params) { { :running => 'true' } }
          
        it do
          should contain_exec('stop_test')
        end
        
      end
      
      # Should start the service and enable it
      it do
        should contain_service('glassfish_test').with({
          'ensure'     => 'running',
          'enable'     => true,
          'hasstatus'  => true,
          'hasrestart' => true,
        }).that_requires('File[test_servicefile]')
      end
      
    end
    
  end
  
end
