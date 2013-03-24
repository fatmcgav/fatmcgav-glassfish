# Class: glassfish::params
#
# Defines Glassfish params
#
#
#
class glassfish::params {

	$glassfish_version			= "3.1.2.2" # Default Glassfish version
	$glassfish_path				= "/usr/local/glassfish-$glassfish_version" # Default Glassfish path
	$glassfish_domain			= undef # Default Glassfish domain name
	$glassfish_user 			= "glassfish" # Default Glassfish User
	$glassfish_group			= "glassfish" # Default Glassfish Group
	$glassfish_asadmin_path		= "$glassfish_path/bin/asadmin" # Default Glassfish Asadmin path
	$glassfish_asadmin_user 	= "admin" # Default Glassfish asadmin user
	$glassfish_asadmin_passfile	= "" # Default Glassfish asadmin password file
	$glassfish_portbase			= "8000" # Default Glassfish portbase
	$glassfish_profile			= "server" # Default Glassfish profile
  $glassfish_download_site = "http://download.java.net/glassfish/$glassfish_version/release" # Default Glassfish download
  $glassfish_download_file = "glassfish-$glassfish_version.zip" # Default Glassfish download
  $glassfish_java         = "java-7-oracle" # JDK version: java-7-oracle, java-7-openjdk, java-6-oracle, java-6-openjdk 
}