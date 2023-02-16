#!/bin/bash
set -eu

CONFIGFILES=( "cupsd.conf" "cups-files.conf" )

for f in "${CONFIGFILES[@]}"
do
  if [ -f "/config/$f" ]; then
   echo >&3 "Merging config file $f"
   cat "/config/$f" >> "/etc/cups/$f"
  fi
done