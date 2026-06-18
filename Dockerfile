FROM debian:trixie-slim

ENV BIRD_CONTROL_SOCKET=/host/run/bird/bird.ctl

RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    bird2 \
    ca-certificates \
    python3 \
    python3-maxminddb; \
  rm -rf /var/lib/apt/lists/*; \
  printf '%s\n' \
    '#!/bin/sh' \
    'set -eu' \
    'exec birdc -s "${BIRD_CONTROL_SOCKET:-/host/run/bird/bird.ctl}" "$@"' \
    > /usr/local/bin/birdc-host; \
  chmod +x /usr/local/bin/birdc-host

USER root
WORKDIR /root
CMD ["birdc-host"]
