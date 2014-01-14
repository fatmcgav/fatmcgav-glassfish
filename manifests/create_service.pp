# Define: glassfish::create_service
#
# Manages Linux service installation if required
#
define glassfish::create_service ($domain = $name, $runuser = $glassfish::user, $running = false) {
  # Check that we've got a domain name.
  unless $domain {
    fail("Domain name must be specified to install service.")
  }

  file { "${domain}_servicefile":
    path    => "/etc/init.d/glassfish_${domain}",
    mode    => '0755',
    content => $::osfamily ? {
      'RedHat' => template('glassfish/glassfish-init-el.erb'),
      'Debian' => template('glassfish/glassfish-init-debian.erb'),
      default  => fail("OSFamily ${::osfamily} not supported.")
    },
    notify  => Service["glassfish_${domain}"]
  }

  # Need to stop the domain if it was auto-started
  if $running {
    exec { "stop_${domain}":
      command => "asadmin stop-domain ${domain}",
      path    => "${glassfish::glassfish_asadmin_path}/bin",
      user    => $glassfish::user
    }
  }

  service { "glassfish_${domain}":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File["${domain}_servicefile"]
  }

}