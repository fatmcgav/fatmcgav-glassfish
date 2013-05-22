Puppet::Type.newtype(:customresource) do
  @doc = "Manage custom resources of Glassfish domains"
  ensurable
  
  newparam(:name) do
    desc "The custom resource name."
    isnamevar
  end
  
  newparam(:restype) do
    desc "The type of custom resource to be created. Specify a fully qualified type definition, for example javax.naming.spi.ObjectFactory. The resource type definition follows the format, xxx.xxx."
    validate do |restype|
      if /^(?:[a-zA-Z_$][a-zA-Z\d_$]*\.)*[A-Z$][a-zA-Z\d_$]{1,}$/.match(restype).nil?
        raise ArgumentError, "%s is not valid Java fully qualified type name" % restype
      end
    end
  end
  
  newparam(:factoryclass) do
    desc "Factory class name for the custom resource. This class implements the javax.naming.spi.ObjectFactory interface."
    validate do |factoryclass|
      if /^(?:[a-zA-Z_$][a-zA-Z\d_$]*\.)*[A-Z$][a-zA-Z\d_$]{1,}$/.match(factoryclass).nil?
        raise ArgumentError, "%s is not valid Java fully qualified type name" % factoryclass
      end
    end
  end
  
  newparam(:properties) do
    desc "Optional attribute name/value pairs for configuring the resource. As String or Hash. Ex. \"user=myuser:password=mypass\""
  end

  newparam(:portbase) do
    desc "The Glassfish domain port base. Default: 4800"
    defaultto "4800"
  end

  newparam(:asadminuser) do
    desc "The internal Glassfish user asadmin uses. Default: admin"
    defaultto "admin"
  end

  newparam(:passwordfile) do
    desc "The file containing the password for the user."

    validate do |value|
      unless File.exists? value
        raise ArgumentError, "%s does not exists" % value
      end
    end
  end

  newparam(:user) do
    desc "The user to run the command as."

    validate do |user|
      unless Puppet.features.root?
        self.fail "Only root can execute commands as other users"
      end
    end
  end
end 