$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..","..",".."))

Puppet::Type.newtype(:networklistener) do
  @doc = "Manage Glassfish network listeners"

  ensurable

  newparam(:name) do
    desc "The Glassfish network listener name."
    isnamevar

    validate do |value|
      unless value =~ /^[\w-]+$/
         raise ArgumentError, "%s is not a valid listener name." % value
      end
    end
  end

  newparam(:address) do
    desc "The Glassfish listener address - IP or hostname."

    validate do |value|
      unless value =~ /^[a-zA-Z0-9\.-]+$/
        raise ArgumentError, "Address should be an IP address or hostname."
      end
    end
  end

  newparam(:port) do
    desc "The Glassfish listener port"

    validate do |value|
      raise ArgumentError, "%s is not a valid port." % value unless value =~ /^\d{4,5}$/
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

  newparam(:threadpool) do
    desc "The Glassfish listener threadpool"

    validate do |value|
      unless value =~ /^[\w-]+$/
         raise ArgumentError, "%s is not a valid threadpool name." % value
      end
    end
  end

  newparam(:protocol) do
    desc "The Glassfish listener protocol"
  end

  newparam(:transport) do
    desc "The Glassfish listener transport"
    defaultto "tcp"
  end

  newparam(:enabled) do
    desc "Whether this Glassfish listener is enabled at runtime"
    defaultto :true
    newvalues(:true, :false)
  end

  newparam(:jkenabled) do
    desc "Whether mod_jk is enabled for this Glassfish listener"
    defaultto :false
    newvalues(:true, :false)
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
    defaultto 'admin'

    validate do |value|
      unless value =~ /^[\w-]+$/
         raise ArgumentError, "%s is not a valid asadmin user name." % value
      end
    end
  end

  newparam(:passwordfile) do
    desc "The file containing the password for the user."
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

  # Global validation
  validate do
    required_params = [ :port, :protocol ]
    required_params.each do |param|
      if not self[param] then
        raise Puppet::Error, "networklisterner:#{param} is required"
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
end
