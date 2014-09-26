require 'spec_helper'

describe Puppet::Type.type(:cluster_node) do

  before :each do
    described_class.stubs(:defaultprovider).returns providerclass
  end

  let :providerclass do
    described_class.provide(:fake_cluster_node_provider) { mk_resource_methods }
  end

  it "should have :nodename as it's namevar" do
    described_class.key_attributes.should == [:nodename]
  end

  describe "when validating attributes" do
    [:nodename, :host, :sshport, :sshuser, :sshkeyfile, :install, :asadminuser, :passwordfile, :dashost, :dasport, :user].each do |param|
      it "should have a #{param} parameter" do
        described_class.attrtype(param).should == :param
      end
    end
  end
  
  describe "when validating values" do  
    describe "for nodename" do
      it "should support an alphanumerical name" do
        described_class.new(:nodename => 'test', :ensure => :present, :host => 'host')[:nodename].should == 'test'
      end
      
      it "should not support spaces" do
        expect { described_class.new(:nodename => 'node name', :ensure => :present, :host => 'host') }.to raise_error(Puppet::Error, /node name is not a valid node name/)
      end
    end
    
    describe "for ensure" do
      it "should support present" do
        described_class.new(:nodename => 'test', :ensure => 'present', :host => 'host')[:ensure].should == :present
      end

      it "should support absent" do
        described_class.new(:nodename => 'test', :ensure => 'absent', :host => 'host')[:ensure].should == :absent
      end

      it "should not support other values" do
        expect { described_class.new(:nodename => 'test', :ensure => 'foo', :host => 'host') }.to raise_error(Puppet::Error, /Invalid value "foo"/)
      end

      it "should not have a default value" do
        described_class.new(:nodename => 'test', :host => 'host')[:ensure].should == nil
      end
    end
      
    describe "for host" do
      it "should support a value" do
        described_class.new(:nodename => 'test', :host => 'host', :ensure => 'present')[:host].should == 'host'
      end
    end
    
    describe "for sshport" do
      it "should support a numerical value" do
        described_class.new(:nodename => 'test', :sshport => '2222', :ensure => :present, :host => 'host')[:sshport].should == 2222
      end

      it "should have a default value of 22" do
        described_class.new(:nodename => 'test', :ensure => :present, :host => 'host')[:sshport].should == 22
      end

      it "should not support a non-numeric value" do
        expect { described_class.new(:nodename => 'test', :sshport => 'a', :ensure => :present, :host => 'host') }.to raise_error(Puppet::Error, /a is not a valid SSH port./)
      end
    end
    
    describe "for sshuser" do
      it "should support an alpha name" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:nodename => 'test', :sshuser => 'glassfish', :ensure => :present, :host => 'host')[:sshuser].should == 'glassfish'
      end

      it "should support underscores" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:nodename => 'test', :sshuser => 'glassfish_user', :ensure => :present, :host => 'host')[:sshuser].should == 'glassfish_user'
      end
   
      it "should support hyphens" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:nodename => 'test', :sshuser => 'glassfish-user', :ensure => :present, :host => 'host')[:sshuser].should == 'glassfish-user'
      end

      it "should not have a default value of admin" do
        described_class.new(:nodename => 'test', :ensure => :present, :host => 'host')[:sshuser].should == nil
      end

      it "should not support spaces" do
        Puppet.features.expects(:root?).returns(true).once
        expect { described_class.new(:nodename => 'test', :sshuser => 'glassfish user', :host => 'host') }.to raise_error(Puppet::Error, /glassfish user is not a valid ssh user name/)
      end
      
      it "should fail if not running as root" do
        Puppet.features.expects(:root?).returns(false).once
        expect { described_class.new(:nodename => 'test', :sshuser => 'glassfish', :host => 'host') }.to raise_error(Puppet::Error, /Only root can execute commands as other users/)
      end
    end
    
    describe "for sshkeyfile" do
      it "should support a valid file path" do
        File.expects(:exists?).with('/tmp/sshkey').returns(true).once
        described_class.new(:nodename => 'test', :sshkeyfile => '/tmp/sshkey', :host => 'host')[:sshkeyfile].should == '/tmp/sshkey'
      end

      it "should fail an invalid file path" do
        File.expects(:exists?).with('/tmp/nonexistent').returns(false).once
        expect { described_class.new(:nodename => 'test', :sshkeyfile => '/tmp/nonexistent', :host => 'host') }.to raise_error(Puppet::Error, /does not exist/)
      end
    end
    
    describe "for install" do
      it "should support true" do
        described_class.new(:nodename => 'test', :install => 'true', :ensure => :present, :host => 'host')[:install].should == :true
      end

      it "should support false" do
        described_class.new(:nodename => 'test', :install => 'false', :ensure => :present, :host => 'host')[:install].should == :false
      end

      it "should have a default value of false" do
        described_class.new(:nodename => 'test', :ensure => :present, :host => 'host')[:install].should == :false
      end

      it "should not support other values" do
        expect { described_class.new(:nodename => 'test', :install => 'foo', :ensure => :present, :host => 'host') }.to raise_error(Puppet::Error, /Invalid value "foo"/)
      end
    end
    
    describe "for dashost" do
      it "should support a value" do
        described_class.new(:nodename => 'test', :dashost => 'host', :ensure => 'present', :host => 'host')[:dashost].should == 'host'
      end
    end
    
    describe "for dasport" do
      it "should support a numerical value" do
        described_class.new(:nodename => 'test', :dasport => '8048', :ensure => :present, :host => 'host')[:dasport].should == 8048
      end

      it "should have a default value of 4848" do
        described_class.new(:nodename => 'test', :ensure => :present, :host => 'host')[:dasport].should == 4848
      end

      it "should not support shorter than 4 digits" do
        expect { described_class.new(:nodename => 'test', :dasport => '123', :ensure => :present, :host => 'host') }.to raise_error(Puppet::Error, /123 is not a valid das port./)
      end

      it "should not support longer than 5 digits" do
        expect { described_class.new(:nodename => 'test', :dasport => '123456', :ensure => :present, :host => 'host') }.to raise_error(Puppet::Error, /123456 is not a valid das port./)
      end

      it "should not support a non-numeric value" do
        expect { described_class.new(:nodename => 'test', :dasport => 'a', :ensure => :present, :host => 'host') }.to raise_error(Puppet::Error, /a is not a valid das port./)
      end
    end
    
    describe "for asadminuser" do
      it "should support an alpha name" do
        described_class.new(:nodename => 'test', :asadminuser => 'user', :ensure => :present, :host => 'host')[:asadminuser].should == 'user'
      end

      it "should support underscores" do
        described_class.new(:nodename => 'test', :asadminuser => 'admin_user', :ensure => :present, :host => 'host')[:asadminuser].should == 'admin_user'
      end
   
      it "should support hyphens" do
        described_class.new(:nodename => 'test', :asadminuser => 'admin-user', :ensure => :present, :host => 'host')[:asadminuser].should == 'admin-user'
      end

      it "should have a default value of admin" do
        described_class.new(:nodename => 'test', :ensure => :present, :host => 'host')[:asadminuser].should == 'admin'
      end

      it "should not support spaces" do
        expect { described_class.new(:nodename => 'test', :asadminuser => 'admin user', :host => 'host') }.to raise_error(Puppet::Error, /admin user is not a valid asadmin user name/)
      end
    end
    
    describe "for passwordfile" do
      it "should support a valid file path" do
        described_class.new(:nodename => 'test', :passwordfile => '/tmp/asadmin.pass', :host => 'host')[:passwordfile].should == '/tmp/asadmin.pass'
      end
    end
    
    describe "for user" do
      it "should support an alpha name" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:nodename => 'test', :user => 'glassfish', :ensure => :present, :host => 'host')[:user].should == 'glassfish'
      end

      it "should support underscores" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:nodename => 'test', :user => 'glassfish_user', :ensure => :present, :host => 'host')[:user].should == 'glassfish_user'
      end
   
      it "should support hyphens" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:nodename => 'test', :user => 'glassfish-user', :ensure => :present, :host => 'host')[:user].should == 'glassfish-user'
      end

      it "should not have a default value of admin" do
        described_class.new(:nodename => 'test', :ensure => :present, :host => 'host')[:user].should == nil
      end

      it "should not support spaces" do
        Puppet.features.expects(:root?).returns(true).once
        expect { described_class.new(:nodename => 'test', :user => 'glassfish user', :host => 'host') }.to raise_error(Puppet::Error, /glassfish user is not a valid user name/)
      end
      
      it "should fail if not running as root" do
        Puppet.features.expects(:root?).returns(false).once
        expect { described_class.new(:nodename => 'test', :user => 'glassfish', :host => 'host') }.to raise_error(Puppet::Error, /Only root can execute commands as other users/)
      end
    end
  end  
  
  describe "when autorequiring" do    
    describe "user autorequire" do
      let :cluster_node do
        described_class.new(
          :nodename => 'test',
          :host     => 'host',
          :dasport  => '8048',
          :user     => 'glassfish'
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
        catalog.add_resource cluster_node
        cluster_node.autorequire.should be_empty
      end
  
      it "should autorequire a matching user" do
        catalog.add_resource cluster_node
        catalog.add_resource user
        reqs = cluster_node.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == user.ref
        reqs[0].target.ref.should == cluster_node.ref
      end
    end
    
    describe "domain autorequire" do
      let :cluster_node do
        described_class.new(
          :nodename => 'test',
          :host     => 'host',
          :dasport  => '8048',
          :user     => 'glassfish'
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
          :portbase     => '8000',
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
        catalog.add_resource cluster_node
        cluster_node.autorequire.should be_empty
      end
    
      it "should autorequire a matching domain" do
        # Create catalogue
        catalog.add_resource cluster_node
        # Additional expect for domain resource. 
        Puppet.features.expects(:root?).returns(true).once
        catalog.add_resource domain
        reqs = cluster_node.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == domain.ref
        reqs[0].target.ref.should == cluster_node.ref
      end
    end
  end
end
