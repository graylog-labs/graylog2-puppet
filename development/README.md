Graylog2 Puppet Module Development
==================================

## Generate server-config.defaults

The `server-config-defaults.txt` file can be used to detect new configuration
options for the graylog2-server.

```
java -jar graylog2-server/target/graylog2-server.jar -f misc/graylog2.conf \
    --dump-config | grep -v -e '^#' -e '^$' -e 'INFO : org.graylog2.Main' | \
    sort -u > server-config-defaults.txt
```

Just diff the newly created file to see any changes to the default config.
