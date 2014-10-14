require 'puppet/provider/asadmin'
Puppet::Type.type(:domain).provide(:asadmin,
                                   :parent => Puppet::Provider::Asadmin) do
  desc "Glassfish Domain support."

  def create
    # Start a new args array
    args = Array.new
    args << "create-domain"
    args << "--portbase" << @resource[:portbase]
    args << "--savelogin"
    args << "--savemasterpassword"
    args << "--template" << @resource[:template] if @resource[:template]
    args << @resource[:name]
    
    # Run the create command
    asadmin_exec(args)

    # Start the domain upon creation if required
    if @resource[:startoncreate] == :true
      asadmin_exec(['start-domain', @resource[:name]])

      # Enable secure admin if required and domain started
      if @resource[:enablesecureadmin] == :true
        asadmin_exec(['enable-secure-admin'])
      end
    end
  end

  def destroy
    args = Array.new
    args << "delete-domain" << @resource[:name]
    asadmin_exec(args)
  end

  def exists?
    asadmin_exec(["list-domains"]).each do |line|
      domain = line.split(" ")[0] if line.match(/running/) # Glassfish > 3.0.1
      domain = line.split(" ")[1] if line.match(/^Name:\ /) # Glassfish =< 3.0.1
      return true if @resource[:name] == domain
    end
    return false
  end
end
