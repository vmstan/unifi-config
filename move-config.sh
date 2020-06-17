# !/bin/bash

echo -e "Updating files"
git pull
echo -e "Moving config.gateway.json in place"
sudo cp config.gateway.json /var/lib/unifi/sites/default/config.gateway.json
echo -e "Setting permissions"
sudo chown unifi:unifi config.gateway.json
echo -e "Force provision on controller to complete!"