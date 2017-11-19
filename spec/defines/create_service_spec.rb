require 'spec_helper'

# Start to describe glassfish::create_service define
describe 'glassfish::create_service', :type => :define do
  
  # Set-up default params values
  let :default_params do 
    {
      :domain_name => 'test',
      :runuser     => 'gfuser'
    }
  end
  
  on_supported_os(
    :hardwaremodels => ['x86_64'],
    :supported_os => [
      {
        'operatingsystem' => 'CentOS',
        'operatingsystemrelease' => %w[7]
      }
    ]
  ).each do |os, facts|
    context "on #{os}" do
      let(:facts) {
        facts
      }

      # Need to eval glassfish class
      let(:pre_condition) {
        'include glassfish'
      }
      
      # Defaults
      describe 'with defaults' do
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
            servicefile_path = '/lib/systemd/system/glassfish_test.service'
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

        it do
          should contain_glassfish__service__systemd('glassfish_test')
        end

        # Should create the service file
        it do
          should contain_file('glassfish_test-servicefile').with({
            'ensure'  => 'present',
            'path'    => servicefile_path,
            'mode'    => '0644',
            'content' => /#{servicefile_content}/
          }).that_notifies('Exec[systemctl-daemon-reload]')
        end

        # Shouldn't contain a stop_domain exec with default params
        it do
          should_not contain_exec('stop_test')
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
      end # describe 'with defaults'

      # Test running behaviour
      describe 'with running => true' do
        let(:title) { 'test-running' }

        let(:params) do
          default_params.merge( { :running => 'true' } )
        end

        it do
          should contain_exec('stop_test').with({
            'command' => /stop-domain test/,
          }).that_comes_before('Service[glassfish_test-running]')
        end

        # Should start the service and enable it
        it do
          should contain_service('glassfish_test-running').with({
            'ensure'     => 'running',
            'enable'     => true,
            'hasstatus'  => true,
            'hasrestart' => true
          })
        end
      end # describe 'with running => true'

      describe 'with restart_config_change => true' do
        # Need to eval glassfish class
        let(:pre_condition) {
          'class { "glassfish":
            restart_config_change => true
          }'
        }
      
        let(:title) { 'test-restart' }

        let(:params) { default_params }

        # Should create the service file
        it do
          should contain_file('glassfish_test-restart-servicefile')
            .that_notifies(['Exec[systemctl-daemon-reload]', 'Service[glassfish_test-restart]'])
        end

        it do
          should contain_service('glassfish_test-restart')
        end
      end # describe 'with restart_config_change => true'

      describe 'with a systemd_start_timeout' do
        let(:title) { 'test-start-timeout' }

        let(:params) do
          default_params.merge( { :systemd_start_timeout => '5m' } )
        end

        it do
          should contain_file('glassfish_test-start-timeout-servicefile')
            .with_content(/TimeoutStartSec = 5m/)
        end

      end # describe 'with a systemd_start_timeout'

    end
  end
end

#EOF
