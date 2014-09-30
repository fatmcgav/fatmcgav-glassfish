require 'spec_helper'

# Start to describe glassfish::install_jars define
describe 'glassfish::install_jars' do

  # Set the osfamily fact
  let(:facts) { {
      :osfamily => 'RedHat'
    } }

  # Include Glassfish class
  let(:pre_condition) {
    "class {'glassfish':
      create_domain => true,
      domain_name   => 'test'
    }" }

  # Set-up default params values
  let(:default_params) do
    {
      :domain_name => 'test',
      :source      => 'source'
    }
  end

  context 'with default params' do
    # Set the title
    let(:title) { 'test.jar' }

    # Set the params
    let(:params) { default_params }

    it { should contain_glassfish__install_jars('test.jar') }
    it { should contain_file('/usr/local/glassfish-3.1.2.2/glassfish/lib/ext').with({
        'ensure' => 'directory',
        'owner'  => 'glassfish',
        'group'  => 'glassfish'
      }).that_comes_before('File[/usr/local/glassfish-3.1.2.2/glassfish/lib/ext/test.jar]') }
    it { should contain_file('/usr/local/glassfish-3.1.2.2/glassfish/lib/ext/test.jar').with({
        'ensure' => 'present',
        'mode'   => '0755',
        'owner'  => 'glassfish',
        'group'  => 'glassfish',
        'source' => 'source'
      }).without_notify() }
  end

  context 'with install_location = domain' do
    # Set the title
    let(:title) { 'test.jar' }

    # Set the params
    let(:params) do
      default_params.merge({
        :install_location => 'domain'
      })
    end

    it { should contain_glassfish__install_jars('test.jar') }
    it { should_not contain_file('/usr/local/glassfish-3.1.2.2/glassfish/lib/ext') }
    it { should contain_file('/usr/local/glassfish-3.1.2.2/glassfish/domains/test/lib/ext/test.jar').with({
        'ensure' => 'present',
        'mode'   => '0755',
        'owner'  => 'glassfish',
        'group'  => 'glassfish',
        'source' => 'source'
      }).that_notifies('Service[glassfish_test]') }
  end

  context 'with install_location = mq' do
    # Set the title
    let(:title) { 'test.jar' }

    # Set the params
    let(:params) do
      default_params.merge({
        :install_location => 'mq'
      })
    end

    it { should contain_glassfish__install_jars('test.jar') }
    it { should_not contain_file('/usr/local/glassfish-3.1.2.2/glassfish/lib/ext') }
    it { should contain_file('/usr/local/glassfish-3.1.2.2/mq/lib/ext/test.jar').with({
        'ensure' => 'present',
        'mode'   => '0755',
        'owner'  => 'glassfish',
        'group'  => 'glassfish',
        'source' => 'source'
      }).without_notify() }
  end

  context 'with download = true' do
    # Set the title
    let(:title) { 'http://www.test.com/test.jar' }

    # Set the params
    let(:params) do
      default_params.merge({
        :download => true
      })
    end

    it { should contain_glassfish__install_jars('http://www.test.com/test.jar') }
    it { should contain_file('/usr/local/glassfish-3.1.2.2/glassfish/lib/ext').with({
        'ensure' => 'directory',
        'owner'  => 'glassfish',
        'group'  => 'glassfish'
      }).that_comes_before('Exec[download_test.jar]') }
    it { should contain_exec('download_test.jar').with({
        'command' => 'wget -q -O /usr/local/glassfish-3.1.2.2/glassfish/lib/ext/test.jar http://www.test.com/test.jar',
        'path'    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        'creates' => '/usr/local/glassfish-3.1.2.2/glassfish/lib/ext/test.jar',
        'user'    => 'glassfish'
      }).without_notify() }
  end

  context 'with a service_name provided' do
    # Create gf_service domain resource
    let(:pre_condition) {
      ["include glassfish",
        "glassfish::create_domain{ 'gf_test':
        service_name => 'gf_service'
        }"]
    }

    # Set the title
    let(:title) { 'test.jar' }

    # Set the params
    let(:params) do
      default_params.merge({
        :install_location => 'domain',
        :domain_name      => 'gf_test',
        :service_name     => 'gf_service'
      })
    end

    it { should contain_glassfish__install_jars('test.jar') }
    it { should_not contain_file('/usr/local/glassfish-3.1.2.2/glassfish/lib/ext') }
    it { should contain_file('/usr/local/glassfish-3.1.2.2/glassfish/domains/gf_test/lib/ext/test.jar').with({
        'ensure' => 'present',
        'mode'   => '0755',
        'owner'  => 'glassfish',
        'group'  => 'glassfish',
        'source' => 'source'
      }).that_notifies('Service[gf_service]') }
  end

  context 'with a top-level service name' do
    let(:pre_condition) {
      "class {'glassfish':
        create_domain => true,
        domain_name   => 'gftest',
        service_name  => 'gftest_service'
      }" }

    # Set the title
    let(:title) { 'test.jar' }

    # Set the params
    let(:params) do
      default_params.merge({
        :install_location => 'domain',
        :domain_name      => 'gftest'
      })
    end

    it { should contain_glassfish__install_jars('test.jar') }
    it { should_not contain_file('/usr/local/glassfish-3.1.2.2/glassfish/lib/ext') }
    it { should contain_file('/usr/local/glassfish-3.1.2.2/glassfish/domains/gftest/lib/ext/test.jar').with({
        'ensure' => 'present',
        'mode'   => '0755',
        'owner'  => 'glassfish',
        'group'  => 'glassfish',
        'source' => 'source'
      }).that_notifies('Service[gftest_service]') }
  end

  context 'with an invalid install_location' do
    # Set the title
    let(:title) { 'test' }

    # Set the params
    let(:params) do
      default_params.merge({
        :install_location => 'invalid'
      })
    end

    it do
      should compile.and_raise_error(/Install location invalid is not supported/)
    end
  end
end 
