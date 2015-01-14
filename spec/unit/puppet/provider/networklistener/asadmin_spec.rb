require 'spec_helper'

describe Puppet::Type.type(:networklistener).provider(:asadmin) do
  
  before :each do
    Puppet::Type.type(:networklistener).stubs(:defaultprovider).returns described_class
    Puppet.features.expects(:root?).returns(true).once
  end
  
  let :networklistener do
    Puppet::Type.type(:networklistener).new(
      :name         => 'test',
      :ensure       => :present,
      :protocol     => 'http-listener-1',
      :port         => '8009',
      :portbase     => '8000',
      :user         => 'glassfish',
      :passwordfile => '/tmp/asadmin.pass' ,
      :provider     => provider
    )
  end
  
  let :provider do
    described_class.new(
      :name => 'test'
    )
  end
  
  describe "when asking exists?" do
    it "should return true if networklistener is present" do
      networklistener.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin --passwordfile /tmp/asadmin.pass list-network-listeners server\"").
        returns("http-listener-1\nhttp-listener-2\nadmin-listener\ntest\nCommand list-network-listeners executed successfully.")
      networklistener.provider.should be_exists
    end

    it "should return false if networklistener is absent" do
      networklistener.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin --passwordfile /tmp/asadmin.pass list-network-listeners server\"").
        returns("http-listener-1\nhttp-listener-2\nadmin-listener\nCommand list-network-listeners executed successfully.")
      networklistener.provider.should_not be_exists
    end
  end

  describe "when creating a resource" do
    it "should be able to create a networklistener with default values" do
      subcmd = "create-network-listener --listenerport 8009 --transport tcp --protocol http-listener-1 --enabled true --jkenabled false --target server test"
      networklistener.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin --passwordfile /tmp/asadmin.pass #{subcmd}\"").
        returns("Command create-network-listener executed successfully.")
      networklistener.provider.create
    end

    it "should be able to create a networklistener with a threadpool" do
      networklistener['threadpool'] = 'test'
      subcmd = [
        "create-network-listener",
        "--listenerport", "8009",
        "--threadpool", "test",
        "--transport", "tcp",
        "--protocol", "http-listener-1",
        "--enabled", "true",
        "--jkenabled", "false",
        "--target", "server",
        "test"
      ].join(" ")
      networklistener.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin --passwordfile /tmp/asadmin.pass #{subcmd}\"").
        returns("Command create-network-listener executed successfully.")
      networklistener.provider.create
    end

    it "should be able to create a networklistener with an address" do
      networklistener['address'] = '172.16.10.5'
      subcmd = [
        "create-network-listener",
        "--address", "172.16.10.5",
        "--listenerport", "8009",
        "--transport", "tcp",
        "--protocol", "http-listener-1",
        "--enabled", "true",
        "--jkenabled", "false",
        "--target", "server",
        "test"
      ].join(" ")
      networklistener.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin --passwordfile /tmp/asadmin.pass #{subcmd}\"").
        returns("Command create-network-listener executed successfully.")
      networklistener.provider.create
    end 

  end 
    
  describe "when destroying a resource" do
    it "should be able to destroy a networklistener" do
      networklistener.provider.set(:ensure => :absent)
      networklistener.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin --passwordfile /tmp/asadmin.pass delete-network-listener test\"").
        returns("Command delete-network-listener executed successfully.")
      networklistener.provider.destroy
    end
  end
end
