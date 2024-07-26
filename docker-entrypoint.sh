#!/bin/bash
set -eu

: ${CUPS_ADMIN_USERNAME:=admin}
: ${CUPS_ADMIN_PASSWORD:=password}
: ${CUPS_TLS_ENABLED:=0}
: ${CUPS_LOG_LEVEL:=warn}

: ${TLS_CERT:=/config/ssl/tls.crt}
: ${TLS_KEY:=/config/ssl/tls.key}

if [ -z "${ENTRYPOINT_QUIET_LOGS:-}" ]; then
    exec 3>&1
else
    exec 3>/dev/null
fi

if [[ -z $CUPS_ADMIN_PASSWORD ]]; then
    echo >&3 'Empty $CUPS_ADMIN_PASSWORD.'
    exit 1
fi

if ! id "$CUPS_ADMIN_USERNAME" >/dev/null 2>&1; then
    useradd -m -G lpadmin -s /usr/sbin/nologin "$CUPS_ADMIN_USERNAME"
    echo "$CUPS_ADMIN_USERNAME:$CUPS_ADMIN_PASSWORD" | chpasswd
fi

if (( $CUPS_TLS_ENABLED )); then
    echo >&3 'Enabeling SSL config'
    cat <<EOT >>  /etc/cups/cupsd.conf
DefaultEncryption Required
SSLListen *:443
EOT

    cat <<EOT >>  /etc/cups/cups-files.conf
CreateSelfSignedCerts no

EOT

    if [[ -d /config/ssl ]]; then
        echo >&3 'Copying SSL certs'
        mkdir -p /etc/cups/ssl
        cat /config/ssl/tls.crt >> /etc/cups/ssl/"$(hostname)".crt
        cat /config/ssl/tls.key >> /etc/cups/ssl/"$(hostname)".key
    fi
fi

sed -i /etc/cups/cupsd.conf -e "s|^LogLevel .*$|LogLevel $CUPS_LOG_LEVEL|"
chmod 1777 /var/spool/cups-pdf/ANONYMOUS

if /usr/bin/find "/docker-entrypoint.d/" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
    echo >&3 "$0: /docker-entrypoint.d/ is not empty, will attempt to perform configuration"

    echo >&3 "$0: Looking for shell scripts in /docker-entrypoint.d/"
    find "/docker-entrypoint.d/" -follow -type f -print | sort -V | while read -r f; do
        case "$f" in
            *.sh)
                if [ -x "$f" ]; then
                    echo >&3 "$0: Launching $f";
                    "$f"
                else
                    # warn on shell scripts without exec bit
                    echo >&3 "$0: Ignoring $f, not executable";
                fi
                ;;
            *) echo >&3 "$0: Ignoring $f";;
        esac
    done

    echo >&3 "$0: Configuration complete; ready for start up"
else
    echo >&3 "$0: No files found in /docker-entrypoint.d/, skipping configuration"
fi

if [[ ${1-} == /* ]]; then
    exec "$@"
fi

exec cupsd -f "$@"
