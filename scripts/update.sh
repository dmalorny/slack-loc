#!/bin/bash

ROOT=$HOME/Library/SlackLoc
source $ROOT/config.sh

LAST_SSID=$(cat $ROOT/last_ssid)
SSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}')
line=$(grep ^"$SSID" $ROOT/known_ssids)

if [[ $? -eq 0 ]]; then
  EMOJI=$(echo $line | cut -d ";" -f 2)
  TEXT=$(echo $line | cut -d ";" -f 3)
else
  EMOJI=$DEFAULT_EMOJI
  TEXT=$DEFAULT_STATUS
fi

if [ "$LAST_SSID" = "$SSID" ]
then
  echo "No update necessary".
  exit 0
fi

STATUS=$(echo "{\"status_text\":\"$TEXT\",\"status_emoji\":\"$EMOJI\"}" | $ROOT/urlencode.sh)
for i in "${TOKENS[@]}"
do
  curl -d "token=$i&profile=$STATUS" https://slack.com/api/users.profile.set
done
echo $SSID >$ROOT/last_ssid
