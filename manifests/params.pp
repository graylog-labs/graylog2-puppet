# == Class: graylog2::params
#
# === Authors
#
# Johannes Graf <graf@synyx.de>
#
# === Copyright
#
# Copyright 2014 synyx GmbH & Co. KG
#
class graylog2::params {

  $repo_name = 'graylog2'

  $repo_baseurl = $::operatingsystem ? {
      /(?i)(ubuntu|debian)/ => 'http://finja.brachium-system.net/~jonas/packages/graylog2_repro/',
      default => fail("${::operatingsystem} is not supported by ${module_name}")
  }

  $repo_key = '016CFFD0'

  $repo_repos = 'main'

  $repo_release = $::osfamily ? {
    'Debian' => 'wheezy',
    default  => fail("${::osfamily} is not supported by ${module_name}")
  }

  $repo_pin = 200
}
