# == Class: glassfish::install
#
# This class manages glassfish installation.
# Can only be called from glassfish::init class.
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
class glassfish::install {
  # Create user/group if required
  if $glassfish::manage_accounts {
    # Create the required group.
    group { $glassfish::group: ensure => 'present' }

    # Create the required user.
    user { $glassfish::user:
      ensure     => 'present',
      managehome => true,
      comment    => 'Glassfish user account',
      gid        => $glassfish::group,
      require    => Group[$glassfish::group]
    }
  }

  # Anchor the install class
  anchor { 'glassfish::install::start': }

  anchor { 'glassfish::install::end': }

  # Take action based on $install_method.
  case $glassfish::install_method {
    'package' : {
      # Build package from $package_prefix and $version
      $package_name = "${glassfish::package_prefix}-${glassfish::version}"

      # Install the package.
      package { $package_name:
        ensure  => present,
        require => Anchor['glassfish::install::start'],
        before  => Anchor['glassfish::install::end']
      }

      # Run User/Group create before Package install, If manage_accounts = true.
      if $glassfish::manage_accounts {
        User[$glassfish::user] -> Package[$package_name]
      }
    }
    'zip'     : {
      # Need to download glassfish from java.net
      $glassfish_download_site = "http://download.java.net/glassfish/${glassfish::version}/release"
      $glassfish_download_file = "glassfish-${glassfish::version}.zip"
      $glassfish_download_dest = "${glassfish::tmp_dir}/${glassfish_download_file}"

      # Work out major version for installation
      $version_arr             = split($glassfish::version, '[.]')
      $mjversion               = $version_arr[0]

      # Make sure that $tmp_dir exists.
      file { $glassfish::tmp_dir:
        ensure  => directory,
        require => Anchor['glassfish::install::start'],
      }

      # Download file
      exec { "download_${glassfish_download_file}":
        command => "wget -q ${glassfish_download_site}/${glassfish_download_file} -O ${glassfish_download_dest}",
        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        creates => $glassfish_download_dest,
        timeout => '300',
        require => File[$glassfish::tmp_dir]
      }

      # Unzip the downloaded glassfish zip file
      exec { 'unzip-downloaded':
        command => "unzip ${glassfish_download_dest}",
        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        cwd     => $glassfish::tmp_dir,
        creates => $glassfish::glassfish_dir,
        require => Exec["download_${glassfish_download_file}"]
      }

      # Chown glassfish folder.
      exec { 'change-ownership':
        command => "chown -R ${glassfish::user}:${glassfish::group} ${glassfish::tmp_dir}/glassfish${mjversion}",
        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        creates => $glassfish::glassfish_dir,
        require => Exec['unzip-downloaded']
      }

      # Make sure that user creation runs before ownership change, IF
      # manage_accounts = true.
      if $glassfish::manage_accounts {
        User[$glassfish::user] -> Exec['change-ownership']
      }

      # Chmod glassfish folder.
      exec { 'change-mode':
        command => "chmod -R g+rwX ${glassfish::tmp_dir}/glassfish${mjversion}",
        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        creates => $glassfish::glassfish_dir,
        require => Exec['change-ownership']
      }

      # Move the glassfish3 folder.
      exec { "move-glassfish${mjversion}":
        command => "mv ${glassfish::tmp_dir}/glassfish${mjversion} ${glassfish::glassfish_dir}",
        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        cwd     => $glassfish::tmp_dir,
        creates => $glassfish::glassfish_dir,
        require => Exec['change-mode']
      }

      if $glassfish::remove_default_domain {
        # Remove default domain1.
        file { 'remove-domain1':
          ensure  => absent,
          path    => "${glassfish::glassfish_dir}/glassfish/domains/domain1",
          force   => true,
          backup  => false,
          require => Exec["move-glassfish${mjversion}"],
          before  => Anchor['glassfish::install::end']
        }
      }
    }
    default   : {
      fail("Unrecognised Installation method ${glassfish::install_method}. Choose one of: 'package','zip'.")
    }
  }

  # Ensure that install runs before any Create_domain & Create_node resources
  Class['glassfish::install'] -> Create_domain <| |>
  Class['glassfish::install'] -> Create_node <| |>
}
