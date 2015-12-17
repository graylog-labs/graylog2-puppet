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

  # OS specific settings.
  case $::osfamily {
    'Debian', 'RedHat': {
      $package_name = 'graylog-web'
      $config_file = '/etc/graylog/web/web.conf'
      $bin_file = '/usr/share/graylog-web-interface/bin/graylog-web-interface'
    }
    'Gentoo': {
      $package_name = 'app-admin/graylog-web-interface'
      $config_file = '/etc/graylog/graylog-web-interface.conf'
      $bin_file = '/opt/graylog-web-interface/bin/graylog-web-interface'
    }
    default: {
      fail("${::osfamily} is not supported by ${module_name}")
    }
  }

  $log_file = '/var/log/graylog/graylog-web.log'

  $pid_file = '/run/graylog/graylog-web.pid'

  $package_version = 'installed'

  $service_name  = 'graylog-web'

  $service_ensure = 'running'

  $service_enable = true

  $graylog2_server_uris = ['http://127.0.0.1:12900/']

  $application_secret = undef

  $command_wrapper = ''

  $timezone = undef

  $field_list_limit = '100'

  $http_address = '0.0.0.0'

  $http_port = '9000'

  $http_path_prefix = false

  $extra_args = ''
  $java_opts = ''

  $daemon_username = 'graylog-web'

  $timeout = false

}
