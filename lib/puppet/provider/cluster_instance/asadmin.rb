require 'puppet/provider/asadmin'
Puppet::Type.type(:cluster_instance).provide(:asadmin,
                                   :parent => Puppet::Provider::Asadmin) do
  desc "Glassfish Cluster Instance support."

  def create
    # Start a new args array
    args = Array.new
    args << "create-instance"
    args << "--node" << @resource[:nodename]
    args << "--cluster" << @resource[:cluster]
    args << "--portbase" << @resource[:portbase] if @resource[:portbase]
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
    asadmin_exec(["list-instances"]).each do |line|
      instance = line.split(" ")[0] if line.match(/running/) # Glassfish > 3.0.1
      return true if @resource[:name] == instance
    end
    return false
  end
end
