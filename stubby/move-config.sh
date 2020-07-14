# !/bin/bash

echo -e "Updating files via git"
git pull
#echo -e "Clearing old stubby.xml"
#sudo rm /etc/stubby/stubby.xml
echo -e "Moving in new stubby.xml"
sudo cp stubby.xml /etc/stubby/stubby.xml
echo -e "Restarting the Stubby resolver"
sudo service stubby restart
echo -e "Showing the status of Stubby"
sudo service stubby status
echo -e "Test Digs"
dig is-dot.cloudflareresolve.com @127.0.0.1 -p 5353
dig vmstan.com @127.0.0.1 -p 5353