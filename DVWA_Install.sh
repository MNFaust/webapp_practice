#!/bin/bash

#============================
# Ubunutu Set-up Script
# by: @jfaust0
#============================

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Change to your google recaptcha keys:
cap_pubk=''
cap_privk=''

#Check if Root
if [ "$(whoami)" != "root" ]
	then
		echo -e "${RED}You must be root${NC}"
		exit 1
fi

echo -e "${GREEN}[+] Running Updates before installing${NC}"
apt-get update && upgrade -y && dist-upgrade -y
apt-get install tmux

#-----------------------
# Install Java JDK/JRE
#-----------------------
echo -e "${GREEN}[+] Installing default Java${NC}"
apt-get install default-jre -y
apt-get install default-jdk -y

#------------------------------------------
# Install Apache2, PHP, MySQL, & DVWA
#------------------------------------------

echo -e "${GREEN}[+] Installing PHP 7.1${NC}"
apt-get install php7.2 php7.2-gd php7.2-mysql libapache2-mod-php
echo -e "${GREEN}[+] Installing MySQL${NC}"
apt-get install mysql-server -y
echo -e "${GREEN}[+] Installing Apache2${NC}"
apt-get install apache2 -y
echo -e "${GREEN}[+] Checking if Git is installed${NC}"
apt-get install git -y
echo -e "${GREEN}[+] Cloning DVWA${NC}"
cd /var/www/html
git clone https://github.com/ethicalhack3r/DVWA.git
mv DVWA dvwa

#----------------------------------------------------------------------
# Edit dvwa/config/config.inc.php - Need to add captcha keys
# Edit /etc/php/7.2/apache2/php.ini - change: allow_url_include = On
#----------------------------------------------------------------------
cd /var/www/html/dvwa/config
cp config.inc.php.dist config.inc.php 
echo -e "${GREEN}[+] Adding reCaptcha Keys to config.inc.php${NC}"
sed -i "s/\$_DVWA\[ 'recaptcha_public_key' ]  = '';/\$_DVWA\[ 'recaptcha_public_key' ]  = '${cap_pubk}';/g" config.inc.php
sed -i "s/\$_DVWA\[ 'recaptcha_private_key' ] = '';/\$_DVWA\[ 'recaptcha_private_key' ] = '${cap_privk}';/g" config.inc.php

echo -e "${GREEN}[+] Adding allow_url_include = On to php.ini${NC}"
cd /etc/php/7.2/apache2
sed -i 's/allow_url_include = Off/allow_url_include = On/g' php.ini

chmod -R 755 /var/www/html/dvwa
cd /var/www/html/dvwa/config
echo -e "${GREEN}[+] Time to initialize the database${NC}"
mysql -u root -Bse "create database dvwa;"
mysql -u root -Bse "create user 'dvwa'@'localhost' identified by 'dvwa';"
mysql -u root -Bse "grant all privileges on * . * to 'dvwa'@'localhost';"
mysql -u root -Bse "flush privileges;"
sed -i "s/\$_DVWA\[ 'db_user' ]     = 'root';/\$_DVWA\[ 'db_user' ]     = 'dvwa';/g" config.inc.php
sed -i "s/\$_DVWA\[ 'db_password' ] = 'p@ssw0rd';/\$_DVWA\[ 'db_password' ] = 'dvwa';/g" config.inc.php

echo -e "${GREEN}[+] Appending server name to apache2.conf${NC}"
echo "ServerName localhost" >> /etc/apache2/apache2.conf
echo -e "${GREEN}[+] Starting Apache2 service${NC}"
service apache2 restart

echo -e "${GREEN}[+] Navigating to DVWA setup page${NC}"
echo -e "${GREEN}[+] Done${NC}"
exit 0
