# == Class: glassfish::path
#
# Add glassfish to profile
#
# === Parameters
#
# None
#
# === Examples
#
# Not applicable
#
# === Authors
#
# Gavin Williams <fatmcgav@gmail.com>
#
# === Copyright
#
# Copyright 2014 Gavin Williams, unless otherwise noted.
#
class glassfish::path {
  case $::osfamily {
    'RedHat' : {
      # Add a file to the profile.d directory
      file { '/etc/profile.d/glassfish.sh':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('glassfish/glassfish-profile-el.erb'),
        require => Class['glassfish::install']
      }
    }
    'Debian' : {
      # Add a file to the profile.d directory
      file { '/etc/profile.d/glassfish.sh':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('glassfish/glassfish-profile-deb.erb'),
        require => Class['glassfish::install']
      }
    }
    default  : {
      fail("OSFamily ${::osfamily} is not currently supported.")
    }
  }

  # Ensure glassfish::path runs before any resources that require asadmin
  Class['glassfish::path'] -> Glassfish::Create_domain <| |>
  Class['glassfish::path'] -> Glassfish::Create_cluster <| |>
  Class['glassfish::path'] -> Glassfish::Create_node <| |>

}
