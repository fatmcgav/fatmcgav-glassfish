require 'spec_helper'

describe Puppet::Type.type(:javamailresource).provider(:asadmin) do

  before :each do
    Puppet::Type.type(:javamailresource).stubs(:defaultprovider).returns described_class
    Puppet.features.expects(:root?).returns(true).once
  end

  let :javamailresource do
    Puppet::Type.type(:javamailresource).new(
      :name        => "test",
      :mailhost    => "localhost",
      :fromaddress => 'noreply@example.com',
      :asadminuser => 'admin',
      :user        => 'glassfish',
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
      javamailresource.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 4848 --user admin list-javamail-resources\"").
        returns("test \nCommand list-javamail-resources executed successfully.")
      javamailresource.provider.should be_exists
    end

    it "should return false if resource is absent" do
      javamailresource.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 4848 --user admin list-javamail-resources\"").
        returns("Nothing to list \nCommand list-javamail-resources executed successfully. \n")
      javamailresource.provider.should_not be_exists
    end
  end

  describe "when creating a resource" do
    it "should be able to create a javamailresource without passing mailuser" do
      javamailresource.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 4848 --user admin create-javamail-resource --target server --mailhost localhost --fromaddress noreply@example.com test\"").
        returns("Mail Resource test created. \nCommand create-javamail-resource executed successfully. \n")
      javamailresource.provider.create
    end

    it "should be able to create a javamailresource with passing mailuser" do
      javamailresource[:mailuser] = "testuser"
      javamailresource.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 4848 --user admin create-javamail-resource --target server --mailhost localhost --mailuser testuser --fromaddress noreply@example.com test\"").
        returns("Mail Resource test created. \nCommand create-javamail-resource executed successfully. \n")
      javamailresource.provider.create
    end

    it "should be possible to pass properties" do
      javamailresource[:properties] = 'port=12345'
      javamailresource.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 4848 --user admin create-javamail-resource --target server --mailhost localhost --fromaddress noreply@example.com --property 'port=12345' test\"").
        returns("Mail Resource test created. \nCommand create-javamail-resource executed successfully. \n")
      javamailresource.provider.create
    end
  end

  describe "when destroying a resource" do
    it "should be able to destroy an javamailresource" do
      javamailresource.provider.set(:ensure => :absent)
      javamailresource.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 4848 --user admin delete-javamail-resource test\"").
        returns("Mail resource test deleted. \nCommand delete-javamail-resource executed successfully. \n")
      javamailresource.provider.destroy
    end
  end
end
