Puppet::Type.newtype(:customresource) do
  @doc = "Manage custom resources of Glassfish domains"
  ensurable
  
  newparam(:name) do
    desc "The custom resource name."
    isnamevar
  end
  
  newparam(:restype) do
    desc "The type of custom resource to be created. Specify a fully qualified type definition, for example javax.naming.spi.ObjectFactory. The resource type definition follows the format, xxx.xxx.xxx"
    
    validate do |value|
      if /^(?:[a-zA-Z_$][a-zA-Z\d_$]*\.)*[A-Z$][a-zA-Z\d_$]{1,}$/.match(value).nil?
        raise ArgumentError, "%s is not valid Java fully qualified type name" % value
      end
    end
  end
  
  newparam(:factoryclass) do
    desc "Factory class name for the custom resource. This class implements the javax.naming.spi.ObjectFactory interface."
    
    validate do |value|
      if /^(?:[a-zA-Z_$][a-zA-Z\d_$]*\.)*[A-Z$][a-zA-Z\d_$]{1,}$/.match(value).nil?
        raise ArgumentError, "%s is not valid Java fully qualified type name" % value
      end
    end
  end
  
  newparam(:properties) do
    desc "Optional attribute name/value pairs for configuring the resource. As String or Hash. Eg: \"user=myuser:password=mypass\""
  end

  newparam(:portbase) do
    desc "The Glassfish domain port base. Default: 4800"
    defaultto '4800'

    validate do |value|
      raise ArgumentError, "%s is not a valid portbase." % value unless value =~ /^\d{4,5}$/
    end

    munge do |value|
      case value
      when String
        if value =~ /^[-0-9]+$/
          value = Integer(value)
        end
      end

      return value
    end
  end

  newparam(:asadminuser) do
    desc "The internal Glassfish user asadmin uses. Default: admin"
    defaultto "admin"

    validate do |value|
      unless value =~ /^[\w-]+$/
         raise ArgumentError, "%s is not a valid asadmin user name." % value
      end
    end
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
      unless user =~ /^[\w-]+$/
         raise ArgumentError, "%s is not a valid user name." % user
      end
    end
  end
  
  # Autorequire the user running command
  autorequire(:user) do
    self[:user]    
  end
  
  # Autorequire the domain resource, based on portbase
  autorequire(:domain) do
    self.catalog.resources.select { |res|
      next unless res.type == :domain
      res if res[:portbase] == self[:portbase]
    }.collect { |res|
      res[:name]
    }
  end
end 