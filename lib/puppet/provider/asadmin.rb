class Puppet::Provider::Asadmin < Puppet::Provider
  
  def asadmin_exec(passed_args)
    
    # Use dashost if present
    if @resource.parameters.include?(:dashost)
      host = @resource[:dashost]
    end
    
    # Use dasport first, and then fallback to portbase
    if @resource.parameters.include?(:dasport)
      port = @resource[:dasport]
    else
      port = @resource[:portbase].to_i + 48
    end

    # Compile an array of command args
    args = Array.new
    args << '--host' << host if host && !host.nil?
    args << '--port' << port.to_s
    args << '--user' << @resource[:asadminuser]
    # Only add passwordfile if specified
    args << '--passwordfile' << @resource[:passwordfile] if @resource[:passwordfile] and
      not @resource[:passwordfile].empty?
        
    # Need to add the passed_args to args array.  
    passed_args.each { |arg| args << arg }
    
    # Transform args array into a exec args string.  
    exec_args = args.join " "
    command = "asadmin #{exec_args}"
    Puppet.debug("asadmin command = #{command}")
    
    # Compile the actual command as the specified user. 
    command = "su - #{@resource[:user]} -c \"#{command}\"" if @resource[:user] and
      not command.match(/create-service/)
    # Debug output of command if required. 
    Puppet.debug("exec command = #{command}")
    
    # Execute the command. 
    output = `#{command}`
    # Check return code and fail if required
    self.fail output unless $? == 0
    
    # Split into array, for later processing...
    result = output.split(/\n/)
    Puppet.debug("result = \n#{result.inspect}")

    # Return the result
    result
  end

  def escape(value)
    # Add three backslashes to escape the colon
    return value.gsub(/:/) { '\\:' }
  end
  
  # def exists?
  #     commands :asadmin => "#{@@asadmin}"
  #     version = asadmin('version')
  #     return false if version.length == 0
      
      # version.each do |line|
      #   if line =~ /(Version)/
      #     return true
      #   else 
      #     return false
      #   end
      # end
  # end
  
  protected
  
  def hasProperties?(props)
    unless props.nil?
      return (not props.to_s.empty?)
    end
    return false
  end
  
  def prepareProperties(properties)
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
      list << "#{rkey}=\\\"#{rvalue}\\\""
    end
    return list.sort!.join(':')
  end   
    
end
