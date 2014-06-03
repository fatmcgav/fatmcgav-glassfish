require 'ipaddr'

Puppet::Type.newtype(:cluster) do
  @doc = "Manage Glassfish clusters"

  ensurable

  newparam(:clustername) do
    desc "The Glassfish cluster name."
    isnamevar

    validate do |value|
      unless value =~ /^[\w-]+$/
         raise ArgumentError, "%s is not a valid cluster name." % value
      end
    end
  end

  newparam(:dashost) do
    desc "The Glassfish DAS hostname."
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
  
  newparam(:gmsenabled) do
    desc "Should Group Messaging service be enabled. Default: true"
    defaultto(:true)
    newvalues(:true, :false)
  end
  
  newparam(:multicastport) do
    desc "The port number of  communication  port  on  which  GMS
    listens  for  group  events. This option must specify a
    valid port number in the range 2048-49151. The default
    is an automatically generated value in this range"
    
    validate do |value|
      raise ArgumentError, "Multicast port must be between 2048 and 49151." unless value.to_i.between?(2048,49151)
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
  
  newparam(:multicastaddress) do
    desc "The address on which GMS listens for group events. This
    option  must  specify  a multicast address in the range
    224.0.0.0  through  239.255.255.255.  The  default   is
    228.9.XX.YY,  where  XX  and  YY are automatically gen-
    erated independent values between 0 and 255."
    
    validate do |value|
      begin
        # Create required IPAddr objects
        t = IPAddr.new(value).to_i
        low = IPAddr.new('224.0.0.0').to_i
        high = IPAddr.new('239.255.255.255').to_i
      rescue ArgumentError
        fail("Invalid value for multicastaddress: #{value}")
      end
      
      # Check that the value is between low and high thresholds        
      raise ArgumentError, "Multicast address must be between 224.0.0.0 and 239.255.255.255." unless t.between?(low,high)
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
