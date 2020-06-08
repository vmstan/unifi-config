# !/bin/bash

echo -e "Moving config.properties.json in place"
sudo cp config.properties.json /var/lib/unifi/sites/default/config.properties.json
chown unifi:unifi config.properties.json
echo -e "Force provision to complete"