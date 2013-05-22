require 'puppet/provider/asadmin'
Puppet::Type.type(:jmsresource).provide(:asadmin, :parent =>
                                      Puppet::Provider::Asadmin) do
  desc "Glassfish JMS resource support."

  def create
    args = Array.new
    args << 'create-jms-resource'
    args << '--restype' << @resource[:restype]
    if hasProperties? @resource[:properties]
      args << '--property'
      args << "\"#{prepareProperties @resource[:properties]}\""
    end 
    args << '--description' << "\"#{@resource[:description]}\"" if @resource[:description] and
      not @resource[:description].empty?
    args << @resource[:name]
    asadmin_exec(args)
  end

  def destroy
    args = Array.new
    args << 'delete-jms-resource' << @resource[:name]
    asadmin_exec(args)
  end

  def exists?
    asadmin_exec(['list-jms-resources']).each do |line|
      return true if @resource[:name] == line.split(" ")[0]
    end
    return false
  end
end
