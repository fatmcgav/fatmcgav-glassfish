class Puppet::Provider::Asadmin < Puppet::Provider

  def asadmin_exec(passed_args)
    port = @resource[:portbase].to_i + 48
    args = []
    args << "--port" << port.to_s
    args << "--user" << @resource[:asadminuser]
    args << "--passwordfile" << @resource[:passwordfile]
    passed_args.each { |arg| args << arg }
    exec_args = args.join " "
    command = "#{@resource[:asadminpath]} #{exec_args}"
    Puppet.debug("Command = #{command}")
    command = "su - #{@resource[:user]} -c \"#{command}\"" if @resource[:user] and
      not command.match(/create-service/)
    self.debug command
    result = `#{command}`
    self.fail result unless $?.exitstatus == 0
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
    
    
end
