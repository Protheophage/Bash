#!/bin/bash

AIC() {
    local DEST_LABEL="DestDir"
    local DEST_MOUNT="/mnt/destDrive"
    local IMAGE_DIR="$DEST_MOUNT/images"
    local USE_DC3DD=false
    local HASH=false

    # Parse arguments
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --dc3dd|-3) USE_DC3DD=true ;;
            --hash|-h) HASH=true ;;
            *) echo "Unknown parameter passed: $1"; return 1 ;;
        esac
        shift
    done

    # Find the destination drive by label
    DEST_DEVICE=$(blkid -L "$DEST_LABEL")

    # If the destination drive is not found, prompt the user for the destination path
    if [ -z "$DEST_DEVICE" ]; then
        read -p "Destination drive not found. Please enter the destination device (e.g., /dev/sdX1): " DEST_DEVICE
    fi

    # Mount the destination drive
    mkdir -p $DEST_MOUNT
    mount $DEST_DEVICE $DEST_MOUNT

    # Ensure the images directory exists
    mkdir -p $IMAGE_DIR

    # Get the boot drive
    BOOT_DRIVE=$(df / | tail -1 | awk '{print $1}' | sed 's/[0-9]*$//')

    # Find all drives except the boot drive and the destination drive
    DRIVES=$(lsblk -nd -o NAME | grep -v "$(basename $BOOT_DRIVE)" | grep -v "$(basename $DEST_DEVICE)")

    for DRIVE in $DRIVES; do
        SRC_DRIVE="/dev/$DRIVE"
        DEST_IMAGE="$IMAGE_DIR/$DRIVE.dd"
        LOG_FILE="$IMAGE_DIR/$DRIVE.log"

        if $USE_DC3DD; then
            if $HASH; then
                dc3dd if=$SRC_DRIVE hof=$DEST_IMAGE hash=sha256 log=$LOG_FILE hlog=$LOG_FILE
            else
                dc3dd if=$SRC_DRIVE of=$DEST_IMAGE
            fi
        else
            if $HASH; then
                dd if=$SRC_DRIVE of=$DEST_IMAGE bs=4M status=progress
                sha256sum $SRC_DRIVE > "$LOG_FILE"
                sha256sum $DEST_IMAGE >> "$LOG_FILE"
            else
                dd if=$SRC_DRIVE of=$DEST_IMAGE bs=4M status=progress
            fi
        fi
    done
}