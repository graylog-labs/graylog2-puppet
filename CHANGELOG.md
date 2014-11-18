Graylog2 Puppet Module Changes
==============================

## 0.8.0 (2014-11-19)

* Add timeout option for graylog2-web-interface.
* Switch repository URLs to HTTPS.
* Add support for graylog2-stream-dashboard. (#5)

## 0.7.0 (2014-09-16)

* Add support for managing graylog2-radio. (#3)
* Compatibility fixes for Puppet 2.7.x. (#4)
* Add `command_wrapper`, `java_opts` and `extra_args` options. (#1, #3)

## 0.6.1 (2014-08-29)

* Fix puppet-lint warnings.
* README updates to clarify some things.

## 0.6.0 (2014-08-29)

* Remove default for the `root_password_sha2` parameter. This needs to be set
  by the user now!
* Remove support for Ubuntu 12.04 as there are no official packages for that
  at the moment.
* Switch to `localhost` for server listen URIs.
* Add new configuration options for Graylog 0.21.
* Switch to the official [Graylog2 package repositories](http://graylog2.org/resources/documentation/general/packages).
* Initial release under the `graylog2` namespace. This module is based on the
  `synyx/graylog2` module version 0.5.1.
