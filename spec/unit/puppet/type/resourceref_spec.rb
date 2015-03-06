require 'spec_helper'

describe Puppet::Type.type(:resourceref) do

  before :each do
    described_class.stubs(:defaultprovider).returns providerclass
  end

  let :providerclass do
    described_class.provide(:fake_resourceref_provider) { mk_resource_methods }
  end

  it "should have :name as it's namevar" do
    described_class.key_attributes.should == [:name]
  end

  describe "when validating attributes" do
    [:name, :target, :portbase, :asadminuser, :passwordfile, :user].each do |param|
      it "should have a #{param} parameter" do
        described_class.attrtype(param).should == :param
      end
    end
  end
  
  describe "when validating values" do
    describe "for name" do
      it "should support an alphanumerical name" do
        described_class.new(:name => 'jmsresource', :ensure => :present)[:name].should == 'jmsresource'
      end

      it "should support underscores" do
        described_class.new(:name => 'jms_resource', :ensure => :present)[:name].should == 'jms_resource'
      end
   
      it "should support hyphens" do
        described_class.new(:name => 'jms-resource', :ensure => :present)[:name].should == 'jms-resource'
      end

      it "should support recommended naming scheme with jms/ prefix" do
        described_class.new(:name => 'jms/resource', :ensure => :present)[:name].should == 'jms/resource'
      end

      it "should not support spaces" do
        expect { described_class.new(:name => 'jms resource', :ensure => :present) }.to raise_error(Puppet::Error, /jms resource is not a valid reference resource name./)
      end
    end

    describe "for ensure" do
      it "should support present" do
        described_class.new(:name => 'jmsresource', :ensure => 'present')[:ensure].should == :present
      end

      it "should support absent" do
        described_class.new(:name => 'jmsresource', :ensure => 'absent')[:ensure].should == :absent
      end

      it "should not support other values" do
        expect { described_class.new(:name => 'jmsresource', :ensure => 'foo') }.to raise_error(Puppet::Error, /Invalid value "foo"/)
      end

      it "should not have a default value" do
        described_class.new(:name => 'jmsresource')[:ensure].should == nil
      end
    end
    
    describe "for target" do
      it "should have a default value of server" do
        described_class.new(:name => 'jmsresource', :portbase => '8000', :ensure => 'present')[:target].should == 'server'
      end
      
      it "should support a cluster target" do
        described_class.new(:name => 'jmsresource', :portbase => '8000', :target => 'cluster', :ensure => 'present')[:target].should == 'cluster'
      end
    end
    
    describe "for portbase" do
      it "should support a numerical value" do
        described_class.new(:name => 'jmsresource', :portbase => '8000', :ensure => 'present')[:portbase].should == 8000
      end

      it "should have a default value of 4800" do
        described_class.new(:name => 'jmsresource', :ensure => 'present')[:portbase].should == 4800
      end

      it "should not support shorter than 4 digits" do
        expect { described_class.new(:name => 'jmsresource', :portbase => '123', :ensure => 'present') }.to raise_error(Puppet::Error, /123 is not a valid portbase./)
      end

      it "should not support longer than 5 digits" do
        expect { described_class.new(:name => 'jmsresource', :portbase => '123456', :ensure => 'present') }.to raise_error(Puppet::Error, /123456 is not a valid portbase./)
      end

      it "should not support a non-numeric value" do
        expect { described_class.new(:name => 'jmsresource', :portbase => 'a', :ensure => 'present') }.to raise_error(Puppet::Error, /a is not a valid portbase./)
      end
    end

    describe "for asadminuser" do
      it "should support an alpha name" do
        described_class.new(:name => 'jmsresource', :asadminuser => 'user', :ensure => 'present')[:asadminuser].should == 'user'
      end

      it "should support underscores" do
        described_class.new(:name => 'jmsresource', :asadminuser => 'admin_user', :ensure => 'present')[:asadminuser].should == 'admin_user'
      end
   
      it "should support hyphens" do
        described_class.new(:name => 'jmsresource', :asadminuser => 'admin-user', :ensure => 'present')[:asadminuser].should == 'admin-user'
      end

      it "should have a default value of admin" do
        described_class.new(:name => 'jmsresource', :ensure => 'present')[:asadminuser].should == 'admin'
      end

      it "should not support spaces" do
        expect { described_class.new(:name => 'jmsresource', :asadminuser => 'admin user') }.to raise_error(Puppet::Error, /admin user is not a valid asadmin user name/)
      end
    end
    
    describe "for user" do
      it "should support an alpha name" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:name => 'jmsresource', :user => 'glassfish', :ensure => 'present')[:user].should == 'glassfish'
      end

      it "should support underscores" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:name => 'jmsresource', :user => 'glassfish_user', :ensure => 'present')[:user].should == 'glassfish_user'
      end
   
      it "should support hyphens" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:name => 'jmsresource', :user => 'glassfish-user', :ensure => 'present')[:user].should == 'glassfish-user'
      end

      it "should not have a default value of admin" do
        described_class.new(:name => 'jmsresource', :ensure => 'present')[:user].should == nil
      end

      it "should not support spaces" do
        Puppet.features.expects(:root?).returns(true).once
        expect { described_class.new(:name => 'jmsresource', :user => 'glassfish user') }.to raise_error(Puppet::Error, /glassfish user is not a valid user name/)
      end
      
      it "should fail if not running as root" do
        Puppet.features.expects(:root?).returns(false).once
        expect { described_class.new(:name => 'jmsresource', :user => 'glassfish') }.to raise_error(Puppet::Error, /Only root can execute commands as other users/)
      end
    end
    
    describe "for passwordfile" do
      it "should support a valid file path" do
        File.expects(:exists?).with('/tmp/asadmin.pass').returns(true).once
        described_class.new(:name => 'jmsresource', :passwordfile => '/tmp/asadmin.pass')[:passwordfile].should == '/tmp/asadmin.pass'
      end

      it "should fail an invalid file path" do
        File.expects(:exists?).with('/tmp/nonexistent').returns(false).once
        expect { described_class.new(:name => 'jmsresource', :passwordfile => '/tmp/nonexistent') }.to raise_error(Puppet::Error, /does not exist/)
      end
    end
  end
  
  describe "when autorequiring" do     
    describe "user autorequire" do
      let :resourceref do
        described_class.new(
          :name   => 'test',
          :target => 'cluster',
          :user   => 'glassfish'
        )
      end
      
      # Need to stub user type and provider.
      let :userprovider do
        Puppet::Type.type(:user).provide(:fake_user_provider) { mk_resource_methods }
      end
      
      let :user do
        Puppet::Type.type(:user).new(
          :name   => 'glassfish',
          :ensure => 'present'
        )
      end
      
      let :catalog do
        Puppet::Resource::Catalog.new
      end
  
      # Stub the user type, and expect File.exists? and Puppet.features.root?
      before :each do
        Puppet::Type.type(:user).stubs(:defaultprovider).returns userprovider
        Puppet.features.expects(:root?).returns(true).once
      end
      
      it "should not autorequire a user when no matching user can be found" do
        catalog.add_resource resourceref
        resourceref.autorequire.should be_empty
      end
  
      it "should autorequire a matching user" do
        catalog.add_resource resourceref
        catalog.add_resource user
        reqs = resourceref.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == user.ref
        reqs[0].target.ref.should == resourceref.ref
      end
    end
    
    describe "domain autorequire" do
      let :resourceref do
        described_class.new(
          :name   => 'test',
          :target => 'cluster',
          :user   => 'glassfish'
        )
      end
      
      # Need to stub user type and provider.
      let :domainprovider do
        Puppet::Type.type(:domain).provide(:fake_domain_provider) { mk_resource_methods }
      end
      
      let :domain do
        Puppet::Type.type(:domain).new(
          :domainname   => 'test',
          :ensure       => 'present',
          :passwordfile => '/tmp/password.file',
          :user         => 'glassfish'
        )
      end
      
      let :catalog do
        Puppet::Resource::Catalog.new
      end
    
      # Stub the domain type, and expect File.exists? and Puppet.features.root?
      before :each do
        Puppet::Type.type(:domain).stubs(:defaultprovider).returns domainprovider
        Puppet.features.expects(:root?).returns(true).once
      end
      
      it "should not autorequire a domain when no matching domain can be found" do
        catalog.add_resource resourceref
        resourceref.autorequire.should be_empty
      end
    
      it "should autorequire a matching domain" do
        # Expects for domain resource
        Puppet.features.expects(:root?).returns(true).once
        # Create catalogue
        catalog.add_resource resourceref
        catalog.add_resource domain
        reqs = resourceref.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == domain.ref
        reqs[0].target.ref.should == resourceref.ref
      end
    end

    describe "resource autorequire" do
      let :resourceref do
        described_class.new(
          :name   => 'jdbc/connectionPool',
          :target => 'cluster',
          :user   => 'glassfish'
        )
      end
      
      # Need to stub jdbcresource provider.
      let :jdbcresourceprovider do
        Puppet::Type.type(:jdbcresource).provide(:fake_jdbcresource_provider) { mk_resource_methods }
      end
      
      let :jdbcresource do
        Puppet::Type.type(:jdbcresource).new(
          :name           => 'jdbc/connectionPool',
          :ensure         => 'present',
          :connectionpool => 'connectionPool',
          :user           => 'glassfish'
        )
      end
      
      let :catalog do
        Puppet::Resource::Catalog.new
      end
    
      # Stub the jdbcresource type, and expect File.exists? and Puppet.features.root?
      before :each do
        Puppet::Type.type(:jdbcresource).stubs(:defaultprovider).returns jdbcresourceprovider
        Puppet.features.expects(:root?).returns(true).once
      end
      
      it "should not autorequire a resource when no matching resource can be found" do
        catalog.add_resource resourceref
        resourceref.autorequire.should be_empty
      end
    
      it "should autorequire a matching resource" do
        # Expects for jdbcresource resource
        Puppet.features.expects(:root?).returns(true).once
        # Create catalogue
        catalog.add_resource resourceref
        catalog.add_resource jdbcresource
        reqs = resourceref.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == jdbcresource.ref
        reqs[0].target.ref.should == resourceref.ref
      end
    end
  end
end
