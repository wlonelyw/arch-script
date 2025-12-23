#!/bin/bash

# mirror.sh
if [[ "$EUID" -eq 0 ]] && [[ -f /etc/arch-release && -d /run/archiso ]]; then
    _sudo=""
    _exec=""
else
    _sudo="sudo"
    _exec="echo"
fi

mirror() {
    echo "pacman Change Mirror Source"

    local country=""
    if ipv4_tmp=$(curl -sf ipv4.ip.sb); then
        ipv4="$ipv4_tmp"
        country=$(curl -sS https://ipinfo.io/$ipv4 | grep -oP '(?<="country": ")[^"]*')
        echo "IPv4: $ipv4"
    fi

    if ipv6_tmp=$(curl -sf ipv6.ip.sb); then
        ipv6="$ipv6_tmp"
        country=$(curl -sS https://ipinfo.io/$ipv4 | grep -oP '(?<="country": ")[^"]*')
        echo "IPv6: $ipv6"
    fi

    [ -z "$country" ] && echo "Fail" && exit 1

    $_exec systemctl stop reflector
    echo "Get And Change Mirror Source List"
    url="https://archlinux.org/mirrorlist/?country=${country}&protocol=https&ip_version=4&ip_version=6&use_mirror_status=on"
    $_sudo curl -sSL $url -o /etc/pacman.d/mirrorlist
    $_sudo sed -i 's/#Server/Server/g' /etc/pacman.d/mirrorlist
    echo "Sync packages Database..."
    $_sudo pacman -Sy --noconfirm > /dev/null
    echo "Done"
}

pacman() {
    echo "Enable MultiLib?"
    read -p "(Y/N): " yn
    case "${yn:-N}" in
    [Yy])
        echo "Enable MultiLib..."
        $_sudo sed -z -i 's|#\[multilib\]\n#Include = /etc/pacman.d/mirrorlist|\[multilib\]\nInclude = /etc/pacman.d/mirrorlist|g' /etc/pacman.conf

        echo "Sync packages Database..."
        $_sudo pacman -Sy --noconfirm > /dev/null

        echo "Done"
        ;;
    *)
        echo "Skip"
        ;;
    esac
    unset yn

    echo "Add archlinuxcn?"
    read -p "(Y/N): " yn
    case "${yn:-N}" in
    [Yy])

        echo "archlinuxcn"
        $_sudo sed -i '$a #\n[archlinuxcn]\nServer = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch' /etc/pacman.conf

        echo "Sync packages Database..."
        $_sudo pacman -Sy --noconfirm > /dev/null
        echo "Add archlinuxcn-keyring"
        $_sudo pacman -S archlinuxcn-keyring --noconfirm

        echo "Done"
        ;;
    *)
        echo "Skip"
        ;;
    esac
    unset yn
}

exit_() {
    echo "Press any key exit..."
    read -n 1 -s
}

if [[ -f /etc/arch-release && -d /run/archiso ]]; then
    mirror
    exit_
    exit
else
    mirror
    pacman
    exit_
    exit
fi

