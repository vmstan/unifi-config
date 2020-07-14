# !/bin/bash

echo -e "Updating files via git"
git pull
echo -e "Clearing old stubby.yml
sudo rm /etc/stubby/stubby.yml
echo -e "Moving in new IPv4 stubby.yml"
sudo cp stubby-4.yml /etc/stubby/stubby.yml
echo -e "Restarting the Stubby resolver"
sudo service stubby restart
echo -e "Showing the status of Stubby"
sudo service stubby status
