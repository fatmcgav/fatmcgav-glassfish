# == Define: glassfish::service::init
#
# Create a glassfish init.d service.
#
# === Parameters
#
# === Examples
#
#
# === Authors
#
# Gavin Williams <fatmcgav@gmail.com>
#
# === Copyright
#
# Copyright 2017 Gavin Williams, unless otherwise noted.
#
define glassfish::service::init (
  $ensure,
  $enable,
  $mode,
  $status     = $glassfish::service_status,
  $status_cmd = undef,
  $svc_name   = $title,
  $user       = $glassfish::user
) {
  # set params: in operation
  if $ensure == 'present' {

    case $status {
      # make sure service is currently running, start it on boot
      'enabled': {
        $_service_ensure = 'running'
        $_service_enable = true
      }
      # make sure service is currently stopped, do not start it on boot
      'disabled': {
        $_service_ensure = 'stopped'
        $_service_enable = false
      }
      # make sure service is currently running, do not start it on boot
      'running': {
        $_service_ensure = 'running'
        $_service_enable = false
      }
      # do not start service on boot, do not care whether currently running
      # or not
      'unmanaged': {
        $_service_ensure = undef
        $_service_enable = false
      }
      # unknown status
      # note: don't forget to update the parameter check in init.pp if you
      #       add a new or change an existing status.
      default: {
        fail("\"${status}\" is an unknown service status value")
      }
    }
  } else {
    # make sure the service is stopped and disabled (the removal itself will be
    # done by package.pp)
    $_service_ensure = 'stopped'
    $_service_enable = false
  }

  # Which template
  case $mode {
    'domain': {
      $_template = $glassfish::params::service_domain_template
    }
    'instance': {
      $_template = $glassfish::params::service_intance_template
    }
    default: {
      fail("Service ${mode} is not currently supported.")
    }
  }

  # Only notify service if restarting on config change
  $service_notify = $glassfish::restart_config_change ? {
    true  => Service[$title],
    false => undef
  }

  # Create the service file
  file { "${title}-servicefile":
    ensure  => present,
    path    => "/etc/init.d/${title}",
    owner   => 'root',
    group   => '0',
    mode    => '0755',
    content => template("glassfish/${_template}"),
    notify  => $service_notify,
  }

  # Handle different service status options
  if $status_cmd {
    $_has_status = false
  } else {
    $_has_status = true
  }

  # Make sure the service is running and enabled.
  service { $title:
    ensure     => $_service_ensure,
    enable     => $_service_enable,
    hasstatus  => $_has_status,
    hasrestart => true,
    status     => $status_cmd
  }

}
