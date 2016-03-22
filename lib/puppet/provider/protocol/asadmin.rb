$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..","..",".."))
require 'puppet/provider/asadmin'

Puppet::Type.type(:protocol).provide(:asadmin, :parent => Puppet::Provider::Asadmin) do
  desc "Glassfish network protocol management."

  def create
    args = Array.new
    args << "create-protocol"
    args << "--securityenabled" << @resource[:securityenabled]
    args << "--target" << @resource[:target]
    args << @resource[:name]

    asadmin_exec(args)
  end

  def destroy
    args = Array.new
    args << "delete-protocol" << @resource[:name]
    args << "--target" << @resource[:target]
    asadmin_exec(args)
  end

  def exists?
    args = [
      "list-protocols",
      @resource[:target],
    ]
    return true if asadmin_exec(args).include?(@resource[:name])
    return false
  end
end
