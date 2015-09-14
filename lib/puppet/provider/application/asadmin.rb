$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..","..",".."))
require 'puppet/provider/asadmin'

Puppet::Type.type(:application).provide(:asadmin, :parent =>
Puppet::Provider::Asadmin) do
  desc "Glassfish application deployment support."
  def create
    args = Array.new
    args << "deploy" << "--precompilejsp=true"
    args << "--target" << @resource[:target] if @resource[:target]
    args << "--contextroot" << @resource[:contextroot] if @resource[:contextroot]
    args << "--name" << @resource[:name]
    args << @resource[:source]

    asadmin_exec(args)
  end

  def destroy
    args = Array.new
    args << "undeploy"
    args << "--target" << @resource[:target]
    args << @resource[:name]

    asadmin_exec(args)
  end

  def exists?
    args = Array.new
    args << "list-applications"
    args << @resource[:target] if @resource[:target]

    asadmin_exec(args).each do |line|
      return true if @resource[:name] == line.split(" ")[0]
    end
    return false
  end
end
