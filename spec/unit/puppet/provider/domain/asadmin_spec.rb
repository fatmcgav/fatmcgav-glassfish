require 'spec_helper'

describe Puppet::Type.type(:domain).provider(:asadmin) do
  
  before :each do
    Puppet::Type.type(:domain).stubs(:defaultprovider).returns described_class
    Puppet.features.expects(:root?).returns(true).once
  end
  
  let :domain do
    Puppet::Type.type(:domain).new(
      :domainname   => 'test',
      :ensure       => :present,
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
    it "should return true if resource is present" do
      domain.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin --passwordfile /tmp/asadmin.pass list-domains\"").
        returns("test running")
      domain.provider.should be_exists
    end

    it "should return false if resource is absent" do
      domain.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin --passwordfile /tmp/asadmin.pass list-domains\"").
        returns("No Domains to list")
      domain.provider.should_not be_exists
    end
  end

  describe "when creating a resource" do
    it "should be able to create a domain with default values" do
      domain.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin --passwordfile /tmp/asadmin.pass create-domain --portbase 8000 --savelogin --savemasterpassword test\"").
        returns("Command create-domain executed successfully.")
      domain.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin --passwordfile /tmp/asadmin.pass start-domain test\"").
        returns("Command start-domain executed successfully.")
      domain.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin --passwordfile /tmp/asadmin.pass enable-secure-admin\"").
        returns("Command enable-secure-admin executed successfully.")
      domain.provider.create
    end
    
    it "should be able to create a domain with enablesecureadmin set to false" do
      domain['enablesecureadmin'] = :false
      domain.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin --passwordfile /tmp/asadmin.pass create-domain --portbase 8000 --savelogin --savemasterpassword test\"").
        returns("Command create-domain executed successfully.")
      domain.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin --passwordfile /tmp/asadmin.pass start-domain test\"").
        returns("Command start-domain executed successfully.")
      domain.provider.create
    end
    
    it "should be able to create a domain with startoncreate and enablesecureadmin set to false" do
      domain['startoncreate'] = :false
      domain['enablesecureadmin'] = :false
      domain.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin --passwordfile /tmp/asadmin.pass create-domain --portbase 8000 --savelogin --savemasterpassword test\"").
        returns("Command create-domain executed successfully.")
      domain.provider.create
    end
    
    it "should be able to create a domain with a template file" do
      # Expect another exists? call to check template file
      File.expects(:exists?).with('/tmp/template.xml').returns(true).once
      # Set template param value
      domain['template'] = '/tmp/template.xml'
      # Check that provider executes as expected... 
      domain.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin --passwordfile /tmp/asadmin.pass create-domain --portbase 8000 --savelogin --savemasterpassword --template /tmp/template.xml test\"").
        returns("Command create-domain executed successfully.")
      domain.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin --passwordfile /tmp/asadmin.pass start-domain test\"").
        returns("Command start-domain executed successfully.")
      domain.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin --passwordfile /tmp/asadmin.pass enable-secure-admin\"").
        returns("Command enable-secure-admin executed successfully.")
      domain.provider.create
    end
  end
  
  describe "when destroying a resource" do
    it "should be able to destroy a domain" do
      domain.provider.set(:ensure => :absent)
      domain.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin --passwordfile /tmp/asadmin.pass delete-domain test\"").
        returns("Command delete-domain executed successfully.")
      domain.provider.destroy
    end
  end
end
