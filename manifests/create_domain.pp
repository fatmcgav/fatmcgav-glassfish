# Class: glassfish::create_domain
#
# Create a glassfish domain on installation.
#
define glassfish::create_domain (
  $asadmin_path     = $glassfish::glassfish_asadmin_path,
  $asadmin_user     = $glassfish::domain_asadmin_user,
  $asadmin_passfile = $glassfish::domain_asadmin_passfile,
  $domain_name      = $name,
  $domain_user      = $glassfish::user,
  $ensure           = present,
  $portbase         = $glassfish::portbase) {
  # Create the domain
  domain { $domain_name:
    user          => $domain_user,
    asadminuser   => $asadmin_user,
    passwordfile  => $asadmin_passfile,
    ensure        => $ensure,
    portbase      => $portbase,
    startoncreate => false
  }

}
