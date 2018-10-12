#!/bin/bash

read -p " ป้อนรายชื่อ user ที่จะลบ : " Pengguna

if getent passwd $Pengguna > /dev/null 2>&1; then
        userdel $Pengguna
        echo -e " รายชื่อ $Pengguna ได้ลบออกแล้ว"
else
        echo -e " ค้นหา: รายชื่อ $Pengguna ไม่เจอในระบบ "
fi
echo -e " by sangmander kasang "
