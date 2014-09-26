# == Define: glassfish::create_asadmin_passfile
#
# Creates an Asadmin Passwordfile in the specified
#  location for the specified user.
#
# === Parameters
#
#  [*group*] - Linux group that should be assigned to passwordfile.
#
#  [*path*]  - Location to create asadmin password file.
#
#  [*user*]  - Linux user that should be assigned to the passwordfile.
#
#  [*asadmin_master_password*] - Asadmin master password to use.
#   Defaults to 'changeit'.
#
#  [*asadmin_password*] - Asadmin password to use.
#   Defaults to 'adminadmin'.
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
define glassfish::create_asadmin_passfile ($group, $path, $user, $asadmin_master_password = 'changeit', $asadmin_password = 'adminadmin') {
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
