# == Class: graylog2::repo::debian
#
# === Authors
#
# Johannes Graf <graf@synyx.de>
#
# === Copyright
#
# Copyright 2014 synyx GmbH & Co. KG
#
class graylog2::repo::debian (
  $repo_name,
  $baseurl,
  $release,
  $repos,
  $pin
) {

  if !defined(Package['apt-transport-https']) {
    ensure_packages(['apt-transport-https'])
  }

  if !defined(Apt::Key[$repo_name]) {
    apt::key { $repo_name:
      key        => '28AB6EB572779C2AD196BE22D44C1D8DB1606F22',
      key_server => 'hkp://pgp.surfnet.nl:80'
    }
  }

  if !defined(Apt::Source[$repo_name]) {
    apt::source { $repo_name:
      location    => $baseurl,
      release     => $release,
      repos       => $repos,
      pin         => $pin,
      include_src => false,
      require     => [
        Package['apt-transport-https'],
        Apt::Key[$repo_name],
      ],
    }
  }
}
