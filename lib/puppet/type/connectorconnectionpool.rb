Puppet::Type.newtype(:connectorconnectionpool) do
  @doc = "Adds a connection pool with the specified connection pool name"


  ensurable

  newparam(:name) do
    desc "The connection pool name."
    isnamevar
  end

  newparam(:raname) do
    desc "The name of the resource adapter."
  end

  newparam(:connectiondefinition) do
    desc "The name of the connection definition."
  end

  newparam(:steadypoolsize) do
    desc "The minimum and initial number of connections maintained in the pool. Default value is 8."
  end

  newparam(:maxpoolsize) do
    desc "The maximum number of connections that can be created to satisfy client requests. Default value is 32."
  end

  newparam(:poolresize) do
    desc "Quantity by which the pool will scale up or scale down the number of connections."
  end

  newparam(:isconnectvalidatereq) do
    desc "If the value is set to true, the connections will be checked to see if they are usable, before they are given out to the application. Default value is false."
  end

  newparam(:failconnection) do
    desc "If set to true, all connections in the pool are closed if a single validation check fails. This parameter is mandatory if the --isconnectvalidatereq option is set to true. Default value is false."
  end

  newparam(:leaktimeout) do
    desc "Specifies the amount of time, in seconds, for which connection leaks in a connection pool are to be traced. If connection leak tracing is enabled, you can use the Administration Console to enable monitoring of the JDBC connection pool to get statistics on the number of connection leaks. Default value is 0, which disables connection leak tracing."
  end

  newparam(:creationretryattempts) do
    desc "Specifies the maximum number of times that the server retries to create a connection if the initial attempt fails."
  end

  newparam(:creationretryinterval) do
    desc "Specifies the interval, in seconds, between successive attempts to create a connection."
  end

  newparam(:leakreclaim) do
    desc "Specifies whether leaked connections are restored to the connection pool after leak connection tracing is complete."
  end

  newparam(:maxconnectionusagecount) do
    desc "Specifies the maximum number of times that a connection can be reused."
  end

  newparam(:validateatmostonceperiod) do
    desc "Specifies the time interval in seconds between successive requests to validate a connection at most once. Setting this attribute to an appropriate value minimizes the number of validation requests by a connection."
  end

  newparam(:transactionsupport) do
    desc "Indicates the level of transaction support that this pool will have. Possible values are XATransaction, LocalTransaction and NoTransaction. This attribute can have a value lower than or equal to but not higher than the resource adapter's transaction support attribute. The resource adapter's transaction support attribute has an order of values, where XATransaction is the highest, and NoTransaction the lowest."
  end

  newparam(:description) do
    desc "The object description"
  end

  newparam(:ping) do
    desc "A pool with this attribute set to true is contacted during creation (or reconfiguration) to identify and warn of any erroneous values for its attributes. Default value is false."
  end

  newparam(:pooling) do
    desc "When set to false, this attribute disables connection pooling. Default value is true."
  end

  newparam(:maxwait) do
    desc "The amount of time, in milliseconds, that a caller must wait before a connection is created, if a connection is not available."
  end

  newparam(:idletimeout) do
    desc "The maximum time that a connection can remain idle in the pool."
  end

  newparam(:properties) do
    desc "The properties. Ex. a=b:c=d"
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

  # Autorequire the domain resource, based on portbase
  autorequire(:domain) do
    self.catalog.resources.select { |res|
      next unless res.type == :domain
      res if res[:portbase] == self[:portbase]
    }.collect { |res|
      res[:name]
    }
  end


  # Validate mandatory params
  validate do
    raise Puppet::Error, 'raname is required.' unless self[:raname]
    raise Puppet::Error, 'connectiondefinition is required.' unless self[:connectiondefinition]
  end

end
