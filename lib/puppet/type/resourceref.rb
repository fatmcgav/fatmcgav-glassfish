$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..","..",".."))

Puppet::Type.newtype(:resourceref) do
  @doc = "Manage resources references for Glassfish domains"

  ensurable

  # Array of resources we can reference
  referenceable_resources = [:jdbcresource, :jmsresource, :javamailresource, :customresource]

  newparam(:name) do
    desc "The reference resource name."
    isnamevar

    validate do |value|
      unless value =~ /^\w+[\w=\-\/.]*$/
         raise ArgumentError, "%s is not a valid reference resource name." % value
      end
    end
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

  # Autorequire the user running command
  autorequire(:user) do
    self[:user]
  end

  # Autorequire the password file
  autorequire(:file) do
    self[:passwordfile]
  end

  # Autorequire the relevant domain
  autorequire(:domain) do
    self.catalog.resources.select { |res|
      next unless res.type == :domain
      res if res[:portbase] == self[:portbase]
    }.collect { |res|
      res[:name]
    }
  end

  # Autorequire the relevant resources
  referenceable_resources.each do |resource|
    autorequire(resource) do
      catalog.resources.select { |res|
        # Skip it if we're not interested in it...
        next unless res.type == resource

        # Match on resource name...
        res if res[:name] == self[:name]
      }.collect { |res|
        # Return resource name to autorequire
        res[:name]
      }
    end
  end
end
