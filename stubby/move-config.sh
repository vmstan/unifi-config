# !/bin/bash

echo -e "Updating files via git"
git pull
#echo -e "Clearing old stubby.yml"
#sudo rm /etc/stubby/stubby.yml
echo -e "Moving in new stubby.yml"
sudo cp stubby.yml /etc/stubby/stubby.yml
echo -e "Restarting the Stubby resolver"
sudo service stubby restart
echo -e "Showing the status of Stubby"
sudo service stubby status
#echo -e "Test Digs"
#dig is-dot.cloudflareresolve.com @127.0.0.1 -p 5353
#dig vmstan.com @127.0.0.1 -p 5353