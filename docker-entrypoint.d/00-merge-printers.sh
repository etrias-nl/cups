#!/bin/bash
set -eu

if /usr/bin/find "/config/printers/" -mindepth 1 -type f -print -quit 2>/dev/null | read v; then
  /usr/bin/find "/config/printers/" -mindepth 1 -maxdepth 1 -follow -type f -print | sort -V | while read -r f; do
    echo >&3 "Adding printers from file $f"
    cat "$f" >> /etc/cups/printers.conf
  done
else
  echo >&3 "$0: No printer config found at /config/printers/"
fi
