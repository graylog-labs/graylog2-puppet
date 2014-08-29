# == Class: graylog2::web::params
#
# === Authors
#
# Johannes Graf <graf@synyx.de>
#
# === Copyright
#
# Copyright 2014 synyx GmbH & Co. KG
#
class graylog2::web::params {

  $package_name = $::osfamily ? {
    /(Debian|RedHat)/ => 'graylog2-web',
    default  => fail("${::osfamily} is not supported by ${module_name}")
  }

  $package_version = 'installed'

  $service_name  = $::osfamily ? {
    /(Debian|RedHat)/ => 'graylog2-web',
    default  => fail("${::osfamily} is not supported by ${module_name}")
  }

  $service_ensure = 'running'

  $service_enable = true

  $graylog2_server_uris = ["http://${::ipaddress_eth0}:12900/"]

  $application_secret = ''

  $timezone = undef

  $field_list_limit = 100

  $run = 'yes'

  $http_address = '0.0.0.0'

  $http_port = '9000'

  $config_file = $::osfamily ? {
    'Debian' => '/etc/graylog2/web/graylog2-web-interface.conf',
    'RedHat' => '/etc/graylog2/web.conf',
    default  => fail("${::osfamily} is not supported by ${module_name}")
  }

  $daemon_username = $::osfamily ? {
    'Debian' => 'graylog2-web',
    'Redhat' => 'graylog2-web',
    default  => fail("${::osfamily} is not supported by ${module_name}")
  }

}
