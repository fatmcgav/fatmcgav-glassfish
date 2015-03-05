require 'puppet/provider/asadmin'

Puppet::Type.type(:resourceref).provide(:asadmin, :parent =>
  Puppet::Provider::Asadmin) do
  desc "Glassfish resource reference support."

  def create
    args = Array.new
    args << 'create-resource-ref'
    args << "--target" << @resource[:target] if @resource[:target]
    args << @resource[:name]

    asadmin_exec(args)
  end

  def destroy
    args = Array.new
    args << 'delete-resource-ref'
    args << 'target' << @resource[:target] if @resource[:target]
    args << @resource[:name]

    asadmin_exec(args)
  end

  def exists?
    args = Array.new
    args << "list-resource-refs"
    args << @resource[:target] if @resource[:target]

    asadmin_exec(args).each do |line|
      return true if @resource[:name] == line.chomp
    end
    return false
  end
end
