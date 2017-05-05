
/**
 * Create a simple non-secured rabbitmq setup for sensu.
 *
 * See the sensu-ssl-tool and documentation for (relatively) easy setup instructions.
 * https://sensuapp.org/docs/0.25/reference/ssl.html#generate-self-signed-openssl-certificates-and-ca
 */
class { '::rabbitmq':
  delete_guest_user => true,
  admin_enable      => true,
}

rabbitmq_user { 'sensu':
  admin    => true,
  password => 'bar',
}
rabbitmq_vhost { '/sensu':
  ensure => present,
}
rabbitmq_user_permissions { 'sensu@/sensu':
  configure_permission => '.*',
  read_permission      => '.*',
  write_permission     => '.*',
  require              => [
    Rabbitmq_vhost['/sensu'],
    Rabbitmq_user['sensu'],
  ],
}

/**
 * Install redis-server for use with sensu.
 */
package { 'redis-server':
  ensure => present,
}~>

service { 'redis-server':
  ensure => 'running',
  enable => true,
}

/**
 * Install the sensu server and client for use on this single server setup.
 */
class { '::sensu':
  install_repo          => true,
  server                => true,
  manage_services       => true,
  manage_user           => true,
  rabbitmq_password     => 'bar',
  rabbitmq_vhost        => '/sensu',
  # Sensu ships with a gem for use in writing plugins, this installs
  # it with the sensu provider.
  sensu_plugin_provider => 'sensu_gem',
  api                   => true,
  api_user              => 'admin',
  api_password          => 'secret',
  client_address        => $::ipaddress_eth1,
  subscriptions         => ['all'],
}

/**
 * Create a simple handler that writes to a file.
 */
file { '/var/log/sensu-default-handler.log':
  ensure => 'file',
  owner  => 'sensu',
  mode   => '0775'
}->

sensu::handler { 'default':
  command => 'echo $(cat) > /var/log/sensu-default-handler.log',
  type    => 'pipe',
}

# An example handler just for this host.
sensu::subscription { 'sensu-test': }

# A super simple check for servers with the above subscription.
sensu::check { 'success':
  command     => 'echo "Something went right" && /bin/true',
  handlers    => 'default',
  subscribers => 'sensu-test',
}

sensu::check { 'minor-failing':
  ensure => 'absent',
  command => 'blah',
}

sensu::check { 'minor-warning':
  command     => 'echo "Something went wrong" && /bin/false',
  handlers    => 'default',
  subscribers => 'sensu-test',
}

sensu::check { 'major-failing-check':
  command     => 'echo "Something went very wrong" && return 2',
  handlers    => 'default',
  subscribers => 'sensu-test',
}

file { '/var/log/some_service.log':
  content => 'looks good',
  mode    => '0777',
}->
sensu::check { 'check-some-service':
  command     => 'grep -qv broken /var/log/some_service.log',
  handlers    => 'default',
  subscribers => 'sensu-test',
}

# Install the memory checks plugin from rubygems into the embedded sensu ruby gems.
package { 'sensu-plugins-memory-checks':
  provider => 'sensu_gem',
}->
# Required to build the vmstat ruby gem.
package { 'build-essential':
  ensure => 'present',
}->
# Install vmstat, a dependency of one of the memory checks we are using.
package { 'vmstat':
  provider => 'sensu_gem',
}

# Define simple checks from the above definition.
sensu::check { 'ram':
  command     => '/opt/sensu/embedded/bin/check-ram.rb',
  subscribers => 'all',
  standalone  => false,
}->

sensu::check { 'swap-percent':
  command     => '/opt/sensu/embedded/bin/check-swap-percent.rb -w 80 -c 95',
  subscribers => 'all',
  standalone  => false,
}->

# Define memory metrics checks to collect memory information.
sensu::check { 'memory-metrics':
  command     => '/opt/sensu/embedded/bin/metrics-memory-percent.rb',
  type        => 'metric',
  subscribers => 'all',
  handlers    => 'influx',
}->

sensu::check { 'swap-percent-metrics':
  command     => '/opt/sensu/embedded/bin/metrics-swap-percent.rb',
  type        => 'metric',
  subscribers => 'all',
  handlers    => 'influx',
  ensure      => 'absent',
}->

package { 'uchiwa':
  ensure => present,
  require => Class['sensu'],
}

file { '/etc/sensu/uchiwa.json':
  ensure  => file,
  content => '
{
  "sensu": [
    {
      "name": "Site",
      "host": "127.0.0.1",
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
  require => Package['uchiwa'],
}~>

service { 'uchiwa':
  ensure  => running,
  require => [ File['/etc/sensu/uchiwa.json'],Package['uchiwa'] ],
  enable  => true,
}

# TODO: This requires a two provisions before it works, investigate.
include ::influxdb::server

class { 'grafana':
  cfg => {
    app_mode => 'production',
    server   => {
      http_port     => 8090,
    },
    database => {
      type          => 'sqlite3',
      host          => '127.0.0.1:3306',
      name          => 'grafana',
      user          => 'root',
      password      => '',
    },
    users    => {
      allow_sign_up => false,
    },
  },
}

# Setup vhosts to proxy to the requisite services.
include nginx
nginx::resource::vhost { 'uchiwa.drupal-devops.zivtech.com':
  server_name => ['uchiwa.drupal-devops.zivtech.com'],
  proxy       => 'http://localhost:3000',
}

nginx::resource::vhost { 'influxdb.drupal-devops.zivtech.com':
  server_name => ['influxdb.drupal-devops.zivtech.com'],
  proxy       => 'http://localhost:8083',
}
nginx::resource::vhost { 'grafana.drupal-devops.zivtech.com':
  server_name => ['grafana.drupal-devops.zivtech.com'],
  proxy       => 'http://localhost:8090',
}

nginx::resource::vhost { 'jenkins.drupal-devops.zivtech.com':
  server_name => ['jenkins.drupal-devops.zivtech.com'],
  proxy       => 'http://localhost:8080',
}

nginx::resource::vhost { 'rabbit.drupal-devops.zivtech.com':
  server_name => ['jenkins.drupal-devops.zivtech.com'],
  proxy       => 'http://localhost:15672',
}

include ::jenkins

/*

# We can't use sensu embedded because gems can't be installed inside sensu embedded if they
# have the same name as a package that is being required.
exec { '/opt/sensu/embedded/bin/gem install influxdb':
  unless => '/opt/sensu/embedded/bin/gem list -i influxdb',
}->

sensu::handler { 'influx':
  command => 'metrics-influxdb.rb',
  config  => {
    server   => '127.0.0.1',
    port     => 8086,
    username => 'root',
    password => 'root',
    database => 'sensu',
  },
}

# Provided by the new and *AWESOME* http://sensu-plugins.io.
# Use this method if you can - you install a gem in the embedded
# ruby provided by sensu.
package { 'sensu-plugins-influxdb':
  provider => 'sensu_gem',
}
*/
