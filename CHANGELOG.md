Graylog2 Puppet Module Changes
==============================

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
