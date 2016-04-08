$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..","..",".."))
require 'puppet/provider/asadmin'

Puppet::Type.type(:httplistener).provide(:asadmin, :parent => Puppet::Provider::Asadmin) do
  desc "Glassfish http listener management."

  def create
    args = Array.new
    args << "create-http-listener"
    if @resource[:listeneraddress]
      args << "--listeneraddress" << @resource[:listeneraddress]
    end
    args << "--listenerport" << @resource[:listenerport]
    if @resource[:defaultvirtualserver]
      args << "--defaultvs" << @resource[:defaultvirtualserver]
    end
    if @resource[:servername]
      args << "--servername" << @resource[:servername]
    end
    if @resource[:acceptorthreads]
      args << "--acceptorthreads" << @resource[:acceptorthreads]
    end
    if @resource[:securityenabled]
      args << "--securityenabled" << @resource[:securityenabled]
    end
    if @resource[:enabled]
      args << "--enabled" << @resource[:enabled]
    end
    args << @resource[:name]

    asadmin_exec(args)
  end

  def destroy
    args = Array.new
    args << "delete-http-listener" << @resource[:name]
    asadmin_exec(args)
  end

  def exists?
    args = [
      "list-http-listeners",
      @resource[:target],
    ]
    return true if asadmin_exec(args).include?(@resource[:name])
    return false
  end
end
