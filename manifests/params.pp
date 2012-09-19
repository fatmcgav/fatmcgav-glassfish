# Class: glassfish::params
#
# Defines Glassfish params
#
#
#
class glassfish::params {

	$glassfish_user 			= "glassfish" # Default Glassfish User
	$glassfish_group			= "glassfish" # Default Glassfish Group
	$glassfish_asadmin_user 	= "admin" # Default Glassfish asadmin user
	$glassfish_asadmin_passfile	= "" # Default Glassfish asadmin password file
	$glassfish_portbase			= "8000" # Default Glassfish portbase

}