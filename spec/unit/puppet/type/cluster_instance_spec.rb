require 'spec_helper'

describe Puppet::Type.type(:cluster_instance) do

  before :each do
    described_class.stubs(:defaultprovider).returns providerclass
  end

  let :providerclass do
    described_class.provide(:fake_cluster_instance_provider) { mk_resource_methods }
  end

  it "should have :instancename as it's namevar" do
    described_class.key_attributes.should == [:instancename]
  end

  describe "when validating attributes" do
    [:instancename, :nodename, :cluster, :portbase, :asadminuser, :passwordfile, :dashost, :dasport, :user].each do |param|
      it "should have a #{param} parameter" do
        described_class.attrtype(param).should == :param
      end
    end
  end
  
  describe "when validating values" do
    describe "for instancename" do
      it "should support an alphanumerical name" do
        described_class.new(:instancename => 'test', :ensure => :present, :nodename => 'node', :cluster => 'cluster')[:instancename].should == 'test'
      end
      
      it "should not support spaces" do
        expect { described_class.new(:instancename => 'instance name', :ensure => :present, :nodename => 'node', :cluster => 'cluster') }.to raise_error(Puppet::Error, /instance name is not a valid instance name/)
      end
    end
    
    describe "for ensure" do
      it "should support present" do
        described_class.new(:instancename => 'test', :ensure => 'present', :nodename => 'node', :cluster => 'cluster')[:ensure].should == :present
      end

      it "should support absent" do
        described_class.new(:instancename => 'test', :ensure => 'absent', :nodename => 'node', :cluster => 'cluster')[:ensure].should == :absent
      end

      it "should not support other values" do
        expect { described_class.new(:instancename => 'test', :ensure => 'foo', :nodename => 'node', :cluster => 'cluster') }.to raise_error(Puppet::Error, /Invalid value "foo"/)
      end

      it "should not have a default value" do
        described_class.new(:instancename => 'test', :nodename => 'node', :cluster => 'cluster')[:ensure].should == nil
      end
    end
      
    describe "for nodename" do
      it "should support a valid value" do
        described_class.new(:instancename => 'test', :nodename => 'node', :ensure => 'present', :cluster => 'cluster')[:nodename].should == 'node'
      end
      it "should not support an invalid value" do
        expect { described_class.new(:instancename => 'test', :nodename => 'node name', :ensure => 'present', :cluster => 'cluster')  }.to raise_error(Puppet::Error, /node name is not a valid node name./)
      end
    end
    
    describe "for cluster" do
      it "should support a valid value" do
        described_class.new(:instancename => 'test', :cluster => 'cluster', :ensure => 'present', :nodename => 'node')[:cluster].should == 'cluster'
      end
      it "should not support an invalid value" do
        expect { described_class.new(:instancename => 'test', :cluster => 'cluster name', :ensure => 'present', :nodename => 'node')  }.to raise_error(Puppet::Error, /cluster name is not a valid cluster name./)
      end
    end
    
    describe "for portbase" do
      it "should support a numerical value" do
        described_class.new(:instancename => 'test', :portbase => '29000', :ensure => :present, :nodename => 'node', :cluster => 'cluster')[:portbase].should == 29000
      end

      it "should have a default value of 28000" do
        described_class.new(:instancename => 'test', :ensure => :present, :nodename => 'node', :cluster => 'cluster')[:portbase].should == 28000
      end

      it "should not support shorter than 4 digits" do
        expect { described_class.new(:instancename => 'test', :portbase => '123', :ensure => :present, :nodename => 'node', :cluster => 'cluster') }.to raise_error(Puppet::Error, /123 is not a valid portbase./)
      end

      it "should not support longer than 5 digits" do
        expect { described_class.new(:instancename => 'test', :portbase => '123456', :ensure => :present, :nodename => 'node', :cluster => 'cluster') }.to raise_error(Puppet::Error, /123456 is not a valid portbase./)
      end
      
      it "should not support a non-numeric value" do
        expect { described_class.new(:instancename => 'test', :portbase => 'a', :ensure => :present, :nodename => 'node', :cluster => 'cluster') }.to raise_error(Puppet::Error, /a is not a valid portbase./)
      end
    end
    
    describe "for dashost" do
      it "should support a value" do
        described_class.new(:instancename => 'test', :dashost => 'host', :ensure => 'present', :nodename => 'node', :cluster => 'cluster')[:dashost].should == 'host'
      end
    end
    
    describe "for dasport" do
      it "should support a numerical value" do
        described_class.new(:instancename => 'test', :dasport => '8048', :ensure => :present, :nodename => 'node', :cluster => 'cluster')[:dasport].should == 8048
      end

      it "should have a default value of 4848" do
        described_class.new(:instancename => 'test', :ensure => :present, :nodename => 'node', :cluster => 'cluster')[:dasport].should == 4848
      end

      it "should not support shorter than 4 digits" do
        expect { described_class.new(:instancename => 'test', :dasport => '123', :ensure => :present, :nodename => 'node', :cluster => 'cluster') }.to raise_error(Puppet::Error, /123 is not a valid das port./)
      end

      it "should not support longer than 5 digits" do
        expect { described_class.new(:instancename => 'test', :dasport => '123456', :ensure => :present, :nodename => 'node', :cluster => 'cluster') }.to raise_error(Puppet::Error, /123456 is not a valid das port./)
      end

      it "should not support a non-numeric value" do
        expect { described_class.new(:instancename => 'test', :dasport => 'a', :ensure => :present, :nodename => 'node', :cluster => 'cluster') }.to raise_error(Puppet::Error, /a is not a valid das port./)
      end
    end
    
    describe "for asadminuser" do
      it "should support an alpha name" do
        described_class.new(:instancename => 'test', :asadminuser => 'user', :ensure => :present, :nodename => 'node', :cluster => 'cluster')[:asadminuser].should == 'user'
      end

      it "should support underscores" do
        described_class.new(:instancename => 'test', :asadminuser => 'admin_user', :ensure => :present, :nodename => 'node', :cluster => 'cluster')[:asadminuser].should == 'admin_user'
      end
   
      it "should support hyphens" do
        described_class.new(:instancename => 'test', :asadminuser => 'admin-user', :ensure => :present, :nodename => 'node', :cluster => 'cluster')[:asadminuser].should == 'admin-user'
      end

      it "should have a default value of admin" do
        described_class.new(:instancename => 'test', :ensure => :present, :nodename => 'node', :cluster => 'cluster')[:asadminuser].should == 'admin'
      end

      it "should not support spaces" do
        expect { described_class.new(:instancename => 'test', :asadminuser => 'admin user', :nodename => 'node', :cluster => 'cluster') }.to raise_error(Puppet::Error, /admin user is not a valid asadmin user name/)
      end
    end
    
    describe "for passwordfile" do
      it "should support a valid file path" do
        File.expects(:exists?).with('/tmp/asadmin.pass').returns(true).once
        described_class.new(:instancename => 'test', :passwordfile => '/tmp/asadmin.pass', :nodename => 'node', :cluster => 'cluster')[:passwordfile].should == '/tmp/asadmin.pass'
      end

      it "should fail an invalid file path" do
        File.expects(:exists?).with('/tmp/nonexistent').returns(false).once
        expect { described_class.new(:instancename => 'test', :passwordfile => '/tmp/nonexistent', :nodename => 'node', :cluster => 'cluster') }.to raise_error(Puppet::Error, /does not exist/)
      end
    end
    
    describe "for user" do
      it "should support an alpha name" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:instancename => 'test', :user => 'glassfish', :ensure => :present, :nodename => 'node', :cluster => 'cluster')[:user].should == 'glassfish'
      end

      it "should support underscores" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:instancename => 'test', :user => 'glassfish_user', :ensure => :present, :nodename => 'node', :cluster => 'cluster')[:user].should == 'glassfish_user'
      end
   
      it "should support hyphens" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:instancename => 'test', :user => 'glassfish-user', :ensure => :present, :nodename => 'node', :cluster => 'cluster')[:user].should == 'glassfish-user'
      end

      it "should not have a default value of admin" do
        described_class.new(:instancename => 'test', :ensure => :present, :nodename => 'node', :cluster => 'cluster')[:user].should == nil
      end

      it "should not support spaces" do
        Puppet.features.expects(:root?).returns(true).once
        expect { described_class.new(:instancename => 'test', :user => 'glassfish user', :nodename => 'node', :cluster => 'cluster') }.to raise_error(Puppet::Error, /glassfish user is not a valid user name/)
      end
      
      it "should fail if not running as root" do
        Puppet.features.expects(:root?).returns(false).once
        expect { described_class.new(:instancename => 'test', :user => 'glassfish', :nodename => 'node', :cluster => 'cluster') }.to raise_error(Puppet::Error, /Only root can execute commands as other users/)
      end
    end
  end  
  
  describe "when autorequiring" do  
    describe "user autorequire" do
      let :cluster_instance do
        described_class.new(
          :instancename => 'test',
          :nodename     => 'node',
          :cluster      => 'cluster',
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
        catalog.add_resource cluster_instance
        cluster_instance.autorequire.should be_empty
      end
  
      it "should autorequire a matching user" do
        catalog.add_resource cluster_instance
        catalog.add_resource user
        reqs = cluster_instance.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == user.ref
        reqs[0].target.ref.should == cluster_instance.ref
      end
    end
    
    describe "node autorequire" do
      let :cluster_instance do
        described_class.new(
          :instancename => 'test',
          :nodename     => 'node',
          :cluster      => 'cluster',
          :user         => 'glassfish'
        )
      end
      
      # Need to stub cluster_node type and provider.
      let :clusternodeprovider do
        Puppet::Type.type(:cluster_node).provide(:fake_cluster_node_provider) { mk_resource_methods }
      end
      
      let :cluster_node do
        Puppet::Type.type(:cluster_node).new(
          :nodename => 'node',
          :host     => 'host',
          :ensure   => 'present'
        )
      end
      
      let :catalog do
        Puppet::Resource::Catalog.new
      end
  
      # Stub the cluster_node type, and expect Puppet.features.root?
      before :each do
        Puppet::Type.type(:cluster_node).stubs(:defaultprovider).returns clusternodeprovider
        Puppet.features.expects(:root?).returns(true).once
      end
      
      it "should not autorequire a user when no matching cluster node can be found" do
        catalog.add_resource cluster_instance
        cluster_instance.autorequire.should be_empty
      end
  
      it "should autorequire a matching cluster node" do
        catalog.add_resource cluster_instance
        catalog.add_resource cluster_node
        reqs = cluster_instance.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == cluster_node.ref
        reqs[0].target.ref.should == cluster_instance.ref
      end
    end
    
    describe "cluster autorequire" do
      let :cluster_instance do
        described_class.new(
          :instancename => 'test',
          :nodename     => 'node',
          :cluster      => 'cluster',
          :user         => 'glassfish'
        )
      end
      
      # Need to stub node type and provider.
      let :clusterprovider do
        Puppet::Type.type(:cluster).provide(:fake_cluster_provider) { mk_resource_methods }
      end
      
      let :cluster do
        Puppet::Type.type(:cluster).new(
          :clustername => 'cluster',
          :ensure      => 'present'
        )
      end
      
      let :catalog do
        Puppet::Resource::Catalog.new
      end
  
      # Stub the node type, and expect Puppet.features.root?
      before :each do
        Puppet::Type.type(:cluster).stubs(:defaultprovider).returns clusterprovider
        Puppet.features.expects(:root?).returns(true).once
      end
      
      it "should not autorequire a user when no matching cluster node can be found" do
        catalog.add_resource cluster_instance
        cluster_instance.autorequire.should be_empty
      end
  
      it "should autorequire a matching cluster node" do
        catalog.add_resource cluster_instance
        catalog.add_resource cluster
        reqs = cluster_instance.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == cluster.ref
        reqs[0].target.ref.should == cluster_instance.ref
      end
    end
    
    describe "domain autorequire" do
      let :cluster_instance do
        described_class.new(
          :instancename => 'test',
          :nodename     => 'node',
          :cluster      => 'cluster',
          :dasport      => '8048',
          :user         => 'glassfish'
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
        catalog.add_resource cluster_instance
        cluster_instance.autorequire.should be_empty
      end
    
      it "should autorequire a matching domain" do
        # Create catalogue
        catalog.add_resource cluster_instance
        # Additional expect for domain resource. 
        Puppet.features.expects(:root?).returns(true).once
        catalog.add_resource domain
        reqs = cluster_instance.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == domain.ref
        reqs[0].target.ref.should == cluster_instance.ref
      end
    end
  end
end
