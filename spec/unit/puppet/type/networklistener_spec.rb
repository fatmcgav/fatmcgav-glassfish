require 'spec_helper'

describe Puppet::Type.type(:networklistener) do

  before :each do
    described_class.stubs(:defaultprovider).returns providerclass
  end

  let :providerclass do
    described_class.provide(:fake_networklistener_provider) { mk_resource_methods }
  end

  it "should have :name as it's namevar" do
    described_class.key_attributes.should == [:name]
  end

  describe "when validating attributes" do
    [:name, :address, :port, :protocol, :transport, :enabled, :jkenabled, :target, :portbase, :asadminuser, :passwordfile, :user].each do |param|
      it "should have a #{param} parameter" do
        described_class.attrtype(param).should == :param
      end
    end
  end

  describe "when validating values" do
    describe "for name" do
     it "should support an alphanumerical name" do
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :ensure => :present)[:name].should == 'listener'
      end

      it "should support underscores" do
        described_class.new(:name => 'listener_name', :port => '8009', :protocol => 'http-listener-1', :ensure => :present)[:name].should == 'listener_name'
      end

      it "should support hyphens" do
        described_class.new(:name => 'listener-name', :port => '8009', :protocol => 'http-listener-1', :ensure => :present)[:name].should == 'listener-name'
      end

      it "should not support spaces" do
        expect {
          described_class.new(
            :name => 'listener name',
            :port => '8009',
            :protocol => 'http-listener-1',
            :ensure => :present
          )
        }.to raise_error(Puppet::Error, /listener name is not a valid listener name/)
      end
    end

    describe "for ensure" do
      it "should support present" do
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :ensure => 'present')[:ensure].should == :present
      end

      it "should support absent" do
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :ensure => 'absent')[:ensure].should == :absent
      end

      it "should not support other values" do
        expect {
          described_class.new(
            :name => 'listener',
            :port => '8009',
            :protocol => 'http-listener-1',
            :ensure => 'foo'
          )
        }.to raise_error(Puppet::Error, /Invalid value "foo"/)
      end

      it "should not have a default value" do
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1')[:ensure].should == nil
      end
    end

    describe "for address" do
      it "should support an ip address" do
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :address => '172.16.10.5', :ensure => :present)[:address].should == '172.16.10.5'
      end

      it "should support a hostname" do
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :address => 'hostname', :ensure => :present)[:address].should == 'hostname'
      end

      it "should not support an invalid hostname" do
        expect {
          described_class.new(
            :name => 'listener',
            :port => '8009',
            :protocol => 'http-listener-1',
            :address => 'invalid,hostname',
            :ensure => :present
          )
       }.to raise_error(Puppet::Error, /should be an IP address or hostname./)
      end
    end

    describe "for port" do
      it "should support a numerical value" do
        described_class.new(:name => 'listener', :port => '8000', :protocol => 'http-listener-1', :ensure => :present)[:port].should == 8000
      end

      it "should not support shorter than 4 digits" do
        expect {
          described_class.new(
            :name => 'listener',
            :port => '123',
            :protocol => 'http-listener-1',
            :ensure => :present
          )
       }.to raise_error(Puppet::Error, /123 is not a valid port./)
      end

      it "should not support longer than 5 digits" do
        expect {
          described_class.new(
            :name => 'listener',
            :port => '123456',
            :protocol => 'http-listener-1',
            :ensure => :present
          )
        }.to raise_error(Puppet::Error, /123456 is not a valid port./)
      end

      it "should not support a non-numeric value" do
        expect { 
          described_class.new(
            :name => 'listener',
            :port => 'a',
            :protocol => 'http-listener-1',
            :ensure => :present
          )
        }.to raise_error(Puppet::Error, /a is not a valid port./)
      end  
    end

    describe "for threadpool" do
      it "should support an alphanumerical name" do
        described_class.new(:name=> 'listener', :port => '8009', :protocol => 'http-listener-1', :threadpool => 'threadpool', :ensure => :present)[:threadpool].should == 'threadpool'
      end

      it "should support underscores" do
        described_class.new(
          :name=> 'listener',
          :port => '8009',
          :protocol => 'http-listener-1',
          :threadpool => 'threadpool_name',
          :ensure => :present
        )[:threadpool].should == 'threadpool_name'
      end

      it "should support hyphens" do
        described_class.new(
          :name=> 'listener',
          :port => '8009',
          :protocol => 'http-listener-1',
          :threadpool => 'threadpool-name',
          :ensure => :present
        )[:threadpool].should == 'threadpool-name'
      end

      it "should not support spaces" do
        expect {
          described_class.new(
            :name=> 'listener',
            :port => '8009',
            :protocol => 'http-listener-1',
            :threadpool => 'threadpool name',
            :ensure => :present
          )
        }.to raise_error(Puppet::Error, /is not a valid threadpool/)
      end
    end

    describe "for transport" do
      it "should have a default value of tcp" do
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :ensure => :present)[:transport].should == 'tcp'
      end
    end

    describe "for enabled" do
      it "should support true" do
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :enabled => 'true')[:enabled].should == :true
      end

      it "should support false" do
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :enabled => 'false')[:enabled].should == :false
      end

      it "should have a default value of true" do
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1')[:enabled].should == :true
      end

      it "should not support other values" do
        expect { described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :enabled => 'foo') }.to raise_error(Puppet::Error, /Invalid value "foo"/)
      end
    end

    describe "for jkenabled" do
      it "should support true" do
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :jkenabled => 'true')[:jkenabled].should == :true
      end

      it "should support false" do
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :jkenabled => 'false')[:jkenabled].should == :false
      end

      it "should have a default value of false" do
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1')[:jkenabled].should == :false
      end

      it "should not support other values" do
        expect { described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :jkenabled => 'foo') }.to raise_error(Puppet::Error, /Invalid value "foo"/)
      end
    end

    describe "for target" do
      it "should have a default value of server" do
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :ensure => :present)[:target].should == 'server'
      end
    end

    describe "for portbase" do
      it "should support a numerical value" do
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :portbase => '8000', :ensure => :present)[:portbase].should == 8000
      end

      it "should have a default value of 4800" do
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :ensure => :present)[:portbase].should == 4800
      end

      it "should not support shorter than 4 digits" do
        expect {
          described_class.new(
            :name => 'listener',
            :port => '8009',
            :protocol => 'http-listener-1',
            :portbase => '123',
            :ensure => :present
          )
        }.to raise_error(Puppet::Error, /123 is not a valid portbase./)
      end

      it "should not support longer than 5 digits" do
        expect {
          described_class.new(
            :name => 'listener',
            :port => '8009',
            :protocol => 'http-listener-1',
            :portbase => '123456',
            :ensure => :present
          )
        }.to raise_error(Puppet::Error, /123456 is not a valid portbase./)
      end

      it "should not support a non-numeric value" do
        expect {
          described_class.new(
            :name => 'listener',
            :port => '8009',
            :protocol => 'http-listener-1',
            :portbase => 'a',
            :ensure => :present
          )
        }.to raise_error(Puppet::Error, /a is not a valid portbase./)
      end
    end

    describe "for asadminuser" do
      it "should support an alpha name" do
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :asadminuser => 'user', :ensure => :present)[:asadminuser].should == 'user'
      end

      it "should support underscores" do
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :asadminuser => 'admin_user', :ensure => :present)[:asadminuser].should == 'admin_user'
      end
   
      it "should support hyphens" do
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :asadminuser => 'admin-user', :ensure => :present)[:asadminuser].should == 'admin-user'
      end

      it "should have a default value of admin" do
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :ensure => :present)[:asadminuser].should == 'admin'
      end

      it "should not support spaces" do
        expect {
          described_class.new(
            :name => 'listener',
            :port => '8009',
            :protocol => 'http-listener-1',
            :asadminuser => 'admin user',
            :ensure => :present
          )
        }.to raise_error(Puppet::Error, /admin user is not a valid asadmin user name/)
      end
    end

    describe "for passwordfile" do
      it "should support a valid file path" do
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :passwordfile => '/tmp/asadmin.pass')[:passwordfile].should == '/tmp/asadmin.pass'
      end
    end

    describe "for user" do
      it "should support an alpha name" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :user => 'glassfish', :ensure => :present)[:user].should == 'glassfish'
      end

      it "should support underscores" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :user => 'glassfish_user', :ensure => :present)[:user].should == 'glassfish_user'
      end
   
      it "should support hyphens" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :user => 'glassfish-user', :ensure => :present)[:user].should == 'glassfish-user'
      end

      it "should not have a default value of admin" do
        described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :ensure => :present)[:user].should == nil
      end

      it "should not support spaces" do
        Puppet.features.expects(:root?).returns(true).once
        expect {
          described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :user => 'glassfish user')
        }.to raise_error(Puppet::Error, /glassfish user is not a valid user name/)
      end
      
      it "should fail if not running as root" do
        Puppet.features.expects(:root?).returns(false).once
        expect {
          described_class.new(:name => 'listener', :port => '8009', :protocol => 'http-listener-1', :user => 'glassfish')
        }.to raise_error(Puppet::Error, /Only root can execute commands as other users/)
      end
    end
    
  end
  
  describe "when autorequiring" do
    describe "user autorequire" do
      let :listener do
        described_class.new(
          :name   => 'test',
          :port => '8009',
          :protocol => 'http-listener-1',
          :user         => 'glassfish',
          :passwordfile => '/tmp/asadmin.pass' 
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
  
      # Stub the user type, and expect Puppet.features.root?
      before :each do
        Puppet::Type.type(:user).stubs(:defaultprovider).returns userprovider
        Puppet.features.expects(:root?).returns(true).once
      end
      
      it "should not autorequire a user when no matching user can be found" do
        catalog.add_resource listener
        listener.autorequire.should be_empty
      end
  
      it "should autorequire a matching user" do
        catalog.add_resource listener
        catalog.add_resource user
        reqs = listener.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == user.ref
        reqs[0].target.ref.should == listener.ref
      end
    end
    
    describe "file autorequire" do
      let :listener do
        described_class.new(
          :name   => 'test',
          :port => '8009',
          :protocol => 'http-listener-1',
          :user         => 'glassfish',
          :passwordfile => '/tmp/asadmin.pass' 
        )
      end
      
      # Need to stub file type and provider.
      let :fileprovider do
        Puppet::Type.type(:file).provide(:fake_file_provider) { mk_resource_methods }
      end
      
      let :file do
        Puppet::Type.type(:file).new(
          :name   => '/tmp/asadmin.pass',
          :ensure => 'present'
        )
      end
      
      let :catalog do
        Puppet::Resource::Catalog.new
      end
    
      # Stub the file type, and expect Puppet.features.root?
      before :each do
        Puppet::Type.type(:file).stubs(:defaultprovider).returns fileprovider
        Puppet.features.expects(:root?).returns(true).once
      end
      
      it "should not autorequire a file when no matching file can be found" do
        catalog.add_resource listener
        listener.autorequire.should be_empty
      end
    
      it "should autorequire a matching file" do
        catalog.add_resource listener
        catalog.add_resource file
        reqs = listener.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == file.ref
        reqs[0].target.ref.should == listener.ref
      end
    end
  end
end
