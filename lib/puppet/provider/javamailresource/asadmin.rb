require 'puppet/provider/asadmin'
Puppet::Type.type(:javamailresource).provide(:asadmin, :parent => Puppet::Provider::Asadmin) do
  desc "Glassfish javamail resources support."

  def create
    args = []
    args << "create-javamail-resource"
    args << "--target" << @resource[:target] if @resource[:target]
    args << "--mailhost" << @resource[:mailhost]
    args << "--mailuser" << @resource[:mailuser]
    args << "--fromaddress" << @resource[:fromaddress]
    args << "--storeprotocol" << @resource[:storeprotocol] if @resource[:storeprotocol]
    args << "--storeprotocolclass" << @resource[:storeprotocolclass] if @resource[:storeprotocolclass]
    args << "--transprotocol" << @resource[:transprotocol] if @resource[:transprotocol]
    args << "--transprotocolclass" << @resource[:transprotocolclass] if @resource[:transprotocolclass]
    args << "--debug" << @resource[:debug] if @resource[:debug]
    args << '--description' << "\'#{@resource[:description]}\'" if @resource[:description] and not @resource[:description].empty?
    args << "--enabled" << @resource[:enabled] if @resource[:enabled]
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
      return true if @resource[:name] == line.chomp
    end
    return false
  end
  
end
