
/*

class { 'jenkins':
  config_hash => {'HTTP_PORT' => {'value' => '8092'}},
  configure_firewall => false,
}
*/

require 'apt'

class { '::rabbitmq':
  service_manage    => true,
  port              => 5672,
  admin_enable      => true,
  delete_guest_user => false,

}

/*
rabbitmq_user { 'sensu':
  admin             => true,
  password          => 'correct-horse-battery-staple',
  provider          => 'rabbitmqctl',
  require           => Service['rabbitmq-server'],
}

rabbitmq_vhost { '/sensu':
  ensure => present,
  provider => 'rabbitmqctl',
  require  => Service['rabbitmq-server'],
}

rabbitmq_user_permissions { 'sensu@sensu':
  configure_permission => '.*',
  read_permission      => '.*',
  write_permission     => '.*',
  require  => [
    Service['rabbitmq-server'],
    Rabbitmq_user['sensu'],
    Rabbitmq_vhost['sensu'],
  ],
}
rabbitmq_vhost { 'sensu':
  ensure => present,
  provider => 'rabbitmqctl',
# require  => Service['rabbitmq-server'],
}
*/


package { 'ruby-json':
  ensure => 'installed',
}->

package { 'redis-server':
  ensure => 'installed',
}->

service { 'redis-server':
  ensure => 'running',
  enable => true,
}->
   

class { 'sensu':
  rabbitmq_password => 'correct-horse-battery-staple',
  rabbitmq_host     => '127.0.0.1',
  rabbitmq_vhost    => '/sensu',
  use_embedded_ruby        => true,
  sensu_plugin_version     => '1.1.0',
  subscriptions     => 'all',
  install_repo      => true,
  server            => true,
  manage_services   => true,
  manage_user       => true,
  api               => true,
  client_address    => $::ipaddress_eth1,
  # For whatever reason localhost was choking on a fresh install on 14.04.
  redis_host        => '127.0.0.1',
  plugins           => [
    'puppet:///modules/sensu_community_plugins/plugins/system/check-disk.rb',
    'puppet:///modules/sensu_community_plugins/plugins/system/check-cpu.rb',
    'puppet:///modules/sensu_community_plugins/plugins/system/check-ram.rb',
    'puppet:///modules/sensu_community_plugins/plugins/system/check-load.rb',
    'puppet:///modules/sensu_community_plugins/plugins/system/check-swap-percentage.sh',
  ],
}

sensu::handler { 'default':
  command => 'echo > /tmp/sensu-notifications.log',
}

sensu::check { 'load':
  command     => '/etc/sensu/plugins/check-load.rb',
  subscribers => 'all',
  standalone  => false,
}

sensu::check { 'cpu':
  command     => '/etc/sensu/plugins/check-cpu.rb',
  subscribers => 'all',
  standalone  => false,
}

sensu::check { 'ram':
  command     => '/etc/sensu/plugins/check-ram.rb',
  subscribers => 'all',
  standalone  => false,
}

sensu::check { 'disk':
  command     => '/etc/sensu/plugins/check-disk.rb',
  subscribers => 'all',
  standalone  => false,
}

sensu::check { 'swap-percent':
  command     => '/etc/sensu/plugins/check-swap-percentage.sh',
  subscribers => 'all',
  standalone  => false,
}

package { 'uchiwa':
  ensure  => present,
  require => Class['sensu'],
}

file { '/etc/sensu/uchiwa.json':
  ensure  => present,
  content => '
{
  "sensu": [
    {
      "name": "Site1",
      "host": "localhost",
      "port": 4567,
      "timeout": 5,
      "user": "admin",
      "pass": "secret"
    }
  ],
  "uchiwa": {
    "host": "0.0.0.0",
    "port": 3000,
    "interval": 5
  }
}',
  require => [
    Package['uchiwa'],
    Class['sensu'],
  ],
  notify  => Service['uchiwa'],
}

service { 'uchiwa':
  ensure  => running,
  require => [
    File['/etc/sensu/uchiwa.json'],
    Package['uchiwa']
  ]
}

# This is busted:
class { 'graphite': }

class { 'logstash':
  manage_repo     => true,
  repo_version    => '1.4',
}->

package { 'logstash-contrib':
  ensure => 'installed',
}
