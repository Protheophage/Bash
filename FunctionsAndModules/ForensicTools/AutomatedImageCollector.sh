#!/bin/bash
#WIP Still need to test and verify full function
AutomatedImageCollector() {
    local DEST_LABEL="DestDir"
    local DEST_MOUNT="/mnt/destDrive"
    local IMAGE_DIR="$DEST_MOUNT/images"
    local USE_DC3DD=false
    local HASH=false
    local WhatIf=false
    local logging=false
    local LOG_DIR="$DEST_MOUNT/logs"
    local DEST_DRIVE=""

    # Parse arguments
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --dc3dd|-3) USE_DC3DD=true ;;
            --hash|-h) HASH=true ;;
            --whatif|-w) WhatIf=true ;;
            --log|-l) logging=true ;;
            --destination|-d) shift; DEST_DRIVE=$1 ;;
            *) echo "Unknown parameter passed: $1"; return 1 ;;
        esac
        shift
    done

    # Find the destination drive by label or use the specified drive
    if [[ -n $DEST_DRIVE ]]; then
        DEST_DEVICE=$DEST_DRIVE
    else
        DEST_DEVICE=$(blkid -L "$DEST_LABEL")
    fi

    # If the destination drive is not found, prompt the user for the destination path
    if [ -z "$DEST_DEVICE" ]; then
        read -p "Destination drive not found. Please enter the destination device (e.g., /dev/sdX1): " DEST_DEVICE
    fi

    # Mount the destination drive
    mkdir -p $DEST_MOUNT
    mount $DEST_DEVICE $DEST_MOUNT

    # Ensure the images and log directories exists
    mkdir -p $IMAGE_DIR
    if $logging; then
    mkdir -p $LOG_DIR
    fi

    # Get the boot device
    local BOOT_DEVICE=$(df / | tail -1 | awk '{print $1}')
    local BASE_BOOT_DEVICE=$(echo $BOOT_DEVICE | sed 's/[0-9]*$//')

    # Get all devices and exclude the boot device and destination device
    local ALL_DEVICES=($(lsblk -nd -o NAME))
    local FILTERED_DEVICES=()
    local DEST_BASE_DEVICE=$(echo $DEST_DEVICE | sed 's/[0-9]*$//') # Get base device for DEST_DEVICE
    for DEVICE in "${ALL_DEVICES[@]}"; do
        if [[ "/dev/$DEVICE" != "$BOOT_DEVICE" && "/dev/$DEVICE" != "$BASE_BOOT_DEVICE"* && "/dev/$DEVICE" != "$DEST_BASE_DEVICE"* ]]; then
            FILTERED_DEVICES+=("/dev/$DEVICE")
        fi
    done

    if $WhatIf; then
        echo "WhatIf mode enabled"
        for DEVICE in "${FILTERED_DEVICES[@]}"; do
            echo "Device $DEVICE will be imaged to $IMAGE_DIR/$(basename $DEVICE).dd"
            if $USE_DC3DD; then
                # Handle dc3dd combinations
                if $logging && $HASH; then
                    echo "Using dc3dd with logging and hashing (sha256). Logs will be saved to $LOG_DIR."
                elif $logging; then
                    echo "Using dc3dd with logging. Logs will be saved to $LOG_DIR."
                elif $HASH; then
                    echo "Using dc3dd with hashing (sha256)."
                else
                    echo "Using dc3dd without logging or hashing."
                fi
            else
                # Handle dd combinations
                if $logging && $HASH; then
                    echo "Using dd with logging and hashing (sha256). Logs will be saved to $LOG_DIR."
                elif $logging; then
                    echo "Using dd with logging. Logs will be saved to $LOG_DIR."
                elif $HASH; then
                    echo "Using dd with hashing (sha256)."
                else
                    echo "Using dd without logging or hashing."
                fi
            fi
        done
        return 0
    fi

    if [[ -n $LOG_DIR ]]; then
        mkdir -p $LOG_DIR
        if [[ $? -ne 0 ]]; then
            echo "Failed to create log directory $LOG_DIR"
            return 1
        fi
    fi

    for DEVICE in "${FILTERED_DEVICES[@]}"; do
        local DEST_IMAGE="$IMAGE_DIR/$(basename $DEVICE).dd"
        local LOG_FILE="$LOG_DIR/$(basename $DEVICE).log"

        echo "Imaging device: $DEVICE"
        if $USE_DC3DD; then
            # Handle dc3dd combinations
            if $logging && $HASH; then
                dc3dd if=$DEVICE of=$DEST_IMAGE hash=sha256 log=$LOG_FILE
            elif $logging; then
                dc3dd if=$DEVICE of=$DEST_IMAGE log=$LOG_FILE
            elif $HASH; then
                dc3dd if=$DEVICE of=$DEST_IMAGE hash=sha256
            else
                dc3dd if=$DEVICE of=$DEST_IMAGE
            fi
        else
            # Handle dd combinations
            if $logging && $HASH; then
                dd if=$DEVICE of=$DEST_IMAGE bs=4M status=progress 2>&1 | tee -a $LOG_FILE
                sha256sum $DEVICE | tee -a $LOG_FILE
                sha256sum $DEST_IMAGE | tee -a $LOG_FILE
            elif $logging; then
                dd if=$DEVICE of=$DEST_IMAGE bs=4M status=progress 2>&1 | tee -a $LOG_FILE
            elif $HASH; then
                dd if=$DEVICE of=$DEST_IMAGE bs=4M status=progress
                sha256sum $DEVICE
                sha256sum $DEST_IMAGE
            else
                dd if=$DEVICE of=$DEST_IMAGE bs=4M status=progress
            fi
        fi
    done
}

#Leave next line commented to make script just declare the function. Uncomment to make script execute the function
#AutomatedImageCollector "$@"