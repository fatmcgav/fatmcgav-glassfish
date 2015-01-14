# == Define: glassfish::create_network_listener
#
# Create a glassfish network listener.
#
# === Parameters
#
# [*address*] - The IP address or the hostname (resolvable by DNS)
# Optional
#
# [*port*] - The port number to create the listen socket on.
# Legal values are 1–65535. On UNIX, creating sockets that
# listen on ports 1–1024 requires superuser privileges.
#
# [*threadpool*] - The name of the thread pool for this listener.
# Optional
#
# [*protocol*] - The name of the protocol for this listener.
#
# [*transport*] - The name of the transport for this listener.
# Defaults to `tcp`
#
# [*enabled*] - Whether the listener is enabled at runtime.
# Defaults to true
#
# [*jkenabled*] - Whether mod_jk is enabled for this listener
# Defaults to false
# 
# [*target*] - Creates the network listener only on the specified target.
# Defaults to "server"
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
define glassfish::create_network_listener (
  $ensure            = present,
  $address           = undef,
  $port              = undef,
  $threadpool        = undef,
  $protocol          = undef,
  $transport         = "tcp",
  $enabled           = true,
  $jkenabled         = false,
  $target            = server,
  $asadmin_path      = $glassfish::glassfish_asadmin_path,
  $asadmin_user      = $glassfish::asadmin_user,
  $asadmin_passfile  = $glassfish::asadmin_passfile,
  $portbase          = $glassfish::portbase,
  $user              = $glassfish::user
) {

  # Validate params
  # The others will be validated by the type
  validate_absolute_path($asadmin_path)
  validate_string($asadmin_user)
  validate_absolute_path($asadmin_passfile)
  validate_string($portbase)
  validate_string($user)

  # Create 
  networklistener { $name:
    ensure            => $ensure,
    address           => $address,
    port              => $port,
    threadpool        => $threadpool,
    protocol          => $protocol,
    transport         => $transport,
    enabled           => $enabled,
    jkenabled         => $jkenabled,
    target            => $target,
    asadminuser       => $asadmin_user,
    passwordfile      => $asadmin_passfile,
    portbase          => $portbase,
    user              => $user
  }
}
