# == Define: glassfish::install_jars
#
# Install additional jars if required.
#
# === Parameters
#
# [*domain*] - Name of domain to install jar into.
#
# [*download*] - Should the jar be downloaded?
#  Defaults to false.
#
# [*source*] - Source to copy jar file from.
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
define glassfish::install_jars ($domain, $download = false, $source = '') {
  $jaraddress = $name
  $jar        = basename($jaraddress)
  $jardest    = "${glassfish::glassfish_dir}/glassfish/domains/${domain}/lib/ext/${jar}"

  if $download {
    exec { "download ${name}":
      command => "wget -O ${jardest} ${jaraddress}",
      path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      creates => $jardest,
      cwd     => $glassfish::glassfish_dir,
      require => File[$glassfish::glassfish_dir],
      notify  => Service["glassfish_${domain}"]
    }
  } else {
    file { $jardest:
      ensure => present,
      mode   => 0755,
      source => $source,
      notify => Service["glassfish_${domain}"]
    # TODO fix service naming
    #      notify  => Service["glassfish"]
    }
  }

}
