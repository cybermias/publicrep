#!/bin/sh

# Script will update caldera by git, and enforce it to run locally inside ATLAS lab (i.e 10.200.11.100).
# Used with snapshot running golang1.16 and caldera git 3.1.0

apt-get install net-tools
# /// # Adapt the local.yml file at conf directory to initialize caldera as the current local IP
# When this was used internally, the upcoming lines will extract the internal IP. The current script version will refer to the external IP.
#ip="$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d. -f1-4 | cut -d/ -f1)"
#sed -i -e "s/0.0.0.0/$ip/g" /home/cmtsadmin/caldera/conf/local.yml
# // # The following commands will only be relevant in an internal caldera deployment (and are currently DISABLED)
# Manx requires websocket to work back to caldera operator browser (since it can be through iptables of openvpn, we reserve the 0.0.0.0:7012 in that line only):
#sed -i -e "s/app.contact.websocket:.*/app.contact.websocket: 0\.0\.0\.0:7012/g" /home/cmtsadmin/caldera/conf/local.yml

sudo apt-get uninstall purge golang*
sudo apt-get update
sudo rm -rf /usr/local/go
sudo apt install -y golang-go upx
crontab -u cmtsadmin  -r

#echo "GOPATH=$HOME/go" > cronstuff.txt
#echo "PATH=$PATH:/usr/local/go/bin:$GOPATH/bin" >> cronstuff.txt
echo "@reboot (cd /home/cmtsadmin/caldera && /usr/bin/python3 server.py &)  > /tmp/cronCaldera.log 2>&1" >> cronstuff.txt
crontab -u cmtsadmin cronstuff.txt

# // # Adapt the local.yml file at conf directory to initialize caldera as the current external IP
PUBLICIP=$(curl -s ipecho.net/plain)
while [ ! $PUBLICIP ]; do
        PUBLICIP=$(curl -s ipecho.net/plain)
done
sed -i -e "s/app.contact.dns.socket:.*/app.contact.dns.socket: $PUBLICIP:8853/g" /home/cmtsadmin/caldera/conf/local.yml
sed -i -e "s/app.contact.http:.*/app.contact.http: http:\/\/$PUBLICIP:8888/g"  /home/cmtsadmin/caldera/conf/local.yml
sed -i -e "s/app.contact.tcp:.*/app.contact.tcp: $PUBLICIP:7010/g"  /home/cmtsadmin/caldera/conf/local.yml
sed -i -e "s/app.contact.udp:.*/app.contact.udp: $PUBLICIP:7011/g"  /home/cmtsadmin/caldera/conf/local.yml
sed -i -e "s/app.contact.websocket:.*/app.contact.websocket: $PUBLICIP:7012/g"  /home/cmtsadmin/caldera/conf/local.yml
sed -i -e "s/app.contact.dns.domain:.*/app.contact.dns.domain: $1/g"  /home/cmtsadmin/caldera/conf/local.yml
sed -i -e "s/reports_dir:.*/reports_dir: \/home\/cmtsadmin\/reports/g"  /home/cmtsadmin/caldera/conf/local.yml
sed -i -e "s/exfil_dir:.*/exfil_dir: \/home\/cmtsadmin\/exfil/g"  /home/cmtsadmin/caldera/conf/local.yml



# Make sure the caldera OS is aware of its public IP (otherwise errors are shown and stability wasn't examined when server.py is run - cannot bind "public IP")
sudo cat <<EOF > /etc/netplan/60-static.yaml
network:
    version: 2
    ethernets:
        eth0:
            addresses:
                - $PUBLICIP/32
EOF
sudo netplan apply

cd /home/cmtsadmin/caldera
git checkout master
git pull
pip3 install -r requirements.txt
pip3 install pyhuman
        
cd plugins/sandcat/gocat
git checkout master
git pull

cd /home/cmtsadmin/caldera
# Oh god do'nt ask why it's done again. Seriously. Veins will be CUT!
pip3 install -r requirements.txt
git checkout master
git pull

# AND AGAIN
cd plugins/human
pip3 install -r requirements.txt
cd pyhuman
pip3 install -r requirements.txt

echo "script completed" > /home/cmtsadmin/finished
shutdown -r 1


#cd /home/cmtsadmin/caldera
#/usr/bin/python3 server.py
