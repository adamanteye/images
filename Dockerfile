FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN printf 'postfix postfix/main_mailer_type select No configuration\n' | debconf-set-selections \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    dovecot-core \
    dovecot-imapd \
    dovecot-lmtpd \
    postfix \
    tini \
  && groupadd -g 5000 vmail \
  && useradd -u 5000 -g 5000 -d /var/vmail -s /usr/sbin/nologin vmail \
  && mkdir -p /usr/share/mail-stack \
  && tar -C /var/spool -cf /usr/share/mail-stack/postfix-spool.tar postfix \
  && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/sbin/mail-entrypoint

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/sbin/mail-entrypoint"]
