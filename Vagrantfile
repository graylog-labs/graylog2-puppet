# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  #config.vm.define 'master' do |machine|
  #  machine.vm.box = 'box-cutter/ubuntu1404'
  #  machine.vm.network 'private_network', ip: '10.10.0.10'
  #  machine.vm.provision 'shell', :path => 'vagrant/provision-master.sh'
  #end

  config.vm.define 'ubuntu1404' do |machine|
    machine.vm.box = 'box-cutter/ubuntu1404'
    machine.vm.network 'private_network', ip: '10.10.0.11'
    machine.vm.provision 'shell', :path => 'vagrant/provision-client.sh'
  end

  #config.vm.define 'ubuntu1204' do |machine|
  #  machine.vm.box = 'box-cutter/ubuntu1204'
  #  machine.vm.network 'private_network', ip: '10.10.0.12'
  #  machine.vm.provision 'shell', :path => 'vagrant/provision-client.sh'
  #end

  #config.vm.define 'debian7' do |machine|
  #  machine.vm.box = 'box-cutter/debian75'
  #  machine.vm.network 'private_network', ip: '10.10.0.13'
  #  machine.vm.provision 'shell', :path => 'vagrant/provision-client.sh'
  #end

  #config.vm.define 'centos6' do |machine|
  #  machine.vm.box = 'box-cutter/centos65'
  #  machine.vm.network 'private_network', ip: '10.10.0.14'
  #  machine.vm.provision 'shell', :path => 'vagrant/provision-client.sh'
  #end
end
