require 'spec_helper'
require 'puppet/provider/asadmin'

describe Puppet::Provider::Asadmin do
  
  describe "#escape" do
    it "should escape a colon" do
      subject.escape('value:value').should == 'value\\:value'
    end
    it "should not escape no colon" do
      subject.escape('value=value').should == 'value=value'
    end
  end
  
  describe "#hasProperties?" do
    # Expose the protected method for testing purposes.
    before(:each) do
      described_class.send(:public, *described_class.protected_instance_methods)
    end
    
    # Test that correct boolean value is returned
    it "should return true with properties" do
      subject.hasProperties?('property').should be_truthy
    end
    it "should return false with nil properties" do
      subject.hasProperties?(nil).should be_falsey
    end
    it "should return false with no properties" do
      subject.hasProperties?('').should be_falsey
    end
  end
  
  describe "#prepareProperties" do
    # Expose the protected method for testing purposes.
    before(:each) do
      described_class.send(:public, *described_class.protected_instance_methods)
    end
    
    # Test handling of various properties values
    it "should not change a string" do
      subject.prepareProperties('property').should == 'property'
    end
    it "should convert an array to a colon seperated string" do
      subject.prepareProperties(['property1', 'property2']).should == 'property1:property2'
    end
    it "should convert a non-hash value to a string" do
      subject.prepareProperties(:symbol).should == 'symbol'
    end
    it "should convert a hash to a key=value colon seperated string" do
      subject.prepareProperties({'key' => 'value', 'key2' => 'value2'}).should == 'key2=value2:key=value'
    end
  end
end