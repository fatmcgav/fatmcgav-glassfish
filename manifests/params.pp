# Class: glassfish::params
#
# Defines Glassfish params
#
#
#
class glassfish::params {

	$glassfish_version          = "3.1.2.2" # Default Glassfish version
	$glassfish_domain			      = "domain1" # Default Glassfish domain name
	$glassfish_user 			      = "glassfish" # Default Glassfish User
	$glassfish_group			      = "glassfish" # Default Glassfish Group
	$glassfish_asadmin_user 	  = "admin" # Default Glassfish asadmin user
	$glassfish_asadmin_passfile	= "" # Default Glassfish asadmin password file
	$glassfish_portbase			    = "8000" # Default Glassfish portbase
	$glassfish_profile			    = "server" # Default Glassfish profile
  $glassfish_java             = "java-7-oracle" # JDK version: java-7-oracle, java-7-openjdk, java-6-oracle, java-6-openjdk 
}