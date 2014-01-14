# Class: glassfish::create_domain
#
# Create a glassfish domain on installation.
#
define glassfish::create_domain (
  $asadmin_path        = $glassfish::glassfish_asadmin_path,
  $asadmin_user        = $glassfish::domain_asadmin_user,
  $asadmin_passfile    = $glassfish::domain_asadmin_passfile,
  $domain_name         = $name,
  $domain_user         = $glassfish::user,
  $ensure              = present,
  $portbase            = $glassfish::portbase,
  $start_domain        = $glassfish::start_domain,
  $enable_secure_admin = $glassfish::enable_secure_admin,
  $create_service      = $glassfish::create_service) {
  # Create the domain
  domain { $domain_name:
    user              => $domain_user,
    asadminuser       => $asadmin_user,
    passwordfile      => $asadmin_passfile,
    ensure            => $ensure,
    portbase          => $portbase,
    startoncreate     => $start_domain,
    enablesecureadmin => $enable_secure_admin
  }

  # Create a init.d service if required
  if $create_service {
    glassfish::create_service { $domain_name: running => $start_domain }
  }

}
