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
  # OS specific settings.
  case $::osfamily {
    'Debian', 'RedHat': {
      # Nothing yet.
    }
    default: {
      fail("${::osfamily} is not supported by ${module_name}")
    }
  }

  $package_name = 'graylog2-server'
  $package_version = 'installed'

  $service_name  = 'graylog2-server'

  $service_ensure = 'running'
  $service_enable = true

  $config_file = '/etc/graylog2.conf'
  $daemon_username = 'graylog2'

  # Config file variables.
  $allow_highlighting = false
  $allow_leading_wildcard_searches = false
  $async_eventbus_processors = 2
  $dead_letters_enabled = false
  $elasticsearch_analyzer = 'standard'
  $elasticsearch_cluster_discovery_timeout = 5000
  $elasticsearch_cluster_name = 'graylog2'
  $elasticsearch_config_file = false
  $elasticsearch_discovery_initial_state_timeout = '3s'
  $elasticsearch_discovery_zen_ping_multicast_enabled = true
  $elasticsearch_discovery_zen_ping_unicast_hosts = false
  $elasticsearch_http_enabled = false
  $elasticsearch_index_prefix = 'graylog2'
  $elasticsearch_max_docs_per_index = 20000000
  $elasticsearch_max_number_of_indices = 20
  $elasticsearch_network_bind_host = false
  $elasticsearch_network_host = false
  $elasticsearch_network_publish_host = false
  $elasticsearch_node_data = false
  $elasticsearch_node_master = false
  $elasticsearch_node_name = 'graylog2-server'
  $elasticsearch_replicas = 0
  $elasticsearch_shards = 4
  $elasticsearch_transport_tcp_port = 9350
  $enable_metrics_collection = false
  $groovy_shell_enable = false
  $groovy_shell_port = 6789
  $http_proxy_uri = false
  $input_cache_max_size = 0
  $is_master = true
  $lb_recognition_period_seconds = 3
  $ldap_connection_timeout = 2000
  $message_cache_commit_interval = 1000
  $message_cache_off_heap = true
  $message_cache_spool_dir = '/var/lib/graylog2-server/message-cache-spool'
  $mongodb_database = 'graylog2'
  $mongodb_host = '127.0.0.1'
  $mongodb_max_connections = 100
  $mongodb_password = false
  $mongodb_port = 27017
  $mongodb_replica_set = false
  $mongodb_threads_allowed_to_block_multiplier = 5
  $mongodb_useauth = false
  $mongodb_user = false
  $node_id_file = '/etc/graylog2/server/node-id'
  $no_retention = false
  $output_batch_size = 25
  $outputbuffer_processor_keep_alive_time = 5000
  $outputbuffer_processors = 3
  $outputbuffer_processor_threads_core_pool_size = 3
  $outputbuffer_processor_threads_max_pool_size = 30
  $output_flush_interval = 1
  $output_module_timeout = 10000
  $password_secret = undef
  $plugin_dir = '/usr/share/graylog2-server/plugin'
  $processbuffer_processors = 5
  $processor_wait_strategy = 'blocking'
  $rest_enable_cors = false
  $rest_enable_gzip = false
  $rest_listen_uri = 'http://127.0.0.1:12900/'
  $rest_transport_uri = 'http://127.0.0.1:12900/'
  $retention_strategy = 'delete'
  $ring_size = 1024
  $root_password_sha2 = undef
  $root_username = 'admin'
  $rules_file = false
  $shutdown_timeout = 30000
  $stale_master_timeout = 2000
  $stream_processing_max_faults = 3
  $stream_processing_timeout = 2000
  $transport_email_auth_password = 'secret'
  $transport_email_auth_username = 'you@example.com'
  $transport_email_enabled = false
  $transport_email_from_email = 'graylog2@example.com'
  $transport_email_hostname = 'mail.example.com'
  $transport_email_port = 587
  $transport_email_subject_prefix = '[graylog2]'
  $transport_email_use_auth = true
  $transport_email_use_ssl = true
  $transport_email_use_tls = true
  $transport_email_web_interface_url = false
  $udp_recvbuffer_sizes = 1048576
  $versionchecks_connection_request_timeout = 10000
  $versionchecks_connect_timeout = 10000
  $versionchecks_socket_timeout = 10000
  $versionchecks = true
  $versionchecks_uri = 'http://versioncheck.torch.sh/check'
}
