# == Define: glassfish::create_http_listener
#
# Create a glassfish http listener.
#
# === Parameters
#
# [*listeneraddress*] - The IP address or the hostname (resolvable by DNS)
# Optional
#
# [*listenerport*] - The port number to create the listen socket on.
# Legal values are 1–65535. On UNIX, creating sockets that
# listen on ports 1–1024 requires superuser privileges.
#
# [*defaultvirtualserver*] - The ID attribute of the default virtual server for this listener.
# Optional
#
# [*servername*] - Tells the server what to put in the host name section of any URLs it sends to the client.
# Optional
#
# [*acceptorthreads*] - The number of acceptor threads for the listener socket.
# Defaults to 1
#
# [*xpowered*] - If set to true, adds the X-Powered-By: Servlet/3.0 and X-Powered-By: JSP/2.0 headers to the appropriate responses.
# Defaults to true
#
# [*jkenabled*] - Whether mod_jk is enabled for this listener
# Defaults to false
#
# [*securityenabled*] - If set to true, the HTTP listener runs SSL. You can turn SSL2 or SSL3 ON or OFF and set ciphers using an SSL
# element. The security setting globally enables or disables SSL by making certificates available to the server instance. The
# default value is false.
# Defaults to false
#
# [*enabled*] - Whether this Glassfish listener is enabled at runtime
# Defaults to true
#
# [*asadmin_path*] - Path to asadmin binary.
#  Defaults to $glassfish::glassfish_asadmin_path
#
# [*asadmin_user*] - Asadmin username.
#  Defaults to $glassfish::asadmin_user
#
# [*asadmin_passfile*] - Asadmin password file.
#  Defaults to $glassfish::asadmin_passfile
#
# [*portbase*] - Portbase to use for domain.
#  Defaults to $glassfish::portbase
#
# === Authors
#
# Jesse Cotton <jcotton1123@gmail.com>
#
define glassfish::create_http_listener (
  $ensure               = present,
  $listeneraddress      = undef,
  $listenerport         = undef,
  $defaultvirtualserver = undef,
  $servername           = undef,
  $acceptorthreads      = undef,
  $xpowered             = undef,
  $securityenabled      = undef,
  $enabled              = undef,
  $target               = server,
  $asadmin_path         = $glassfish::glassfish_asadmin_path,
  $asadmin_user         = $glassfish::asadmin_user,
  $asadmin_passfile     = $glassfish::asadmin_passfile,
  $portbase             = $glassfish::portbase,
  $user                 = $glassfish::user) {
  # Validate params
  # The others will be validated by the type
  validate_absolute_path($asadmin_path)
  validate_string($asadmin_user)
  validate_absolute_path($asadmin_passfile)
  validate_string($portbase)
  validate_string($user)

  # Create
  httplistener { $name:
    ensure               => $ensure,
    listeneraddress      => $listeneraddress,
    listenerport         => $listenerport,
    defaultvirtualserver => $defaultvirtualserver,
    servername           => $servername,
    acceptorthreads      => $acceptorthreads,
    xpowered             => $xpowered,
    securityenabled      => $securityenabled,
    enabled              => $enabled,
    target               => $target,
    asadminuser          => $asadmin_user,
    passwordfile         => $asadmin_passfile,
    portbase             => $portbase,
    user                 => $user
  }
}
