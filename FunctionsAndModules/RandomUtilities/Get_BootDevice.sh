#!/bin/bash

# Function to get non-boot devices
get-BootDevice() {
    # Get the boot device
    local boot_device=$(df / | tail -1 | awk '{print $1}')

    # Extract the base device name (e.g., /dev/sda from /dev/sda1)
    local base_boot_device=$(echo $boot_device | sed 's/[0-9]*$//')

    # Return the filtered devices
    echo $base_boot_device
}

#Leave next line commented to make script just declare the function. Uncomment to make script execute the function
#get-BootDevice "$@"