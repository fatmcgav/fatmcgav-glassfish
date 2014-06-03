require 'spec_helper'

describe Puppet::Type.type(:jdbcconnectionpool) do

  before :each do
    described_class.stubs(:defaultprovider).returns providerclass
  end

  let :providerclass do
    described_class.provide(:fake_jdbcconnectionpool_provider) { mk_resource_methods }
  end

  it "should have :name as it's namevar" do
    described_class.key_attributes.should == [:name]
  end

  describe "when validating attributes" do
    [:name, :dsclassname, :resourcetype, :properties, :portbase, :asadminuser, :passwordfile, :user].each do |param|
      it "should have a #{param} parameter" do
        described_class.attrtype(param).should == :param
      end
    end
  end
  
  describe "when validating values" do  
    describe "for name" do
      it "should support an alphanumerical name" do
        described_class.new(:name => 'test', :ensure => :present, :dsclassname => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource',
          :resourcetype => 'javax.sql.ConnectionPoolDataSource')[:name].should == 'test'
      end
    end
    
    describe "for ensure" do
      it "should support present" do
        described_class.new(:name => 'test', :ensure => 'present', :dsclassname => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource',
          :resourcetype => 'javax.sql.ConnectionPoolDataSource')[:ensure].should == :present
      end

      it "should support absent" do
        described_class.new(:name => 'test', :ensure => 'absent', :dsclassname => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource',
          :resourcetype => 'javax.sql.ConnectionPoolDataSource')[:ensure].should == :absent
      end

      it "should not support other values" do
        expect { described_class.new(:name => 'test', :ensure => 'foo') }.to raise_error(Puppet::Error, /Invalid value "foo"/)
      end

      it "should not have a default value" do
        described_class.new(:name => 'test', :dsclassname => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource',
          :resourcetype => 'javax.sql.ConnectionPoolDataSource')[:ensure].should == nil
      end
    end
      
    describe "for dsclassname" do
      it "should support a value" do
        described_class.new(:name => 'test', :dsclassname => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource',
          :resourcetype => 'javax.sql.ConnectionPoolDataSource', :ensure => 'present')[:dsclassname].should == 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource'
      end
    end
    
    describe "for resourcetype" do
      it "should support a value" do
        described_class.new(:name => 'test', :dsclassname => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource',
          :resourcetype => 'javax.sql.ConnectionPoolDataSource', :ensure => 'present')[:resourcetype].should == 'javax.sql.ConnectionPoolDataSource'
      end
    end
    
    describe "for properties" do
      it "should support a value" do
        described_class.new(:name => 'test', :dsclassname => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource',
          :resourcetype => 'javax.sql.ConnectionPoolDataSource', :properties => 'user=myuser:password=mypass:url=jdbc\:mysql\://myhost.ex.com\:3306/mydatabase',
          :ensure => 'present')[:properties].should == 'user=myuser:password=mypass:url=jdbc\:mysql\://myhost.ex.com\:3306/mydatabase'
      end
    end
    
    describe "for portbase" do
      it "should support a numerical value" do
        described_class.new(:name => 'test', :portbase => '8000', :ensure => :present, :dsclassname => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource',
          :resourcetype => 'javax.sql.ConnectionPoolDataSource')[:portbase].should == 8000
      end

      it "should have a default value of 4800" do
        described_class.new(:name => 'test', :ensure => :present, :dsclassname => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource',
          :resourcetype => 'javax.sql.ConnectionPoolDataSource')[:portbase].should == 4800
      end

      it "should not support shorter than 4 digits" do
        expect { described_class.new(:name => 'test', :portbase => '123', :ensure => :present) }.to raise_error(Puppet::Error, /123 is not a valid portbase./)
      end

      it "should not support longer than 5 digits" do
        expect { described_class.new(:name => 'test', :portbase => '123456', :ensure => :present) }.to raise_error(Puppet::Error, /123456 is not a valid portbase./)
      end

      it "should not support a non-numeric value" do
        expect { described_class.new(:name => 'test', :portbase => 'a', :ensure => :present) }.to raise_error(Puppet::Error, /a is not a valid portbase./)
      end
    end

    describe "for asadminuser" do
      it "should support an alpha name" do
        described_class.new(:name => 'test', :asadminuser => 'user', :ensure => :present, :dsclassname => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource',
          :resourcetype => 'javax.sql.ConnectionPoolDataSource')[:asadminuser].should == 'user'
      end

      it "should support underscores" do
        described_class.new(:name => 'test', :asadminuser => 'admin_user', :ensure => :present, :dsclassname => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource',
          :resourcetype => 'javax.sql.ConnectionPoolDataSource')[:asadminuser].should == 'admin_user'
      end
   
      it "should support hyphens" do
        described_class.new(:name => 'test', :asadminuser => 'admin-user', :ensure => :present, :dsclassname => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource',
          :resourcetype => 'javax.sql.ConnectionPoolDataSource')[:asadminuser].should == 'admin-user'
      end

      it "should have a default value of admin" do
        described_class.new(:name => 'test', :ensure => :present, :dsclassname => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource',
          :resourcetype => 'javax.sql.ConnectionPoolDataSource')[:asadminuser].should == 'admin'
      end

      it "should not support spaces" do
        expect { described_class.new(:name => 'test', :asadminuser => 'admin user', :dsclassname => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource',
          :resourcetype => 'javax.sql.ConnectionPoolDataSource') }.to raise_error(Puppet::Error, /admin user is not a valid asadmin user name/)
      end
    end
    
    describe "for passwordfile" do
      it "should support a valid file path" do
        File.expects(:exists?).with('/tmp/asadmin.pass').returns(true).once
        described_class.new(:name => 'test', :passwordfile => '/tmp/asadmin.pass', :dsclassname => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource',
          :resourcetype => 'javax.sql.ConnectionPoolDataSource')[:passwordfile].should == '/tmp/asadmin.pass'
      end

      it "should fail an invalid file path" do
        File.expects(:exists?).with('/tmp/nonexistent').returns(false).once
        expect { described_class.new(:name => 'test', :passwordfile => '/tmp/nonexistent') }.to raise_error(Puppet::Error, /does not exist/)
      end
    end
    
    describe "for user" do
      it "should support an alpha name" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:name => 'test', :user => 'glassfish', :ensure => :present, :dsclassname => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource',
          :resourcetype => 'javax.sql.ConnectionPoolDataSource')[:user].should == 'glassfish'
      end

      it "should support underscores" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:name => 'test', :user => 'glassfish_user', :ensure => :present, :dsclassname => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource',
          :resourcetype => 'javax.sql.ConnectionPoolDataSource')[:user].should == 'glassfish_user'
      end
   
      it "should support hyphens" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:name => 'test', :user => 'glassfish-user', :ensure => :present, :dsclassname => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource',
          :resourcetype => 'javax.sql.ConnectionPoolDataSource')[:user].should == 'glassfish-user'
      end

      it "should not have a default value of admin" do
        described_class.new(:name => 'test', :ensure => :present, :dsclassname => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource',
          :resourcetype => 'javax.sql.ConnectionPoolDataSource')[:user].should == nil
      end

      it "should not support spaces" do
        Puppet.features.expects(:root?).returns(true).once
        expect { described_class.new(:name => 'test', :user => 'glassfish user', :dsclassname => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource',
          :resourcetype => 'javax.sql.ConnectionPoolDataSource') }.to raise_error(Puppet::Error, /glassfish user is not a valid user name/)
      end
      
      it "should fail if not running as root" do
        Puppet.features.expects(:root?).returns(false).once
        expect { described_class.new(:name => 'test', :user => 'glassfish') }.to raise_error(Puppet::Error, /Only root can execute commands as other users/)
      end
    end
    
    describe "validate" do
      describe "dsclassname" do
        it "should not fail with a valid dsclassname" do
          expect { described_class.new(:name => 'test', :dsclassname => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource',
            :resourcetype => 'javax.sql.ConnectionPoolDataSource') }.not_to raise_error
        end
        it "should fail with a missing dsclassname" do
          expect { described_class.new(:name => 'test', :resourcetype => 'javax.sql.ConnectionPoolDataSource') }.to raise_error(Puppet::Error, /Dsclassname is required./)
        end
      end
      
      describe "resourcetype" do
        it "should not fail with a valid resourcetype" do
          expect { described_class.new(:name => 'test', :dsclassname => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource',
            :resourcetype => 'javax.sql.ConnectionPoolDataSource') }.not_to raise_error
        end
        it "should fail with a missing resourcetype" do
          expect { described_class.new(:name => 'test', :dsclassname => 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource') }.to raise_error(Puppet::Error, /Resourcetype is required./)
        end
      end
    end
  end  
  
  describe "when autorequiring" do    
    describe "user autorequire" do
      let :jdbconnectionpool do
        described_class.new(
          :name         => 'test',
          :dsclassname  => 'oracle.jdbc.pool.OracleConnectionPoolDataSource',
          :resourcetype => 'javax.sql.ConnectionPoolDataSource',
          :properties   => 'user=myuser:password=mypass:url=jdbc\:mysql\://myhost.ex.com\:3306/mydatabase',
          :portbase     => '8000',
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
        catalog.add_resource jdbconnectionpool
        jdbconnectionpool.autorequire.should be_empty
      end
  
      it "should autorequire a matching user" do
        catalog.add_resource jdbconnectionpool
        catalog.add_resource user
        reqs = jdbconnectionpool.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == user.ref
        reqs[0].target.ref.should == jdbconnectionpool.ref
      end
    end
    
    describe "domain autorequire" do
      let :jdbconnectionpool do
        described_class.new(
          :name         => 'test',
          :dsclassname  => 'oracle.jdbc.pool.OracleConnectionPoolDataSource',
          :resourcetype => 'javax.sql.ConnectionPoolDataSource',
          :properties   => 'user=myuser:password=mypass:url=jdbc\:mysql\://myhost.ex.com\:3306/mydatabase',
          :portbase     => '8000',
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
        catalog.add_resource jdbconnectionpool
        jdbconnectionpool.autorequire.should be_empty
      end
    
      it "should autorequire a matching domain" do
        # Create catalogue
        catalog.add_resource jdbconnectionpool
        # Additional expect for domain resource. 
        Puppet.features.expects(:root?).returns(true).once
        catalog.add_resource domain
        reqs = jdbconnectionpool.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == domain.ref
        reqs[0].target.ref.should == jdbconnectionpool.ref
      end
    end
  end
end
