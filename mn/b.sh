#!/bin/bash

IP=`dig +short myip.opendns.com @resolver1.opendns.com`

read -p "ทดลอง(จำนวนวัน): " hari

Login=trial`</dev/urandom tr -dc X-Z0-9 | head -c4`

#hari="1"

Pass=`</dev/urandom tr -dc a-f0-9 | head -c9`

useradd -e `date -d "$hari days" +"%Y-%m-%d"` -s /bin/false -M $Login
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
echo -e ""
echo -e "====บัญชีทดลอง SSH Account===="
echo -e "Host: $IP" 
echo -e "Port OpenSSH   : 22,143"
echo -e "Port Dropbear  : 80,444"
echo -e "Port SSL/TLS   : 443"
echo -e "Port Squid     : 8080,3128"
echo -e "http://$IP:81/client.ovpn"
echo -e "Username: $Login"
echo -e "Password: $Pass\n"
echo -e ""
echo -e " ไฟล์ทดลองใช้งาน $hari วัน "
echo -e ""
echo -e " ไฟล์ใช้กับ computer "
echo -e "http://$IP:81/clientPC.ovpn"
echo -e "============================="
echo -e " by sangmander kasang "
