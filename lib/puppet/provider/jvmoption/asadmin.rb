require 'puppet/provider/asadmin'

Puppet::Type.type(:jvmoption).provide(:asadmin, :parent =>
Puppet::Provider::Asadmin) do
  desc "Glassfish jvm-options support."
  def create
    args = Array.new
    args << "create-jvm-options"
    args << "--target" << @resource[:target] if @resource[:target]
    args << "'" + escape(@resource[:name]) + "'"

    asadmin_exec(args)
  end

  def destroy
    args = Array.new
    args << "delete-jvm-options"
    args << "--target" << @resource[:target]
    args << "'" + escape(@resource[:name]) + "'"

    asadmin_exec(args)
  end

  def exists?
    args = Array.new
    args << "list-jvm-options"
    args << "--target" << @resource[:target] if @resource[:target]
    
    #Remove escaped semi-colons for matching the jvm option name
    name = @resource[:name].sub "\\:" , ":"

    asadmin_exec(args).each do |line|
      line.sub!(/-XX: ([^\ ]+)/, '-XX:+\1')
      if line.match(/^-.[^\ ]+/)
        return true if name == line.chomp
      end
    end
    return false
  end
end
