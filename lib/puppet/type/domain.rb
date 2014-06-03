Puppet::Type.newtype(:domain) do
  @doc = "Manage Glassfish domains"

  ensurable

  newparam(:domainname) do
    desc "The Glassfish domain name."
    isnamevar

    validate do |value|
      unless value =~ /^[\w-]+$/
         raise ArgumentError, "%s is not a valid domain name." % value
      end
    end
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
  
  newparam(:startoncreate) do
    desc "Start the domain immediately after it is created. Default: true"
    defaultto(:true)
    newvalues(:true, :false)
  end
  
  newparam(:enablesecureadmin) do
    desc "Should secure admin be enabled. Default: true"
    defaultto(:true)
    newvalues(:true, :false)
  end
  
  newparam(:template) do 
    desc "Path to Glassfish template to use when creating the domain"

    validate do |value|
      unless File.exists? value
        raise ArgumentError, "%s does not exist" % value
      end
    end
  end
  
  # Validate multiple param values
  validate do
    if self[:enablesecureadmin] == :true and self[:startoncreate] == :false
      raise Puppet::Error, "Enablesecureadmin cannot be true if startoncreate is false"
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
