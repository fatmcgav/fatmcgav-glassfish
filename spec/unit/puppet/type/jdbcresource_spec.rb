require 'spec_helper'

describe Puppet::Type.type(:jdbcresource) do

  before :each do
    described_class.stubs(:defaultprovider).returns providerclass
  end

  let :providerclass do
    described_class.provide(:fake_jdbcresource_provider) { mk_resource_methods }
  end

  it "should have :name as it's namevar" do
    described_class.key_attributes.should == [:name]
  end

  describe "when validating attributes" do
    [:name, :connectionpool, :portbase, :asadminuser, :passwordfile, :user].each do |param|
      it "should have a #{param} parameter" do
        described_class.attrtype(param).should == :param
      end
    end
  end
  
  describe "when validating values" do  
    describe "for name" do
      it "should support an alphanumerical name" do
        described_class.new(:name => 'test', :ensure => :present, :connectionpool => 'test')[:name].should == 'test'
      end
      
      it "should support forward slashes" do
        described_class.new(:name => 'jdbc/test', :ensure => :present, :connectionpool => 'test')[:name].should == 'jdbc/test'
      end
    end
    
    describe "for ensure" do
      it "should support present" do
        described_class.new(:name => 'jdbc/test', :ensure => 'present', :connectionpool => 'test')[:ensure].should == :present
      end

      it "should support absent" do
        described_class.new(:name => 'jdbc/test', :ensure => 'absent', :connectionpool => 'test')[:ensure].should == :absent
      end

      it "should not support other values" do
        expect { described_class.new(:name => 'jdbc/test', :ensure => 'foo') }.to raise_error(Puppet::Error, /Invalid value "foo"/)
      end

      it "should not have a default value" do
        described_class.new(:name => 'jdbc/test', :connectionpool => 'test')[:ensure].should == nil
      end
    end
      
    describe "for connectionpool" do
      it "should support a value" do
        described_class.new(:name => 'jdbc/test', :connectionpool => 'pool', :ensure => 'present')[:connectionpool].should == 'pool'
      end
    end
    
    describe "for portbase" do
      it "should support a numerical value" do
        described_class.new(:name => 'jdbc/test', :portbase => '8000', :ensure => :present, :connectionpool => 'test')[:portbase].should == 8000
      end

      it "should have a default value of 4800" do
        described_class.new(:name => 'jdbc/test', :ensure => :present, :connectionpool => 'test')[:portbase].should == 4800
      end

      it "should not support shorter than 4 digits" do
        expect { described_class.new(:name => 'jdbc/test', :portbase => '123', :ensure => :present) }.to raise_error(Puppet::Error, /123 is not a valid portbase./)
      end

      it "should not support longer than 5 digits" do
        expect { described_class.new(:name => 'jdbc/test', :portbase => '123456', :ensure => :present) }.to raise_error(Puppet::Error, /123456 is not a valid portbase./)
      end

      it "should not support a non-numeric value" do
        expect { described_class.new(:name => 'jdbc/test', :portbase => 'a', :ensure => :present) }.to raise_error(Puppet::Error, /a is not a valid portbase./)
      end
    end

    describe "for asadminuser" do
      it "should support an alpha name" do
        described_class.new(:name => 'jdbc/test', :asadminuser => 'user', :ensure => :present, :connectionpool => 'test')[:asadminuser].should == 'user'
      end

      it "should support underscores" do
        described_class.new(:name => 'jdbc/test', :asadminuser => 'admin_user', :ensure => :present, :connectionpool => 'test')[:asadminuser].should == 'admin_user'
      end
   
      it "should support hyphens" do
        described_class.new(:name => 'jdbc/test', :asadminuser => 'admin-user', :ensure => :present, :connectionpool => 'test')[:asadminuser].should == 'admin-user'
      end

      it "should have a default value of admin" do
        described_class.new(:name => 'jdbc/test', :ensure => :present, :connectionpool => 'test')[:asadminuser].should == 'admin'
      end

      it "should not support spaces" do
        expect { described_class.new(:name => 'jdbc/test', :asadminuser => 'admin user') }.to raise_error(Puppet::Error, /admin user is not a valid asadmin user name/)
      end
    end
    
    describe "for passwordfile" do
      it "should support a valid file path" do
        File.expects(:exists?).with('/tmp/asadmin.pass').returns(true).once
        described_class.new(:name => 'jdbc/test', :passwordfile => '/tmp/asadmin.pass', :connectionpool => 'test')[:passwordfile].should == '/tmp/asadmin.pass'
      end

      it "should fail an invalid file path" do
        File.expects(:exists?).with('/tmp/nonexistent').returns(false).once
        expect { described_class.new(:name => 'jdbc/test', :passwordfile => '/tmp/nonexistent') }.to raise_error(Puppet::Error, /does not exist/)
      end
    end
    
    describe "for user" do
      it "should support an alpha name" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:name => 'jdbc/test', :user => 'glassfish', :ensure => :present, :connectionpool => 'test')[:user].should == 'glassfish'
      end

      it "should support underscores" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:name => 'jdbc/test', :user => 'glassfish_user', :ensure => :present, :connectionpool => 'test')[:user].should == 'glassfish_user'
      end
   
      it "should support hyphens" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:name => 'jdbc/test', :user => 'glassfish-user', :ensure => :present, :connectionpool => 'test')[:user].should == 'glassfish-user'
      end

      it "should not have a default value of admin" do
        described_class.new(:name => 'jdbc/test', :ensure => :present, :connectionpool => 'test')[:user].should == nil
      end

      it "should not support spaces" do
        Puppet.features.expects(:root?).returns(true).once
        expect { described_class.new(:name => 'jdbc/test', :user => 'glassfish user') }.to raise_error(Puppet::Error, /glassfish user is not a valid user name/)
      end
      
      it "should fail if not running as root" do
        Puppet.features.expects(:root?).returns(false).once
        expect { described_class.new(:name => 'jdbc/test', :user => 'glassfish') }.to raise_error(Puppet::Error, /Only root can execute commands as other users/)
      end
    end
    
    describe "validate" do
      it "should not fail with a valid connectionpool" do
        expect { described_class.new(:name => 'jdbc/test', :connectionpool => 'test') }.not_to raise_error
      end
      it "should fail with a missing connectionpool" do
        expect { described_class.new(:name => 'jdbc/test') }.to raise_error(Puppet::Error, /Connectionpool is required./)
      end
    end
  end  
  
  describe "when autorequiring" do    
    describe "user autorequire" do
      let :jdbcresource do
        described_class.new(
          :name           => 'jdbc/test',
          :connectionpool => 'test',
          :portbase       => '8000',
          :user           => 'glassfish'
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
        catalog.add_resource jdbcresource
        jdbcresource.autorequire.should be_empty
      end
  
      it "should autorequire a matching user" do
        catalog.add_resource jdbcresource
        catalog.add_resource user
        reqs = jdbcresource.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == user.ref
        reqs[0].target.ref.should == jdbcresource.ref
      end
    end
    
    describe "domain autorequire" do
      let :jdbcresource do
        described_class.new(
          :name           => 'jdbc/test',
          :connectionpool => 'test',
          :portbase       => '8000',
          :user           => 'glassfish'
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
        catalog.add_resource jdbcresource
        jdbcresource.autorequire.should be_empty
      end
    
      it "should autorequire a matching domain" do
        # Create catalogue
        catalog.add_resource jdbcresource
        # Additional expect for domain resource. 
        Puppet.features.expects(:root?).returns(true).once
        catalog.add_resource domain
        reqs = jdbcresource.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == domain.ref
        reqs[0].target.ref.should == jdbcresource.ref
      end
    end
    
    describe "jdbcconnectionpool autorequire" do
      let :jdbcresource do
        described_class.new(
          :name           => 'jdbc/test',
          :connectionpool => 'test',
          :portbase       => '8000',
          :user           => 'glassfish'
        )
      end
      
      # Need to stub jdbcconnectionpool type and provider.
      let :jdbcconpoolprovider do
        Puppet::Type.type(:jdbcconnectionpool).provide(:fake_jdbcconpool_provider) { mk_resource_methods }
      end
      
      let :jdbcconpool do
        Puppet::Type.type(:jdbcconnectionpool).new(
          :name         => 'test',
          :dsclassname  => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource',
          :resourcetype => 'javax.sql.ConnectionPoolDataSource',
          :ensure       => 'present',
          :portbase     => '8000',
          :user         => 'glassfish'
        )
      end
      
      let :catalog do
        Puppet::Resource::Catalog.new
      end
    
      # Stub the jdbcconnectionpool type, and expect Puppet.features.root?
      before :each do
        Puppet::Type.type(:jdbcconnectionpool).stubs(:defaultprovider).returns jdbcconpoolprovider
        Puppet.features.expects(:root?).returns(true).once
      end
      
      it "should not autorequire a jdbc connection pool when no matching resource can be found" do
        catalog.add_resource jdbcresource
        jdbcresource.autorequire.should be_empty
      end
    
      it "should autorequire a matching domain" do
        # Create catalogue
        catalog.add_resource jdbcresource
        # Additional expect for jdbcconnectionpool resource. 
        Puppet.features.expects(:root?).returns(true).once
        catalog.add_resource jdbcconpool
        reqs = jdbcresource.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == jdbcconpool.ref
        reqs[0].target.ref.should == jdbcresource.ref
      end
    end
  end
end
