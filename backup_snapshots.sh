#Filename: backup_snapshots.sh
#Author: Kyle McColgan
#Date: 28 February 2025
#Description: Script to transfer Snapper backup snapshots to a pre-specified local host.

#!/bin/bash

# Variables
SNAPSHOT_DIR="/.snapshots"
BACKUP_DIR="/mnt/samba_backups"  # Mount point for the Samba server.
SAMBA_SHARE="//192.168.1.94/Backups"
SAMBA_USER="kyle"

# Folders to back up
INCLUDE_FOLDERS=("Desktop" "Documents" "Downloads")

# Check if the Samba share is already mounted.
if ! mount | grep -q $BACKUP_DIR; then
    echo "Mounting Samba share..."
    sudo mount -t cifs $SAMBA_SHARE $BACKUP_DIR -o username=$SAMBA_USER
else
    echo "Samba share already mounted..."
fi

# Check if the Snapper snapshots directory exists.
if [ ! -d "$SNAPSHOT_DIR" ]; then
    echo "Snapshot directory $SNAPSHOT_DIR does not exist."
    exit 1
fi

# Rsync selected folders from the latest snapshot.
LATEST_SNAPSHOT=$(ls -d "$SNAPSHOT_DIR"/*/ | sort -V | tail -n 1)

if [ -z "$LATEST_SNAPSHOT" ]; then
    echo "[ERROR]: No snapshots found."
    exit 1
fi

echo "Using latest snapshot: $LATEST_SNAPSHOT"

# Ensure we use the correct user directory inside the snapshot...
USER_SNAPSHOT="$LATEST_SNAPSHOT/snapshot/kyle"

for folder in "${INCLUDE_FOLDERS[@]}"; do
    SOURCE="$USER_SNAPSHOT/$folder"
    DESTINATION="$BACKUP_DIR/$folder"

    if [ -d "$SOURCE" ]; then
        echo "Backing up $SOURCE to $DESTINATION..."
        sudo rsync -avz --one-file-system "$SOURCE/" "$DESTINATION/"
    else
        echo "Skipping $folder, directory not found in snapshot."
    fi
done

# Check if rsync was successful.
if [ $? -eq 0 ]; then
    echo "Backup completed successfully."
else
    echo "[ERROR]: Backup unsuccessful."
fi

# Unmount the Samba Share.
if mount | grep -q "$BACKUP_DIR"; then
    echo "Unmounting Samba share..."
    sudo umount "$BACKUP_DIR"
else
    echo "$BACKUP_DIR is not mounted."
fi
