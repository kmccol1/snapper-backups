#Filename: backup_snapshots.sh
#Author: Kyle McColgan
#Date: 17 February 2025
#Description: Script to sync snapshots between local hosts.

#!/bin/bash

# Variables
SNAPSHOT_DIR="/.snapshots"
BACKUP_DIR="/mnt/samba_backups"  # Mount point for Samba
SAMBA_SHARE="//192.168.1.94/Backups"
SAMBA_USER="kyle"

# Check if the Samba share is already mounted
if ! mount | grep -q $BACKUP_DIR; then
    echo "Mounting Samba share..."
    sudo mount -t cifs $SAMBA_SHARE $BACKUP_DIR -o username=$SAMBA_USER
else
    echo "Samba share already mounted."
fi

# Check if the Snapper snapshots directory exists
if [ ! -d "$SNAPSHOT_DIR" ]; then
    echo "Snapshot directory $SNAPSHOT_DIR does not exist."
    exit 1
fi

# Rsync Snapper Snapshots to Samba share
echo "Backing up Snapper snapshots to Samba share..."
sudo rsync -avz $SNAPSHOT_DIR $BACKUP_DIR

# Check if rsync was successful
if [ $? -eq 0 ]; then
    echo "Backup completed successfully."
else
    echo "Error: Backup failed."
fi

# Unmount Samba Share
if mount | grep -q "/mnt/samba_backups"; then
    echo "Unmounting Samba share..."
    sudo umount $BACKUP_DIR
else
    echo "/mnt/samba_backups is not mounted."
fi
