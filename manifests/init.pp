# Class: glassfish
#
# This module installs and manages glassfish
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#

class glassfish (
  $java = $glassfish::params::glassfish_java, # JDK version: java-7-oracle, java-7-openjdk, java-6-oracle, java-6-openjdk
  $version = $glassfish::params::glassfish_version, # '3.1.2.2'
  $extrajars = [], # extra jars 
) inherits glassfish::params {
  include glassfish::download

  $download_dir = '/opt/download' 
  $download_file = "glassfish-$version.zip"
  $glassfish_dir              = "glassfish-$version"
  $glassfish_parent_dir       = '/usr/local/lib'
  $glassfish_path             = "$glassfish_parent_dir/$glassfish_dir" # Default Glassfish path
  $glassfish_asadmin_path     = "$glassfish_path/bin/asadmin" # Default Glassfish Asadmin path
  $glassfish_download_site    = "http://download.java.net/glassfish/$version/release" # Default Glassfish download

  file { $download_dir: ensure => "directory" }
  file { versionfile:
    content => $version,
    path => '/etc/glassfish-version',
  }
  file { "$download_dir/$download_file":  }
  file { $glassfish_parent_dir:
    ensure => directory,
  }
  file { "$download_dir/$glassfish_dir":  }
  file { $glassfish_path: 
    group => $glassfish::params::glassfish_group,
    owner => $glassfish::params::glassfish_user,
    mode => 2775
  }

  user { $glassfish::params::glassfish_user:
    ensure     => "present",
    managehome => true
  }
  
  group { $glassfish::params::glassfish_group:
    ensure    => "present",
    require   => User[$glassfish::params::glassfish_user],
    members   => User[$glassfish::params::glassfish_user],
  }

  glassfish::download::download { "$download_dir/$download_file":
    uri => "$glassfish_download_site/$download_file",
    require => [
      File[$glassfish_path], 
      File[$glassfish_parent_dir],
      File[$download_dir],
    ]
  }

  package { unzip:
    ensure => "installed"
  }
  
  exec {'unzip-downloaded':
    command => "unzip $download_file",
    path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",                                                         
    cwd => $download_dir,
    creates => $glassfish_path,                                                              
    require => [
      File["$download_dir/$download_file"],
      Package[unzip]
    ]
  }
  
  define setgroupaccess ($user, $group, $dir, $glpath) {
      exec { "rwX $name":
          command => "chmod -R g+rwX $dir",
          path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
          creates => $glpath,
      }
      exec { "find $name":
          command => "find $dir -type d -exec chmod g+s {} +",
          path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
          creates => $glpath,
      }
      exec { "group $name":
          command => "chown -R $user:$group $dir",
          path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
          creates => $glpath,
      }
  }
  define install_jars ($glpath, $domain) {
    $jaraddress = $name
    $jar = basename($jaraddress)
    $jardest = "$glpath/glassfish/domains/$domain/lib/$jar"
	  exec { "download $name":
      command => "wget -O $jardest $jaraddress",
      path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
      creates => $jardest,
      cwd => $glpath,
	    require => [
	      File[$glpath], 
	    ],
	    notify => Service["glassfish"],
	  }
	}
  
  setgroupaccess {'set-perm':
    user => $glassfish::params::glassfish_user,
    group => $glassfish::params::glassfish_group,
    require => Group[$glassfish::params::glassfish_group],
    dir => "$download_dir/glassfish3",
    glpath => $glassfish_path,                                                             
  }
  
  exec {'move-downloaded':
    command => "mv $download_dir/glassfish3 $glassfish_path",
    path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",                                                         
    cwd => $download_dir,
    creates => $glassfish_path,                                                              
  }
  
  install_jars { $extrajars:
    domain => $glassfish::params::glassfish_domain,
    glpath => $glassfish_path,
    require => Exec['move-downloaded'],
    
  }
  
  file {servicefile:
    path => "/etc/init.d/glassfish",
    mode => 755,
    content => template('glassfish/glassfish-init.erb'),
    notify  => Service["glassfish"]
  } 
	
	case $java {
    'java-7-oracle'  : {
      require java7
      service { "glassfish":
		    ensure     => running,
		    enable     => true,
		    hasstatus  => true,
		    hasrestart => true,
		    require => [
		      File[$glassfish_path],
		      File[servicefile],
		      Class[java7],
		    ]
		  }
    }
    'java-7-openjdk' : {
      package { 'openjdk-7-jdk': ensure => "installed" }
      service { "glassfish":
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        require => [
          File[$glassfish_path],
          File[servicefile],
          Package['openjdk-7-jdk'],
        ]
      }
    }
    'java-6-oracle'  : {
      package { 'sun-java6-jdk': ensure => "installed" }
      service { "glassfish":
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        require => [
          File[$glassfish_path],
          File[servicefile],
          Package['sun-java6-jdk'],
        ]
      }
    }
    'java-6-openjdk' : {
      package { 'openjdk-6-jdk': ensure => "installed" }
      service { "glassfish":
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        require => [
          File[$glassfish_path],
          File[servicefile],
          Package['openjdk-6-jdk'],
        ]
      }
    }
    default          : {
      fail("Unrecognized Java version. Choose one of: java-7-oracle, java-7-openjdk, java-6-oracle, java-6-openjdk")
    }
  }
  
  Glassfish::Download::Download["$download_dir/$download_file"] 
  -> Exec['unzip-downloaded'] 
  -> Setgroupaccess['set-perm'] 
  -> Exec['move-downloaded'] 
  -> File [servicefile]
  -> File [versionfile]
  
  File [servicefile] -> Service['glassfish']

}
