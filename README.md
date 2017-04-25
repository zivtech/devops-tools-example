
# Drupal Devops Example

An example vagrant environment that demonstrates how to setup a number of services
using puppet. These modules have been used (with slightly different configuration
appropriate to our environments) for our own infrastructure and that of some of our
clients.

Once you have the VM up and running you should be able to connect to:

  - [InfluxDB](https://influxdb.com/) at [influxdb.drupal-devops.zivtech.com](http://influxdb.drupal-devops.zivtech.com) with username `root` and password `root`
  - [Grafana](http://grafana.org/) on [grafana.drupal-devops.zivtech.com](http://grafana.drupal-devops.zivtech.com) with username `admin` and password `admin`
  - [Sensu's Uchiwa](https://uchiwa.io/) on [uchiwa.drupal-devops.zivtech.com](http://uchiwa.drupal-devops.zivtech.com)
  - [RabbitMQ's admin interface](https://www.rabbitmq.com/) on [rabbitmq.drupal-devops.zivtech.com](http://rabbitmq.drupal-devops.zivtech.com) with username `sensu` and password `boo` 
  - [Jenkins](http://jenkinsci.org/) on [jenkins.drupal-devops.zivtech.com](http://jenkins.drupal-devops.zivtech.com)

## Installation

This module uses both [librarian-puppet](https://github.com/rodjek/librarian-puppet)
to fetch resources and dependencies so you need to acquire all of these assets before running `vagrant up`. Librarian-puppet has known issues
on windows.

````bash
gem install puppet facter librarian-puppet
git clone --recursive https://github.com/zivtech/devops-tools-example.git
cd devops-tools-example
librarian-puppet install
vagrant up
````

## Setup

In order to get data into influxdb from sensu you will need to log into InfluxDB (see above) and create a user called database called `sensu` by running `CREATE DATABASE sensu` at the command
field in the web window.

