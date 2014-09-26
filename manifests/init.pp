# == Class: glassfish
#
# This module manages glassfish
#
# === Parameters
#
#  [*add_path*] - Should glassfish bin be added to path?
#  Defaults to true
#
#  [*asadmin_user*] - Asadmin username.
#  Defaults to 'admin'
#
#  [*asadmin_passfile*] - Asadmin password file.
#  Defaults to '/home/glassfish/asadmin.pass'
#
#  [*asadmin_password*] - Asadmin password.
#  Defaults to 'adminadmin'
#
#  [*create_domain*] - Should a glassfish domain be created on installation?
#  Defaults to false
#
#  [*create_service*] - Should a glassfish service be created on installation?
#  Defaults to true
#
#  [*create_passfile*] - Should a glassfish password file be created?
#  Defaults to true
#
#  [*domain_name*] - Glassfish domain name. Defaults to 'domain1'.
#
#  [*domain_template*] - Glassfish domain template to use.
#
#  [*enable_secure_admin*] - Should secure admin be enabled?
#  Defaults to true
#
#  [*gms_enabled*] - Should Group Messaging Service be enabled for cluster.
#
#  [*gms_multicast_port*] - GMS Multicast port.
#
#  [*gms_multicast_address*] - GMS Multicast address.
#
#  [*group*] - Glassfish group name.
#
#  [*install_method*]  - Glassfish installation method.
#  Can be: 'zip', 'package'. Defaults to 'zip'.
#
#  [*java_ver*]        - Java version to install if managing Java.
#
#  [*manage_accounts*] - Should this module manage user accounts and groups
#  required for Glassfish? Defaults to true.
#
#  [*manage_java*]     - Should Java installation be managed by this module?
#  Defaults to true.
#
#  [*package_prefix*]  - Glassfish package name prefix. Defaults to
#  'glassfish3'.
#
#  [*parent_dir*]      - Glassfish parent directory. Defaults to '/usr/local'.
#
#  [*portbase*]        - Glassfish portbase. Used when creating a domain on install.
#  Defaults to '4800'
#
#  [*start_domain*] - Should the glassfish domain be started on creation?
#  Defaults to true
#
#  [*tmp_dir*]         - Glassfish temporary directory. Defaults to '/tmp'.
#  Only used if installing using zip method.
#
#  [*user*]            - Glassfish user name.
#
#  [*version*]         - Glassfish version, defaults to '3.1.2.2'.
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
class glassfish (
  $add_path                = $glassfish::params::glassfish_add_path,
  $asadmin_user            = $glassfish::params::glassfish_asadmin_user,
  $asadmin_passfile        = $glassfish::params::glassfish_asadmin_passfile,
  $asadmin_master_password = $glassfish::params::glassfish_asadmin_master_password,
  $asadmin_password        = $glassfish::params::glassfish_asadmin_password,
  $create_domain           = $glassfish::params::glassfish_create_domain,
  $create_service          = $glassfish::params::glassfish_create_service,
  $create_passfile         = $glassfish::params::glassfish_create_passfile,
  $domain_name             = $glassfish::params::glassfish_domain,
  $domain_template         = $glassfish::params::glassfish_domain_template,
  $enable_secure_admin     = $glassfish::params::glassfish_enable_secure_admin,
  $gms_enabled             = $glassfish::params::glassfish_gms_enabled,
  $gms_multicast_port      = $glassfish::params::glassfish_multicast_port,
  $gms_multicast_address   = $glassfish::params::glassfish_multicast_address,
  $group                   = $glassfish::params::glassfish_group,
  $install_dir             = $glassfish::params::glassfish_install_dir,
  $install_method          = $glassfish::params::glassfish_install_method,
  $java_ver                = $glassfish::params::glassfish_java_ver,
  $manage_accounts         = $glassfish::params::glassfish_manage_accounts,
  $manage_java             = $glassfish::params::glassfish_manage_java,
  $package_prefix          = $glassfish::params::glassfish_package_prefix,
  $parent_dir              = $glassfish::params::glassfish_parent_dir,
  $portbase                = $glassfish::params::glassfish_portbase,
  $service_name            = $glassfish::params::glassfish_service_name,
  $start_domain            = $glassfish::params::glassfish_start_domain,
  $tmp_dir                 = $glassfish::params::glassfish_tmp_dir,
  $user                    = $glassfish::params::glassfish_user,
  $version               = $glassfish::params::glassfish_version) inherits glassfish::params {
  #
  # # Calculate some vars based on passed parameters
  #
  # Installation location
  if ($install_dir == undef) {
    $glassfish_dir = "${parent_dir}/glassfish-${version}"
  } else {
    $glassfish_dir = "${parent_dir}/${install_dir}"
  }

  # Asadmin path
  $glassfish_asadmin_path = "${glassfish_dir}/bin/asadmin"

  # Validate passed paramater values
  validate_bool($add_path)
  validate_bool($create_domain)
  validate_bool($create_service)
  validate_bool($create_passfile)
  validate_bool($start_domain)
  validate_bool($enable_secure_admin)
  validate_string($asadmin_user)
  validate_string($domain_name)
  validate_string($group)
  validate_string($install_method)
  validate_bool($manage_accounts)
  validate_bool($manage_java)
  validate_string($package_prefix)
  validate_string($user)

  #
  # # Start to run through the install process
  #

  # Ensure that the $parent_dir exists
  file { $parent_dir: ensure => directory }

  # Do we need to manage Java?
  if $manage_java {
    class { 'glassfish::java': before => Class['glassfish::install'] }
  }

  # Should we create a passfile?
  if $create_passfile {
    # Create a passfile
    glassfish::create_asadmin_passfile { "${user}_asadmin_passfile":
      asadmin_master_password => $asadmin_master_password,
      asadmin_password        => $asadmin_password,
      group                   => $group,
      path                    => $asadmin_passfile,
      user                    => $user
    }

    # Run this before any resources that require it
    Glassfish::Create_asadmin_passfile["${user}_asadmin_passfile"] -> Create_domain <| |>
    Glassfish::Create_asadmin_passfile["${user}_asadmin_passfile"] -> Create_cluster <| |>
    Glassfish::Create_asadmin_passfile["${user}_asadmin_passfile"] -> Create_node <| |>
    Glassfish::Create_asadmin_passfile["${user}_asadmin_passfile"] -> Create_instance <| |>
  }

  # Call the install method
  include glassfish::install

  # Make sure parent_dir runs before glassfish::install.
  File[$parent_dir] -> Class['glassfish::install']

  # Need to manage path?
  if $add_path {
    class { 'glassfish::path': require => Class['glassfish::install'] }

    # Setup path before creating the domain...
    if $create_domain {
      Class['glassfish::path'] -> Create_domain[$domain_name]
    }
  }

  # Do we need to create a domain on installation?
  if $create_domain {
    # Validate params required for domain creation
    validate_string($domain_name)
    validate_absolute_path($asadmin_passfile)

    # Service name
    if ($service_name == undef) {
      $svc_name = "glassfish_${domain_name}"
    } else {
      $svc_name = $service_name
    }

    # Need to create the required domain
    create_domain { $domain_name: require => Class['glassfish::install'] }

  }

}
