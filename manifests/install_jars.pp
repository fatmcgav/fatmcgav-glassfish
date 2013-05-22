# Define: glassfish::install_jars
#
# Manages addition Jar installation if required
#
define glassfish::install_jars ($domain) {
  $jaraddress = $name
  $jar = basename($jaraddress)
  $jardest = "${glassfish::glassfish_dir}/glassfish/domains/${domain}/lib/${jar}"

  exec { "download ${name}":
    command => "wget -O ${jardest} ${jaraddress}",
    path    => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    creates => $jardest,
    cwd     => $glassfish::glassfish_dir,
    require => File[glassfish::glassfish_dir],
    notify  => Service["glassfish_${domain}"]
  }

}
