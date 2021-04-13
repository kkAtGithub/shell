#!/bin/bash

if [ $# -eq 3] || [ $# -eq 4 ]; then
    apt-get update && \
    apt-get install rclone -y
    DRIVE_LIST = $(rclone config show | grep "\[.*\]" | sed 's/^.//' | sed 's/.$//' | xargs)
    if [ $# -eq 4 ]; then
        DRIVE_LIST = $(cat $4 | grep "\[.*\]" | sed 's/^.//' | sed 's/.$//' | xargs)
        CONFIG_FILE = "--config $4"
    fi
    for drive in DRIVE_LIST
    do 
        rclone -P $1 "$2" "$drive":"$3" $CONFIG_FILE
    done
fi
