require 'puppet/provider/asadmin'
Puppet::Type.type(:cluster).provide(:asadmin,
                                   :parent => Puppet::Provider::Asadmin) do
  desc "Glassfish Cluster support."

  def create
    # Start a new args array
    args = Array.new
    args << "create-cluster"
    args << "--gmsenabled" << @resource[:gmsenabled] if @resource[:gmsenabled]
    args << "--multicastport" << @resource[:multicastport] if @resource[:multicastport]
    args << "--multicastaddress" << @resource[:multicastaddress] if @resource[:multicastaddress]
    args << @resource[:name]
    
    # Run the create command
    asadmin_exec(args)

  end

  def destroy
    args = Array.new
    args << "delete-cluster" << @resource[:name]
    asadmin_exec(args)
  end

  def exists?
    asadmin_exec(["list-clusters"]).each do |line|
      cluster = line.split(" ")[0] if line.match(/running/) # Glassfish > 3.0.1
      return true if @resource[:name] == cluster
    end
    return false
  end
end
