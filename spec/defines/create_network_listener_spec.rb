require 'spec_helper'

describe 'glassfish::create_network_listener' do
  
  let(:facts) { {
    :osfamily => 'RedHat'
  } }
  
  let (:pre_condition) { "include glassfish" }
  
  let :default_params do 
    {
      :asadmin_path        => '/usr/local/glassfish3.1.2.2/bin/asadmin',
      :asadmin_user        => 'admin',
      :asadmin_passfile    => '/tmp/asadmin.pass',
      :portbase            => '8000',
    }
  end
  
  context 'with default params' do 

    let(:title) { 'test' }
      
    let(:params) { default_params }
    
    it do
      should contain_networklistener('test').with({
        'ensure'            => 'present',
        'address'           => nil,
        'port'              => nil,
        'threadpool'        => nil,
        'protocol'          => nil,
        'transport'         => 'tcp',
        'enabled'           => true,
        'jkenabled'         => false,
        'target'            => 'server',
        'asadminuser'       => 'admin',
        'passwordfile'      => '/tmp/asadmin.pass',
        'portbase'          => '8000',
      })
    end
    
  end

  context 'with all parameters set' do

    let(:title) { 'test' }

    let(:params) {
      default_params.merge({
        :address    => '172.16.10.5',
        :port       => '8009',
        :threadpool => 'test',
        :protocol   => 'http-listener-1',
        :transport  => 'udp',
        :enabled    => false,
        :jkenabled  => true,
        :target     => 'test' 
      })
    }

    it do
      should contain_networklistener('test').with({
        'address'    => '172.16.10.5',
        'port'       => '8009',
        'threadpool' => 'test',
        'protocol'   => 'http-listener-1',
        'transport'  => 'udp',
        'enabled'    => false,
        'jkenabled'  => true,
        'target'     => 'test'
      })
    end

  end

end 
