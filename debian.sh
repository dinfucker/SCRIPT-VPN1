#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";

PLK="http://104.238.136.182:81/pvc"

cd
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

apt-get update;apt-get -y install wget curl;

ln -fs /usr/share/zoneinfo/Asia/Bangkok /etc/localtime

sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service ssh restart
clear



# set repo
wget -O /etc/apt/sources.list $PLK/sources.list.debian7

wget "http://www.dotdeb.org/dotdeb.gpg"

cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg
sh -c 'echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list'
wget -qO - http://www.webmin.com/jcameron-key.asc | apt-key add -

apt-get update

apt-get -y install nginx

apt-get -y install nano iptables dnsutils openvpn screen whois ngrep unzip unrar

echo "deb http://dl.bintray.com/dawidd6/neofetch jessie main" | tee -a /etc/apt/sources.list
curl "https://bintray.com/user/downloadSubjectPublicKey?username=bintray"| apt-key add -
apt-get update
apt-get install neofetch

echo "deb http://dl.bintray.com/dawidd6/neofetch jessie main" | tee -a /etc/apt/sources.list
curl "https://bintray.com/user/downloadSubjectPublicKey?username=bintray"| apt-key add -
apt-get update
apt-get install neofetch
echo "clear" >> .bash_profile
echo "neofetch" >> .bash_profile

cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf $PLK/nginx.conf
mkdir -p /home/vps/public_html
echo "<pre>~sivoi~</pre>" > /home/vps/public_html/index.html
wget -O /etc/nginx/conf.d/vps.conf $PLK/vps.conf
service nginx restart

# install openvpn
wget -O /etc/openvpn/openvpn.tar $PLK/vpn.tar
cd /etc/openvpn/
tar xf openvpn.tar
rm -f /etc/openvpn/openvpn.tar
wget -O /etc/openvpn/1194.conf $PLK/1194.conf
service openvpn restart
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
iptables -t nat -I POSTROUTING -s 192.168.100.0/24 -o eth0 -j MASQUERADE
iptables-save > /etc/iptables_set.conf
wget -O /etc/network/if-up.d/iptables $PLK/iptables
chmod +x /etc/network/if-up.d/iptables
service openvpn restart

# konfigurasi openvpn
cd /etc/openvpn/
wget -O /etc/openvpn/client.ovpn $PLK/client-1194.conf
wget -O /etc/openvpn/clientPC.ovpn $PLK/client-1194pc.conf

sed -i $MYIP2 /etc/openvpn/client.ovpn;
sed -i $MYIP2 /etc/openvpn/clientPC.ovpn;

cp client.ovpn /home/vps/public_html/
cp clientPC.ovpn /home/vps/public_html/

# install badvpn
cd
wget -O /usr/bin/badvpn-udpgw $PLK/badvpn-udpgw
if [ "$OS" == "x86_64" ]; then
  wget -O /usr/bin/badvpn-udpgw $PLK/badvpn-udpgw64
fi
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300

# setting port ssh
cd
sed -i 's/Port 22/Port 22/g' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
service ssh restart

# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=444/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 444 -p 80"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
service ssh restart
service dropbear restart

# install dropbear 2017
cd
wget $PLK/dropbear-2017.75.tar.bz2
apt-get install zlib1g-dev
bzip2 -cd dropbear-2017.75.tar.bz2  | tar xvf -
cd dropbear-2017.75
./configure
make && make install
mv /usr/sbin/dropbear /usr/sbin/dropbear1
ln /usr/local/sbin/dropbear /usr/sbin/dropbear
service dropbear restart
rm -f /root/dropbear-2017.75.tar.bz2

# install stunnel4
apt-get -y install stunnel4
wget -O /etc/stunnel/stunnel.pem $PLK/stunnel.pem
wget -O /etc/stunnel/stunnel.conf $PLK/stunnel.conf
sed -i $MYIP2 /etc/stunnel/stunnel.conf
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
service stunnel4 restart

# install fail2ban
apt-get -y install fail2ban;
service fail2ban restart

# install squid3
cd
apt-get -y install squid3
wget -O /etc/squid3/squid.conf $PLK/squid3.conf
sed -i $MYIP2 /etc/squid3/squid.conf;
service squid3 restart

# install webmin
cd
wget "http://prdownloads.sourceforge.net/webadmin/webmin_1.850_all.deb"
dpkg --install webmin_1.850_all.deb;
apt-get -y -f install;
rm /root/webmin_1.850_all.deb
sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
service webmin restart

# blockir torrent
iptables -A OUTPUT -p tcp --dport 6881:6889 -j DROP
iptables -A OUTPUT -p udp --dport 1024:65534 -j DROP
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP

# install ddos deflate
cd
apt-get -y install dnsutils dsniff
wget $PLK/ddos-deflate-master.zip
unzip ddos-deflate-master.zip
cd ddos-deflate-master
./install.sh
rm -rf /root/ddos-deflate-master.zip

# setting banner
rm /etc/issue.net
wget -O /etc/issue.net $PLK/issue.net
sed -i 's@#Banner@Banner@g' /etc/ssh/sshd_config
sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/issue.net"@g' /etc/default/dropbear
service ssh restart
service dropbear restart

# download script
cd /usr/bin
wget -O menu $PLK/mn/menu.sh
wget -O a $PLK/mn/a.sh
wget -O b $PLK/mn/b.sh
wget -O c $PLK/mn/c.sh
wget -O d $PLK/mn/d.sh
wget -O f $PLK/mn/f.sh
wget -O g $PLK/mn/g.sh
wget -O rsq $PLK/mn/rsq.sh
wget -O speedtest $PLK/mn/speedtest_cli.py
wget -O info $PLK/mn/info.sh
wget -O about $PLK/mn/about.sh

echo "03 30 * * * root /sbin/reboot" > /etc/cron.d/reboot

chmod +x menu
chmod +x a
chmod +x b
chmod +x c
chmod +x d
chmod +x f
chmod +x rsq
chmod +x speedtest
chmod +x info
chmod +x g
chmod +x about

apt-get -y install vnstat
vnstat -u -i eth0
sudo chown -R vnstat:vnstat /var/lib/vnstat
service vnstat restart

cd
chown -R www-data:www-data /home/vps/public_html
service nginx start
service openvpn restart
service cron restart
service ssh restart
service dropbear restart
service stunnel4 restart
service squid3 restart
service fail2ban restart
service webmin restart
rm -rf ~/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile
clear

echo "========================================" 
echo " "
echo "OpenSSH  : 22, 143" 
echo "Dropbear : 80, 444"
echo "SSL      : 443" 
echo "Squid3   : 8080, 3128 (limit to IP SSH)"
echo " "
echo "OpenVPN  : TCP 1194 "
echo "http://$MYIP:81/client.ovpn"
echo " "
echo "http://$MYIP:81/clientPC.ovpn"
echo " "
echo "========================================" 
echo " "
echo "Webmin   : http://$MYIP:10000/" 
echo " Time เวลา กทม " 
echo " "
echo " ขอบคุณโครงสร้างไฟล์จาก " 
echo "Admin And All Member KPN Family"
echo " Thai4G And speed100.ga "
echo " "
echo " เข้าเมนู พิมพ์ menu"
echo " "
echo " ดัดแปลงแก้ไข by sangmander kasang "
echo " Facebook : sangmander kasang "
echo " "
echo " *****   หมายเหตุ สคริปแจกฟรี เท่านั้น  *****  "
echo "========================================"  
cd
rm -f /root/debian.sh


