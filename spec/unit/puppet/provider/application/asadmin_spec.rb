require 'spec_helper'

describe Puppet::Type.type(:application).provider(:asadmin) do
  
  before :each do
    Puppet::Type.type(:application).stubs(:defaultprovider).returns described_class
    Puppet.features.expects(:root?).returns(true).once
  end
  
  let :application do
    Puppet::Type.type(:application).new(
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
      application.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin list-applications\"").
        returns("test  <web>  \nCommand list-applications executed successfully. \n")
      application.provider.should be_exists
    end

    it "should return false if resource is absent" do
      application.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin list-applications\"").
        returns("Nothing to list \nCommand list-applications executed successfully. \n")
      application.provider.should_not be_exists
    end
  end

  describe "when creating a resource" do
    it "should be able to deploy an application without a context root" do
      application.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin deploy --precompilejsp=true --target server --name test /tmp/test.war\"").
        returns("Application deployed with name test. \nCommand deploy executed successfully. \n")
      application.provider.create
    end
    
    it "should be able to deploy an application with a context root" do
      application[:contextroot] = 'test'
      application.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin deploy --precompilejsp=true --target server --contextroot test --name test /tmp/test.war\"").
        returns("Application deployed with name test. \nCommand deploy executed successfully. \n")
      application.provider.create
    end
  end
  
  describe "when destroying a resource" do
    it "should be able to undeploy an application" do
      application.provider.set(:ensure => :absent)
      application.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin undeploy test\"").
        returns("Command undeploy executed successfully. \n")
      application.provider.destroy
    end
  end
end