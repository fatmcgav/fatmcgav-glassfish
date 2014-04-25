# Define: glassfish::install_jars
#
# Manages addition Jar installation if required
#
define glassfish::install_jars ($domain,$download = false,$source = '') {
  $jaraddress = $name
  $jar        = basename($jaraddress)
  $jardest    = "${glassfish::glassfish_dir}/glassfish/domains/${domain}/lib/ext/${jar}"

  if $download {
  exec { "download ${name}":
    command => "wget -O ${jardest} ${jaraddress}",
    path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    creates => $jardest,
    cwd     => $glassfish::glassfish_dir,
    require => File[glassfish::glassfish_dir],
    notify  => Service["glassfish_${domain}"]
  }
  } else {
    file {"${glassfish::glassfish_dir}/glassfish/domains/${domain}/lib/ext/${jar}":
      ensure => present,
      mode   => 0755,
      source => $source,
      # TODO fix service naming
      #      notify  => Service["glassfish"]
    }
  }

}
