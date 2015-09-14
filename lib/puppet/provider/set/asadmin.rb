$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..","..",".."))
require 'puppet/provider/asadmin'

Puppet::Type.type(:set).provide(:asadmin, :parent =>
                                      Puppet::Provider::Asadmin) do
  desc "Glassfish domain attribute support."

  def create
    args = Array.new
    args << 'set'
    args << "#{@resource[:name]}=#{@resource[:value]}"
    asadmin_exec(args)
  end

  def destroy
    # Destroy can't do anything with set.
  end

  def exists?
    begin
      asadmin_exec(["get #{@resource[:name]}"]).each do |line|
        return true if "#{@resource[:name]}=#{@resource[:value]}" == line.chomp
      end
      return false
    rescue Exception => msg
      #We need to allow the set command to continue if the variable is not found.
      return false
    end
  end
end
