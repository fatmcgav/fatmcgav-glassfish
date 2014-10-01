require 'spec_helper'

describe Puppet::Type.type(:application) do

  before :each do
    described_class.stubs(:defaultprovider).returns providerclass
  end

  let :providerclass do
    described_class.provide(:fake_application_provider) { mk_resource_methods }
  end

  it "should have :name as it's namevar" do
    described_class.key_attributes.should == [:name]
  end

  describe "when validating attributes" do
    [:name, :contextroot, :source, :portbase, :asadminuser, :passwordfile, :user].each do |param|
      it "should have a #{param} parameter" do
        described_class.attrtype(param).should == :param
      end
    end
  end

  describe "when validating values" do   
    describe "for name" do
      it "should support an alphanumerical name" do
        described_class.new(:name => 'application', :ensure => :present, :source => '/tmp/application.ear')[:name].should == 'application'
      end

      it "should support underscores" do
        described_class.new(:name => 'application_name', :ensure => :present, :source => '/tmp/application.ear')[:name].should == 'application_name'
      end
   
      it "should support hyphens" do
        described_class.new(:name => 'application-name', :ensure => :present, :source => '/tmp/application.ear')[:name].should == 'application-name'
      end

      it "should not support spaces" do
        expect { described_class.new(:name => 'application name', :ensure => :present) }.to raise_error(Puppet::Error, /application name is not a valid application name/)
      end
    end

    describe "for ensure" do
      it "should support present" do
        described_class.new(:name => 'application', :ensure => 'present', :source => '/tmp/application.ear')[:ensure].should == :present
      end

      it "should support absent" do
        described_class.new(:name => 'application', :ensure => 'absent', :source => '/tmp/application.ear')[:ensure].should == :absent
      end

      it "should not support other values" do
        expect { described_class.new(:name => 'application', :ensure => 'foo') }.to raise_error(Puppet::Error, /Invalid value "foo"/)
      end

      it "should not have a default value" do
        described_class.new(:name => 'application', :source => '/tmp/application.ear')[:ensure].should == nil
      end
    end

    describe "for contextroot" do
      it "should support a value" do
        described_class.new(:name => 'application', :contextroot => 'context', :ensure => 'present', :source => '/tmp/application.ear')[:contextroot].should == 'context'
      end
    end
    
    describe "for source" do
      it "should support a valid file path" do
        described_class.new(:name => 'application', :source => '/tmp/application.ear')[:source].should == '/tmp/application.ear'
      end
    end
    
    describe "for portbase" do
      it "should support a numerical value" do
        described_class.new(:name => 'application', :portbase => '8000', :ensure => :present, :source => '/tmp/application.ear')[:portbase].should == 8000
      end

      it "should have a default value of 4800" do
        described_class.new(:name => 'application', :ensure => :present, :source => '/tmp/application.ear')[:portbase].should == 4800
      end

      it "should not support shorter than 4 digits" do
        expect { described_class.new(:name => 'application', :portbase => '123', :ensure => :present) }.to raise_error(Puppet::Error, /123 is not a valid portbase./)
      end

      it "should not support longer than 5 digits" do
        expect { described_class.new(:name => 'application', :portbase => '123456', :ensure => :present) }.to raise_error(Puppet::Error, /123456 is not a valid portbase./)
      end

      it "should not support a non-numeric value" do
        expect { described_class.new(:name => 'application', :portbase => 'a', :ensure => :present) }.to raise_error(Puppet::Error, /a is not a valid portbase./)
      end
    end

    describe "for asadminuser" do
      it "should support an alpha name" do
        described_class.new(:name => 'application', :asadminuser => 'user', :ensure => :present, :source => '/tmp/application.ear')[:asadminuser].should == 'user'
      end

      it "should support underscores" do
        described_class.new(:name => 'application', :asadminuser => 'admin_user', :ensure => :present, :source => '/tmp/application.ear')[:asadminuser].should == 'admin_user'
      end
   
      it "should support hyphens" do
        described_class.new(:name => 'application', :asadminuser => 'admin-user', :ensure => :present, :source => '/tmp/application.ear')[:asadminuser].should == 'admin-user'
      end

      it "should have a default value of admin" do
        described_class.new(:name => 'application', :ensure => :present, :source => '/tmp/application.ear')[:asadminuser].should == 'admin'
      end

      it "should not support spaces" do
        expect { described_class.new(:name => 'application', :asadminuser => 'admin user') }.to raise_error(Puppet::Error, /admin user is not a valid asadmin user name/)
      end
    end

    describe "for passwordfile" do
      it "should support a valid file path" do
        File.expects(:exists?).with('/tmp/asadmin.pass').returns(true).once
        described_class.new(:name => 'application', :passwordfile => '/tmp/asadmin.pass', :source => '/tmp/application.ear')[:passwordfile].should == '/tmp/asadmin.pass'
      end

      it "should fail an invalid file path" do
        File.expects(:exists?).with('/tmp/nonexistent').returns(false).once
        expect { described_class.new(:name => 'application', :passwordfile => '/tmp/nonexistent') }.to raise_error(Puppet::Error, /does not exist/)
      end
    end

    describe "for user" do
      it "should support an alpha name" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:name => 'application', :user => 'glassfish', :ensure => :present, :source => '/tmp/application.ear')[:user].should == 'glassfish'
      end

      it "should support underscores" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:name => 'application', :user => 'glassfish_user', :ensure => :present, :source => '/tmp/application.ear')[:user].should == 'glassfish_user'
      end
   
      it "should support hyphens" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:name => 'application', :user => 'glassfish-user', :ensure => :present, :source => '/tmp/application.ear')[:user].should == 'glassfish-user'
      end

      it "should not have a default value of admin" do
        described_class.new(:name => 'application', :ensure => :present, :source => '/tmp/application.ear')[:user].should == nil
      end

      it "should not support spaces" do
        Puppet.features.expects(:root?).returns(true).once
        expect { described_class.new(:name => 'application', :user => 'glassfish user') }.to raise_error(Puppet::Error, /glassfish user is not a valid user name/)
      end
      
      it "should fail if not running as root" do
        Puppet.features.expects(:root?).returns(false).once
        expect { described_class.new(:name => 'application', :user => 'glassfish') }.to raise_error(Puppet::Error, /Only root can execute commands as other users/)
      end
    end
    
    describe "validate" do
      it "should not fail with a valid source" do
        expect { described_class.new(:name => 'application', :source => '/tmp/application.ear') }.not_to raise_error
      end
      it "should fail with a missing source" do
        expect { described_class.new(:name => 'application') }.to raise_error(Puppet::Error, /Source is required./)
      end
      it "should not fail with a missing source and ensure => absent" do
        expect { described_class.new(:name => 'application', :ensure => :absent) }.not_to raise_error
      end
    end
  end  
    
  describe "when autorequiring" do    
    describe "user autorequire" do
      let :application do
        described_class.new(
          :name         => 'test',
          :source       => '/tmp/application.ear',
          :user         => 'glassfish'
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
        catalog.add_resource application
        application.autorequire.should be_empty
      end
  
      it "should autorequire a matching user" do
        catalog.add_resource application
        catalog.add_resource user
        reqs = application.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == user.ref
        reqs[0].target.ref.should == application.ref
      end
    end
  
    describe "file autorequire" do
      let :application do
        described_class.new(
          :name         => 'test',
          :source       => '/tmp/application.ear',
          :user         => 'glassfish'
        )
      end
      
      # Need to stub user type and provider.
      let :fileprovider do
        Puppet::Type.type(:file).provide(:fake_file_provider) { mk_resource_methods }
      end
      
      let :file do
        Puppet::Type.type(:file).new(
          :name   => '/tmp/application.ear',
          :ensure => 'present'
        )
      end
      
      let :catalog do
        Puppet::Resource::Catalog.new
      end
    
      # Stub the user type, and expect File.exists? and Puppet.features.root?
      before :each do
        Puppet::Type.type(:file).stubs(:defaultprovider).returns fileprovider
        Puppet.features.expects(:root?).returns(true).once
      end
      
      it "should not autorequire a file when no matching file can be found" do
        catalog.add_resource application
        application.autorequire.should be_empty
      end
    
      it "should autorequire a matching file" do
        catalog.add_resource application
        catalog.add_resource file
        reqs = application.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == file.ref
        reqs[0].target.ref.should == application.ref
      end
    end
    
    describe "domain autorequire" do
      let :application do
        described_class.new(
          :name         => 'test',
          :source       => '/tmp/application.ear',
          :user         => 'glassfish'
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
        catalog.add_resource application
        application.autorequire.should be_empty
      end
    
      it "should autorequire a matching domain" do
        # Create catalogue
        catalog.add_resource application
        # Additional expect for domain resource. 
        Puppet.features.expects(:root?).returns(true).once
        catalog.add_resource domain
        reqs = application.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == domain.ref
        reqs[0].target.ref.should == application.ref
      end
    end
  end
end
