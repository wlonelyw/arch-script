#!/bin/bash

#timdate.sh
if [[ "$EUID" -eq 0 ]] && [[ -f /etc/arch-release && -d /run/archiso ]]; then
    _sudo=""
    _exec=""
else
    _sudo="sudo"
    _exec="echo"
fi

echo "timezone"

timezone=""
if ipv4_tmp=$(curl -sf ipv4.ip.sb); then
    ipv4="$ipv4_tmp"
    timezone=$(curl -sS https://ipinfo.io/$ipv4 | grep -oP '(?<="timezone": ")[^"]*')
    echo "IPv4 获取成功: $ipv4"
fi

if ipv6_tmp=$(curl -sf ipv6.ip.sb); then
    ipv6="$ipv6_tmp"
    timezone=$(curl -sS https://ipinfo.io/$ipv4 | grep -oP '(?<="timezone": ")[^"]*')
    echo "IPv6 获取成功: $ipv6"
fi

[ -z "$timezone" ] && echo "Fail" && exit 1

#echo "$(timedatectl list-timezones | cat | xargs)"

if $_sudo timedatectl set-timezone ${timezone} 2>/dev/null; then
    echo "timezone is set to ${CYAN}$timezone${CLEAR}"
    $_sudo timedatectl set-ntp true
    $_sudo timedatectl status
    echo -e "${GREEN}Successfully${CLEAR}"
else
    echo -e "${RED}Error: Invalid timezone${CLEAR}"
fi
