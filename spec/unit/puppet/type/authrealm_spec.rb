require 'spec_helper'

describe Puppet::Type.type(:authrealm) do

  before :each do
    described_class.stubs(:defaultprovider).returns providerclass
  end

  let :providerclass do
    described_class.provide(:fake_authrealm_provider) { mk_resource_methods }
  end

  it "should have :name as it's namevar" do
    described_class.key_attributes.should == [:name]
  end

  describe "when validating attributes" do
    [:name, :classname, :properties, :isdefault, :portbase, :asadminuser, :passwordfile, :user].each do |param|
      it "should have a #{param} parameter" do
        described_class.attrtype(param).should == :param
      end
    end
  end
  
  describe "when validating values" do
    describe "for name" do
      it "should support an alphanumerical name" do
        described_class.new(:name => 'realm', :ensure => :present, :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm')[:name].should == 'realm'
      end

      it "should support underscores" do
        described_class.new(:name => 'realm_name', :ensure => :present, :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm')[:name].should == 'realm_name'
      end
   
      it "should support hyphens" do
        described_class.new(:name => 'realm-name', :ensure => :present, :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm')[:name].should == 'realm-name'
      end

      it "should not support spaces" do
        expect { described_class.new(:name => 'realm name', :ensure => :present, :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm') }.to raise_error(Puppet::Error, /realm name is not a valid realm name/)
      end
    end

    describe "for ensure" do
      it "should support present" do
        described_class.new(:name => 'realm', :ensure => 'present', :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm')[:ensure].should == :present
      end

      it "should support absent" do
        described_class.new(:name => 'realm', :ensure => 'absent', :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm')[:ensure].should == :absent
      end

      it "should not support other values" do
        expect { described_class.new(:name => 'realm', :ensure => 'foo') }.to raise_error(Puppet::Error, /Invalid value "foo"/)
      end

      it "should not have a default value" do
        described_class.new(:name => 'realm', :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm')[:ensure].should == nil
      end
    end

    describe "for classname" do 
      it "should support a valid class name" do
        described_class.new(:name => 'realm', :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm')[:classname].should == 'com.sun.enterprise.security.auth.realm.file.FileRealm'
      end
      
      it "should fail an invalid class name" do
        expect { described_class.new(:name => 'realm', :classname => 'com.sun.enterprise.security.auth.realm.file.') }.to raise_error(Puppet::Error, /is not a valid Java fully qualified type name/)
      end
    end
    
    describe "for properties" do
      #TODO: Add properties tests
    end
    
    describe "for isdefault" do
      it "should support true" do
        described_class.new(:name => 'realm', :isdefault => 'true', :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm')[:isdefault].should == :true
      end

      it "should support false" do
        described_class.new(:name => 'realm', :isdefault => 'false', :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm')[:isdefault].should == :false
      end

      it "should have a default value of false" do
        described_class.new(:name => 'realm', :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm')[:isdefault].should == :false
      end

      it "should not support other values" do
        expect { described_class.new(:name => 'realm', :isdefault => 'foo') }.to raise_error(Puppet::Error, /Invalid value "foo"/)
      end
    end
    
    describe "for portbase" do
      it "should support a numerical value" do
        described_class.new(:name => 'realm', :portbase => '8000', :ensure => :present, :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm')[:portbase].should == 8000
      end

      it "should have a default value of 4800" do
        described_class.new(:name => 'realm', :ensure => :present, :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm')[:portbase].should == 4800
      end

      it "should not support shorter than 4 digits" do
        expect { described_class.new(:name => 'realm', :portbase => '123', :ensure => :present) }.to raise_error(Puppet::Error, /123 is not a valid portbase./)
      end

      it "should not support longer than 5 digits" do
        expect { described_class.new(:name => 'realm', :portbase => '123456', :ensure => :present) }.to raise_error(Puppet::Error, /123456 is not a valid portbase./)
      end

      it "should not support a non-numeric value" do
        expect { described_class.new(:name => 'realm', :portbase => 'a', :ensure => :present) }.to raise_error(Puppet::Error, /a is not a valid portbase./)
      end
    end

    describe "for asadminuser" do
      it "should support an alpha name" do
        described_class.new(:name => 'realm', :asadminuser => 'user', :ensure => :present, :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm')[:asadminuser].should == 'user'
      end

      it "should support underscores" do
        described_class.new(:name => 'realm', :asadminuser => 'admin_user', :ensure => :present, :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm')[:asadminuser].should == 'admin_user'
      end
   
      it "should support hyphens" do
        described_class.new(:name => 'realm', :asadminuser => 'admin-user', :ensure => :present, :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm')[:asadminuser].should == 'admin-user'
      end

      it "should have a default value of admin" do
        described_class.new(:name => 'realm', :ensure => :present, :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm')[:asadminuser].should == 'admin'
      end

      it "should not support spaces" do
        expect { described_class.new(:name => 'realm', :asadminuser => 'admin user', :ensure => :present) }.to raise_error(Puppet::Error, /admin user is not a valid asadmin user name/)
      end
    end

    describe "for passwordfile" do
      it "should support a valid file path" do
        File.expects(:exists?).with('/tmp/asadmin.pass').returns(true).once
        described_class.new(:name => 'realm', :passwordfile => '/tmp/asadmin.pass', :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm')[:passwordfile].should == '/tmp/asadmin.pass'
      end

      it "should fail an invalid file path" do
        File.expects(:exists?).with('/tmp/nonexistent').returns(false).once
        expect { described_class.new(:name => 'realm', :passwordfile => '/tmp/nonexistent') }.to raise_error(Puppet::Error, /does not exist/)
      end
    end

    describe "for user" do
      it "should support an alpha name" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:name => 'realm', :user => 'glassfish', :ensure => :present, :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm')[:user].should == 'glassfish'
      end

      it "should support underscores" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:name => 'realm', :user => 'glassfish_user', :ensure => :present, :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm')[:user].should == 'glassfish_user'
      end
   
      it "should support hyphens" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:name => 'realm', :user => 'glassfish-user', :ensure => :present, :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm')[:user].should == 'glassfish-user'
      end

      it "should not have a default value of admin" do
        described_class.new(:name => 'realm', :ensure => :present, :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm')[:user].should == nil
      end

      it "should not support spaces" do
        Puppet.features.expects(:root?).returns(true).once
        expect { described_class.new(:name => 'realm', :user => 'glassfish user') }.to raise_error(Puppet::Error, /glassfish user is not a valid user name/)
      end
      
      it "should fail if not running as root" do
        Puppet.features.expects(:root?).returns(false).once
        expect { described_class.new(:name => 'realm', :user => 'glassfish') }.to raise_error(Puppet::Error, /Only root can execute commands as other users/)
      end
    end
    
    describe "validate" do
      it "should not fail with a valid classname" do
        expect { described_class.new(:name => 'realm', :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm') }.not_to raise_error
      end
      it "should fail with a missing classname" do
        expect { described_class.new(:name => 'realm') }.to raise_error(Puppet::Error, /Classname is required./)
      end
    end
  end
  
  describe "when autorequiring" do    
    describe "user autorequire" do
      let :realm do
        described_class.new(
          :name      => 'test',
          :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm',
          :user      => 'glassfish'
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
        #File.expects(:exists?).with('/tmp/application.ear').returns(true).once
        Puppet.features.expects(:root?).returns(true).once
      end
      
      it "should not autorequire a user when no matching user can be found" do
        catalog.add_resource realm
        realm.autorequire.should be_empty
      end
  
      it "should autorequire a matching user" do
        catalog.add_resource realm
        catalog.add_resource user
        reqs = realm.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == user.ref
        reqs[0].target.ref.should == realm.ref
      end
    end
    
    describe "domain autorequire" do
      let :realm do
        described_class.new(
          :name      => 'test',
          :classname => 'com.sun.enterprise.security.auth.realm.file.FileRealm', 
          :user      => 'glassfish'
        )
      end
      
      # Need to stub domain type and provider.
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
        #File.expects(:exists?).with('/tmp/application.ear').returns(true).once
        Puppet.features.expects(:root?).returns(true).once
      end
      
      it "should not autorequire a domain when no matching domain can be found" do
        catalog.add_resource realm
        realm.autorequire.should be_empty
      end
    
      it "should autorequire a matching domain" do
        # Create catalogue
        catalog.add_resource realm
        # Additional expect for domain resource. 
        Puppet.features.expects(:root?).returns(true).once
        catalog.add_resource domain
        reqs = realm.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == domain.ref
        reqs[0].target.ref.should == realm.ref
      end
    end
  end
end
