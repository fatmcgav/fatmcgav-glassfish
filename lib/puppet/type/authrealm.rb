Puppet::Type.newtype(:authrealm) do
  @doc = "Manage authentication realms of Glassfish domains"
  ensurable

  newparam(:name) do
    desc "The realm name."
    isnamevar
    
    validate do |name|
      unless name =~ /^[\w-]+$/
         raise ArgumentError, "%s is not a valid realm name." % name
      end
    end
  end

  newparam(:classname) do
    desc "The Java class name. Eg: com.sun.identity.agents.appserver.v81.AmASRealm"
    validate do |classname|
      if /^(?:[a-zA-Z_$][a-zA-Z\d_$]*\.)*[A-Z$][a-zA-Z\d_$]{1,}$/.match(classname).nil?
        raise ArgumentError, "%s is not a valid Java fully qualified type name" % classname
      end
    end
  end

  newparam(:properties) do
    desc "The properties. Eg: jaas-context=agentRealm"
  end

  newparam(:isdefault) do
    desc "Sets realm to default if true."
    defaultto(:false)
    newvalues(:true, :false)
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
  
  # Validate mandatory params
  validate do
    raise Puppet::Error, 'Classname is required.' unless self[:classname]
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
