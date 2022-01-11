#!/bin/bash

cd /root/shell/rclone

source rclone_mount.env

# if [ -z "$1" ]; then
#     echo "Using default config file for rclone-mount: $CONFIG_FILE"
# else
#     CONFIG_FILE=$1
#     echo "Using custom config file for rclone-mount: $CONFIG_FILE"
# fi

for mount_path in $((find $MOUNT_ROOT -maxdepth 1  | xargs ls -d $MOUNT_ROOT | grep $MOUNT_ROOT/$MOUNT_PREFIX) || exit 1)
do
    echo "Unmount $mount_path"
    (fusermount -uz "$mount_path") || exit 1
done


exit 0
