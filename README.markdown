# Puppet Glassfish module

[![Build Status](https://travis-ci.org/fatmcgav/fatmcgav-glassfish.svg?branch=develop)](https://travis-ci.org/fatmcgav/fatmcgav-glassfish)
[![Coverage Status](https://coveralls.io/repos/fatmcgav/fatmcgav-glassfish/badge.png?branch=develop)](https://coveralls.io/r/fatmcgav/fatmcgav-glassfish?branch=develop)

Original puppet-glassfish author - Lars Tobias Skjong-Børsting <larstobi@conduct.no>  
Copyright - Gavin Williams <fatmcgav@gmail.com>

License: GPLv3

####Table of Contents

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
  
Further features that are likely to be added include: 
 * Additional support for Cluster environments, such as targeting resources at cluster. 

##Requirements
This module requires the Puppetlabs-Stdlib module >= 3.2.0. 

##Usage

##Limitations
This module has been primarily developed on CentOS v6. 
It has also been tested on Debian and Ubuntu, so should support most common Linux distributions. 

##Development
If you have any features that you feel are missing or find any bugs for this module, 
feel free to raise an issue on [Github](https://github.com/fatmcgav/fatmcgav-glassfish/issues?state=open),
or even better submit a PR and I will review as soon as I can. 

##Testing
This module has been written to support Rspec testing of both the manifests and types/providers.
In order to execute the tests, run the following from the root of the module: 
 `bundle install && bundle exec rake spec`  