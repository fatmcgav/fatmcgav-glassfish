require 'spec_helper'

describe Puppet::Type.type(:domain) do

  before :each do
    described_class.stubs(:defaultprovider).returns providerclass
  end

  let :providerclass do
    described_class.provide(:fake_domain_provider) { mk_resource_methods }
  end

  it "should have :domainname as it's namevar" do
    described_class.key_attributes.should == [:domainname]
  end

  describe "when validating attributes" do
    [:domainname, :startoncreate, :portbase, :asadminuser, :passwordfile, :user, :enablesecureadmin, :template].each do |param|
      it "should have a #{param} parameter" do
        described_class.attrtype(param).should == :param
      end
    end
  end

  describe "when validating values" do
    describe "for domain name" do
      it "should support an alphanumerical name" do
        described_class.new(:domainname => 'domain', :ensure => :present)[:domainname].should == 'domain'
      end

      it "should support underscores" do
        described_class.new(:domainname => 'domain_name', :ensure => :present)[:domainname].should == 'domain_name'
      end
   
      it "should support hyphens" do
        described_class.new(:domainname => 'domain-name', :ensure => :present)[:domainname].should == 'domain-name'
      end

      it "should not support spaces" do
        expect { described_class.new(:domainname => 'domain name', :ensure => :present) }.to raise_error(Puppet::Error, /domain name is not a valid domain name/)
      end
    end

    describe "for ensure" do
      it "should support present" do
        described_class.new(:domainname => 'domain', :ensure => 'present')[:ensure].should == :present
      end

      it "should support absent" do
        described_class.new(:domainname => 'domain', :ensure => 'absent')[:ensure].should == :absent
      end

      it "should not support other values" do
        expect { described_class.new(:domainname => 'domain', :ensure => 'foo') }.to raise_error(Puppet::Error, /Invalid value "foo"/)
      end

      it "should not have a default value" do
        described_class.new(:domainname => 'domain')[:ensure].should == nil
      end
    end

    describe "for portbase" do
      it "should support a numerical value" do
        described_class.new(:domainname => 'domain', :portbase => '8000', :ensure => :present)[:portbase].should == 8000
      end

      it "should have a default value of 4800" do
        described_class.new(:domainname => 'domain', :ensure => :present)[:portbase].should == 4800
      end

      it "should not support shorter than 4 digits" do
        expect { described_class.new(:domainname => 'domain', :portbase => '123', :ensure => :present) }.to raise_error(Puppet::Error, /123 is not a valid portbase./)
      end

      it "should not support longer than 5 digits" do
        expect { described_class.new(:domainname => 'domain', :portbase => '123456', :ensure => :present) }.to raise_error(Puppet::Error, /123456 is not a valid portbase./)
      end

      it "should not support a non-numeric value" do
        expect { described_class.new(:domainname => 'domain', :portbase => 'a', :ensure => :present) }.to raise_error(Puppet::Error, /a is not a valid portbase./)
      end
    end

    describe "for asadminuser" do
      it "should support an alpha name" do
        described_class.new(:domainname => 'domain', :asadminuser => 'user', :ensure => :present)[:asadminuser].should == 'user'
      end

      it "should support underscores" do
        described_class.new(:domainname => 'domain', :asadminuser => 'admin_user', :ensure => :present)[:asadminuser].should == 'admin_user'
      end
   
      it "should support hyphens" do
        described_class.new(:domainname => 'domain', :asadminuser => 'admin-user', :ensure => :present)[:asadminuser].should == 'admin-user'
      end

      it "should have a default value of admin" do
        described_class.new(:domainname => 'domain', :ensure => :present)[:asadminuser].should == 'admin'
      end

      it "should not support spaces" do
        expect { described_class.new(:domainname => 'domain', :asadminuser => 'admin user', :ensure => :present) }.to raise_error(Puppet::Error, /admin user is not a valid asadmin user name/)
      end
    end

    describe "for passwordfile" do
      it "should support a valid file path" do
        described_class.new(:domainname => 'domain', :passwordfile => '/tmp/asadmin.pass')[:passwordfile].should == '/tmp/asadmin.pass'
      end
    end

    describe "for user" do
      it "should support an alpha name" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:domainname => 'domain', :user => 'glassfish', :ensure => :present)[:user].should == 'glassfish'
      end

      it "should support underscores" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:domainname => 'domain', :user => 'glassfish_user', :ensure => :present)[:user].should == 'glassfish_user'
      end
   
      it "should support hyphens" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:domainname => 'domain', :user => 'glassfish-user', :ensure => :present)[:user].should == 'glassfish-user'
      end

      it "should not have a default value of admin" do
        described_class.new(:domainname => 'domain', :ensure => :present)[:user].should == nil
      end

      it "should not support spaces" do
        Puppet.features.expects(:root?).returns(true).once
        expect { described_class.new(:domainname => 'domain', :user => 'glassfish user') }.to raise_error(Puppet::Error, /glassfish user is not a valid user name/)
      end
      
      it "should fail if not running as root" do
        Puppet.features.expects(:root?).returns(false).once
        expect { described_class.new(:domainname => 'domain', :user => 'glassfish') }.to raise_error(Puppet::Error, /Only root can execute commands as other users/)
      end
    end
    
    describe "for startoncreate" do
      it "should support true" do
        described_class.new(:domainname => 'domain', :startoncreate => 'true')[:startoncreate].should == :true
      end

      it "should support false" do
        described_class.new(:domainname => 'domain', :startoncreate => 'false', :enablesecureadmin => 'false')[:startoncreate].should == :false
      end

      it "should have a default value of true" do
        described_class.new(:domainname => 'domain')[:startoncreate].should == :true
      end

      it "should not support other values" do
        expect { described_class.new(:domainname => 'domain', :startoncreate => 'foo') }.to raise_error(Puppet::Error, /Invalid value "foo"/)
      end
    end
    
    describe "for enablesecureadmin" do
      it "should support true" do
        described_class.new(:domainname => 'domain', :enablesecureadmin => 'true')[:enablesecureadmin].should == :true
      end

      it "should support false" do
        described_class.new(:domainname => 'domain', :enablesecureadmin => 'false')[:enablesecureadmin].should == :false
      end

      it "should have a default value of true" do
        described_class.new(:domainname => 'domain')[:enablesecureadmin].should == :true
      end

      it "should not support other values" do
        expect { described_class.new(:domainname => 'domain', :enablesecureadmin => 'foo') }.to raise_error(Puppet::Error, /Invalid value "foo"/)
      end
    end
    
    describe "for template" do
      it "should support a valid file path" do
        File.expects(:exists?).with('/tmp/template.xml').returns(true).once
        described_class.new(:domainname => 'domain', :template => '/tmp/template.xml')[:template].should == '/tmp/template.xml'
      end

      it "should fail an invalid file path" do
        File.expects(:exists?).with('/tmp/nonexistent').returns(false).once
        expect { described_class.new(:domainname => 'domain', :template => '/tmp/nonexistent') }.to raise_error(Puppet::Error, /does not exist/)
      end
    end
    
    describe "validate" do
      it "should not fail with startoncreate => true and enablesecureadmin => true" do
        expect { described_class.new(:domainname => 'domain', :startoncreate => 'true', :enablesecureadmin => 'true') }.not_to raise_error
      end
      it "should not fail with startoncreate => true and enablesecureadmin => false" do
        expect { described_class.new(:domainname => 'domain', :startoncreate => 'true', :enablesecureadmin => 'false') }.not_to raise_error
      end
      it "should not fail with startoncreate => false and enablesecureadmin => false" do
        expect { described_class.new(:domainname => 'domain', :startoncreate => 'false', :enablesecureadmin => 'false') }.not_to raise_error
      end
      it "should fail with startoncreate => false and enablesecureadmin => true" do
        expect { described_class.new(:domainname => 'domain', :startoncreate => 'false', :enablesecureadmin => 'true') }.to raise_error(Puppet::Error, /Enablesecureadmin cannot be true if startoncreate is false/)
      end
    end
  end
  
  describe "when autorequiring" do
    describe "user autorequire" do
      let :domain do
        described_class.new(
          :domainname   => 'test',
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
        catalog.add_resource domain
        domain.autorequire.should be_empty
      end
  
      it "should autorequire a matching user" do
        catalog.add_resource domain
        catalog.add_resource user
        reqs = domain.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == user.ref
        reqs[0].target.ref.should == domain.ref
      end
    end
    
    describe "file autorequire" do
      let :domain do
        described_class.new(
          :domainname   => 'test',
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
        catalog.add_resource domain
        domain.autorequire.should be_empty
      end
    
      it "should autorequire a matching file" do
        catalog.add_resource domain
        catalog.add_resource file
        reqs = domain.autorequire
        reqs.size.should == 1
        reqs[0].source.ref.should == file.ref
        reqs[0].target.ref.should == domain.ref
      end
    end
  end
end
