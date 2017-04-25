#!/usr/bin/env ruby
#^syntax detection

forge 'https://forgeapi.puppetlabs.com'

mod 'sensu-sensu'
mod 'puppetlabs-rabbitmq'
mod 'rtyler-jenkins'
mod 'jfryman-nginx'
mod 'golja-influxdb'

# Using a git provider for now due to an open issue:
mod 'bfraser-grafana',
  :git => 'https://github.com/bfraser/puppet-grafana.git',
  :ref => 'acc8075403b84b2c4433e1b0533b33de0f51ce66'
