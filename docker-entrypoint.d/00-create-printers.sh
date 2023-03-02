#!/bin/bash
set -eu

if /usr/bin/find "/config/printers/" -mindepth 1 -type f -print -quit 2>/dev/null | read v; then

  cupsd -f & pid=$! && while test ! -S /run/cups/cups.sock; do sleep 1; done

  /usr/bin/find "/config/printers/" -mindepth 1 -maxdepth 1 -follow -type f -print | sort -V | while read -r f; do
    echo >&3 "Adding printers from file $f"

    name=$(jq -r ".name" "$f")
    location=$(jq -r ".location" "$f")
    deviceUri=$(jq -r ".deviceUri" "$f")
    driver=$(jq -r ".driver" "$f")
    options=$(jq -r '.options | to_entries | map("-o \(.key)=\(.value|tostring)") | join(" ")' "$f")

    lpadmin -p "$name" -v "$deviceUri" -P $driver -E $options -L "$location"
  done

  while kill "$pid" 2>/dev/null; do sleep 1; done
else
  echo >&3 "$0: No printer config found at /config/printers/"
fi
