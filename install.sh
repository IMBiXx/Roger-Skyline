echo "==================================================================\n"
echo "            updating..."
echo "\n"
apt-get -y update
apt-get -y upgrade

echo "\n"
echo "==================================================================\n"
echo "            installing package..."
echo "\n"
apt-get install -y sudo
apt-get install -y git
apt-get install -y apache2
apt-get install -y sendmail

echo "\n"
echo "==================================================================\n"
echo "            debian disk infos :"
echo "\n"
sudo fdisk -l

echo "\n"
echo "==================================================================\n"
echo "            installing folder..."
echo "\n"

cd /root
git clone https://github.com/IMBiXx/Roger-Skyline.git /root/roger-skyline

echo "\n"
echo "==================================================================\n"
echo "            user creation..."
echo "\n"

echo "Adding sudo user... Username ? (default: 'roger')"
read Username
Username=${Username:-"roger"}
sudo adduser $Username
sudo adduser $Username sudo

echo "\n"
echo "==================================================================\n"
echo "            INTERFACES"
echo "\n"

cp /etc/network/interfaces /etc/network/interfaces_save
rm -f /etc/network/interfaces
cp /root/roger-skyline/files/interfaces /etc/network

cp /root/roger-skyline/files/enp0s3 /etc/network/interfaces.d/

sudo service networking restart

echo "\n"
echo "==================================================================\n"
echo "            SSHD_CONFIG"
echo "\n"

cp /etc/ssh/sshd_config /etc/ssh/sshd_config_save
rm -rf /etc/ssh/sshd_config
cp /root/roger-skyline/files/sshd_config /etc/ssh/
mkdir -pv /home/$Username/.ssh
cat /root/roger-skyline/files/id_rsa.pub >> /home/$Username/.ssh/authorized_keys

/etc/init.d/ssh restart

echo "\n"
echo "==================================================================\n"
echo "            FIREWALL"
echo "\n"

sh /root/roger-skyline/scripts/firewall.sh
echo "done."

echo "\n"
echo "==================================================================\n"
echo "            DDOS PROTECTION"
echo "\n"

sh /root/roger-skyline/scripts/ddos.sh
echo "done."

echo "\n"
echo "==================================================================\n"
echo "            PORTS SCAN"
echo "\n"

sh /root/roger-skyline/scripts/ports.sh
echo "done."

echo "\n"
echo "==================================================================\n"
echo "            making the configuration persistent..."
echo "\n"

apt-get install -y iptables-persistent

echo "\n"
echo "==================================================================\n"
echo "            MAIL SERVER"
echo "\n"

yes 'Y' | sudo sendmailconfig

echo "\n"
echo "==================================================================\n"
echo "            UPDATE SCRIPT"
echo "\n"

mkdir /root/scripts
cp /root/roger-skyline/scripts/script_log.sh /root/scripts/
chmod 755 /root/scripts/script_log.sh
chown root /root/scripts/script_log.sh

echo "0 4 * * wed root /root/scripts/script_log.sh\n" >> /etc/crontab
echo "@reboot root /root/scripts/script_log.sh\n" >> /etc/crontab

echo "0 4 * * wed root /root/scripts/script_log.sh\n" >> /var/spool/cron/crontabs/root
echo "@reboot root /root/scripts/script_log.sh\n" >> /var/spool/cron/crontabs/root

echo "\n"
echo "==================================================================\n"
echo "            CRONTAB SCRIPT"
echo "\n"

cp /root/roger-skyline/scripts/script_crontab.sh /root/scripts/
cp /root/roger-skyline/files/mail_type.txt /root/scripts/
chmod 755 /root/scripts/script_crontab.sh
chown root /root/scripts/script_crontab.sh
chown root /root/scripts/mail_type.txt

echo "0 0 * * * root /root/scripts/script_crontab.sh\n" >> /etc/crontab
echo "0 0 * * * root /root/scripts/script_crontab.sh\n" >> /var/spool/cron/crontabs/root

cat /etc/crontab > /root/scripts/tmp

echo "\n"
echo "==================================================================\n"
echo "            WEB SERVER"
echo "\n"

systemctl start apache2

echo "\n"
echo "==================================================================\n"
echo "            VIRTUAL HOST"
echo "\n"

mkdir -p /var/www/init.login.fr/html
chown -R $Username:$Username /var/www/init.login.fr/html
chmod -R 775 /var/www/init.login.fr

cp /root/roger-skyline/files/index.html /var/www/init.login.fr/html/

cp /root/roger-skyline/files/init.login.fr.conf /etc/apache2/sites-available/

rm /etc/apache2/sites-enabled/000-default.conf
ln -s /etc/apache2/sites-available/init.login.fr.conf /etc/apache2/sites-enabled/

echo "\n"
echo "==================================================================\n"
echo "            SSL CERTIFICAT"
echo "\n"

cd /etc/ssl/certs/
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout roger.key -out roger.crt

sudo a2enmod ssl
sudo service apache2 restart

echo "\n"
echo "==================================================================\n"
echo "            CLEANING"
echo "\n"

apt-get remove -y git
rm -rf /root/roger-skyline/
echo "Subject: Install done for $Username." | sudo sendmail -v valecart@student.42.fr
echo "Work done."
