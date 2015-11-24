require 'puppet/provider/asadmin'
Puppet::Type.type(:javamailresource).provide(:asadmin, :parent => Puppet::Provider::Asadmin) do
  desc "Glassfish javamail resources support."

  def create
    args = []
    args << "create-javamail-resource"
    args << "--target" << @resource[:target] if @resource[:target]
    args << "--mailhost" << @resource[:mailhost]
    args << "--mailuser" << @resource[:mailuser] if @resource[:mailuser]
    args << "--fromaddress" << @resource[:fromaddress]
    if hasProperties? @resource[:properties]
      args << "--property"
      args << "\'#{prepareProperties @resource[:properties]}\'"
    end
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
      return true if @resource[:name] == line.strip
    end
    return false
  end

end
