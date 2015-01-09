require 'puppet/provider/asadmin'
Puppet::Type.type(:networklistener).provide(:asadmin, :parent => Puppet::Provider::Asadmin) do
  desc "Glassfish network listener management."

  def create
    args = Array.new
    args << "create-network-listener"
    if @resource[:address]
      args << "--address" << @resource[:address]
    end
    args << "--listenerport" << @resource[:port]
    if @resource[:threadpool]
      args << "--threadpool" << @resource[:threadpool]
    end
    args << "--transport" << @resource[:transport]
    args << "--protocol" << @resource[:protocol]
    args << "--enabled" << @resource[:enabled]
    args << "--jkenabled" << @resource[:jkenabled]
    args << "--target" << @resource[:target]
    args << @resource[:name]
    
    asadmin_exec(args)
  end

  def destroy
    args = Array.new
    args << "delete-network-listener" << @resource[:name]
    asadmin_exec(args)
  end

  def exists?
    args = [
      "list-network-listeners",
      @resource[:target],
    ]
    return true if asadmin_exec(args).include?(@resource[:name])
    return false
  end
end
