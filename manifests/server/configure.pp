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

  $alert_check_interval,
  $allow_highlighting,
  $allow_leading_wildcard_searches,
  $async_eventbus_processors,
  $collector_expiration_threshold,
  $collector_inactive_threshold,
  $command_wrapper,
  $dashboard_widget_default_cache_time,
  $dead_letters_enabled,
  $disable_index_optimization,
  $disable_index_range_calculation,
  $disable_sigar,
  $elasticsearch_analyzer,
  $elasticsearch_cluster_discovery_timeout,
  $elasticsearch_cluster_name,
  $elasticsearch_config_file,
  $elasticsearch_disable_version_check,
  $elasticsearch_discovery_initial_state_timeout,
  $elasticsearch_discovery_zen_ping_multicast_enabled,
  $elasticsearch_discovery_zen_ping_unicast_hosts,
  $elasticsearch_http_enabled,
  $elasticsearch_index_prefix,
  $elasticsearch_max_docs_per_index,
  $elasticsearch_max_number_of_indices,
  $elasticsearch_max_size_per_index,
  $elasticsearch_max_time_per_index,
  $elasticsearch_network_bind_host,
  $elasticsearch_network_host,
  $elasticsearch_network_publish_host,
  $elasticsearch_node_data,
  $elasticsearch_node_master,
  $elasticsearch_node_name,
  $elasticsearch_replicas,
  $elasticsearch_request_timeout,
  $elasticsearch_shards,
  $elasticsearch_transport_tcp_port,
  $enable_metrics_collection,
  $extra_args,
  $gc_warning_threshold,
  $http_connect_timeout,
  $http_proxy_uri,
  $http_read_timeout,
  $http_write_timeout,
  $index_optimization_max_num_segments,
  $inputbuffer_processors,
  $inputbuffer_ring_size,
  $inputbuffer_wait_strategy,
  $is_master,
  $java_opts,
  $lb_recognition_period_seconds,
  $ldap_connection_timeout,
  $message_journal_dir,
  $message_journal_enabled,
  $message_journal_flush_age,
  $message_journal_flush_interval,
  $message_journal_max_age,
  $message_journal_max_size,
  $message_journal_segment_age,
  $message_journal_segment_size,
  $mongodb_database,
  $mongodb_host,
  $mongodb_uri,
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
  $output_fault_count_threshold,
  $output_fault_penalty_seconds,
  $output_flush_interval,
  $output_module_timeout,
  $password_secret,
  $plugin_dir,
  $processbuffer_processors,
  $processor_wait_strategy,
  $rest_enable_cors,
  $rest_enable_gzip,
  $rest_enable_tls,
  $rest_listen_uri,
  $rest_max_chunk_size,
  $rest_max_header_size,
  $rest_max_initial_line_length,
  $rest_thread_pool_size,
  $rest_tls_cert_file,
  $rest_tls_key_file,
  $rest_tls_key_password,
  $rest_transport_uri,
  $rest_worker_threads_max_pool_size,
  $retention_strategy,
  $ring_size,
  $root_email,
  $root_password_sha2,
  $root_username,
  $root_timezone,
  $rotation_strategy,
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
  $usage_statistics_cache_timeout,
  $usage_statistics_dir,
  $usage_statistics_enabled,
  $usage_statistics_gzip_enabled,
  $usage_statistics_initial_delay,
  $usage_statistics_max_queue_size,
  $usage_statistics_offline_mode,
  $usage_statistics_report_interval,
  $usage_statistics_url,
  $versionchecks,
  $versionchecks_uri,
  $admin_user,
  $admin_pass,
  $api_port,
  $in_bypass_prefixes,
  $out_bypass_prefixes,
  $stream_bypass_prefixes,
  $user_bypass_prefixes,
) {
  validate_bool(
    $allow_highlighting,
    $allow_leading_wildcard_searches,
    $dead_letters_enabled,
    $disable_index_optimization,
    $disable_index_range_calculation,
    $disable_sigar,
    $elasticsearch_disable_version_check,
    $elasticsearch_discovery_zen_ping_multicast_enabled,
    $elasticsearch_http_enabled,
    $elasticsearch_node_data,
    $elasticsearch_node_master,
    $enable_metrics_collection,
    $is_master,
    $message_journal_enabled,
    $mongodb_useauth,
    $no_retention,
    $rest_enable_cors,
    $rest_enable_gzip,
    $rest_enable_tls,
    $rest_tls_key_password,
    $transport_email_enabled,
    $transport_email_use_auth,
    $transport_email_use_ssl,
    $transport_email_use_tls,
    $usage_statistics_enabled,
    $usage_statistics_gzip_enabled,
    $usage_statistics_offline_mode,
    $versionchecks,
  )

  # We also validate number values to be a string because it works and we can
  # detect invalid values.
  validate_string(
    $daemon_username,

    $alert_check_interval,
    $async_eventbus_processors,
    $collector_expiration_threshold,
    $collector_inactive_threshold,
    $command_wrapper,
    $dashboard_widget_default_cache_time,
    $elasticsearch_analyzer,
    $elasticsearch_cluster_discovery_timeout,
    $elasticsearch_cluster_name,
    $elasticsearch_discovery_initial_state_timeout,
    $elasticsearch_index_prefix,
    $elasticsearch_max_docs_per_index,
    $elasticsearch_max_number_of_indices,
    $elasticsearch_max_size_per_index,
    $elasticsearch_max_time_per_index,
    $elasticsearch_node_name,
    $elasticsearch_replicas,
    $elasticsearch_request_timeout,
    $elasticsearch_shards,
    $elasticsearch_transport_tcp_port,
    $extra_args,
    $gc_warning_threshold,
    $http_connect_timeout,
    $http_read_timeout,
    $http_write_timeout,
    $index_optimization_max_num_segments,
    $inputbuffer_processors,
    $inputbuffer_ring_size,
    $inputbuffer_wait_strategy,
    $java_opts,
    $lb_recognition_period_seconds,
    $ldap_connection_timeout,
    $message_journal_flush_age,
    $message_journal_flush_interval,
    $message_journal_max_age,
    $message_journal_max_size,
    $message_journal_segment_age,
    $message_journal_segment_size,
    $mongodb_database,
    $mongodb_max_connections,
    $mongodb_threads_allowed_to_block_multiplier,
    $node_id_file,
    $output_batch_size,
    $outputbuffer_processor_keep_alive_time,
    $outputbuffer_processors,
    $outputbuffer_processor_threads_core_pool_size,
    $outputbuffer_processor_threads_max_pool_size,
    $output_fault_count_threshold,
    $output_fault_penalty_seconds,
    $output_flush_interval,
    $output_module_timeout,
    $plugin_dir,
    $processbuffer_processors,
    $processor_wait_strategy,
    $rest_listen_uri,
    $rest_max_chunk_size,
    $rest_max_header_size,
    $rest_max_initial_line_length,
    $rest_thread_pool_size,
    $rest_tls_cert_file,
    $rest_tls_key_file,
    $rest_transport_uri,
    $rest_worker_threads_max_pool_size,
    $retention_strategy,
    $ring_size,
    $rotation_strategy,
    $root_email,
    $root_password_sha2,
    $root_timezone,
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
    $usage_statistics_cache_timeout,
    $usage_statistics_initial_delay,
    $usage_statistics_max_queue_size,
    $usage_statistics_report_interval,
    $usage_statistics_url,
    $versionchecks_uri,
    $admin_user,
    $admin_pass,
    $api_port,
  )

  validate_absolute_path(
    $config_file,
    $message_journal_dir,
    $node_id_file,
    $plugin_dir,
    $usage_statistics_dir,
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

  # Check wheather old, version 1.0, configuration method is used and throw a warning
  if ! $mongodb_uri {
    warning('You are using a deprecated MongoDB configuration method. If you are running Graylog >=1.1, please use mongodb_uri.')
  }

  ensure_resource('file', '/etc/graylog/server', {
    ensure  => directory,
    owner   => $daemon_username,
    group   => $daemon_username,
  })

  file {$config_file:
    ensure    => file,
    owner     => $daemon_username,
    group     => $daemon_username,
    mode      => '0640',
    content   => template("${module_name}/server.conf.erb"),
    show_diff => false,
    require   => File['/etc/graylog/server'],
  }

  case $::osfamily {
    'Debian': {
      file { '/etc/default/graylog-server':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("${module_name}/server.default.erb"),
      }
    }
    'RedHat': {
      file { '/etc/sysconfig/graylog-server':
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

  #preparing files for native types
  # in this directory are placed two important files for the native types, declared below
  file{'/var/lib/puppet/module_data/graylog2':
    ensure => 'directory',
  }
  # file that contains the configuration for the native types
  # TODO deal with password
  file{'/var/lib/puppet/module_data/graylog2/types_conf.yaml':
    content => template('graylog2/types_conf.yaml.erb'),
  }
  # file that keeps a small YAML-based table of strearule-id -> names
  file{'/var/lib/puppet/module_data/graylog2/streamrule_ids.yaml':
    ensure  => 'present',
  }

}
