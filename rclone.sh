#!/bin/bash

if [ $# -eq 3 ]; then
    DRIVE_LIST=$(rclone config show | grep "\[.*\]" | sed 's/^.//' | sed 's/.$//' | xargs)
    SRC_PATH=$(echo "$2" | sed 's/ /\\ /g')
    DES_PATH=$(echo "$3" | sed 's/ /\\ /g')
    for drive in $DRIVE_LIST
    do
        rclone -P $1 "$SRC_PATH" "$drive":"$DES_PATH"
    done
fi
