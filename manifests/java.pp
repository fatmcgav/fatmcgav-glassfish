# Class: glassfish::java
#
# Manages java installation if required
#
class glassfish::java {
  # Get the package name based on required java_ver.
  case $glassfish::java_ver {
    'java-7-oracle'  : {
      # require ::java7
      $package = 'UNSET'
    }
    'java-7-openjdk' : {
      $package = $glassfish::params::java7_openjdk_package
    }
    'java-6-oracle'  : {
      $package = 'UNSET'
    }
    'java-6-openjdk' : {
      $package = $glassfish::params::java6_openjdk_package
    }

    default          : {
      fail("Unrecognized Java version ${glassfish::java_ver}. Choose one of: java-7-oracle, java-7-openjdk, java-6-oracle, java-6-openjdk"
      )
    }
  }

  # Install the required package, if set.
  if !$package == 'UNSET' {
    package { $package: ensure => 'installed' }
  }

}
