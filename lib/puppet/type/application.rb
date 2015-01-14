Puppet::Type.newtype(:application) do
  @doc = "Manage applications of Glassfish domains"
  ensurable

  newparam(:name) do
    desc "The application name."
    isnamevar

    validate do |value|
      unless value =~ /^[\w\-\.]+$/
         raise ArgumentError, "%s is not a valid application name." % value
      end
    end
  end

  newparam(:contextroot) do
    desc "The URL context root."
    #defaultto ""
  end

  newparam(:source) do
    desc "The application file to deploy."
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

    validate do |value|
      unless Puppet.features.root?
        self.fail "Only root can execute commands as other users"
      end
      unless value =~ /^[\w-]+$/
         raise ArgumentError, "%s is not a valid user name." % value
      end
    end
  end
  
  # Validate mandatory params
  validate do
    raise Puppet::Error, 'Source is required.' if self[:source].nil? and self[:ensure] == :present
  end
  
  # Autorequire the user running command
  autorequire(:user) do
    self[:user]    
  end
  
  # Autorequire the source application file
  autorequire(:file) do 
    self[:source]
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
