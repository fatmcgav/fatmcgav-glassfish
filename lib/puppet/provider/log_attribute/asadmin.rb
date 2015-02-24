require 'puppet/provider/asadmin'
Puppet::Type.type(:log_attribute).provide(:asadmin, :parent =>
                                      Puppet::Provider::Asadmin) do
  desc "Glassfish domain log attribute support."

  def create
    args = Array.new
    args << 'set-log-attributes'
    args << "--target" << @resource[:target] if @resource[:target]
    args << "#{@resource[:name]}=#{@resource[:value]}"
    asadmin_exec(args)
  end

  def destroy
    # Destroy can't do anything with log_attribute. 
  end

  def exists?
    asadmin_exec(["list-log-attributes"]).each do |line|
      return true if "#{@resource[:name]}\t<#{@resource[:value]}>" == line.chomp
    end
    return false
  end
end
