#!/bin/bash
#
#  A script to automate upgrading Splunk during competition.
#  Not super complicated. Much nicer than most of my other Splunk scripts. 
#
#  Most of this is AI generated with nudges and tweaks from me. It's solid and worked well in comp!
#
#  Samuel Brucker 2024-2025

SPLUNK_UPGRADE_LINK="https://download.splunk.com/products/splunk/releases/9.4.0/linux/splunk-9.4.0-6b4ebe426ca6.x86_64.rpm"

# Check if running as root/sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo privileges"
    exit 1
fi

# Set Splunk home path - adjust if your Splunk installation is elsewhere
SPLUNK_HOME=/opt/splunk

# Download latest Enterprise version (adjust URL based on your needs)
if ! wget -q --show-progress "$SPLUNK_UPGRADE_LINK" -O splunk-upgrade.rpm; then
    echo "Splunk's upgrade failed to download"
    exit 1
fi

# Stop Splunk first
echo "Stopping Splunk..."
"$SPLUNK_HOME/bin/splunk" stop

# Backup current installation
BACKUP_DIR="/tmp/splunk_backup_pre-update_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -rp "$SPLUNK_HOME/etc" "$BACKUP_DIR/"
cp -rp "$SPLUNK_HOME/var/log" "$BACKUP_DIR/"

if ! rpm -Uhv splunk-*.rpm; then
    echo "Upgrade installation failed"
    exit 1
fi

# Initialize upgrade
"$SPLUNK_HOME/bin/splunk" _internal restart

# Start Splunk
echo "Starting Splunk..."
"$SPLUNK_HOME/bin/splunk" start --accept-license --answer-yes

# Clean up downloaded package
rm -f splunk-*.rpm
