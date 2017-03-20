#!/bin/bash

# simple vagrant provisioning script

# some coloring in outputs.
COLOR="\033[;35m"
COLOR_RST="\033[0m"

echo -e "${COLOR}---updating system---${COLOR_RST}"
apt-get update

echo -e "${COLOR}---installing some tools: zip,unzip,curl, python-software-properties---${COLOR_RST}"

apt-get install -y software-properties-common
apt-get install -y python-software-properties
apt-get install -y zip unzip
apt-get install -y curl
apt-get install -y build-essential
apt-get install -y vim

# installing mysql
# pre-loading a default password --> yourpassword
debconf-set-selections <<< "mysql-server mysql-server/root_password password secret"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password secret"
echo -e "${COLOR}---installing MySql---${COLOR_RST}"
apt-get install -y mysql-server mysql-client

# installing apache2
echo -e "${COLOR}---installing Apache---${COLOR_RST}"
apt-get install -y apache2
rm -rf /var/www/html
ln -fs /vagrant /var/www/html

# installing php 5.3
echo -e "${COLOR}---installing php---${COLOR_RST}"
apt-get install -y php5 libapache2-mod-php5 php5-mcrypt php5-curl php5-mysql php5-xdebug php5-gd

#setup the database
cd /vagrant
mysql -u root -psecret -e "DROP DATABASE IF EXISTS wordpress;"
mysql -u root -psecret -e "create database wordpress;"
mysql -u root -psecret -e "grant usage on *.* to wordpress@localhost identified by 'password';"
mysql -u root -psecret -e "grant all privileges on wordpress.* to wordpress@localhost;"

#ensure apache runs as vagrant
echo -e "${COLOR}---run apache as vagrant to avoid issues with permissions---${COLOR_RST}"
sudo sed -i 's_www-data_vagrant_' /etc/apache2/envvars

# enable mod rewrite for apache2
echo -e "${COLOR}---enabling rewrite module---${COLOR_RST}"
if [ ! -f /etc/apache2/mods-enabled/rewrite.load ] ; then
    a2enmod rewrite
fi

#deflat module for apache2
if [ ! -f /etc/apache2/mods-enabled/deflate.load ] ; then
    a2enmod deflate
fi

#enable modrewrite for htaccess
echo -e "${COLOR}---enable FollowSymLinks---${COLOR_RST}"
sudo sed -i "/VirtualHost/a <Directory /var/www/html/> \n Options Indexes FollowSymLinks MultiViews \n AllowOverride All \n Order allow,deny \n  allow from all \n </Directory>" /etc/apache2/sites-available/000-default.conf

# restart apache2
echo -e "${COLOR}---restarting apache2---${COLOR_RST}"
service apache2 restart

# install git
apt-get install git-core

# install yii
# setup database:
echo "CREATE DATABASE IF NOT EXISTS yii_app" | mysql
echo "CREATE USER 'root'@'localhost' IDENTIFIED BY ''" | mysql
echo "GRANT ALL PRIVILEGES ON yii_app.* TO 'yii_app'@'localhost' IDENTIFIED BY ''" | mysql
# run migration
cd /var/www/
yiic migrate
# give write permission to some directories
sudo chmod -R 777 /var/www/assets/
sudo chmod -R 777 /var/www/protected/runtime/
