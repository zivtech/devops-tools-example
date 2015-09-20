#! /usr/bin/env ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|

  config.vm.hostname = 'devops'

  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--memory', 2048]
  end

  #config.vm.network :private_network, ip: params[:private_ip]
  config.vm.network :private_network, ip: '33.33.33.45'

  config.vm.box = 'puppetlabs/ubuntu-14.04-64-puppet'

  config.ssh.forward_agent = true

  if Vagrant.has_plugin?("vagrant-librarian-puppet")
    config.librarian_puppet.placeholder_filename = '.gitignore'
  elsif not File.exist?('modules/sensu/manifests/init.pp')
    raise Vagrant::Errors::VagrantError.new, "You are not using vagrant-librarian-puppet and have not installed the dependencies."
  end


  is_windows = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)

  # If vagrant-cachier is installed, use it!
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
    if not is_windows
      # See https://github.com/fgrehm/vagrant-cachier for details.
      config.cache.synced_folder_opts = {
        type: :nfs,
        mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
      }
    end
  end

  config.vm.provision :shell, inline: "/bin/sed -i '/templatedir/d' /etc/puppet/puppet.conf"
  config.vm.provision :puppet do |puppet|
    puppet.module_path = [
      'modules',
      'custom-modules'
    ]
    puppet.manifests_path = 'manifests'
    puppet.manifest_file = 'base.pp'
    puppet.hiera_config_path = 'hiera/hiera.yaml'
    puppet.working_directory = '/vagrant'
  end


end
