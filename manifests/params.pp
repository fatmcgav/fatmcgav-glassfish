# == Class: glassfish::params
#
# This class manages glassfish module params.
#
# === Parameters
#
#  None
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
class glassfish::params {
  # Installation method. Can be: 'package','zip'.
  $glassfish_install_method      = 'zip'

  $glassfish_install_dir         = undef

  # Default glassfish temporary directory for downloading Zip.
  $glassfish_tmp_dir             = '/tmp'

  # RPM Package prefix
  $glassfish_package_prefix      = 'glassfish3'

  # Default Glassfish version
  $glassfish_version             = '3.1.2.2'

  # Default Glassfish install parent directory.
  $glassfish_parent_dir          = '/usr/local'

  # Should Glassfish manage user accounts/groups?
  $glassfish_manage_accounts     = true
  # Default Glassfish User
  $glassfish_user                = 'glassfish'
  # Default Glassfish Group
  $glassfish_group               = 'glassfish'

  # Should the included default 'domain1' be removed?
  $glassfish_remove_default_domain = true

  # Default Glassfish asadmin username
  $glassfish_asadmin_user        = 'admin'
  # Default Glassfish asadmin password file
  $glassfish_asadmin_passfile    = '/home/glassfish/asadmin.pass'
  # Default Glassfish asadmin master password
  $glassfish_asadmin_master_password = 'changeit'
  # Default Glassfish asadmin password
  $glassfish_asadmin_password    = 'adminadmin'
  # Should a passfile be created?
  $glassfish_create_passfile     = true

  # Should a glassfish domain be created on installation?
  $glassfish_create_domain       = false
  # Should a glassfish service be created on installation?
  $glassfish_create_service      = true
  # Default Glassfish domain, portbase and profile
  $glassfish_domain              = undef
  $glassfish_portbase            = '4800'
  # Default Glassfish service name
  $glassfish_service_name        = undef

  # Should the glassfish domain be started upon creation?
  $glassfish_start_domain        = true

  # Should secure-admin be enabled upon creation?
  $glassfish_enable_secure_admin = true

  # Glassfish domain tempalte
  $glassfish_domain_template     = undef

  # Should the path be updated?
  case $::osfamily {
    RedHat  : { $glassfish_add_path = true }
    Debian  : { $glassfish_add_path = true }
    default : { $glassfish_add_path = false }
  }

  # Should this module manage Java installation?
  $glassfish_manage_java = true
  # JDK version: java-7-oracle, java-7-openjdk, java-6-oracle, java-6-openjdk
  $glassfish_java_ver    = 'java-7-openjdk'

  # Set package names based on Operating System...
  case $::osfamily {
    RedHat  : {
      $java6_openjdk_package = 'java-1.6.0-openjdk-devel'
      $java6_sun_package     = undef
      $java7_openjdk_package = 'java-1.7.0-openjdk-devel'
      $java7_sun_package     = undef
    }
    Debian  : {
      $java6_openjdk_package = 'openjdk-6-jdk'
      $java6_sun_package     = 'sun-java6-jdk'
      $java7_openjdk_package = 'openjdk-7-jdk'
      $java7_sun_package     = undef
    }
    default : {
      fail("${::osfamily} not supported by this module.")
    }
  }

  # Clustering config params
  # Enable GMS?
  $glassfish_gms_enabled       = true

  # Multicase params
  $glassfish_multicast_port    = undef
  $glassfish_multicast_address = undef

}
