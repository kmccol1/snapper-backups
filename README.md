
# Automated Snapper Backup System

This project automates the backup of Snapper snapshots from a Linux system to a Samba server, ensuring secure and efficient off-site backups. The backups are transferred via `rsync` to a local host running a Samba server.

## Prerequisites

Before using this backup system, ensure you have the following:

- **OpenSUSE Linux** (or similar Linux distributions)
- **Snapper** configured for snapshot management
- A **Samba server** (active on the local network)
- **rsync** installed on your OpenSUSE system
- **CIFS** utilities for mounting the Samba share

### Setup Steps

1. **Ensure Snapper is configured:**
   Make sure Snapper snapshots are set up and configured for your system. Snapper should be actively taking snapshots of the file systems you want to back up.

2. **Set up the Samba share:**
   On the Raspberry Pi, set up a Samba share that will act as the destination for your backups. This will involve configuring `/etc/samba/smb.conf` and ensuring the share is accessible from the host system.

3. **Create a mount point on your host system:**
   Create a directory to mount the Samba share:

   ```bash
   sudo mkdir /mnt/samba_backups
   ```

4. **Update the backup script with correct paths:**
   Ensure that the script (`backup_snapshots.sh`) has the correct paths for both the Snapper snapshot directory and the Samba share mount point.

   - Replace `/mnt/samba_backups` with the correct mount point for your Samba share.
   - Ensure that the Snapper snapshots are located in the correct directory (usually `/root/.snapshots` or `/home/your_username/.snapshots`).

5. **Automate with Cron (optional):**
   To schedule the backups to run automatically, use cron jobs. For example, to run the backup every day at midnight:

   ```bash
   sudo crontab -e
   ```

   Add the following line:

   ```bash
   0 0 * * * /path/to/backup_snapshots.sh
   ```

## Backup Script Overview

The backup script performs the following steps:

1. Mount the Samba share.
2. Use `rsync` to transfer Snapper snapshots to the Samba share.
3. Unmount the Samba share after the backup completes.

```bash
#!/bin/bash

# Variables
SNAPSHOT_DIR="/.snapshots"  # Modify this to the actual path of your Snapper snapshots
BACKUP_DIR="/mnt/samba_backups"  # Samba mount point
SAMBA_SHARE="//<samba_server_ip_or_hostname>/Backups"
SAMBA_USER="your_username"

# Mount Samba Share
sudo mount -t cifs $SAMBA_SHARE $BACKUP_DIR -o username=$SAMBA_USER

# Rsync Snapper Snapshots to Samba Share
sudo rsync -avz $SNAPSHOT_DIR $BACKUP_DIR

# Unmount Samba Share
if mount | grep -q "/mnt/samba_backups"; then
    sudo umount $BACKUP_DIR
else
    echo "/mnt/samba_backups is not mounted."
fi
```

### Troubleshooting

- **Mount Errors:** If you encounter issues mounting the Samba share, ensure the path and credentials are correct. Check the logs (`dmesg` or `/var/log/syslog`) for detailed error messages.
  
- **Permission Issues:** If you receive "Permission Denied" errors, ensure the snapshot directory is readable by the user running the script, or run the script with `sudo` to access the system-wide snapshot directories.

## Security Considerations

- **Credentials:** Ensure the credentials used for mounting the Samba share are stored securely. Consider using a credentials file instead of including your username and password directly in the script.

- **Encryption:** If sensitive data is being backed up, consider encrypting the backup directory or using encrypted file systems to protect your data.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
