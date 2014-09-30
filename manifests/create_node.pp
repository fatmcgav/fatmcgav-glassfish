# == Define: glassfish::create_node
#
# Create a glassfish node.
#
# === Parameters
#
# [*asadmin_user*]
#  Name of asadmin username.
#  Defaults to admin
#
# [*asadmin_passfile*]
#  Path to asadmin password file.
#  Defaults to '/tmp/asadmin.pass'
#
# [*node_host*]
#  Host to run this node on.
#  Defaults to $::hostname.
#
# [*node_name*]
#  Name of node to create.
#  Defaults to the resource name if not specified.
#
# [*node_user*]
#  Username to run node under.
#  Defaults to $glassfish::user.
#
# [*ensure*]
#  Cluster ensure state
#  Defaults to present.
#
# [*das_host*]
#  Domain Adminsitration Service host.
#  No default.
#
# [*das_port*]
#  Domain Adminsitration Service port.
#  Defaults to '4848'.
#
# [*login*]
#  Should glassfish login be run?
#  Defaults to true.
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
define glassfish::create_node (
  $asadmin_user     = $glassfish::asadmin_user,
  $asadmin_passfile = $glassfish::asadmin_passfile,
  $node_host        = $::hostname,
  $node_name        = $name,
  $node_user        = $glassfish::user,
  $ensure           = present,
  $das_host         = undef,
  $das_port         = '4848',
  $login            = true) {
  # Validate params
  validate_string($asadmin_user)
  validate_absolute_path($asadmin_passfile)
  validate_string($node_name)

  # Create the cluster
  cluster_node { $node_name:
    ensure       => $ensure,
    user         => $node_user,
    asadminuser  => $asadmin_user,
    passwordfile => $asadmin_passfile,
    host         => $node_host,
    dashost      => $das_host,
    dasport      => $das_port
  }

}
