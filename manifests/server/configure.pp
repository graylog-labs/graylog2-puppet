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
  $run,
  $is_master,
  $node_id_file,
  $password_secret = undef,
  $root_username,
  $root_password_sha2,
  $plugin_dir,
  $rest_listen_uri,
  $rest_transport_uri = undef,
  $rest_enable_cors = undef,
  $elasticsearch_config_file = undef,
  $elasticsearch_max_docs_per_index,
  $elasticsearch_max_number_of_indices,
  $retention_strategy,
  $elasticsearch_shards,
  $elasticsearch_replicas,
  $elasticsearch_index_prefix,
  $allow_leading_wildcard_searches,
  $elasticsearch_analyzer,
  $elasticsearch_transport_tcp_port = undef,
  $elasticsearch_network_host = undef,
  $elasticsearch_discovery_zen_ping_multicast_enabled = undef,
  $elasticsearch_discovery_zen_ping_unicast_hosts = undef,
  $output_batch_size,
  $processbuffer_processors,
  $outputbuffer_processors,
  $processor_wait_strategy,
  $ring_size,
  $mongodb_useauth,
  $mongodb_user = undef,
  $mongodb_password = undef,
  $mongodb_host,
  $mongodb_replica_set = undef,
  $mongodb_database,
  $mongodb_port,
  $mongodb_max_connections,
  $mongodb_threads_allowed_to_block_multiplier,
  $transport_email_enabled,
  $transport_email_hostname,
  $transport_email_port,
  $transport_email_use_auth,
  $transport_email_use_tls,
  $transport_email_use_ssl,
  $transport_email_auth_username,
  $transport_email_auth_password,
  $transport_email_subject_prefix,
  $transport_email_from_email,
) {

  file { '/etc/default/graylog2-server':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/server_default.erb"),
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

}
