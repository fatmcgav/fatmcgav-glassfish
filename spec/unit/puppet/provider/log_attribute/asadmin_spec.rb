require 'spec_helper'

describe Puppet::Type.type(:log_attribute).provider(:asadmin) do
  
  before :each do
    Puppet::Type.type(:log_attribute).stubs(:defaultprovider).returns described_class
    #File.expects(:exists?).with('/tmp/test.war').returns(:true).once
    Puppet.features.expects(:root?).returns(true).once
  end
  
  let :log_attribute do
    Puppet::Type.type(:log_attribute).new(
      :name           => 'com.sun.enterprise.server.logging.GFFileHandler.formatter',
      :ensure         => :present,
      :value          => 'com.sun.enterprise.server.logging.UniformLogFormatter',
      :user           => 'glassfish',
      :portbase       => '8000',
      :asadminuser    => 'admin',
      :provider       => provider
    )
  end
  
  let :provider do
    described_class.new(
      :name => 'com.sun.enterprise.server.logging.GFFileHandler.formatter'
    )
  end
  
  describe "when asking exists?" do
    it "should return true if resource value matches" do
      log_attribute.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin list-log-attributes\"").
        returns("com.sun.enterprise.server.logging.GFFileHandler.flushFrequency\t<1>
com.sun.enterprise.server.logging.GFFileHandler.formatter\t<com.sun.enterprise.server.logging.UniformLogFormatter>
com.sun.enterprise.server.logging.GFFileHandler.logtoConsole\t<false>")
      log_attribute.provider.should be_exists
    end

    it "should return false if resource value doesn't match" do
      log_attribute.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin list-log-attributes\"").
        returns("com.sun.enterprise.server.logging.GFFileHandler.flushFrequency\t<1>
com.sun.enterprise.server.logging.GFFileHandler.formatter\t<com.sun.enterprise.server.logging.UniformLogFormat>
com.sun.enterprise.server.logging.GFFileHandler.logtoConsole\t<false>")
      log_attribute.provider.should_not be_exists
    end
  end

  describe "when creating a resource" do
    it "should be able to set a log_attribute without a target" do
      log_attribute[:value] = 'blah'
      log_attribute.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin set-log-attributes --target server com.sun.enterprise.server.logging.GFFileHandler.formatter=blah\"").
        returns("com.sun.enterprise.server.logging.GFFileHandler.formatter logging attribute set with value blah.
        These logging attributes are set for server.
        Command set-log-attributes executed successfully.")
      log_attribute.provider.create
    end
    
    it "should be able to set a log_attribute with a target" do
      log_attribute[:value] = 'blah'
      log_attribute[:target] = 'cluster'
      log_attribute.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin set-log-attributes --target cluster com.sun.enterprise.server.logging.GFFileHandler.formatter=blah\"").
        returns("com.sun.enterprise.server.logging.GFFileHandler.formatter logging attribute set with value blah. 
        These logging attributes are set for cluster.
        Command set-log-attributes executed successfully.")
      log_attribute.provider.create
    end
  end
end
