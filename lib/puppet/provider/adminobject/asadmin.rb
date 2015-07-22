require 'puppet/provider/asadmin'

Puppet::Type.type(:adminobject).provide(:asadmin, :parent =>
Puppet::Provider::Asadmin) do
  desc "Glassfish Admin Object support."
  def create
    args = Array.new
    args << 'create-admin-object'
    args << "--target" << @resource[:target] if @resource[:target]
    args << '--restype' << @resource[:restype]
    args << '--classname' << @resource[:classname] if @resource[:classname]
    args << '--raname' << @resource[:raname]
    if hasProperties? @resource[:properties]
      args << '--property'
      args << "\'#{prepareProperties @resource[:properties]}\'"
    end
    args << '--enabled' << @resource[:enabled] if @resource[:enabled]
    args << '--description' << "\'#{@resource[:description]}\'" if @resource[:description] and not @resource[:description].empty?
    args << @resource[:name]

    asadmin_exec(args)
  end

  def destroy
    args = Array.new
    args << 'delete-admin-object'
    args << 'target' << @resource[:target] if @resource[:target]
    args << @resource[:name]

    asadmin_exec(args)
  end

  def exists?
    args = Array.new
    args << "list-admin-objects"
    args << @resource[:target] if @resource[:target]

    asadmin_exec(args).each do |line|
      return true if @resource[:name] == line.chomp
    end
    return false
  end
end
