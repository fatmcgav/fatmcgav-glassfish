require 'puppet/provider/asadmin'
Puppet::Type.type(:connectorresource).provide(:asadmin, :parent =>
                                           Puppet::Provider::Asadmin) do
  desc "Glassfish Connector Resource registers the connector resource with the specified JNDI name"


  def create
    args = Array.new
    args << "create-connector-resource"
    args << "--target" << @resource[:target] if @resource[:target]
    args << "--poolname" << @resource[:poolname]
    args << "--enabled" << @resource[:enabled] if @resource[:enabled]
    args << '--description' << "\'#{@resource[:description]}\'" if @resource[:description] and not @resource[:description].empty?
    args << "--objecttype" << @resource[:objecttype] if @resource[:objecttype]
    args << @resource[:name]
    asadmin_exec(args)
  end

  def destroy
    args = Array.new
    args << "delete-connector-resource" << @resource[:name]
    asadmin_exec(args)
  end

  def exists?
    asadmin_exec(["list-connector-resources"]).each do |line|
      return true if @resource[:name] == line.strip
    end
    return false
  end
end
