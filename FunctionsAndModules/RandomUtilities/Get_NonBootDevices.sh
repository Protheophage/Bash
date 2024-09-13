#!/bin/bash

# Function to get non-boot devices
get-NonBootDevices() {
    # Get the boot device
    local boot_device=$(df / | tail -1 | awk '{print $1}')

    # Extract the base device name (e.g., /dev/sda from /dev/sda1)
    local base_boot_device=$(echo $boot_device | sed 's/[0-9]*$//')

    # Get all devices
    local all_devices=($(lsblk -nd -o NAME))

    # Create an array excluding the boot device and its partitions
    local filtered_devices=()
    for device in "${all_devices[@]}"; do
        if [[ "/dev/$device" != "$boot_device" && "/dev/$device" != "$base_boot_device"* ]]; then
            filtered_devices+=("/dev/$device")
        fi
    done

    # Return the filtered devices
    echo "${filtered_devices[@]}"
}

#Leave next line commented to make script just declare the function. Uncomment to make script execute the function
#get-NonBootDevices "$@"