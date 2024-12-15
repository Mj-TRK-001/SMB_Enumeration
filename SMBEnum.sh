#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <Target_IP> <USERNAME> <PASSWORD>"
    exit 1
fi

Target_IP=$1
USERNAME=$2
PASSWORD=$3

echo "Starting SMB Enumeration On $Target_IP..."
echo "-------------------------------------------------"

# List Shares On The Target System
echo "Listing Available SMB Shares..."
SHARES=$(smbclient -L "//$Target_IP" -U "$USERNAME%$PASSWORD" 2>/dev/null | awk '/Disk|IPC/ {print $1}')

if [ -z "$SHARES" ]; then
    echo "NO SMB Shares were Found On $Target_IP"
else
    for SHARE in $SHARES; do
        echo "-------------------------------------------------"
        echo "Checking Share: $SHARE"
        smbclient "//$Target_IP/$SHARE" -U "$USERNAME%$PASSWORD" -c "ls" 2>/dev/null | grep -v "^session setup failed" || echo "Access Denied Or Share Is Empty."
    done
fi

echo "-----------------------"
echo "Enumeration Complete."
