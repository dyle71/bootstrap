#!/bin/bash

set -e

if [ $# -ne 2 ]; then
    echo Update Veyon configuration with pupils of current lesson in current room
    echo
    echo $0 ipRange localTime
    echo       ipRange     the IPv4 range of the room like 172.25.44.0/24
    echo       localTime   local time when current lesson started like 08:00, 09:40
    exit 1
fi


IP_RANGE=$1
LOCAL_TIME=$2

if [[ -z "${VEYON_TOKEN}"  ]]; then
  echo "NO VEYON_TOKEN given"
  exit 1
fi

echo Fetching users in CSV format from backend
URL="https://ccc.intra.htl-villach.at/api/clients?ipv4Network=${IP_RANGE}&newerThan=${LOCAL_TIME}"
curl -fsSL --ssl-no-revoke -H "x-client-token: ${VEYON_TOKEN}" -H "Accept: text/csv" $URL -o /tmp/current-pupils.csv

echo Disabling clipboard synchronization
sudo veyon-cli config set Service/ClipboardSynchronizationDisabled true

echo Clearing all network objects in Veyon
sudo veyon-cli networkobjects clear

echo Adding default current classroom
sudo veyon-cli networkobjects add location CurrentClassroom

echo Adding users to current classroom
sudo veyon-cli networkobjects import /tmp/current-pupils.csv location CurrentClassroom format "%name%;%host%;%mac%"

setsid veyon-master >/dev/null 2>&1 &
