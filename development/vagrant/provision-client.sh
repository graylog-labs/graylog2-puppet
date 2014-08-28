#!/bin/bash

set -e

codename=$(lsb_release -cs)
repo_package="puppetlabs-release-${codename}.deb"

apt-get -y update
apt-get -y install wget

wget -nv http://apt.puppetlabs.com/$repo_package

dpkg -i $repo_package
apt-get -y update
apt-get -y install puppet

puppet module install -i /etc/puppet/modules puppetlabs-stdlib
puppet module install -i /etc/puppet/modules puppetlabs-apt
puppet module install -i /etc/puppet/modules elasticsearch-elasticsearch
puppet module install -i /etc/puppet/modules puppetlabs-mongodb

ln -s /vagrant /etc/puppet/modules/graylog2
