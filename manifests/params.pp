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

  $repo_baseurl = $::osfamily ? {
      'Debian' => 'http://finja.brachium-system.net/~jonas/packages/graylog2_repro/',
      'RedHat' => 'http://rpm.leebriggs.co.uk/',
      default  => fail("${::osfamily} is not supported by ${module_name}")
  }

  $repo_key = $::osfamily ? {
    'Debian' => '016CFFD0',
    'RedHat' => '',
    default  => fail("${::osfamily} is not supported by ${module_name}")
  }

  $repo_repos = 'main'

  $repo_release = $::osfamily ? {
    'Debian' => 'wheezy',
    'RedHat' => '',
    default  => fail("${::osfamily} is not supported by ${module_name}")
  }

  $repo_pin = 200

  $repo_key_source = $::osfamily ? {
      'Debian' => '',
      'Redhat' => 'http://rpm.leebriggs.co.uk/RPM-GPG-KEY-lbriggs',
      default => fail("${::osfamily} is not supported by ${module_name}")
  }

  $repo_gpgcheck = $::osfamily ? {
      'Debian' => 0,
      'Redhat' => 1,
      default => fail("${::osfamily} is not supported by ${module_name}")
  }

  $repo_enabled = $::osfamily ? {
      'Debian' => 0,
      'Redhat' => 1,
      default => fail("${::osfamily} is not supported by ${module_name}")
  }

}
