#!/bin/bash

TheBlackScorme() {
    local use_dc3dd=false
    local log_dir=""
    local boot_drive=$(lsblk -o NAME,MOUNTPOINT | grep -w '/' | awk '{print $1}')
    local WhatIf=false

    while [[ "$1" != "" ]]; do
        case $1 in
            --dc3dd | -3 ) use_dc3dd=true ;;
            --log | -l ) shift; log_dir=$1 ;;
            --whatif | -w ) WhatIf=true ;;
            * ) echo "Invalid option: $1"; return 1 ;;
        esac
        shift
    done

    if $WhatIf; then
        for device in $(lsblk -dno NAME | grep -v $boot_drive); do
            if $use_dc3dd; then
                if [[ -n $log_dir ]]; then
                    echo "Device $device will be wiped with dc3dd, and logged to $log_dir."
                    return 0
                else
                    echo "Device $device will be wiped with dc3dd, and no logs will be created."
                    return 0
                fi
            else
                if [[ -n $log_dir ]]; then
                    echo "Device $device will be wiped with dd, and logged to $log_dir."
                    return 0
                else
                    echo "Device $device will be wiped with dd, and no logs will be created."
                    return 0
                fi
            fi
        done    

    if [[ -n $log_dir ]]; then
        mkdir -p $log_dir
        if [[ $? -ne 0 ]]; then
            echo "Failed to create log directory $log_dir"
            return 1
        fi
    fi

    for device in $(lsblk -dno NAME | grep -v $boot_drive); do
        if $use_dc3dd; then
            if [[ -n $log_dir ]]; then
                dc3dd hwipe=/dev/$device hash=sha256 log=${log_dir}/dc3dd${device}.log hashlog=${log_dir}/hash${device}.log
            else
                dc3dd hwipe=/dev/$device hash=sha256
            fi
        else
            if [[ -n $log_dir ]]; then
                dd if=/dev/zero of=/dev/$device bs=1M status=progress 2>&1 | tee -a ${log_dir}/dd${device}.log
                sha256sum /dev/$device | tee -a ${log_dir}/hash${device}.log
            else
                dd if=/dev/zero of=/dev/$device bs=1M status=progress
                sha256sum /dev/$device
            fi
        fi
    done
}