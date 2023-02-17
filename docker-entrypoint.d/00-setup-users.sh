#!/bin/bash
set -eu

USERFILE="/config/users.conf"
TMPUSERFILE="/tmp/users.conf"

if [ -f "${USERFILE}" ]; then
  echo >&3 "Creating printing users"
  cp $USERFILE $TMPUSERFILE

  addgroup printing

  echo -e "\n" >> "$TMPUSERFILE"
  while IFS=: read -r username password
  do
    if [ -z "$username" ]; then
      echo >&3 "Username is empty, skipping"
    else
      echo >&3 "Adding user $username"
      useradd --no-create-home --no-user-group --groups printing --shell /usr/sbin/nologin "$username"
      echo "$username:$password" | chpasswd
    fi;
  done < "$TMPUSERFILE"

  rm "$TMPUSERFILE"

fi;
