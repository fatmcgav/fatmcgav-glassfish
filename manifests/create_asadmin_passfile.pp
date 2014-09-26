# == Define: glassfish::create_asadmin_passfile
#
# Creates an Asadmin Passwordfile
#
# === Parameters
#
#  [*add_path*] - Should glassfish bin be added to path?
#  Defaults to true
#
# === Examples
#
#
# === Authors
#
# Gavin Williams <fatmcgav@gmail.com>
#
# === Copyright
#
# Copyright 2014 Gavin Williams, unless otherwise noted.
#
define glassfish::create_asadmin_passfile ($asadmin_master_pass = 'changeit', $asadmin_password, $group, $path = $name, $user) {
  # Create the required passfile
  file { $name:
    ensure  => present,
    path    => $path,
    content => template('glassfish/passwordfile'),
    owner   => $user,
    group   => $group,
    mode    => '0644'
  }

}
