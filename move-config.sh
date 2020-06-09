# !/bin/bash

echo -e "Moving config.properties.json in place"
cp config.gateway.json /var/lib/unifi/sites/default/config.gateway.json
chown unifi:unifi config.properties.json
echo -e "Force provision to complete"