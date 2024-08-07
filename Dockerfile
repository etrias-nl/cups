FROM ubuntu:18.04

RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        cups printer-driver-cups-pdf hplip jq && \
    rm -rf /var/lib/apt/lists/*

COPY cupsd.conf cups-files.conf /etc/cups/
COPY docker-entrypoint.d /docker-entrypoint.d/
COPY ppd/*  /usr/share/ppd/

RUN cupsd -f & pid=$! && \
    while test ! -S /run/cups/cups.sock; do sleep 1; done && \
    lpadmin -p PDF -v cups-pdf:/ -m lsb/usr/cups-pdf/CUPS-PDF_opt.ppd -E && \
    while kill "$pid" 2>/dev/null; do sleep 1; done

COPY docker-entrypoint.sh /
RUN chmod +x docker-entrypoint.sh

EXPOSE 631
VOLUME ["/var/spool/cups-pdf/ANONYMOUS"]
ENTRYPOINT ["/docker-entrypoint.sh"]
