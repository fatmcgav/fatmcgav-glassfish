# Define: glassfish::create_service
#
# Manages Linux service installation if required
#
define glassfish::create_service (
  $domain  = $name,
  $runuser = $glassfish::user,
  $running = false) {
  # Check that we've got a domain name.
  unless $domain {
    fail('Domain name must be specified to install service.')
  }

  # What service_file should we be using, based on osfamily.
  $service_file = $::osfamily ? {
    'RedHat' => template('glassfish/glassfish-init-el.erb'),
    'Debian' => template('glassfish/glassfish-init-debian.erb'),
    default  => fail("OSFamily ${::osfamily} not supported.")
  }

  # Create the init file
  file { "${domain}_servicefile":
    ensure  => present,
    path    => "/etc/init.d/glassfish_${domain}",
    mode    => '0755',
    content => $service_file,
    notify  => Service["glassfish_${domain}"]
  }

  # Need to stop the domain if it was auto-started
  if $running {
    exec { "stop_${domain}":
      command => "${glassfish::glassfish_asadmin_path} stop-domain ${domain}",
      user    => $glassfish::user,
      before  => Service["glassfish_${domain}"]
    }
  }

  # Make sure the service is running and enabled.
  service { "glassfish_${domain}":
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File["${domain}_servicefile"]
  }

}
