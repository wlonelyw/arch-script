#!/bin/bash

# mirror.sh

# function
mirror() {
    echo "pacman Change mirror source"
    echo "Enter the country code."

    local country="CN"
    read -p "(default: CN) (global: all) " country

    url="https://archlinux.org/mirrorlist/?country=${country}&protocol=https&ip_version=4&ip_version=6&use_mirror_status=on"
    echo "Get mirror source list"
    curl -L -s $url -o mirrorlist
    echo "Change pacman mirror source list"
    sed -i 's/#Server/Server/g' /etc/pacman.d/mirrorlist
    #pacman -Sy
    echo "Done"
}

pacman() {
    echo "Enable multilib mirror source ?"
    read -p "(Y/N) " yn
    case "${yn:-N}" in
    [Yy])
        echo "Enable multilib"
        sed -z -i 's|#\[multilib\]\n#Include = /etc/pacman.d/mirrorlist|\[multilib\]\nInclude = /etc/pacman.d/mirrorlist|g' /etc/pacman.conf

        echo "Sync package database..."
        sudo pacman -Sy --noconfirm > /dev/null

        echo "Done"
        ;;
    *)
        echo "Skip"
        ;;
    esac
    unset yn

    echo "Add archlinuxcn mirror source?"
    read -p "(Y/N) " yn
    case "${yn:-N}" in
    [Yy])

        echo "Add archlinuxcn"
        sed -i '$a #\n[archlinuxcn]\nServer = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch' /etc/pacman.conf

        echo "Sync package database..."
        sudo pacman -Sy --noconfirm > /dev/null
        echo "Add archlinuxcn-keyring"
        sudo pacman -S archlinuxcn-keyring --noconfirm

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

# main
if [[ -f /etc/arch-release && -d /run/archiso ]]; then
    mirror
    exit_
    exit
else
    pacman
    exit_
    exit
fi

