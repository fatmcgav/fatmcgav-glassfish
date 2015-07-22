require 'puppet/provider/asadmin'
Puppet::Type.type(:connectorconnectionpool).provide(:asadmin, :parent =>
                                           Puppet::Provider::Asadmin) do
  desc "Glassfish Connector connection pool support."


  def create
    args = Array.new
    args << "create-connector-connection-pool"
    args << "--target" << @resource[:target] if @resource[:target]
    args << "--raname" << @resource[:raname]
    args << "--connectiondefinition" << @resource[:connectiondefinition]
    args << "--steadypoolsize" << @resource[:steadypoolsize] if @resource[:steadypoolsize]
    args << "--maxpoolsize" << @resource[:maxpoolsize] if @resource[:maxpoolsize]
    args << "--poolresize" << @resource[:poolresize] if @resource[:poolresize]
    args << "--maxwait" << @resource[:maxwait] if @resource[:maxwait]
    args << "--idletimeout" << @resource[:idletimeout] if @resource[:idletimeout]
    args << "--isconnectvalidatereq" << @resource[:isconnectvalidatereq] if @resource[:isconnectvalidatereq]
    args << "--failconnection" << @resource[:failconnection] if @resource[:failconnection]
    args << "--leaktimeout" << @resource[:leaktimeout] if @resource[:leaktimeout]
    args << "--leakreclaim" << @resource[:leakreclaim] if @resource[:leakreclaim]
    args << "--creationretryattempts" << @resource[:creationretryattempts] if @resource[:creationretryattempts]
    args << "--creationretryinterval" << @resource[:creationretryinterval] if @resource[:creationretryinterval]
    args << "--maxconnectionusagecount" << @resource[:maxconnectionusagecount] if @resource[:maxconnectionusagecount]
    args << "--validateatmostonceperiod" << @resource[:validateatmostonceperiod] if @resource[:validateatmostonceperiod]
    args << "--transactionsupport" << @resource[:transactionsupport] if @resource[:transactionsupport]
    args << '--description' << "\'#{@resource[:description]}\'" if @resource[:description] and not @resource[:description].empty?
    args << "--ping" << @resource[:ping] if @resource[:ping]
    args << "--pooling" << @resource[:pooling] if @resource[:pooling]
    if hasProperties? @resource[:properties]
      args << "--property"
      args << "\'#{prepareProperties @resource[:properties]}\'"
    end
    args << @resource[:name]
    asadmin_exec(args)
  end

  def destroy
    args = Array.new
    args << "delete-connector-connection-pool" << @resource[:name]
    asadmin_exec(args)
  end

  def exists?
    asadmin_exec(["list-connector-connection-pools"]).each do |line|
      return true if @resource[:name] == line.strip
    end
    return false
  end
end
