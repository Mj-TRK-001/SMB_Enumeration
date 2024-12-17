#!/bin/bash


#Check SMB Port
Check_SMB_Port(){
    nc -z -w3 "$1" 445 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "[!] Error SMB Port 445 is closed On $1. Exiting ..."
        exit 1
    else
        echo "[+] SMB Port is Open On $1 ..."
    fi
}
#Usage Check
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <Target_IP> <USERNAME> <PASSWORD>"
    exit 1
fi
#Variables
Target_IP=$1
USERNAME=$2
PASSWORD=$3

echo "Checking If SMB Port 445 is Open On $Target_IP ..."
Check_SMB_Port "$Target_IP"

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
