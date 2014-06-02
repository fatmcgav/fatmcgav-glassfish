# == Define: glassfish::create_cluster
#
# Create a glassfish cluster.
#
# === Parameters
#
# [*asadmin_user*] - Name of asadmin username.
#  Defaults to admin
#
# [*asadmin_passfile*] - Path to asadmin password file.
#  Defaults to '/tmp/asadmin.pass'
#
# [*cluster_name*] - Name of cluster to create.
#  Defaults to the resource name if not specified.
#
# [*cluster_user*] - Name of account running glassfish cluster.
#  Defaults to $glassfish::user.
#
# [*create_service*] - Create a service init file for cluster
#  Defaults to $glassfish::create_service
#
# [*dasport*] - Domain Adminsitration Service port.
#  Defaults to '4848'.
#
# [*ensure*] - Cluster ensure state
#  Defaults to present.
#
# [*gms_enabled*] - Should Group Messaging Service (GMS) be enabled.
#  Defaults to true.
#
# [*gms__multicast__port*] - GMS Multicast port.
#  Defaults to undef.
#
# [*gms__multicast__address*] - GMS Multicast address.
#  Defaults to undef.
#
# [*service_name*] - Specify a custom service name.
#  Defaults to `glassfish_${cluster_name}`
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
define glassfish::create_cluster (
  $asadmin_user          = $glassfish::asadmin_user,
  $asadmin_passfile      = $glassfish::asadmin_passfile,
  $cluster_name          = $name,
  $cluster_user          = $glassfish::user,
  $create_service        = $glassfish::create_service,
  $das_port              = '4848',
  $ensure                = present,
  $gms_enabled           = $glassfish::gms_enabled,
  $gms_multicast_port    = $glassfish::gms_multicast_port,
  $gms_multicast_address = $glassfish::gms_multicast_address,
  $service_name          = $glassfish::service_name) {
  # Validate params
  validate_string($asadmin_user)
  validate_absolute_path($asadmin_passfile)
  validate_string($cluster_name)

  # Service name
  if ($service_name == undef) {
    $svc_name = "glassfish_${cluster_name}"
  } else {
    $svc_name = $service_name
  }

  # Check boolean if provided
  if $gms_enabled {
    validate_bool($gms_enabled)
  }

  # Create the cluster
  cluster { $cluster_name:
    ensure           => $ensure,
    user             => $cluster_user,
    asadminuser      => $asadmin_user,
    passwordfile     => $asadmin_passfile,
    dasport          => $das_port,
    gmsenabled       => $gms_enabled,
    multicastport    => $gms_multicast_port,
    multicastaddress => $gms_multicast_address
  }

  # Create a init.d service if required
  if $create_service {
    glassfish::create_service { $cluster_name:
      mode         => 'cluster',
      cluster_name => $cluster_name,
      das_port     => $das_port,
      service_name => $svc_name,
      status_cmd   => "${glassfish::glassfish_asadmin_path} --port ${das_port} --passwordfile ${asadmin_passfile} list-clusters |grep '${cluster_name} running'",
      require      => Cluster[$cluster_name]
    }
  }

}
