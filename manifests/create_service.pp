# Define: glassfish::create_service
#
# Manages Linux service installation if required
#
define glassfish::create_service ($domain = $name, $runuser = $glassfish::user) {
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

  service { "glassfish_${domain}":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File["${domain}_servicefile"]
  }
}
