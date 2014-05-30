require 'spec_helper'

describe Puppet::Type.type(:jdbcconnectionpool).provider(:asadmin) do
  
  before :each do
    Puppet::Type.type(:jdbcconnectionpool).stubs(:defaultprovider).returns described_class
    Puppet.features.expects(:root?).returns(true).once
  end
  
  let :jdbcconnectionpool do
    Puppet::Type.type(:jdbcconnectionpool).new(
      :name         => 'test',
      :dsclassname  => 'oracle.jdbc.pool.OracleConnectionPoolDataSource',
      :resourcetype => 'javax.sql.ConnectionPoolDataSource',
      :properties   => 'user=myuser:password=mypass:url=jdbc\:mysql\://myhost.ex.com\:3306/mydatabase',
      :portbase     => '8000',
      :user         => 'glassfish',
      :provider    => provider
    )
  end
  
  let :provider do
    described_class.new(
      :name => 'test'
    )
  end
  
  describe "when asking exists?" do
    it "should return true if resource is present" do
      jdbcconnectionpool.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin list-jdbc-connection-pools\"").
        returns("__TimerPool \n__default \ntest \nCommand list-jdbc-connection-pools executed successfully.")
      jdbcconnectionpool.provider.should be_exists
    end

    it "should return false if resource is absent" do
      jdbcconnectionpool.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin list-jdbc-connection-pools\"").
        returns("Nothing to list \nCommand list-jdbc-connection-pools executed successfully. \n")
      jdbcconnectionpool.provider.should_not be_exists
    end
  end

  describe "when creating a resource" do
    it "should be able to deploy an jdbcconnectionpool without a context root" do
      jdbcconnectionpool.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin create-jdbc-connection-pool --datasourceclassname oracle.jdbc.pool.OracleConnectionPoolDataSource --restype javax.sql.ConnectionPoolDataSource --property 'user=myuser:password=mypass:url=jdbc\\:mysql\\://myhost.ex.com\\:3306/mydatabase' test\"").
        returns("Application deployed with name test. \nCommand deploy executed successfully. \n")
      jdbcconnectionpool.provider.create
    end
  end
  
  describe "when destroying a resource" do
    it "should be able to undeploy an jdbcconnectionpool" do
      jdbcconnectionpool.provider.set(:ensure => :absent)
      jdbcconnectionpool.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin delete-jdbc-connection-pool test\"").
        returns("Command delete-jdbc-connection-pool executed successfully. \n")
      jdbcconnectionpool.provider.destroy
    end
  end
end