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
  $graylog2_server_uris,
  $application_secret,
  $timezone = undef,
  $field_list_limit,
  $run,
  $http_address,
  $http_port,
) {

  file { '/etc/default/graylog2-web':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/web_default.erb"),
  }

  file {'/etc/graylog2/web/graylog2-web-interface.conf':
    ensure  => file,
    owner   => '_graylog2',
    group   => '_graylog2',
    mode    => '0640',
    content => template("${module_name}/graylog2-web-interface.conf.erb"),
  }

}
