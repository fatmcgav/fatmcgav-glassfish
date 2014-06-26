Puppet::Type.newtype(:javamailresource) do
  @doc = "Manage javamail resources of Glassfish domains"
  ensurable
  
  newparam(:name) do
    desc "The resource name."
    isnamevar
    
    validate do |value|
      unless value =~ /^[^\W]?[\w\-\.\/]+$/
         raise ArgumentError, "%s is not a valid JavaMail resource name." % value
      end
    end
  end

  newparam(:mailhost) do
    desc "The mail server address."
  end

  newparam(:fromaddress) do
    desc "The mail from address."
  end

  newparam(:mailuser) do
    desc "The mail user name."
  end

  newparam(:target) do
    desc "This option helps specify the target to which you  are deploying. 
    Valid options are: server, domain, [cluster name], [instance name]. 
    Defaults to: server"
    defaultto "server"
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
