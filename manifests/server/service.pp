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
  $manage_service_ensure,
  $manage_service_enable,
) {

  service { $service_name:
    ensure     => $manage_service_ensure,
    enable     => $manage_service_enable,
    hasstatus  => true,
    hasrestart => true,
  }

}
