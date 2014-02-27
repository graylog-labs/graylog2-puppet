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
  $key,
  $pin
) {

  if !defined(Apt::Source[$repo_name]) {
    apt::source { $repo_name:
      location    => $baseurl,
      release     => $release,
      repos       => $repos,
      key         => $key,
      pin         => $pin,
      include_src => false,
    }
  }

}
