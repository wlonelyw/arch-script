#!/bin/bash

#sh.sh

#source <(curl -sSL https://example.com/script.sh)
source ./txt/environment.txt

function archiso {
    local PS3="select: "
    local options=("Change Mirror" "Sync Timezone" "UEFI Check")
    local opt=""

}

function archlinux {
    local PS3="选择: "
    local option=("自动更换镜像源" "自动同步时区")
    local opt=""

}

if [[ -f /etc/arch-release && -d /run/archiso ]]; then
    archiso
else
    archlinux
fi

while true; do
    echo -e "
    ########################
    #   ${GREEN}01${CLEAR}: ${YELLOW}Change Mirror${CLEAR}  #
    #   ${GREEN}00${CLEAR}: ${YELLOW}EXIT${CLEAR}           #
    ########################
    "

    read -p "option: " option

    case "${option:-00}" in
        1|01)
            echo "Download mirrors.sh"
            bash -c "$(curl -sSL https://archlinux-sh.pages.dev/sh/mirrors.sh)"
            ;;
        00)
            exit 0
            ;;
        *)

            ;;
    esac
done
