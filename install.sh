echo "$_PURPLE==================================================================$_DEF\n"
echo "$_PURPLE            debian disk infos :"
sudo fdisk -l

echo "\n"
echo "$_PURPLE==================================================================$_DEF\n"
echo "$_PURPLE            updating..."
apt-get -y update
apt-get -y upgrade

echo "\n"
echo "$_PURPLE==================================================================$_DEF\n"
echo "$_PURPLE            installing package..."
apt-get install -y sudo
apt-get install -y git
apt-get install -y apache2

echo "$_PURPLE==================================================================$_DEF\n"
echo "$_PURPLE            installing folder..."

cd /root
git clone https://github.com/IMBiXx/Roger-Skyline.git /root/roger-skyline

echo "$_PURPLE==================================================================$_DEF\n"
echo "$_PURPLE            user creation..."
echo "\n"
echo "Adding sudo user... Username ? (default: 'roger')"
read Username
Username=${Username:-"roger"}
sudo adduser $Username
sudo adduser $Username sudo

echo "\n"
echo "$_PURPLE==================================================================$_DEF\n"
echo "$_PURPLE            INTERFACES"

cp /etc/network/interfaces /etc/network/interfaces_save
rm -f /etc/network/interfaces
cp /root/roger-skyline/files/interfaces /etc/network

cp /root/roger-skyline/files/enp0s3 /etc/network/interfaces.d/

sudo service networking restart

echo "\n"
echo "$_PURPLE==================================================================$_DEF\n"
echo "$_PURPLE            SSHD_CONFIG"

cp /etc/ssh/sshd_config /etc/ssh/sshd_config_save
rm -rf /etc/ssh/sshd_config
cp /root/roger-skyline/files/sshd_config /etc/ssh/

/etc/init.d/ssh restart

echo "\n"
echo "$_PURPLE==================================================================$_DEF\n"
echo "$_PURPLE            FIREWALL"

sh /root/roger-skyline/scripts/firewall.sh

echo "\n"
echo "$_PURPLE==================================================================$_DEF\n"
echo "$_PURPLE            DDOS PROTECTION"

sh /root/roger-skyline/scripts/ddos.sh

echo "\n"
echo "$_PURPLE==================================================================$_DEF\n"
echo "$_PURPLE            PORTS SCAN"

sh /root/roger-skyline/scripts/ports.sh

echo "\n"
echo "$_PURPLE==================================================================$_DEF\n"
echo "$_PURPLE            making the configuration persistent..."

apt-get install -y iptables-persistent

echo "\n"
echo "$_PURPLE==================================================================$_DEF\n"
echo "$_PURPLE            UPDATE SCRIPT"

mkdir /root/scripts
cp /root/roger-skyline/scripts/script_log.sh /root/scripts/
chmod 755 /root/scripts/script_log.sh
chown root /root/scripts/script_log.sh

echo "0 4 * * wed root /root/scripts/script_log.sh\n" >> /etc/crontab
echo "@reboot root /root/scripts/script_log.sh\n" >> /etc/crontab

echo "0 4 * * wed root /root/scripts/script_log.sh\n" >> /var/spool/cron/crontabs/root
echo "@reboot root /root/scripts/script_log.sh\n" >> /var/spool/cron/crontabs/root

echo "\n"
echo "$_PURPLE==================================================================$_DEF\n"
echo "$_PURPLE            CRONTAB SCRIPT"

cp /root/roger-skyline/scripts/script_crontab.sh /root/scripts/
chmod 755 /root/scripts/script_crontab.sh
chown root /root/scripts/script_crontab.sh

echo "0 0 * * * root /root/scripts/script_crontab.sh\n" >> /etc/crontab
echo "0 0 * * * root /root/scripts/script_crontab.sh\n" >> /var/spool/cron/crontabs/root

echo "\n"
echo "$_PURPLE==================================================================$_DEF\n"
echo "$_PURPLE            WEB SERVER"

systemctl start apache2

echo "\n"
echo "$_PURPLE==================================================================$_DEF\n"
echo "$_PURPLE            VIRTUAL HOST"

mkdir -p /var/www/init.login.fr/html
chown -R $Username:$Username /var/www/init.login.fr/html
chmod -R 775 /var/www/init.login.fr

cp /root/roger-skyline/files/index.html /var/www/init.login.fr/html/

cp /root/roger-skyline/files/init.login.fr.conf /etc/apache2/sites-available/

rm /etc/apache2/sites-enabled/000-default.conf
ln -s /etc/apache2/sites-available/init.login.fr.conf /etc/apache2/sites-enabled/

echo "\n"
echo "$_PURPLE==================================================================$_DEF\n"
echo "$_PURPLE            SSL CERTIFICAT"

cd /etc/ssl/certs/
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout roger.key -out roger.crt

sudo a2enmod ssl
sudo service apache2 restart
