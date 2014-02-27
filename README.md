#puppet-graylog2

[![Build Status](https://travis-ci.org/synyx/puppet-graylog2.png)](https://travis-ci.org/synyx/puppet-graylog2)

##Overview

This module manages a [graylog2](http://www.graylog2.org) setup including the [server](https://github.com/Graylog2/graylog2-server) and [web-interface](https://github.com/Graylog2/graylog2-web-interface).

Supported plattform:
* Debian
* Ubuntu


##Usage

This is the very basic usage:

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


## License

puppet-graylog2 is released under the MIT License. See the bundled LICENSE file
for details.
