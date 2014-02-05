# Class: glassfish
#
# This module manages glassfish
#
# Parameters:
#   [*create_domain*]   - Should a glassfish domain be created on installation?
#   Defaults to false
#   [*domain_name*]     - Glassfish domain name.
#   [*extra_jars*]      - Should additional jars be installed by this module?
#   [*group*]           - Glassfish group name.
#   [*install_method*]  - Glassfish installation method. Defaults to 'zip'.
#   Other options: 'yum'.
#   [*java_ver*]        - Java version to install if managing Java.
#   [*manage_accounts*] - Should this module manage user accounts and groups
#   required for Glassfish? Defaults to true.
#   [*manage_java*]     - Should Java installation be managed by this module?
#   Defaults to true.
#   [*package_prefix*]  - Glassfish package name prefix. Defaults to
#   'glassfish3'.
#   [*parent_dir*]      - Glassfish parent directory. Defaults to '/usr/local'.
#   #   [*portbase*]        - Glassfish portbase. Used
#   when creating a domain on install.
#   [*tmp_dir*]         - Glassfish temporary directory. Defaults to '/tmp'.
#   Only used if installing using zip method.
#   [*user*]            - Glassfish user name.
#   [*version*]         - Glassfish version, defaults to '3.1.2.2'.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class glassfish (
  $add_path                = $glassfish::params::glassfish_add_path,
  $create_domain           = $glassfish::params::glassfish_create_domain,
  $create_service          = $glassfish::params::glassfish_create_service,
  $start_domain            = $glassfish::params::glassfish_start_domain,
  $enable_secure_admin     = $glassfish::params::glassfish_enable_secure_admin,
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
  $version                 = $glassfish::params::glassfish_version,
  $domain_template         = $glassfish::params::glassfish_domain_template) inherits glassfish::params {
  # Calculate some vars based on passed parameters
  $glassfish_dir          = "${parent_dir}/glassfish-${version}"
  $glassfish_asadmin_path = "${glassfish_dir}/bin/asadmin"

  # Validate passed paramater values
  validate_bool($add_path)
  validate_bool($create_domain)
  validate_bool($create_service)
  validate_bool($start_domain)
  validate_bool($enable_secure_admin)
  validate_string($domain_asadmin_user)
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
    # Need to make sure that the $domain_asadmin_passfile path is valid
    validate_absolute_path($domain_asadmin_passfile)

    # Need to create the required domain
    create_domain { $domain_name: require => Class['glassfish::install'] }

    # Install extrajars if required, only if creating a domain.
    if !empty($extrajars) {
      install_jars { $extrajars:
        domain  => $domain_name,
        require => Create_domain[$domain_name]
      }
    }

  }

}
