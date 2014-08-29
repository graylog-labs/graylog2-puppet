# == Class: graylog2::web::service
#
# === Authors
#
# Johannes Graf <graf@synyx.de>
#
# === Copyright
#
# Copyright 2014 synyx GmbH & Co. KG
#
class graylog2::web::service (
  $service_name,
  $service_ensure,
  $service_enable,
) {

  service { $service_name:
    ensure     => $service_ensure,
    enable     => $service_enable,
    hasstatus  => true,
    hasrestart => true,
  }

}
