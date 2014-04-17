# == Class: graylog2::server::params
#
# === Authors
#
# Johannes Graf <graf@synyx.de>
#
# === Copyright
#
# Copyright 2014 synyx GmbH & Co. KG
#
class graylog2::server::params {

  $package_name = $::osfamily ? {
    /(Debian|RedHat)/ => 'graylog2-server',
    default  => fail("${::osfamily} is not supported by ${module_name}")
  }

  $package_version = 'installed'

  $service_name  = $::osfamily ? {
    /(Debian|RedHat)/ => 'graylog2-server',
    default  => fail("${::osfamily} is not supported by ${module_name}")
  }

  $manage_service_ensure = 'running'

  $manage_service_enable = true

  $run = 'yes'

  $is_master = true

  $node_id_file =$::osfamily ? {
    'Debian' => '/etc/graylog2/server/node-id',
    'RedHat' => '/etc/graylog2/node-id',
    default  => fail("${::osfamily} is not supported by ${module_name}")
  }

  $config_file = $::osfamily ? {
    'Debian' => '/etc/graylog2/server/server.conf',
    'RedHat' => '/etc/graylog2/server.conf',
    default  => fail("${::osfamily} is not supported by ${module_name}")
  }

  $daemon_username = $::osfamily ? {
    'Debian' => '_graylog2',
    'Redhat' => 'graylog2',
    default  => fail("${::osfamily} is not supported by ${module_name}")
  }

  $root_username = 'admin'

  $root_password_sha2 = '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918' #admin

  $plugin_dir = $::osfamily ? {
    'Debian' => '/usr/share/graylog2-server/plugin',
    'RedHat' => '/opt/graylog2/server/plugin',
    default  => fail("${::osfamily} is not supported by ${module_name}")
  }

  $rest_listen_uri = 'http://127.0.0.1:12900/'

  $elasticsearch_max_docs_per_index = 20000000

  $elasticsearch_max_number_of_indices = 20

  $retention_strategy = 'delete'

  $elasticsearch_shards = 1

  $elasticsearch_replicas = 0

  $elasticsearch_index_prefix = 'graylog2'

  $allow_leading_wildcard_searches = false

  $elasticsearch_analyzer = 'standard'

  $output_batch_size = 5000

  $processbuffer_processors = 5

  $outputbuffer_processors = 5

  $processor_wait_strategy = 'blocking'

  $ring_size = 1024

  $mongodb_useauth = false

  $mongodb_host = '127.0.0.1'

  $mongodb_database = 'graylog2'

  $mongodb_port = 27017

  $mongodb_max_connections = 100

  $mongodb_threads_allowed_to_block_multiplier = 5

  $transport_email_enabled = false

  $transport_email_hostname = 'mail.example.com'

  $transport_email_port = 587

  $transport_email_use_auth = true

  $transport_email_use_tls = true

  $transport_email_use_ssl = true

  $transport_email_auth_username = 'you@example.com'

  $transport_email_auth_password = 'secret'

  $transport_email_subject_prefix = '[graylog2]'

  $transport_email_from_email = 'graylog2@example.com'
}
