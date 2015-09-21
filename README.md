
# Drupal Devops Example

An example vagrant environment that demonstrates how to setup a number of services
using puppet. These modules have been used (with slightly different configuration
appropriate to our environments) for our own infrastructure and that of some of our
clients.

Once you have the VM up and running you should be able to connect to:

  - [InfluxDB](https://influxdb.com/) on [port 8081](http://33.33.33.45:8083/) with username `root` and password `root`
  - [Grafana](http://grafana.org/) on [port 8080](http://33.33.33.45:8080/) with username `admin` and password `admin`
  - [Sensu's Uchiwa](https://uchiwa.io/) on [port 3000](http://33.33.33.45:3000)
  - [RabbitMQ's admin interface](https://www.rabbitmq.com/) on [port 15672](http://33.33.33.45:15672) with username `sensu` and password `boo` 
  - [Kibana](https://www.elastic.co/products/kibana) on [port 5601](http://33.33.33.45:5601/)
  - [Elasticsearch's](https://www.elastic.co/products/elasticsearch) [Head front admin plugin](http://mobz.github.io/elasticsearch-head/) on [port 9200 and path `_plugin/head`](http://33.33.33.45:9200/_plugin/head/)
  - [Jenkins](http://jenkinsci.org/) on [port 8092](http://33.33.33.45:8092)

## Installation

This module uses both git submodules and [librarian-puppet](https://github.com/rodjek/librarian-puppet)
to fetch resources and dependencies so you need to acquire all of these assets before running `vagrant up`. Librarian-puppet has known issues
on windows.

*Alternately, if you are on windows or want a short cut, you can download the pre-baked release from the releases tab (be careful not to
download the source code zip or tarball by accident).*

````bash
git clone --recursive https://github.com/zivtech/devops-tools-example.git
cd devops-tools-example
librarian-puppet install
vagrant up
````

## Setup

In order to get data into influxdb from sensu you will need to log into InfluxDB (see above) and
create a user called database called `sensu` by running `CREATE DATABASE sensu` at the command
field in the web window.

