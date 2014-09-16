# == Class: graylog2::radio::configure
#
# === Authors
#
# Renan Silva <renanvice@gmail.com>
#
# === Copyright
#
# Copyright 2014 synyx GmbH & Co. KG
#
class graylog2::radio::configure (
  $config_file,
  $daemon_username,
  $node_id_file,
  $transport_type,
  $graylog2_server_uris,
  $rest_listen_uri,
  $rest_transport_uri,
  $amqp_broker_hostname,
  $amqp_broker_port,
  $amqp_broker_vhost,
  $amqp_broker_username,
  $amqp_broker_password,
  $command_wrapper,
  $kafka_brokers,
  $kafka_producer_type,
  $kafka_batch_size,
  $kafka_batch_max_wait_ms,
  $kafka_required_acks,
  $processbuffer_processors,
  $processor_wait_strategy,
  $ring_size,
  $input_cache_max_size,
  $java_opts,
  $extra_args,
  $template_file,
  $template_config_file,
) {

  validate_array(
    $graylog2_server_uris,
    $kafka_brokers,
  )

  validate_string(
    $daemon_username,
    $node_id_file,
    $transport_type,
    $rest_listen_uri,
    $rest_transport_uri,
    $amqp_broker_hostname,
    $amqp_broker_port,
    $amqp_broker_vhost,
    $amqp_broker_username,
    $amqp_broker_password,
    $command_wrapper,
    $kafka_producer_type,
    $kafka_batch_size,
    $kafka_batch_max_wait_ms,
    $kafka_required_acks,
    $processbuffer_processors,
    $processor_wait_strategy,
    $ring_size,
    $input_cache_max_size,
    $java_opts,
    $extra_args,
    $template_file,
    $template_config_file
  )

  validate_absolute_path(
    $config_file,
    $node_id_file,
  )

  ensure_resource('file', '/etc/graylog2/radio', {
    ensure => directory,
    owner  => $daemon_username,
    group  => $daemon_username,
  })

  case $::osfamily {
    'Debian': {
      $template_content = $template_file ? {
        ''      => template("${module_name}/radio.default.erb"),
        default => template("${module_name}/${template_file}"),
      }
      file { '/etc/default/graylog2-radio':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => $template_content,
      }
    }
    'RedHat': {
      $template_content = $template_file ? {
        ''      => template("${module_name}/radio.sysconfig.erb"),
        default => template("${module_name}/${template_file}"),
      }
      file { '/etc/sysconfig/graylog2-radio':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => $template_content,
        }
      }
    default: {
      fail("${::osfamily} is not supported by ${module_name}")
    }
  }

  $template_config_content = $template_config_file ? {
    ''      => template("${module_name}/graylog2-radio.conf.erb"),
    default => template("${module_name}/${template_config_file}")
  }
  file {$config_file:
    ensure  => file,
    owner   => $daemon_username,
    group   => $daemon_username,
    mode    => '0640',
    content => $template_config_content,
  }

}
