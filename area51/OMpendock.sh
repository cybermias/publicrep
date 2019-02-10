#!/bin/bash

sudo apt-get -y install git
git clone https://github.com/eystsen/pentestlab /opt/pentestlab
cd pentestlab/
 
if fuser /var/lib/dpkg/lock > /dev/null 2>&1
then
        echo "Software management (APT) is already running. Cannot install docker right now."
        echo "Just wait a minute or two and try again"
        exit
fi
  
sudo apt-get update
 
# apt-get dependencies
sudo apt-get install \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common
 
# Add gpg key for docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
 
echo Adding to sources.list
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
 
sudo apt-get -y update
sudo apt-get -y install docker-ce
 
# Exposing bWAPP
 iptables -t nat -A  DOCKER -p tcp --dport 82 -j DNAT --to-destination 172.17.0.2:80
 iptables -t nat -A POSTROUTING -j MASQUERADE -p tcp --source 172.17.0.2 --destination 172.17.0.2 --dport 80

# Exposing WebGoat
 iptables -t nat -A  DOCKER -p tcp --dport 81 -j DNAT --to-destination 172.17.0.3:8080
 iptables -t nat -A POSTROUTING -j MASQUERADE -p tcp --source 172.17.0.3 --destination 172.17.0.3 --dport 8080

# Exposing DVWA
 iptables -t nat -A  DOCKER -p tcp --dport 80 -j DNAT --to-destination 172.17.0.4:80
 iptables -t nat -A POSTROUTING -j MASQUERADE -p tcp --source 172.17.0.4 --destination 172.17.0.4 --dport 80

# Add the docker commands to Boot time
cat <<EOF > /etc/init.d/pentestStart.sh
#!/bin/bash
PATH=/usr/sbin:/sbin:/usr/bin:/bin
sudo /opt/pentestlab/pentestlab.sh start bwapp && sudo /opt/pentestlab/pentestlab.sh start webgoat8 && sudo /opt/pentestlab/pentestlab.sh start dvwa
iptables -t nat -A  DOCKER -p tcp --dport 82 -j DNAT --to-destination 172.17.0.2:80
iptables -t nat -A POSTROUTING -j MASQUERADE -p tcp --source 172.17.0.2 --destination 172.17.0.2 --dport 80
iptables -t nat -A  DOCKER -p tcp --dport 81 -j DNAT --to-destination 172.17.0.3:8080
iptables -t nat -A POSTROUTING -j MASQUERADE -p tcp --source 172.17.0.3 --destination 172.17.0.3 --dport 8080
iptables -t nat -A  DOCKER -p tcp --dport 80 -j DNAT --to-destination 172.17.0.4:80
iptables -t nat -A POSTROUTING -j MASQUERADE -p tcp --source 172.17.0.4 --destination 172.17.0.4 --dport 80
docker run --rm -it -d -p 8080:80 cyrivs89/web-dvws
EOF
chmod ugo+x /etc/init.d/pentestStart.sh

# Normal update-rc.d doesn't work anymore, especially not on 18.04. Reverting to Crontab
#sudo update-rc.d pentestStart.sh defaults

sudo crontab -l > ptcron
sudo echo "@reboot /etc/init.d/pentestStart.sh" >> ptcron
sudo crontab ptcron
sudo rm ptcron

# Start Docker on boot
sudo systemctl enable docker
cd /opt/pentestlab

sudo ./pentestlab.sh start bwapp && sudo ./pentestlab.sh start webgoat8 && sudo ./pentestlab.sh start dvwa
#docker run --rm -it -d -p 8080:80 cyrivs89/web-dvws
