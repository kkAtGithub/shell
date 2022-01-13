#!/bin/bash


cd /root/shell/rclone

(source /root/.config/rclone/rclone_mount.env) || exit 1

if [ -z "$1" ]; then
    echo "Using default config file for rclone-mount: $CONFIG_FILE"
else
    CONFIG_FILE=$1
    echo "Using custom config file for rclone-mount: $CONFIG_FILE"
fi

(chown "$MOUNT_USER":"$MOUNT_USER" "$CONFIG_FILE") || exit 1

for drive_name in $((cat "$CONFIG_FILE" | grep -o  '\[.*\]' | cut -d  '['  -f2 | cut -d  ']'  -f1) || exit 1)
do
    mount_name=$(echo "$drive_name" | cut -d '_' -f2)

    if [ ! -d "$MOUNT_ROOT/$MOUNT_PREFIX$mount_name" ]; then
        (mkdir "$MOUNT_ROOT/$MOUNT_PREFIX$mount_name") || exit 1
    fi

    (chown "$MOUNT_USER":"$MOUNT_USER" -R "$MOUNT_ROOT/$MOUNT_PREFIX$mount_name") || exit 1
    echo "Mount $drive_name to $MOUNT_ROOT/$MOUNT_PREFIX$mount_name by $MOUNT_USER"
    (runuser -l "$MOUNT_USER" -c "/usr/bin/rclone mount $drive_name:/ $MOUNT_ROOT/$MOUNT_PREFIX$mount_name $OTHER_OPTS --config $CONFIG_FILE --daemon &") || exit 1

done

exit 0
