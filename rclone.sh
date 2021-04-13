#!/bin/bash

if [ $# -eq 3 ] || [ $# -eq 4 ]; then
    DRIVE_LIST=$(rclone config show | grep "\[.*\]" | sed 's/^.//' | sed 's/.$//' | xargs)
    SRC_PATH=$(echo "$2" | sed 's/ /\\ /g')
    DES_PATH=$(echo "$3" | sed 's/ /\\ /g')
    if [ $# -eq 4 ]; then
        DRIVE_LIST=$(cat $4 | grep "\[.*\]" | sed 's/^.//' | sed 's/.$//' | xargs)
        CONFIG_FILE="--config $4"
    fi
    for drive in $DRIVE_LIST
    do
        rclone -P $1 "$SRC_PATH" "$drive":"$DES_PATH" $CONFIG_FILE
    done
fi
