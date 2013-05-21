# Define: glassfish::service
#
# Manages java installation if required
#
define glassfish::service ($domain = $name, $runuser = $glassfish::params::glassfish_user) {
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
    notify  => Service["glassfish"]
  }

  service { "glassfish_${domain}":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [File[$glassfish::glassfish_dir], File["${domain}_servicefile"]]
  }
}
