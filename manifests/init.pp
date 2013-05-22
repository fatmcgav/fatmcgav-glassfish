# Class: glassfish
#
# This module manages glassfish
#
# Parameters:
#   [*create_domain*]   - Should a glassfish domain be created on installation?
#   [*domain_name*]     - Glassfish domain name.
#   [*extra_jars*]      - Should additional jars be installed by this module?
#   [*group*]           - Glassfish group name.
#   [*install_method*]  - Glassfish installation method. Defaults to 'yum'. Other options: 'zip'.
#   [*java_ver*]        - Java version to install if managing Java.
#   [*manage_accounts*] - Should this module manage user accounts and groups required for Glassfish? Defaults to true.
#   [*manage_java*]     - Should Java installation be managed by this module? Defaults to false.
#   [*package_prefix*]  - Glassfish package name prefix. Defaults to 'glassfish3'.
#   [*parent_dir*]      - Glassfish parent directory. Defaults to '/usr/local'.
#   [*portbase*]        - Glassfish portbase. Used
#   when creating a domain on install.
#   [*tmp_dir*]         - Glassfish temporary directory. Defaults to '/tmp'. Only used if installing using zip method.
#   [*user*]
#   - Glassfish user name.
#   [*version*]         - Glassfish version, defaults to '3.1.2.2'.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class glassfish (
  $create_domain           = $glassfish::params::glassfish_create_domain,
  $create_service          = $glassfish::params::glassfish_create_service,
  $domain_asadmin_user     = $glassfish::params::glassfish_asadmin_user,
  $domain_asadmin_passfile = $glassfish::params::glassfish_asadmin_passfile,
  $domain_name             = $glassfish::params::glassfish_domain,
  $extrajars               = [],
  $group                   = $glassfish::params::glassfish_group,
  $install_method          = $glassfish::params::glassfish_install_method,
  $java_ver                = $glassfish::params::glassfish_java_ver,
  $manage_accounts         = $glassfish::params::glassfish_manage_accounts,
  $manage_java             = $glassfish::params::glassfish_manage_java,
  $package_prefix          = $glassfish::params::glassfish_package_prefix,
  $parent_dir              = $glassfish::params::glassfish_parent_dir,
  $portbase                = $glassfish::params::glassfish_portbase,
  $tmp_dir                 = $glassfish::params::glassfish_tmp_dir,
  $user                    = $glassfish::params::glassfish_user,
  $version                 = $glassfish::params::glassfish_version) inherits glassfish::params {
  # Calculate some vars based on passed parameters
  $glassfish_dir = "${parent_dir}/glassfish-${version}"
  $glassfish_asadmin_path = "${glassfish_dir}/bin/asadmin"

  #
  # # Start to run through the install process
  #

  # Ensure that the $parent_dir exists
  file { $parent_dir: ensure => directory }

  # Do we need to manage Java?
  if $manage_java {
    class { 'glassfish::java': }

    # Set the dependencies
    Class['glassfish::java'] -> Class['glassfish::install']
  }

  # Call the install method
  class { 'glassfish::install':
  }

  # Make sure parent_dir runs before glassfish::install.
  File[$parent_dir] -> Class['glassfish::install']

  # Do we need to create a domain on installation?
  if $create_domain {
    # Need to create the required domain
    create_domain { $domain_name: require => Class['glassfish::install'] }

    # Install extrajars if required, only if creating a domain.
    install_jars { $extrajars:
      domain  => $domain_name,
      require => Create_domain[$domain]
    }

    # Need to create a service?
    if $create_service {
      create_service { $domain_name:
        runuser => $user,
        require => [Create_domain[$domain_name], Install_jars[$extrajars]]
      }
    }

  }

}
