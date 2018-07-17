#!/bin/sh
wget https://releases.hashicorp.com/vagrant/2.1.2/vagrant_2.1.2_x86_64.deb
sudo apt install ./vagrant_2.1.2_x86_64.deb

#apt-add-repository ppa:ansible/ansible
#apt-get update && sudo apt-get install -y ansible

sudo apt-get install -y ruby-dev zlib1g-dev liblzma-dev build-essential patch virtualbox ruby-bundler imagemagick libmagickwand-dev libpq-dev libcurl4-openssl-dev libxml2-dev

sudo apt-get -y install apache2 libapache2-mod-php7.0 libapr1 libaprutil1 libaprutil1-dbd-sqlite3 libaprutil1-ldap libapr1 php7.0-common php7.0-mysql php7.0-soap php-pear wget

#echo "sudo vboxwebsrv -b --host 0.0.0.0 --port 18083" > /etc/rc.local
#echo "exit 0" >> /etc/rc.local

vboxmanage setproperty websrvauthlibrary null

systemctl enable vboxweb.service
sed -i '/--background/s/$/ --host 0.0.0.0/' /lib/systemd/system/vboxweb.service
systemctl daemon-reload

cd /var/www/html
git clone https://github.com/phpvirtualbox/phpvirtualbox.git
cd phpvirtualbox
cp config.php-example config.php

shutdown -r 1
