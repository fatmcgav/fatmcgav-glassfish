require 'puppet/provider/asadmin'

Puppet::Type.type(:authrealm).provide(:asadmin, :parent =>
Puppet::Provider::Asadmin) do
  desc "Glassfish authentication realms support."
  def create
    args = Array.new
    args << "create-auth-realm"
    args << "--target" << @resource[:target] if @resource[:target]
    args << "--classname" << @resource[:classname]
    if hasProperties? @resource[:properties]
      args << "--property"
      args << "#{prepareProperties @resource[:properties]}"
    end
    args << @resource[:name]

    asadmin_exec(args)
  end

  def destroy
    args = Array.new
    args << 'delete-auth-realm'
    args << "--target" << @resource[:target]
    args << @resource[:name]

    asadmin_exec(args)
  end

  def exists?
    args = Array.new
    args << "list-auth-realms"
    args << @resource[:target] if @resource[:target]

    asadmin_exec(args).each do |line|
      return true if @resource[:name] == line.split(" ")[0]
    end
    return false
  end
end
