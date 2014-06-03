require 'puppet/provider/asadmin'
Puppet::Type.type(:javamailresource).provide(:asadmin, :parent => Puppet::Provider::Asadmin) do
  desc "Glassfish javamail resources support."

  def create
    args = []
    args << "create-javamail-resource"
    args << "--mailhost" << @resource[:mailhost]
    args << "--mailuser" << @resource[:mailuser]
    args << "--fromaddress" << @resource[:fromaddress]
    args << @resource[:name]
    asadmin_exec(args)
  end

  def destroy
    args = []
    args << "delete-javamail-resource" << @resource[:name]
    asadmin_exec(args)
  end

  def exists?
    asadmin_exec(["list-javamail-resources"]).each do |line|
      return true if @resource[:name] == line.chomp
    end
    return false
  end
  
end
