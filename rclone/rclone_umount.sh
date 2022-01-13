#!/bin/bash


(source /root/.config/rclone/rclone_mount.env) || exit 1

for mount_path in $((find $MOUNT_ROOT -maxdepth 1  | xargs ls -d $MOUNT_ROOT | grep $MOUNT_ROOT/$MOUNT_PREFIX) || exit 1)
do
    echo "Unmount $mount_path"
    (fusermount -uz "$mount_path") || exit 1
done


exit 0
