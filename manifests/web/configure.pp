# == Class: graylog2::web::configure
#
# === Authors
#
# Johannes Graf <graf@synyx.de>
#
# === Copyright
#
# Copyright 2014 synyx GmbH & Co. KG
#
class graylog2::web::configure (
  $config_file,
  $daemon_username,
  $graylog2_server_uris,
  $application_secret,
  $timezone = undef,
  $field_list_limit,
  $http_address,
  $http_port,
) {

  ensure_resource('file', '/etc/graylog2', {
    ensure => directory,
    owner  => $daemon_username,
    group  => $daemon_username,
  })

  file {$config_file:
    ensure  => file,
    owner   => $daemon_username,
    group   => $daemon_username,
    mode    => '0640',
    content => template("${module_name}/graylog2-web-interface.conf.erb"),
  }

}
