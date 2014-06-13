#puppet-graylog2

[![Build Status](https://travis-ci.org/synyx/puppet-graylog2.png)](https://travis-ci.org/synyx/puppet-graylog2)

##Overview

This module manages a [graylog2](http://www.graylog2.org) setup including the [server](https://github.com/Graylog2/graylog2-server) and the [web-interface](https://github.com/Graylog2/graylog2-web-interface).

Supported plattforms:
* Debian 7
* Ubuntu 12.04
* Ubuntu 14.04
* CentOS 6.5

There is an implicit dependency to java - make sure to setup java properly before using this module!

## Installation

This module depends on:
* [puppetlabs/apt](https://github.com/puppetlabs/puppetlabs-apt)
* [puppetlabs/stdlib](https://github.com/puppetlabs/puppetlabs-stdlib)

So all repositories have to be checked out:

```bash
git clone https://github.com/synyx/puppet-graylog2.git modules/graylog2
git clone https://github.com/puppetlabs/puppetlabs-apt.git modules/apt
git clone https://github.com/puppetlabs/puppetlabs-stdlib.git modules/stdlib
```

##Usage

A graylog2 example including the server and the webinterface component

```puppet
class {'graylog2::repo':}

class {'graylog2::server':
  password_secret => 'veryStrongSecret',
}

class {'graylog2::web':
  application_secret => 'veryStrongSecret',
}
```


## Authors

* Johannes Graf ([@grafjo](https://github.com/grafjo))
* Jonathan Buch ([@BuJo](https://github.com/BuJo))
* Sascha Rüssel ([@zivis](https://github.com/zivis))

## Credits

To the package maintainers:
* [@hggh](https://github.com/hggh) for providing debs
* [@jaxxstorm](https://github.com/jaxxstorm) for providing rpms

## License

puppet-graylog2 is released under the MIT License. See the bundled LICENSE file
for details.
