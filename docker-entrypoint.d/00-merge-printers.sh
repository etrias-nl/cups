#!/bin/bash
set -eu

if [[ -f /config/printers.conf ]]; then
  cat /config/printers.conf >> /etc/cups/printers.conf
fi