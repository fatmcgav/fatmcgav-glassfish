require 'spec_helper'

# Start to describe glassfish::create_service define
describe 'glassfish::create_service' do
  
  # Set-up default params values
  let :default_params do 
    {
      :domain_name => 'test',
      :runuser     => 'gfuser'
    }
  end
  
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) {
        facts
      }

      # Need to eval glassfish class
      let(:pre_condition) {
        'include glassfish'
      }
      
      # Test RedHat osfamily behaviour
      describe 'with a title' do
        let(:title) { 'test' }
        
        # Setup params
        let(:params) { default_params }

        # Work out correct servicefile path and contents
        case facts["systemd"]
        when true
          case facts[:osfamily]
          when 'Debian'
            servicefile_path = '/etc/systemd/system/glassfish_test.service'
          when 'RedHat'
            servicefile_path = '/usr/lib/systemd/system/glassfish_test.service'
          end
          servicefile_content = '\[Service\]\nUser=gfuser'
        when false
          servicefile_path = '/etc/init.d/glassfish_test'
          case facts[:osfamily]
          when 'Debian'
            servicefile_content = 'END INIT INFO\n\nUSER=gfuser'
          when 'RedHat'
            servicefile_content = 'chkconfig:[\s\S]+="gfuser"'
          end
        end

        # Should create the service file
        it do
          should contain_file('test_servicefile').with({
            'ensure'  => 'present',
            'path'    => servicefile_path,
            'mode'    => '0755',
            'content' => /#{servicefile_content}/
          }).that_notifies('Service[glassfish_test]')
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
              'command' => /stop-domain test/,
            })
          end
          
        end
        
        # Should start the service and enable it
        it do
          should contain_service('glassfish_test').with({
            'ensure'     => 'running',
            'enable'     => true,
            'hasstatus'  => true,
            'hasrestart' => true
          })
        end
      end
    end
  end
end

#EOF
