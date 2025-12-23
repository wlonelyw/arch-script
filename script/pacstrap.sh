#!/bin/bash

#pacstrap.sh
function run_pacstrap {
    #echo "default: ${BLUE}pacstrap -K /mnt base base-devel vim NetWorkManager (amd-ucode / intel-ucode)${CLEAR}"

    echo "pacstrap"

    local packages=("base" "base-devel" "linux-firmware" "vim" "networkmanager")

    local PS3="select kernel: "
    local options=("linux" "linux-hardened" "linux-lts" "linux-rt" "linux-rt-lts" "linux-zen")
    local kernel=""

    select kernel in "${options[@]}"; do
        if [[ "$opt" =~ ^(linux|linux-hardened|linux-lts|linux-rt|linux-rt-lts|linux-zen)$ ]]; then
            packages+=("$opt")
            break
        else
            echo -e "Invalid option"
        fi
    done

    local headers=""



    local cpu_model="$(lscpu | grep "Model name:" | sed 's/Model name: *//')"

    case "${cpu_model}" in
        *Intel*)
            packages+=("intel-ucode")
            echo "Intel"
            ;;
        *AMD*)
            packages+=("amd-ucode")
            echo "AMD"
            ;;
        *)
            echo "?"
            ;;
    esac

    echo "Add more packages?"
    read -p "(space split)packages: " -a add_packages
    echo ${add_packages[@]}
    packages+=(${add_packages[@]})

    echo "pacstrap..."
    pacstrap -K /mnt ${packages[@]}

}

if [[ -f /etc/arch-release && -d /run/archiso ]]; then
    run_pacstrap
else
    echo "archiso"
    exit 1
fi
