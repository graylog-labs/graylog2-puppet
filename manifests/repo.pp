# == Class: graylog2::repo
#
# === Authors
#
# Johannes Graf <graf@synyx.de>
#
# === Copyright
#
# Copyright 2014 synyx GmbH & Co. KG
#
class graylog2::repo (
  $repo_name  = $graylog2::params::repo_name,
  $baseurl    = $graylog2::params::repo_baseurl,
  $key        = $graylog2::params::repo_key,
  $repos      = $graylog2::params::repo_repos,
  $release    = $graylog2::params::repo_release,
  $pin        = $graylog2::params::repo_pin,
  $key_source = $graylog2::params::repo_key_source,
  $gpgcheck   = $graylog2::params::repo_gpgcheck,
  $enabled    = $graylog2::params::repo_enabled,
) inherits graylog2::params {

  anchor { 'graylog2::repo::begin': }
  anchor { 'graylog2::repo::end': }

  case $::osfamily {
    'Debian': {
      class {'graylog2::repo::debian':
        repo_name  => $repo_name,
        baseurl    => $baseurl,
        key        => $key,
        repos      => $repos,
        release    => $release,
        pin        => $pin,
        require    => Anchor['graylog2::repo::begin'],
        before     => Anchor['graylog2::repo::end'],
      }
    }
    'RedHat': {
      class { 'graylog2::repo::redhat':
        repo_name => $repo_name,
        baseurl   => $baseurl,
        gpgkey    => $key_source,
        gpgcheck  => $gpgcheck,
        enabled   => $enabled,
        require   => Anchor['graylog2::repo::begin'],
        before    => Anchor['graylog2::repo::end'],
      }
    }
    default: { fail("${::osfamily} is not supported by ${module_name}") }
  }

}
