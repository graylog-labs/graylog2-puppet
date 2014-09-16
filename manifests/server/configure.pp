# == Class: graylog2_server::configure
#
# === Authors
#
# Johannes Graf <graf@synyx.de>
#
# === Copyright
#
# Copyright 2014 synyx GmbH & Co. KG
#
class graylog2::server::configure (
  $config_file,
  $daemon_username,

  $allow_highlighting,
  $allow_leading_wildcard_searches,
  $async_eventbus_processors,
  $dead_letters_enabled,
  $elasticsearch_analyzer,
  $elasticsearch_cluster_discovery_timeout,
  $elasticsearch_cluster_name,
  $elasticsearch_config_file,
  $elasticsearch_discovery_initial_state_timeout,
  $elasticsearch_discovery_zen_ping_multicast_enabled,
  $elasticsearch_discovery_zen_ping_unicast_hosts,
  $elasticsearch_http_enabled,
  $elasticsearch_index_prefix,
  $elasticsearch_max_docs_per_index,
  $elasticsearch_max_number_of_indices,
  $elasticsearch_network_bind_host,
  $elasticsearch_network_host,
  $elasticsearch_network_publish_host,
  $elasticsearch_node_data,
  $elasticsearch_node_master,
  $elasticsearch_node_name,
  $elasticsearch_replicas,
  $elasticsearch_shards,
  $elasticsearch_transport_tcp_port,
  $enable_metrics_collection,
  $extra_args,
  $groovy_shell_enable,
  $groovy_shell_port,
  $http_proxy_uri,
  $input_cache_max_size,
  $is_master,
  $java_opts,
  $lb_recognition_period_seconds,
  $ldap_connection_timeout,
  $message_cache_commit_interval,
  $message_cache_off_heap,
  $message_cache_spool_dir,
  $mongodb_database,
  $mongodb_host,
  $mongodb_max_connections,
  $mongodb_password,
  $mongodb_port,
  $mongodb_replica_set,
  $mongodb_threads_allowed_to_block_multiplier,
  $mongodb_useauth,
  $mongodb_user,
  $node_id_file,
  $no_retention,
  $output_batch_size,
  $outputbuffer_processor_keep_alive_time,
  $outputbuffer_processors,
  $outputbuffer_processor_threads_core_pool_size,
  $outputbuffer_processor_threads_max_pool_size,
  $output_flush_interval,
  $output_module_timeout,
  $password_secret,
  $plugin_dir,
  $processbuffer_processors,
  $processor_wait_strategy,
  $rest_enable_cors,
  $rest_enable_gzip,
  $rest_listen_uri,
  $rest_transport_uri,
  $retention_strategy,
  $ring_size,
  $root_password_sha2,
  $root_username,
  $rules_file,
  $shutdown_timeout,
  $stale_master_timeout,
  $stream_processing_max_faults,
  $stream_processing_timeout,
  $transport_email_auth_password,
  $transport_email_auth_username,
  $transport_email_enabled,
  $transport_email_from_email,
  $transport_email_hostname,
  $transport_email_port,
  $transport_email_subject_prefix,
  $transport_email_use_auth,
  $transport_email_use_ssl,
  $transport_email_use_tls,
  $transport_email_web_interface_url,
  $udp_recvbuffer_sizes,
  $versionchecks_connection_request_timeout,
  $versionchecks_connect_timeout,
  $versionchecks_socket_timeout,
  $versionchecks,
  $versionchecks_uri,
) {
  validate_bool(
    $allow_highlighting,
    $allow_leading_wildcard_searches,
    $dead_letters_enabled,
    $elasticsearch_discovery_zen_ping_multicast_enabled,
    $elasticsearch_http_enabled,
    $elasticsearch_node_data,
    $elasticsearch_node_master,
    $enable_metrics_collection,
    $groovy_shell_enable,
    $is_master,
    $message_cache_off_heap,
    $mongodb_useauth,
    $no_retention,
    $rest_enable_cors,
    $rest_enable_gzip,
    $transport_email_enabled,
    $transport_email_use_auth,
    $transport_email_use_ssl,
    $transport_email_use_tls,
    $versionchecks,
  )

  # We also validate number values to be a string because it works and we can
  # detect invalid values.
  validate_string(
    $daemon_username,

    $async_eventbus_processors,
    $elasticsearch_analyzer,
    $elasticsearch_cluster_discovery_timeout,
    $elasticsearch_cluster_name,
    $elasticsearch_discovery_initial_state_timeout,
    $elasticsearch_index_prefix,
    $elasticsearch_max_docs_per_index,
    $elasticsearch_max_number_of_indices,
    $elasticsearch_node_name,
    $elasticsearch_replicas,
    $elasticsearch_shards,
    $elasticsearch_transport_tcp_port,
    $extra_args,
    $groovy_shell_port,
    $input_cache_max_size,
    $java_opts,
    $lb_recognition_period_seconds,
    $ldap_connection_timeout,
    $message_cache_commit_interval,
    $message_cache_spool_dir,
    $mongodb_database,
    $mongodb_host,
    $mongodb_max_connections,
    $mongodb_port,
    $mongodb_threads_allowed_to_block_multiplier,
    $node_id_file,
    $output_batch_size,
    $outputbuffer_processor_keep_alive_time,
    $outputbuffer_processors,
    $outputbuffer_processor_threads_core_pool_size,
    $outputbuffer_processor_threads_max_pool_size,
    $output_flush_interval,
    $output_module_timeout,
    $plugin_dir,
    $processbuffer_processors,
    $processor_wait_strategy,
    $rest_listen_uri,
    $rest_transport_uri,
    $retention_strategy,
    $ring_size,
    $root_password_sha2,
    $root_username,
    $shutdown_timeout,
    $stale_master_timeout,
    $stream_processing_max_faults,
    $stream_processing_timeout,
    $transport_email_auth_password,
    $transport_email_auth_username,
    $transport_email_from_email,
    $transport_email_hostname,
    $transport_email_port,
    $transport_email_subject_prefix,
    $udp_recvbuffer_sizes,
    $versionchecks_connection_request_timeout,
    $versionchecks_connect_timeout,
    $versionchecks_socket_timeout,
    $versionchecks_uri,
  )

  validate_absolute_path(
    $config_file,

    $message_cache_spool_dir,
    $node_id_file,
    $plugin_dir,
  )

  # This is required and there is no default!
  if ! $password_secret {
    fail('Missing or empty password_secret parameter!')
  }

  if size($password_secret) < 64 {
    fail('The password_secret parameter is too short. (at least 64 characters)!')
  }

  # This is required and there is no default!
  if ! $root_password_sha2 {
    fail('Missing or empty root_password_sha2 parameter!')
  }

  if size($root_password_sha2) < 64 {
    fail('The root_password_sha2 parameter does not look like a SHA256 checksum!')
  }

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
    content => template("${module_name}/server.conf.erb"),
  }

  case $::osfamily {
    'Debian': {
      file { '/etc/default/graylog2-server':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("${module_name}/server.default.erb"),
      }
    }
    'RedHat': {
      file { '/etc/sysconfig/graylog2-server':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("${module_name}/server.sysconfig.erb"),
        }
      }
    default: {
      fail("${::osfamily} is not supported by ${module_name}")
    }
  }
}
