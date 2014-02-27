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
    'Debian' => 'graylog2-web',
    default  => fail("${::osfamily} is not supported by ${module_name}")
  }

  $package_version = 'installed'

  $service_name  = $::osfamily ? {
    'Debian' => 'graylog2-web',
    default  => fail("${::osfamily} is not supported by ${module_name}")
  }

  $manage_service_ensure = 'running'

  $manage_service_enable = true

  $graylog2_server_uris = ['http://127.0.0.1:12900/']

  $application_secret = ''

  $timezone = undef

  $field_list_limit = 100

  $run = 'yes'

  $http_address = '0.0.0.0'

  $http_port = '9000'
}
