require 'spec_helper_acceptance'

context 'with defaults' do
  let(:manifest) {
    <<-EOS
      class { 'glassfish': }
    EOS
  }

  it 'should run without errors' do
    apply_manifest(manifest, :catch_failures => true)
    expect(apply_manifest(manifest, :catch_failures => true).exit_code).to be_zero
  end

  describe user('glassfish') do
    it { should exist }
    it { should belong_to_primary_group 'glassfish' }
  end

  describe file('/usr/local/glassfish-3.1.2.2') do
    it { should be_directory }
    it { should be_owned_by 'glassfish' }
    it { should be_grouped_into 'glassfish' }
  end
  
  describe file('/usr/local/glassfish-3.1.2.2/glassfish/domains/domain1') do
    it { should_not be_directory }
  end
end

context 'when creating a domain' do
  let(:manifest) {
    <<-EOS
      class { 'glassfish':
        create_domain => true,
        domain_name   => 'test',
        portbase      => '8000'
      }
    EOS
  }

  it 'should run without errors' do
    apply_manifest(manifest, :catch_failures => true)
    expect(apply_manifest(manifest, :catch_failures => true).exit_code).to be_zero
  end

  describe file('/usr/local/glassfish-3.1.2.2/glassfish/domains/test') do
    it { should be_directory }
  end

  describe file('/usr/lib/systemd/system/glassfish_test.service') do
    it { should be_file }
  end

  describe service('glassfish_test') do
    it { should be_enabled }
    it { should be_running }
  end

  describe process("java") do
    it { should be_running }
    its(:count) { should eq 1 }
  end

  describe port(8080) do
    it { should be_listening }
  end

  describe port(8048) do
    it { should be_listening }
  end
end
