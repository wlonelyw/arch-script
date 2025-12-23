#!/bin/bash

#uefi-check

if [[ -d /sys/firmware/efi/fw_platform_size ]]; then
    echo -e "${GREEN}UEFI${CLEAR}"
    echo -e "$(cat /sys/firmware/efi/fw_platform_size)-bit"
else
    echo -e "${YELLOW}}BIOS${CLEAR}"
fi
