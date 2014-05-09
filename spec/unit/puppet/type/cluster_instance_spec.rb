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
    [:instancename, :node_name, :cluster, :portbase, :asadminuser, :passwordfile, :dashost, :dasport, :user].each do |param|
      it "should have a #{param} parameter" do
        described_class.attrtype(param).should == :param
      end
    end
  end
  
end
