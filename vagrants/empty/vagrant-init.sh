### Empty Vagrant initialization script.
#
# Sole purpose of initializing a simple Nested Virtualization server using Vagrant and phpvirtualbox as client-apache server
#
# Creation Date: 20180722

#!/bin/sh

wget https://releases.hashicorp.com/vagrant/2.1.2/vagrant_2.1.2_x86_64.deb
sudo apt install ./vagrant_2.1.2_x86_64.deb

# Someone said this helps performance, oh well..
vagrant plugin install vagrant-cachier
vagrant plugin install vagrant-vbguest

apt-get update 

sudo apt-get install -y htop sysstat ruby-dev zlib1g-dev liblzma-dev build-essential patch virtualbox ruby-bundler imagemagick libmagickwand-dev libpq-dev libcurl4-openssl-dev libxml2-dev
echo virtualbox-ext-pack virtualbox-ext-pack/license select true | sudo debconf-set-selections
sudo apt-get install -y virtualbox-ext-pack

sudo apt-get -y install apache2 libapache2-mod-php7.0 libapr1 libaprutil1 libaprutil1-dbd-sqlite3 libaprutil1-ldap libapr1 php7.0-common php7.0-mysql php7.0-soap php-pear wget

# Remove the need to authenticate for vboxweb
vboxmanage setproperty websrvauthlibrary null

systemctl enable vboxweb.service

cd /var/www/html
git clone https://github.com/phpvirtualbox/phpvirtualbox.git
cd phpvirtualbox
cp config.php-example config.php

shutdown -r 1
