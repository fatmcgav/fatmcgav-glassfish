require 'puppet/provider/asadmin'
Puppet::Type.type(:cluster_node).provide(:asadmin,
                                   :parent => Puppet::Provider::Asadmin) do
  desc "Glassfish Node support."

  def create
    # Start a new args array
    args = Array.new
    args << "create-node-ssh"
    args << "--nodehost" << @resource[:host]
    # SSH details are optional
    args << "--sshport" << @resource[:sshport] if @resource[:sshport]
    args << "--sshuser" << @resource[:sshuser] if @resource[:sshuser]
    args << "--sshkeyfile" << @resource[:sshkeyfile] if @resource[:sshkeyfile]
    # Optionally install GF software
    args << "--install" << @resource[:install] if @resource[:install]
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
    asadmin_exec(["list-nodes"]).each do |line|
      node = line.split(" ")[0] if line.match(/SSH/) # Glassfish > 3.0.1
      return true if @resource[:name] == node
    end
    return false
  end
end
