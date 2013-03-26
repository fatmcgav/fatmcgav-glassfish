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
  $java = $glassfish::params::glassfish_java # JDK version: java-7-oracle, java-7-openjdk, java-6-oracle, java-6-openjdk 
) inherits glassfish::params {
  include glassfish::download

  $download_dir = '/opt/download' 

  file { $download_dir: ensure => "directory" }
  file { "$download_dir/$glassfish::params::glassfish_download_file":  }
  file { "$download_dir/$glassfish::params::glassfish_dir":  }
  file { $glassfish::params::glassfish_path: 
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

  glassfish::download::download { "$download_dir/$glassfish::params::glassfish_download_file":
    uri => "$glassfish::params::glassfish_download_site/$glassfish::params::glassfish_download_file",
    require => [
      File[$glassfish::params::glassfish_path], 
      File[$download_dir]
    ]
  }

  package { unzip:
    ensure => "installed"
  }
  
  exec {'unzip-downloaded':
    command => "unzip $glassfish::params::glassfish_download_file",
    path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",                                                         
    cwd => $download_dir,
    creates => $glassfish::params::glassfish_path,                                                              
    require => [
      File["$download_dir/$glassfish::params::glassfish_download_file"],
      Package[unzip]
    ]
  }
  
  define setgroupaccess ($user, $group, $dir) {
      exec { "rwX $name":
          command => "chmod -R g+rwX $dir",
          path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
          creates => $glassfish::params::glassfish_path,
      }
      exec { "find $name":
          command => "find $dir -type d -exec chmod g+s {} +",
          path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
          creates => $glassfish::params::glassfish_path,
      }
      exec { "group $name":
          command => "chown -R $user:$group $dir",
          path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
          creates => $glassfish::params::glassfish_path,
      }
  }
  
  setgroupaccess {'set-perm':
    user => $glassfish::params::glassfish_user,
    group => $glassfish::params::glassfish_group,
    require => Group[$glassfish::params::glassfish_group],
    dir => "$download_dir/glassfish3",                                                             
  }
  
  exec {'move-downloaded':
    command => "mv $download_dir/glassfish3 $glassfish::params::glassfish_path",
    path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",                                                         
    cwd => $download_dir,
    creates => $glassfish::params::glassfish_path,                                                              
  }
  
  file {servicefile:
    path => "/etc/init.d/glassfish",
    mode => 755,
    content => template('glassfish/glassfish-init.erb'),
    notify  => Service["glassfish"]
  } 
	
	case $java {
    'java-7-oracle'  : {
      java7 { instalation: }
      service { "glassfish":
		    ensure     => running,
		    enable     => true,
		    hasstatus  => true,
		    hasrestart => true,
		    require => [
		      File[$glassfish::params::glassfish_path],
		      File[servicefile],
		      Java7[instalation],
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
          File[$glassfish::params::glassfish_path],
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
          File[$glassfish::params::glassfish_path],
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
          File[$glassfish::params::glassfish_path],
          File[servicefile],
          Package['openjdk-6-jdk'],
        ]
      }
    }
    default          : {
      fail("Unrecognized Java version. Choose one of: java-7-oracle, java-7-openjdk, java-6-oracle, java-6-openjdk")
    }
  }
    
  Glassfish::Download::Download["$download_dir/$glassfish::params::glassfish_download_file"] 
  -> Exec['unzip-downloaded'] 
  -> Setgroupaccess['set-perm'] 
  -> Exec['move-downloaded'] 
  -> File [servicefile]
  -> Service['glassfish']

}
