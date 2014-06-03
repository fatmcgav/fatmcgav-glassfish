require 'puppet/provider/asadmin'
Puppet::Type.type(:application).provide(:asadmin, :parent =>
                                           Puppet::Provider::Asadmin) do
  desc "Glassfish application deployment support."

  def create
    if @resource[:autodeploy] == :false then
      args = Array.new
      args << "deploy" << "--precompilejsp=true"
      args << "--contextroot" << @resource[:contextroot] if @resource[:contextroot]
      args << "--name" << @resource[:name]
      args << @resource[:source]
      asadmin_exec(args)
    end
  end

  def destroy
    args = Array.new
    args << "undeploy" << @resource[:name]
    asadmin_exec(args)
  end

  def exists?
    asadmin_exec(["list-applications"]).each do |line|
      return true if @resource[:name] == line.split(" ")[0]
    end
    return false
  end
end
