FROM debian:trixie-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN printf 'postfix postfix/main_mailer_type select No configuration\n' | debconf-set-selections \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    libsasl2-modules \
    mlmmj \
    postfix \
    tini \
  && useradd -r -d /var/spool/mlmmj -s /usr/sbin/nologin mlmmj \
  && mkdir -p /usr/share/mlmmj-stack \
  && tar -C /var/spool -cf /usr/share/mlmmj-stack/postfix-spool.tar postfix \
  && rm -rf /var/lib/apt/lists/*
COPY entrypoint.sh /usr/local/sbin/mlmmj-entrypoint
COPY maildir-deliver /usr/local/bin/maildir-deliver
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/sbin/mlmmj-entrypoint"]
CMD ["postfix"]
