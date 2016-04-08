$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..","..",".."))

Puppet::Type.newtype(:httplistener) do
  @doc = "Manage Glassfish http listeners"

  ensurable

  newparam(:name) do
    desc "The Glassfish http listener name."
    isnamevar

    validate do |value|
      unless value =~ /^[\w-]+$/
         raise ArgumentError, "%s is not a valid listener name." % value
      end
    end
  end

  newparam(:listeneraddress) do
    desc "The Glassfish listener address - IP or hostname."

    validate do |value|
      unless value =~ /^[a-zA-Z0-9\.-]+$/
        raise ArgumentError, "Address should be an IP address or hostname."
      end
    end
  end

  newparam(:listenerport) do
    desc "The Glassfish listener port"

    validate do |value|
      raise ArgumentError, "%s is not a valid listener port." % value unless value =~ /^\d{4,5}$/
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

  newparam(:defaultvirtualserver) do
    desc "The ID attribute of the default virtual server for this listener."
    defaultto "server"
  end

  newparam(:servername) do
    desc "Tells the server what to put in the host name section of any URLs it sends to the client."
  end

  newparam(:acceptorthreads) do
    desc "The number of acceptor threads for the listener socket."
    defaultto "1"
  end

  newparam(:xpowered) do
    desc "If set to true, adds the X-Powered-By: Servlet/3.0 and X-Powered-By: JSP/2.0 headers to the appropriate responses."
    defaultto "true"
  end

  newparam(:securityenabled) do
    desc "If set to true, the HTTP listener runs SSL. You can turn SSL2 or SSL3 ON or OFF and set ciphers using an SSL element. The security setting globally enables or disables SSL by making certificates available to the server instance. The default value is false."
    defaultto "false"
  end

  newparam(:enabled) do
    desc "Whether this Glassfish listener is enabled at runtime"
    defaultto :true
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
    required_params = [ :listenerport, :listeneraddress ]
    required_params.each do |param|
      if not self[param] then
        raise Puppet::Error, "httplistener:#{param} is required"
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
