# Class: glassfish::domain
#
# Create a glassfish domain
#
#
#
class glassfish::domain ( 
	$glassfish_domain 			= $glassfish::params::glassfish_domain,
	$glassfish_user				= $glassfish::params::glassfish_user,
	$glassfish_group			= $glassfish::params::glassfish_group,
	$glassfish_asadmin_path		= $glassfish::params::glassfish_asadmin_path,	
	$glassfish_asadmin_user		= $glassfish::params::glassfish_asadmin_user,
	$glassfish_asadmin_passfile	= $glassfish::params::glassfish_asadmin_passfile,
	$glassfish_portbase			= $glassfish::params::glassfish_portbase,
	$glassfish_ensure			= present,
) inherits glassfish::params {
	
	# Check if domain name has been defined. 
	if  $glassfish_domain == undef {
		fail('Please specify a glassfish domain name now!')
	}

	# Notify user
	notify {'gfdomain':
	        message => "Creating Glassfish domain $glassfish_domain using portbase $glassfish_portbase"
	}

	# Create the domain
	domain { $glassfish_domain:
        user            => $glassfish_user,
        asadminuser     => $glassfish_asadmin_user,
        passwordfile    => $glassfish_asadmin_passfile,
        ensure			=> $glassfish_ensure,
        portbase		=> $glassfish_portbase,
        asadminpath		=> $glassfish_asadmin_path,
	}

	
}