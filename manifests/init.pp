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
class glassfish {
  include glassfish::params
  include glassfish::download
  
  case $glassfish::params::glassfish_java {
    'java-7-oracle': {
      include java7 
    }
    'java-7-openjdk': {
      package {'openjdk-7-jdk':
        ensure => "installed"
      }
    }
    'java-6-oracle': {
      package {'sun-java6-jdk':
        ensure => "installed"
      }
    }
    'java-6-openjdk': {
      package {'openjdk-6-jdk':
        ensure => "installed"
      }
    }
    default: { 
      fail("Unrecognized Java version. Choose one of: java-7-oracle, java-7-openjdk, java-6-oracle, java-6-openjdk")
    }
  }
  
  file { $glassfish::params::glassfish_path:
      ensure => "directory",
  }
  
  glassfish::download::download_file { $glassfish::params::glassfish_download_file:
    site => $glassfish::params::glassfish_download_site,                                                                           
    cwd => $glassfish::params::glassfish_path,                                                                            
    creates => "$glassfish::params::glassfish_path/$glassfish::params::glassfish_download_file",                                                                  
    require => File[$glassfish::params::glassfish_path],                                                                  
    user => $glassfish::params::glassfish_user
  }
  
}
