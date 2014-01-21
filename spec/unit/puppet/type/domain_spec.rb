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
    [:domainname, :startoncreate, :portbase, :asadminuser, :passwordfile, :user, :enablesecureadmin].each do |param|
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

    describe "for startoncreate" do
      it "should support true" do
        described_class.new(:domainname => 'domain', :startoncreate => 'true')[:startoncreate].should == :true
      end

      it "should support false" do
        described_class.new(:domainname => 'domain', :startoncreate => 'false')[:startoncreate].should == :false
      end

      it "should have a default value of true" do
        described_class.new(:domainname => 'domain')[:startoncreate].should == :true
      end

      it "should not support other values" do
        expect { described_class.new(:domainname => 'domain', :startoncreate => 'foo') }.to raise_error(Puppet::Error, /Invalid value "foo"/)
      end
    end

    describe "for portbase" do
      it "should support a numerical value" do
        described_class.new(:domainname => 'domain', :portbase => '8000', :ensure => :present)[:portbase].should == 8000
      end

      it "should have a default value of 8000" do
        described_class.new(:domainname => 'domain', :ensure => :present)[:portbase].should == 8000
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
        #File.stubs(:exists?).with('/tmp/asadmin.pass').returns(:true)
        File.expects(:exists?).with('/tmp/asadmin.pass').returns(true).once
        described_class.new(:domainname => 'domain', :passwordfile => '/tmp/asadmin.pass')[:passwordfile].should == '/tmp/asadmin.pass'
      end

      it "should fail an invalid file path" do
        #File.stubs(:exists?).with('/tmp/nonexistent').returns(:false)
        File.expects(:exists?).with('/tmp/nonexistent').returns(false).once
        expect { described_class.new(:domainname => 'domain', :passwordfile => '/tmp/nonexistent') }.to raise_error(Puppet::Error, /does not exist/)
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
  end
end
