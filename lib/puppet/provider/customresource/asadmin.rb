require 'puppet/provider/asadmin'
Puppet::Type.type(:customresource).provide(:asadmin, :parent => Puppet::Provider::Asadmin) do
  desc "Glassfish custom resources support."

  commands :asadmin => "#{Puppet::Provider::Asadmin.asadminpath}"

  def create
    args = []
    args << "create-custom-resource"
    args << "--restype" << @resource[:restype]
    args << "--factoryclass" << @resource[:factoryclass]
    if hasProperties? @resource[:properties]
      args << "--property"
      args << "\"#{prepareProperties @resource[:properties]}\""
    end    
    args << @resource[:name]
    asadmin_exec(args)
  end

  def destroy
    args = []
    args << "delete-custom-resource" << @resource[:name]
    asadmin_exec(args)
  end

  def exists?
    asadmin_exec(["list-custom-resources"]).each do |line|
      return true if @resource[:name] == line.chomp
    end
    return false
  end
  
end
