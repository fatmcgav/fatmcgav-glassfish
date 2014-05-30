require 'spec_helper'

describe Puppet::Type.type(:cluster) do

  before :each do
    described_class.stubs(:defaultprovider).returns providerclass
  end

  let :providerclass do
    described_class.provide(:fake_clusterresource_provider) { mk_resource_methods }
  end

  it "should have :clustername as it's namevar" do
    described_class.key_attributes.should == [:clustername]
  end

  describe "when validating attributes" do
    [:clustername, :dashost, :dasport, :gmsenabled, :multicastport, :multicastaddress, 
      :asadminuser, :passwordfile, :user].each do |param|
      it "should have a #{param} parameter" do
        described_class.attrtype(param).should == :param
      end
    end
  end
  
  describe "when validating values" do  
    describe "for clustername" do
      it "should support an alphanumerical name" do
        described_class.new(:clustername => 'test', :ensure => :present)[:clustername].should == 'test'
      end
      
      it "should not support spaces" do
        expect { described_class.new(:clustername => 'cluster name', :ensure => :present) }.to raise_error(Puppet::Error, /cluster name is not a valid cluster name/)
      end
    end
    
    describe "for ensure" do
      it "should support present" do
        described_class.new(:clustername => 'test', :ensure => 'present')[:ensure].should == :present
      end

      it "should support absent" do
        described_class.new(:clustername => 'test', :ensure => 'absent')[:ensure].should == :absent
      end

      it "should not support other values" do
        expect { described_class.new(:clustername => 'test', :ensure => 'foo') }.to raise_error(Puppet::Error, /Invalid value "foo"/)
      end

      it "should not have a default value" do
        described_class.new(:clustername => 'test')[:ensure].should == nil
      end
    end
      
    describe "for dashost" do
      it "should support a value" do
        described_class.new(:clustername => 'test', :dashost => 'host', :ensure => 'present')[:dashost].should == 'host'
      end
    end
    
    describe "for dasport" do
      it "should support a numerical value" do
        described_class.new(:clustername => 'test', :dasport => '8048', :ensure => :present)[:dasport].should == 8048
      end

      it "should have a default value of 4848" do
        described_class.new(:clustername => 'test', :ensure => :present)[:dasport].should == 4848
      end

      it "should not support shorter than 4 digits" do
        expect { described_class.new(:clustername => 'test', :dasport => '123', :ensure => :present) }.to raise_error(Puppet::Error, /123 is not a valid das port./)
      end

      it "should not support longer than 5 digits" do
        expect { described_class.new(:clustername => 'test', :dasport => '123456', :ensure => :present) }.to raise_error(Puppet::Error, /123456 is not a valid das port./)
      end

      it "should not support a non-numeric value" do
        expect { described_class.new(:clustername => 'test', :dasport => 'a', :ensure => :present) }.to raise_error(Puppet::Error, /a is not a valid das port./)
      end
    end

    describe "for gmsenabled" do
      it "should support true" do
        described_class.new(:clustername => 'test', :dasport => '8048', :ensure => :present, :gmsenabled => 'true')[:gmsenabled].should == :true
      end

      it "should support false" do
        described_class.new(:clustername => 'test', :dasport => '8048', :ensure => :present, :gmsenabled => 'false')[:gmsenabled].should == :false
      end

      it "should have a default value of true" do
        described_class.new(:clustername => 'test', :dasport => '8048', :ensure => :present)[:gmsenabled].should == :true
      end

      it "should not support other values" do
        expect { described_class.new(:clustername => 'test', :dasport => '8048', :ensure => :present, :gmsenabled => 'foo') }.to raise_error(Puppet::Error, /Invalid value "foo"/)
      end
    end
    
    describe "for multicastport" do
      it "should support a numerical value" do
        described_class.new(:clustername => 'test', :dasport => '8048', :ensure => :present, :multicastport => '2500')[:multicastport].should == 2500
      end

      it "should not have a default value" do
        described_class.new(:clustername => 'test', :dasport => '8048', :ensure => :present)[:multicastport].should == nil
      end

      it "should not support a value smaller than 2048" do
        expect { described_class.new(:clustername => 'test', :dasport => '8048', :ensure => :present, :multicastport => '2000') }.to raise_error(Puppet::Error, /Multicast port must be between 2048 and 49151./)
      end

      it "should not support a value larger than 49151" do
        expect { described_class.new(:clustername => 'test', :dasport => '8048', :ensure => :present, :multicastport => '49200') }.to raise_error(Puppet::Error, /Multicast port must be between 2048 and 49151./)
      end

      it "should not support a non-numeric value" do
        expect { described_class.new(:clustername => 'test', :dasport => '8048', :ensure => :present, :multicastport => 'a') }.to raise_error(Puppet::Error, /Multicast port must be between 2048 and 49151./)
      end
    end
    
    describe "for multicastaddress" do
      it "should support a valid multicast address" do
        described_class.new(:clustername => 'test', :dasport => '8048', :ensure => :present, :multicastaddress => '228.9.1.1')[:multicastaddress].should == '228.9.1.1'
      end

      it "should not have a default value" do
        described_class.new(:clustername => 'test', :dasport => '8048', :ensure => :present)[:multicastaddress].should == nil
      end

      it "should not support an invalid IP Address" do
        expect { described_class.new(:clustername => 'test', :dasport => '8048', :ensure => :present, :multicastaddress => '228.9.1.a') }.to raise_error(Puppet::Error, /Invalid value for multicastaddress: 228.9.1.a/)
      end

      it "should not support a IP Address outside of the allowed range" do
        expect { described_class.new(:clustername => 'test', :dasport => '8048', :ensure => :present, :multicastaddress => '220.0.0.0') }.to raise_error(Puppet::Error, /Multicast address must be between 224.0.0.0 and 239.255.255.255./)
      end
    end
    
    describe "for asadminuser" do
      it "should support an alpha name" do
        described_class.new(:clustername => 'test', :asadminuser => 'user', :ensure => :present)[:asadminuser].should == 'user'
      end

      it "should support underscores" do
        described_class.new(:clustername => 'test', :asadminuser => 'admin_user', :ensure => :present)[:asadminuser].should == 'admin_user'
      end
   
      it "should support hyphens" do
        described_class.new(:clustername => 'test', :asadminuser => 'admin-user', :ensure => :present)[:asadminuser].should == 'admin-user'
      end

      it "should have a default value of admin" do
        described_class.new(:clustername => 'test', :ensure => :present)[:asadminuser].should == 'admin'
      end

      it "should not support spaces" do
        expect { described_class.new(:clustername => 'test', :asadminuser => 'admin user') }.to raise_error(Puppet::Error, /admin user is not a valid asadmin user name/)
      end
    end
    
    describe "for passwordfile" do
      it "should support a valid file path" do
        File.expects(:exists?).with('/tmp/asadmin.pass').returns(true).once
        described_class.new(:clustername => 'test', :passwordfile => '/tmp/asadmin.pass')[:passwordfile].should == '/tmp/asadmin.pass'
      end

      it "should fail an invalid file path" do
        File.expects(:exists?).with('/tmp/nonexistent').returns(false).once
        expect { described_class.new(:clustername => 'test', :passwordfile => '/tmp/nonexistent') }.to raise_error(Puppet::Error, /does not exist/)
      end
    end
    
    describe "for user" do
      it "should support an alpha name" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:clustername => 'test', :user => 'glassfish', :ensure => :present)[:user].should == 'glassfish'
      end

      it "should support underscores" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:clustername => 'test', :user => 'glassfish_user', :ensure => :present)[:user].should == 'glassfish_user'
      end
   
      it "should support hyphens" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:clustername => 'test', :user => 'glassfish-user', :ensure => :present)[:user].should == 'glassfish-user'
      end

      it "should not have a default value of admin" do
        described_class.new(:clustername => 'test', :ensure => :present)[:user].should == nil
      end

      it "should not support spaces" do
        Puppet.features.expects(:root?).returns(true).once
        expect { described_class.new(:clustername => 'test', :user => 'glassfish user') }.to raise_error(Puppet::Error, /glassfish user is not a valid user name/)
      end
      
      it "should fail if not running as root" do
        Puppet.features.expects(:root?).returns(false).once
        expect { described_class.new(:clustername => 'test', :user => 'glassfish') }.to raise_error(Puppet::Error, /Only root can execute commands as other users/)
      end
    end
  end  
  
  describe "when autorequiring" do    
    describe "user autorequire" do
      let :cluster do
        described_class.new(
          :clustername => 'test',
          :dasport     => '8048',
          :user        => 'glassfish'
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
        catalog.add_resource cluster
        cluster.autorequire.should be_empty
      end
  
      it "should autorequire a matching user" do
        catalog.add_resource cluster
        catalog.add_resource user
        reqs = cluster.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == user.ref
        reqs[0].target.ref.should == cluster.ref
      end
    end
    
    describe "domain autorequire" do
      let :cluster do
        described_class.new(
          :clustername => 'test',
          :dasport     => '8048',
          :user        => 'glassfish'
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
        catalog.add_resource cluster
        cluster.autorequire.should be_empty
      end
    
      it "should autorequire a matching domain" do
        # Create catalogue
        catalog.add_resource cluster
        # Additional expect for domain resource. 
        Puppet.features.expects(:root?).returns(true).once
        catalog.add_resource domain
        reqs = cluster.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == domain.ref
        reqs[0].target.ref.should == cluster.ref
      end
    end
  end
end
