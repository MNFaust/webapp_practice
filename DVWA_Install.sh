#!/bin/bash

#============================
# Ubunutu Set-up Script
# by: @jfaust0
#============================

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

#Check if Root
if [ "$(whoami)" != "root" ]
	then
		echo "${RED}You must be root${NC}"
		exit 1
fi

echo "${GREEN}[+] Running Updates before installing${NC}"
apt-get update && upgrade -y && dist-upgrade -y
apt-get install tmux

#-----------------------
# Install Java JDK/JRE
#-----------------------
echo "${GREEN}[+] Installing default Java${NC}"
apt-get install default-jre -y
apt-get install default-jdk -y

#------------------------------------------
# Install Apache2, PHP, MySQL, & DVWA
#------------------------------------------

echo "${GREEN}[+] Installing PHP 7.1${NC}"
apt-get install php7.2 php7.2-gd php7.2-mysql libapache2-mod-php
echo "${GREEN}[+] Installing MySQL${NC}"
apt-get install mysql-server -y
echo "${GREEN}[+] Installing Apache2${NC}"
apt-get install apache2 -y
echo "${GREEN}[+] Checking if Git is installed${NC}"
apt-get install git -y
echo "${GREEN}[+] Cloning DVWA${NC}"
cd /var/www/html
git clone https://github.com/ethicalhack3r/DVWA.git
mv DVWA dvwa

echo "#!/bin/bash" > data.sh
echo "Edit dvwa/config/config.inc.php - Need to add captcha keys" >> data.sh
echo "Edit /etc/php/7.1/apache2/php.ini - change: allow_url_include = On" >> data.sh

echo "${GREEN}[+] Starting TMUX session to edit files${NC}"
#tmux new -d -s DVWA data.sh
#tmux attach -t DVWA

#----------------------------------------------------------------------
# Edit dvwa/config/config.inc.php - Need to add captcha keys
# Edit /etc/php/7.1/apache2/php.ini - change: allow_url_include = On
#----------------------------------------------------------------------
echo -n 'Are you done editing the files? (Y|N):'; read ans
if [ $ans == "Y" ] || [ $ans == "y" ]
	then
		cp /var/www/html/dvwa/config/config.inc.php.dist config.inc.php
		chmod -R 777 /var/www/html/dvwa
		echo "${GREEN}[+] Time to initialize the database${NC}"
		echo -n "What is the MySQL Password?"; read PASS
		mysql -u root -p$PASS -Bse "create database dvwa; exit;"

		echo "${GREEN}[+] Appending server name to apache2.conf"
		echo "ServerName localhost" >> /etc/apache2/apache2.conf
		echo "${GREEN}[+] Starting Apache2 service${NC}"
		service apache2 start
		echo "${GREEN}[+] Navigating to DVWA setup page${NC}"
		firefox var/www/html/dvwa/setup.php &
		rm -rf data.sh
		echo "${GREEN}[+] Done${NC}"
	else 
		echo "P${RED}ROGRAM STOPPED, PLEASE EDIT FILES"
		exit 1
fi
exit 0
	
