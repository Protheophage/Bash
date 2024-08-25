#!/bin/bash

theblackscorme() {
    local use_dc3dd=false
    local log_dir=""
    local WhatIf=false
    local boot_drive=$(df / | tail -1 | awk '{print $1}')
    local base_boot_device=$(echo $boot_drive | sed 's/[0-9]*$//')
    local all_devices=($(lsblk -nd -o NAME))
    # Create an array excluding the boot device and its partitions
    local filtered_devices=()
    for device in "${all_devices[@]}"; do
        if [[ "/dev/$device" != "$boot_device" && "/dev/$device" != "$base_boot_device"* ]]; then
            filtered_devices+=("/dev/$device")
        fi
    done

    printf "Boot drive: %s\n" "$boot_drive"  # Debug statement

    while [[ "$1" != "" ]]; do
        case $1 in
            --dc3dd | -3 ) use_dc3dd=true ;;
            --log | -l ) shift; log_dir=$1 ;;
            --whatif | -w ) WhatIf=true ;;
            * ) printf "Invalid option: %s\n" "$1"; return 1 ;;
        esac
        shift
    done

    if $WhatIf; then
        printf "WhatIf mode enabled\n"  # Debug statement
        for device in $filtered_devices; do
            printf "Processing device: %s\n" "$device"  # Debug statement
            if $use_dc3dd; then
                if [[ -n $log_dir ]]; then
                    printf "Device %s will be wiped with dc3dd, and logged to %s.\n" "$device" "$log_dir"
                else
                    printf "Device %s will be wiped with dc3dd, and no logs will be created.\n" "$device"
                fi
            else
                if [[ -n $log_dir ]]; then
                    printf "Device %s will be wiped with dd, and logged to %s.\n" "$device" "$log_dir"
                else
                    printf "Device %s will be wiped with dd, and no logs will be created.\n" "$device"
                fi
            fi
        done
        return 0
    fi

    if [[ -n $log_dir ]]; then
        mkdir -p $log_dir
        if [[ $? -ne 0 ]]; then
            printf "Failed to create log directory %s\n" "$log_dir"
            return 1
        fi
    fi

    for device in $filtered_devices; do
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