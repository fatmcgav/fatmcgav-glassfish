class Puppet::Provider::Asadmin < Puppet::Provider

  def asadmin_exec(passed_args)
    port = @resource[:portbase].to_i + 48
    # Compile an array of command args
    args = Array.new
    args << "--port" << port.to_s
    args << "--user" << @resource[:asadminuser]
    # Only add passwordfile if specified
    args << "--passwordfile" << @resource[:passwordfile] if @resource[:passwordfile] and
      not @resource[:passwordfile].empty?
        
    # Need to add the passed_args to args array.  
    passed_args.each { |arg| args << arg }
    
    # Transform args array into a exec args string.  
    exec_args = args.join " "
    command = "#{@resource[:asadminpath]} #{exec_args}"
    Puppet.debug("Command = #{command}")
    
    # Compile the actual command as the specified user. 
    command = "su - #{@resource[:user]} -c \"#{command}\"" if @resource[:user] and
      not command.match(/create-service/)
    # Debug output of command if required. 
    self.debug command
    
    # Execute the command, and check the result. 
    result = `#{command}`
    self.fail result unless $? == 0
    
    # Return the result
    result
  end

  def escape(value)
    # Add three backslashes to escape the colon
    return value.gsub(/:/) { '\\:' }
  end
  
  def exists?
      commands :asadmin => "#{@resource[:asadminpath]}"
      version = asadmin("version")
      return false if version.length == 0
      
      version.each do |line|
        if line =~ /(Version)/
          return true
        else 
          return false
        end
      end
  end
  
  protected
  
  def hasProperties? props
    unless props.nil?
      return (not props.to_s.empty?)
    end
    return false
  end
  
  def prepareProperties properties
    if properties.is_a? String
      return properties
    end
    if properties.is_a? Array
      return properties.join(':')
    end
    if not properties.is_a? Hash
      return properties.to_s
    end
    list = []
    properties.each do |key, value|
      rkey = key.to_s.gsub(/([=:])/, '\\\\\\1')
      rvalue = value.to_s.gsub(/([=:])/, '\\\\\\1')
      list << "#{rkey}=#{rvalue}"
    end
    return list.join(':')
  end   
    
end
