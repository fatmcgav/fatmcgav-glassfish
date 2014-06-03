Puppet::Type.newtype(:jdbcconnectionpool) do
  @doc = "Manage JDBC connection pools of Glassfish domains"

  ensurable

  newparam(:name) do
    desc "The JDBC connection pool name."
    isnamevar
  end

  newparam(:dsclassname) do
    desc "The data source class name. Ex. com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource"
  end

  newparam(:resourcetype) do
    desc "The resource type. Ex. javax.sql.ConnectionPoolDataSource"
  end

  newparam(:properties) do
    desc "The properties. Ex. user=myuser:password=mypass:url=jdbc\:mysql\://myhost.ex.com\:3306/mydatabase"
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
    raise Puppet::Error, 'Dsclassname is required.' unless self[:dsclassname]
    raise Puppet::Error, 'Resourcetype is required.' unless self[:resourcetype]
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
end
