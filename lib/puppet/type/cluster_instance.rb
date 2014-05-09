Puppet::Type.newtype(:cluster_instance) do
  @doc = "Manage Glassfish cluster instances"

  ensurable

  newparam(:instancename) do
    desc "The Glassfish instance name."
    isnamevar

    validate do |value|
      unless value =~ /^[\w-]+$/
         raise ArgumentError, "%s is not a valid instance name." % value
      end
    end
  end
  
  newparam(:nodename) do
    desc "The name of the node that defines the  host  where  the
    instance is to be created. The node must already exist.
    If the instance is to be created on the host where  the
    domain  administration server (DAS) is running, use the
    predefined node localhost-domain."
    
    validate do |value|
      unless value =~ /^[\w-]+$/
         raise ArgumentError, "%s is not a valid node name." % value
      end
    end
  end
  
  newparam(:cluster) do
    desc "Specifies the cluster from which the instance  inherits
    its  configuration.  Specifying  the  --cluster  option
    creates a clustered instance."
    
    validate do |value|
      unless value =~ /^[\w-]+$/
         raise ArgumentError, "%s is not a valid cluster name." % value
      end
    end
  end
  
  newparam(:portbase) do
    desc "Determines the number with which  the  port  assignment
    should  start.  An  instance  uses  a certain number of
    ports that are statically assigned. The portbase  value
    determines  where  the  assignment  should  start. 
    Default: 28000"
    defaultto '28000'

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
  
  newparam(:dashost) do
    desc "The Glassfish DAS hostname. "
  end
  
  newparam(:dasport) do
    desc "The Glassfish DAS port. Default: 4848"
    defaultto '4848'

    validate do |value|
      raise ArgumentError, "%s is not a valid das port." % value unless value =~ /^\d{4,5}$/
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
    raise Puppet::Error, 'Nodename is required.' unless self[:nodename]
    raise Puppet::Error, 'Cluster is required.' unless self[:cluster]
  end
  
  # Autorequire the user running command
  autorequire(:user) do
    self[:user]
  end
  
  # Autorequire the node the instance is being created on
  autorequire(:cluster_node) do
    self[:nodename]
  end
  
  # Autorequire the cluster the instance is being created in
  autorequire(:cluster) do
    self[:cluster]
  end
  
  # Autorequire the password file
  autorequire(:file) do
    self[:passwordfile] 
  end
  
  # Autorequire the das domain
  autorequire(:domain) do
    self.catalog.resources.select { |res|
      next unless res.type == :domain
      res if res[:portbase] == self[:dasport]-48
    }.collect { |res|
      res[:name]
    }
  end
end
