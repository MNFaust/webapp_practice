#!/bin/bash

#============================
# Ubunutu Set-up Script
# by: Joshua Faust
#============================

#Check if Root
if [ "$(whoami)" != "root" ]
	then
		echo "You must be root"
		exit 1
fi

echo "[+] Running Updates before installing"
apt-get update && upgrade -y && dist-upgrade -y
apt-get install tmux

#-----------------------
# Install Java JDK/JRE
#-----------------------
echo "[+] Installing default Java"
apt-get install default-jre -y
apt-get install default-jdk -y
echo "[+] Adding Oracle repo and Updating" 
add-apt-repository ppa:webupd8team/java
apt-get update
echo "[+] Installing Oracle Java 9"
apt-get install oracle-java9-installer

#------------------------------------------
# Install Apache2, PHP, MySQL, & DVWA
#------------------------------------------

echo "[+] Installing PHP 7.1"
apt-get install php7.0 php7.0-gd php7.0-mysql libapache2-mod-php
echo "[+] Installing MySQL"
apt-get install mysql-server -y
echo "[+] Installing Apache2"
apt-get install apache2 -y
echo "[+] Checking if Git is installed"
apt-get install git -y
echo "[+] Cloning DVWA"
cd /var/www/html
git clone https://github.com/ethicalhack3r/DVWA.git
mv DVWA dvwa

echo "#!/bin/bash" > data.sh
echo "Edit dvwa/config/config.inc.php - Need to add captcha keys" >> data.sh
echo "Edit /etc/php/7.1/apache2/php.ini - change: allow_url_include = On" >> data.sh

echo "[+] Starting TMUX session to edit files"
tmux new -d -s DVWA data.sh
tmux attach -t DVWA

#----------------------------------------------------------------------
# Edit dvwa/config/config.inc.php - Need to add captcha keys
# Edit /etc/php/7.1/apache2/php.ini - change: allow_url_include = On
#----------------------------------------------------------------------
echo -n 'Are you done editing the files? (Y|N):'; read ans
if [ $ans == "Y" ] || [ $ans == "y" ]
	then
		cp /var/www/html/dvwa/config/config.inc.php.dist config.inc.php
		chmod -R 777 /var/www/html/dvwa
		echo "[+] Time to initialize the database"
		echo -n "What is the MySQL Password?"; read PASS
		mysql -u root -p$PASS -Bse "create database dvwa; exit;"

		echo "[+] Appending server name to apache2.conf"
		echo "ServerName localhost" >> /etc/apache2/apache2.conf
		echo "[+] Starting Apache2 service"
		service apache2 start
		echo "[+] Navigating to DVWA setup page"
		firefox var/www/html/dvwa/setup.php &
		rm -rf data.sh
		echo "[+] Done"
	else 
		echo "PROGRAM STOPPED, PLEASE EDIT FILES"
		exit 1
fi
exit 0
	
