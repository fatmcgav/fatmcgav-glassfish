require 'spec_helper'

describe Puppet::Type.type(:app).provider(:asadmin) do
  
  before :each do
    Puppet::Type.type(:app).stubs(:defaultprovider).returns described_class
    Puppet.features.expects(:root?).returns(true).once
  end
  
  let :app do
    Puppet::Type.type(:app).new(
      :name        => 'test',
      :ensure      => :present,
      :user        => 'glassfish',
      :portbase    => '8000',
      :asadminuser => 'admin',
      :source      => '/tmp/test.war',
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
      app.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin list-applications server\"").
        returns("test  <web>  \nCommand list-applications executed successfully. \n")
      app.provider.should be_exists
    end

    it "should return false if resource is absent" do
      app.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin list-applications server\"").
        returns("Nothing to list \nCommand list-applications executed successfully. \n")
      app.provider.should_not be_exists
    end
  end

  describe "when creating a resource" do
    it "should be able to deploy an application without a context root" do
      app.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin deploy --precompilejsp=true --target server --name test /tmp/test.war\"").
        returns("Application deployed with name test. \nCommand deploy executed successfully. \n")
      app.provider.create
    end
    
    it "should be able to deploy an application with a context root" do
      app[:contextroot] = 'test'
      app.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin deploy --precompilejsp=true --target server --contextroot test --name test /tmp/test.war\"").
        returns("Application deployed with name test. \nCommand deploy executed successfully. \n")
      app.provider.create
    end
    
    it "should be able to deploy an application with a target" do
      app[:target] = 'testCluster'
      app.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin deploy --precompilejsp=true --target testCluster --name test /tmp/test.war\"").
        returns("Application deployed with name test. \nCommand deploy executed successfully. \n")
      app.provider.create
    end
  end
  
  describe "when destroying a resource" do
    it "should be able to undeploy an application" do
      app.provider.set(:ensure => :absent)
      app.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin undeploy --target server test\"").
        returns("Command undeploy executed successfully. \n")
      app.provider.destroy
    end
  end

  describe "when refreshing a resource" do
    it "should redeploy an application" do
      app.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin redeploy --name test /tmp/test.war\"").
        returns("Application deployed with name test. \nCommand redeploy executed successfully. \n")
      app.provider.redeploy
    end
  end
end
