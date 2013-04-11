require 'puppet/provider/asadmin'
Puppet::Type.type(:jdbcconnectionpool).provide(:asadmin, :parent =>
                                           Puppet::Provider::Asadmin) do
  desc "Glassfish JDBC connection pool support."
  
  commands :asadmin => "#{Puppet::Provider::Asadmin.asadminpath}"


  def create
    args = []
    args << "create-jdbc-connection-pool"
    args << "--datasourceclassname" << @resource[:datasourceclassname]
    args << "--restype" << @resource[:resourcetype]
    args << "--property"
    args << "\"#{prepareProperties @resource[:properties]}\""
    args << @resource[:name]
    asadmin_exec(args)
  end

  def destroy
    args = []
    args << "delete-jdbc-connection-pool" << @resource[:name]
    asadmin_exec(args)
  end

  def exists?
    asadmin_exec(["list-jdbc-connection-pools"]).each do |line|
      return true if @resource[:name] == line.chomp
    end
    return false
  end
  
  private
  def prepareProperties properties
    if properties.is_a? String
      return properties
    end
    if not properties.is_a? Hash
      return properties.to_s
    end
    list = []
    properties.each do |key, value|
      rkey = key.gsub(/([=:])/, '\\\\\\1')
      rvalue = value.gsub(/([=:])/, '\\\\\\1')
      list << "#{rkey}=#{rvalue}"
    end
    Puppet.debug("Properties = #{list}")
    return list.join ':'
  end
end
