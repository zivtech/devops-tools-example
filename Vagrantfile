#! /usr/bin/env ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :
#
Vagrant.configure('2') do |config|

  config.vm.hostname = 'devopsexample'

  config.vm.network :private_network, ip: '10.0.0.6'

  config.vm.box = 'zivtech/ubuntu-14.04-server-puppet-4'
  config.ssh.forward_agent = true

  config.vm.provision :puppet do |puppet|
    puppet.facter = {
      "vagrant" => "1",
      "vagrant_share_www" => true
    }
    puppet.hiera_config_path = 'hiera/hiera.yaml'
    puppet.working_directory = '/vagrant'
    puppet.manifests_path = 'manifests'
    puppet.module_path = [
      "modules",
      "custom-modules"
    ]
    puppet.manifests_path = "manifests"
    puppet.manifest_file = "."
    puppet.environment_path = "environments"
    puppet.environment = "dev"
  end


end
