class Puppet::Provider::Asadmin < Puppet::Provider

  @@glversion = `cat /etc/glassfish-version` # Default Glassfish version
  @@gldir     = "glassfish"
  @@glpath    = "/usr/local/lib/#{@@gldir}" # Default Glassfish path
  @@asadmin   = "#{@@glpath}/bin/asadmin"
  
  def self.asadminpath
    @@asadmin
  end
  
  def asadmin_exec(passed_args)
    port = @resource[:portbase].to_i + 48
    args = []
    args << "--port" << port.to_s
    args << "--user" << @resource[:asadminuser]
    args << "--passwordfile" << @resource[:passwordfile] if @resource[:passwordfile] and 
      not @resource[:passwordfile].empty?
    passed_args.each { |arg| args << arg }
    exec_args = args.join " "
    command = "#{@@asadmin} #{exec_args}"
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
      commands :asadmin => "#{@@asadmin}"
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
      return properties.join ':'
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
    return list.join ':'
  end  
    
end
