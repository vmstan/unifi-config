# Unifi-JSON

## `config.gateway.json`
Contains Unifi USG configuration that are not available in the controller interface to perform 
- Redirects of outbound DNS traffic back to Pi-hole.
- Time based firewall blocking of devices to the Internet.

## `move-config.sh`
- This will move the configuration into the correct place on the Unifi controller. Requires forced provisioning operation of the controller from within the Unifi interface to complete.