require 'puppet/provider/asadmin'
Puppet::Type.type(:jdbcresource).provide(:asadmin, :parent =>
                                           Puppet::Provider::Asadmin) do
  desc "Glassfish JDBC connection pool support."

  def create
    args = Array.new
    args << "create-jdbc-resource"
    args << "--connectionpoolid" << @resource[:connectionpool]
    args << "--target" << @resource[:target] if @resource[:target]
    args << @resource[:name]
    asadmin_exec(args)
  end

  def destroy
    args = Array.new
    args << "delete-jdbc-resource" << @resource[:name]
    asadmin_exec(args)
  end

  def exists?
    args = Array.new
    args << "list-jdbc-resources"
    args << @resource[:target] if @resource[:target]

    asadmin_exec(args).each do |line|
      return true if @resource[:name] == line.strip
    end
    return false
  end
end
