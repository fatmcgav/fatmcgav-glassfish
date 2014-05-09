require 'spec_helper'

describe Puppet::Type.type(:jdbcresource).provider(:asadmin) do
  
  before :each do
    Puppet::Type.type(:jdbcresource).stubs(:defaultprovider).returns described_class
    #File.expects(:exists?).with('/tmp/test.war').returns(:true).once
    Puppet.features.expects(:root?).returns(true).once
  end
  
  let :jdbcresource do
    Puppet::Type.type(:jdbcresource).new(
      :name           => 'jdbc/test',
      :ensure         => :present,
      :connectionpool => 'test',
      :user           => 'glassfish',
      :portbase       => '8000',
      :asadminuser    => 'admin',
      :provider       => provider
    )
  end
  
  let :provider do
    described_class.new(
      :name => 'jdbc/test'
    )
  end
  
  describe "when asking exists?" do
    it "should return true if resource is present" do
      jdbcresource.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin list-jdbc-resources\"").
        returns("jdbc/__TimerPool \njdbc/__default \njdbc/test \nCommand list-jdbc-resources executed successfully.")
      jdbcresource.provider.should be_exists
    end

    it "should return false if resource is absent" do
      jdbcresource.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin list-jdbc-resources\"").
        returns("jdbc/__TimerPool \njdbc/__default \nCommand list-jdbc-resources executed successfully.")
      jdbcresource.provider.should_not be_exists
    end
  end

  describe "when creating a resource" do
    it "should be able to create a jdbcresource without a target" do
      jdbcresource.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin create-jdbc-resource --connectionpoolid test --target server jdbc/test\"").
        returns("JDBC resource jdbc/test created successfully. \nCommand create-jdbc-resource executed successfully. \n")
      jdbcresource.provider.create
    end
    
    it "should be able to deploy an jdbcresource with a target" do
      jdbcresource[:target] = 'cluster'
      jdbcresource.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin create-jdbc-resource --connectionpoolid test --target cluster jdbc/test\"").
        returns("JDBC resource jdbc/test created successfully. \nCommand create-jdbc-resource executed successfully. \n")
      jdbcresource.provider.create
    end
  end
  
  describe "when destroying a resource" do
    it "should be able to undeploy a jdbcresource" do
      jdbcresource.provider.set(:ensure => :absent)
      jdbcresource.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin delete-jdbc-resource jdbc/test\"").
        returns("JDBC resource jdbc/test deleted successfully \nCommand delete-jdbc-resource executed successfully.")
      jdbcresource.provider.destroy
    end
  end
end