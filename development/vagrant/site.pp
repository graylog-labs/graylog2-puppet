node default {
  $es_cluster_name = 'gl2'

  # Dependencies
  class { 'elasticsearch':
    version      => '0.90.10',
    manage_repo  => true,
    repo_version => '0.90',
    java_install => true,
  }

  elasticsearch::instance { 'esgl2':
    config => {
      'cluster.name' => $es_cluster_name,
    },
  }

  class {'::mongodb::globals':
    manage_package_repo => true,
  }->
  class {'::mongodb::server': }


  # Graylog2
  class { 'graylog2::repo': version => '0.21' }

  class {'graylog2::server':
    password_secret            => '16BKgz0Qelg6eFeJYh8lc4hWU1jJJmAgHlPEx6qkBa2cQQTUG300FYlPOEvXsOV4smzRtnwjHAKykE3NIWXbpL7yGLN7V2P2',
    root_password_sha2         => '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918',
    elasticsearch_cluster_name => $es_cluster_name,
    require                    => [
      Elasticsearch::Instance['esgl2'],
      Class['mongodb::server'],
    ],
  }
}
