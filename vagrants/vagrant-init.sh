#!/bin/sh

wget https://releases.hashicorp.com/vagrant/2.1.2/vagrant_2.1.2_x86_64.deb
sudo apt install ./vagrant_2.1.2_x86_64.deb

# Someone said this helps performance, oh well..
vagrant plugin install vagrant-cachier

apt-get update 

sudo apt-get install -y ruby-dev zlib1g-dev liblzma-dev build-essential patch virtualbox ruby-bundler imagemagick libmagickwand-dev libpq-dev libcurl4-openssl-dev libxml2-dev
echo virtualbox-ext-pack virtualbox-ext-pack/license select true | sudo debconf-set-selections
sudo apt-get install -y virtualbox-ext-pack

sudo apt-get -y install apache2 libapache2-mod-php7.0 libapr1 libaprutil1 libaprutil1-dbd-sqlite3 libaprutil1-ldap libapr1 php7.0-common php7.0-mysql php7.0-soap php-pear wget

# Remove the need to authenticate for vboxweb
vboxmanage setproperty websrvauthlibrary null

systemctl enable vboxweb.service
#sed -i '/--background/s/$/ --host 0.0.0.0/' /lib/systemd/system/vboxweb.service
#systemctl daemon-reload

cd /var/www/html
git clone https://github.com/phpvirtualbox/phpvirtualbox.git
cd phpvirtualbox
cp config.php-example config.php

#wget https://az792536.vo.msecnd.net/vms/VMBuild_20150916/VirtualBox/IE10/IE10.Win7.VirtualBox.zip
#unzip IE10.Win7.VirtualBox.zip
#rm IE10.Win7.VirtualBox.zip
#mkdir --parents ~/vm/ie10-windows7 && cd ~/vm/ie10-windows7
#wget --continue --input-file https://github.com/magnetikonline/linuxmicrosoftievirtualmachines/raw/master/vmarchiveset/ie10-windows7.txt
#unzip IE10.Win7.VirtualBox.zip
#rm IE10.Win7.VirtualBox.zip

### Acquire win7ie8 Vagrant Box
mkdir /opt/win7ie8
cd /opt/win7ie8
echo "#!/bin/sh -e" > /etc/rc.local
echo "cd /opt && su -c 'vagrant up' &" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local

sudo wget https://raw.githubusercontent.com/cybermias/publicrep/master/vagrants/Vagrantfile
#sudo wget https://raw.githubusercontent.com/cybermias/publicrep/master/vagrants/InstallChocolatey.ps1
#sudo wget https://raw.githubusercontent.com/cybermias/publicrep/master/vagrants/chocospawn.cmd
sudo vagrant up

vboxmanage snapshot "win7ie8" take "Initial-Install-win7ie8"

shutdown -r 1
