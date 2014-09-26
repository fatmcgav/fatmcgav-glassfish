# Puppet Glassfish module

[![Puppet Forge](http://img.shields.io/puppetforge/v/fatmcgav/glassfish.svg)](https://forge.puppetlabs.com/fatmcgav/glassfish)
[![Build Status](https://travis-ci.org/fatmcgav/fatmcgav-glassfish.svg?branch=develop)](https://travis-ci.org/fatmcgav/fatmcgav-glassfish)
[![Coverage Status](https://coveralls.io/repos/fatmcgav/fatmcgav-glassfish/badge.png?branch=develop)](https://coveralls.io/r/fatmcgav/fatmcgav-glassfish?branch=develop)

Original puppet-glassfish author - Lars Tobias Skjong-Børsting <larstobi@conduct.no>  
Copyright - Gavin Williams <fatmcgav@gmail.com>

License: GPLv3

####Table of Contents
- [Puppet Glassfish module](#puppet-glassfish-module)
	- [Overview](#overview)
	- [Features](#features)
	- [Requirements](#requirements)
	- [Usage](#usage)
	- [Limitations](#limitations)
	- [Contributors](#contributors)
	- [Development](#development)
	- [Testing](#testing)
	
##Overview
This module adds support for installing and managing the Glassfish J2EE application server.
It supports Glassfish J2EE version 3.1 and 4.0, running on EL and Debian linux distributions.

##Features
This module can do the following: 
 * Install Glassfish J2EE Application server, either by downloading a Zip file 
 or installing from a package.
 * Install and configure Java if appropriate. 
 * Manage user accounts if appropriate. 
 * Configure PATH to support Glassfish.
 * Create Linux service to run Glassfish on system startup.
 * Create asadmin password files for different users or locations.
 * Install additional JARs if appropriate.
 * Create and manage Glassfish clusters, including: 
  * Domain Administration Service (DAS) 
  * Nodes 
  * Instances
 * Manage various configuration elements of Glassfish, including: 
  * Applications
  * Auth Realm
  * Custom Resources
  * JDBC Connection Pools
  * JDBC Resources
  * JMS Resources
  * JVM Options
  * Set options
  * System properties
  * Javamail Resources
  
Further features that are likely to be added include: 
 * Additional support for Cluster environments, such as targeting resources at cluster. 

##Requirements
This module requires the Puppetlabs-Stdlib module >= 3.2.0. 

##Usage
Glassfish can be installed and configured with a default configuration with:  
```puppet
include glassfish
```
This will install Java 7 OpenJDK, create a Glassfish group and user account, 
download and install Glassfish J2EE v3.1.2.2 using a Zip file. No domains are created by default.

To install Glassfish using a package manager, such as yum or apt, you could do: 
```puppet
class { 'glassfish':
  install_method => 'package', 
  package_prefix => 'glassfish'
}
```
_package_prefix_ can be used to change the package naming structure. 
The required version is appended to the end to form the package name, e.g.: `glassfish3-3.1.2.2`

To create and configure a domain upon installation, you could do: 
```puppet
class { 'glassfish': 
  create_domain => true, 
  domain_name   => 'gf_domain', 
  portbase      => '8000'
}
```
This will install Glassfish and create a domain called 'gf_domain' using portbase 8000, 
with a default username/password of '_admin/adminadmin_'.

If you are using other means to manage user accounts on this host, 
then you can stop this module managing user accounts by doing: 
```puppet
class { 'glassfish':
  manage_accounts => false 
}
```

This module also provides several defined types which can be used to simplify other tasks, 
such as creating a domain using `glassfish::create_domain` to create a new domain, 
or `glassfish::create_cluster` to create a new cluster.  

It is also possible to use the types directly.   
E.g.
```puppet
  jdbcconnectionpool { 'ConPool':
    ensure       => present,
    resourcetype => 'javax.sql.ConnectionPoolDataSource',
    dsclassname  => 'oracle.jdbc.pool.OracleConnectionPoolDataSource',
    properties   => 'user=con_user:password=con_password:url=jdbc\:oracle\:thin\:@localhost\:1521\:XE',
    portbase     => '8000',
    asadminuser  => 'admin',
    user         => 'glassfish'
  }

  jdbcresource { 'jdbc/ConPool':
    ensure         => present,
    connectionpool => 'ConPool',
    portbase       => '8000',
    target         => 'aCluster',
    asadminuser    => 'admin',
    user           => 'glassfish'
  }
```

##Limitations
This module has primarily been developed and tested on CentOS 6. 
It has also been lightly tested on Debian and Ubuntu, so should support most common Linux distributions. 

##Contributors
Thanks to the following people who have helped with this module: 
 * Stepan Stipl - Features and testing
 * Jon Black - Testing
 * Alex Jennings - Features

##Development
If you have any features that you feel are missing or find any bugs for this module, 
feel free to raise an issue on [Github](https://github.com/fatmcgav/fatmcgav-glassfish/issues?state=open),
or even better submit a PR and I will review as soon as I can. 

##Testing
This module has been written to support Rspec testing of both the manifests and types/providers.
In order to execute the tests, run the following from the root of the module: 
 `bundle install && bundle exec rake spec`  

