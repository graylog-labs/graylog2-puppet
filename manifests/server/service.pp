# == Class: graylog2::server::service
#
# === Authors
#
# Johannes Graf <graf@synyx.de>
#
# === Copyright
#
# Copyright 2014 synyx GmbH & Co. KG
#
class graylog2::server::service (
  $service_name,
  $service_ensure,
  $service_enable,
) {

  $service_provider = $::operatingsystem ? {
    'Ubuntu' => 'upstart',
    'Gentoo' => 'openrc',
    default  => undef,
  }

  if $service_provider {
    service { $service_name:
      ensure     => $service_ensure,
      enable     => $service_enable,
      hasstatus  => true,
      hasrestart => true,
      provider   => $service_provider,
    }
  } else {
    service { $service_name:
      ensure     => $service_ensure,
      enable     => $service_enable,
      hasstatus  => true,
      hasrestart => true,
    }
  }

}
