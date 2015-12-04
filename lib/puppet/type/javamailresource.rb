$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..","..",".."))

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

  newparam(:storeprotocol) do
    desc "The mail server store protocol. The default is imap. Change this value only if you have reconfigured the GlassFish Server's mail provider to use a non-default store protocol."
  end

  newparam(:storeprotocolclass) do
    desc "The mail server store protocol class name. The default is com.sun.mail.imap.IMAPStore. Change this value only if you have reconfigured the GlassFish Server's mail provider to use a nondefault store protocol."
  end

  newparam(:transprotocol) do
    desc "The mail server transport protocol. The default is smtp. Change this value only if you have reconfigured the GlassFish Server's mail provider to use a nondefault transport protocol."
  end

  newparam(:transprotocolclass) do
    desc "The mail server transport protocol class name. The default is com.sun.mail.smtp.SMTPTransport. Change this value only if you have reconfigured the GlassFish Server's mail provider to use a nondefault transport protocol."
  end

  newparam(:debug) do
    desc "If set to true, the server starts up in debug mode for this resource. If the JavaMail log level is set to FINE or FINER, the debugging output will be generated and will be included in the server log file. The default value is false."
  end

  newparam(:enabled) do
    desc "If set to true, the resource is enabled at runtime. The default value is true."
  end

  newparam(:properties) do
    desc "The properties. Ex. jaas-context=agentRealm. Seperate multiple pairs using :."
  end

  newparam(:description) do
    desc "The object description"
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
