Puppet::Type.newtype(:cluster_node) do
  @doc = "Manage Glassfish cluster nodes"

  ensurable

  newparam(:nodename) do
    desc "The Glassfish node name."
    isnamevar

    validate do |value|
      unless value =~ /^[\w-]+$/
         raise ArgumentError, "%s is not a valid node name." % value
      end
    end
  end
  
  newparam(:host) do
    desc "The name of the host that the node represents. The name
    of  the  host  must  be  specified. Otherwise, an error
    occurs."
  end
  
  newparam(:sshport) do
    desc "The port to use for  SSH  connections  to  this  node's
    host.  The  default  is 22. If the --nodehost option is
    set  to  localhost-domain,  the  --sshport  option   is
    ignored."
    defaultto '22'
    
    validate do |value|
      raise ArgumentError, "%s is not a valid SSH port." % value unless value =~ /^\d*$/
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
  
  newparam(:sshuser) do 
    desc "The user on this node's host that is to run the process
    for  connecting to the host through SSH. The default is
    the user that is running the  DAS  process.  To  ensure
    that the DAS can read this user's SSH private key file,
    specify the user that is running the  DAS  process.  If
    the  --nodehost  option is set to localhost-domain, the
    --sshuser option is ignored."

    validate do |value|
      unless Puppet.features.root?
        self.fail "Only root can execute commands as other users"
      end
      unless value =~ /^[\w-]+$/
         raise ArgumentError, "%s is not a valid ssh user name." % value
      end
    end
  end
  
  newparam(:sshkeyfile) do 
    desc "The absolute path to the SSH private key file for  user
    that  the --sshuser option specifies. This file is used
    for authentication to the sshd  daemon  on  the  node's
    host.
    
    The path to the key file must be reachable by  the  DAS
    and the key file must be readable by the DAS.

    The default is the a key file in the user's .ssh direc-
    tory.  If  multiple key files are found, the subcommand
    uses the following order of preference:
    1.  id_rsa
    2.  id_dsa
    3.  identity"
    
    validate do |value|
      unless File.exists? value
        raise ArgumentError, "%s does not exists" % value
      end
    end
  end
  
  newparam(:install) do 
    desc "Specifies whether  the  subcommand  shall  install  the
    GlassFish  Server  software  on  the host that the node
    represents. Default: false"
    defaultto(:false)
    newvalues(:true, :false)
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
    raise Puppet::Error, 'Host is required.' unless self[:host]
  end
  
  # Autorequire the user running command
  autorequire(:user) do
    self[:user]    
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
