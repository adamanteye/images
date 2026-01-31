FROM debian:trixie-slim

ARG DEBIAN_FRONTEND=noninteractive
ARG GENTOO_PREFIX_BOOTSTRAP_URL=https://gitweb.gentoo.org/repo/proj/prefix.git/plain/scripts/bootstrap-prefix.sh

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

ENV GENTOO_PREFIX_BOOTSTRAP_URL=${GENTOO_PREFIX_BOOTSTRAP_URL}

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    bash \
    ca-certificates \
    clang \
    curl \
    dnsutils \
    fish \
    g++ \
    gdu \
    git \
    gnupg \
    htop \
    iproute2 \
    iputils-ping \
    kubernetes-client \
    make \
    mold \
    netcat-openbsd \
    openssh-client \
    openssh-server \
    passwd \
    rsync \
    rustup \
    sudo \
    tcpdump \
    tmux \
    tree \
    unzip \
    wget \
    zip \
  && printf '%s\n' \
    '#!/bin/sh' \
    'set -eu' \
    'url="${GENTOO_PREFIX_BOOTSTRAP_URL:-https://gitweb.gentoo.org/repo/proj/prefix.git/plain/scripts/bootstrap-prefix.sh}"' \
    'tmp="$(mktemp)"' \
    'trap '\''rm -f "${tmp}"'\'' EXIT' \
    'wget -O "${tmp}" "${url}"' \
    'chmod 0755 "${tmp}"' \
    'exec "${tmp}" "$@"' \
    >/usr/local/bin/bootstrap-prefix.sh \
  && chmod 0755 /usr/local/bin/bootstrap-prefix.sh \
  && groupadd -f wheel \
  && echo "root:debian" | chpasswd \
  && install -d -m 0755 /run/sshd \
  && printf '%s\n' \
    'PubkeyAuthentication yes' \
    'PasswordAuthentication no' \
    'PermitRootLogin yes' \
    >>/etc/ssh/sshd_config \
  && echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >/etc/sudoers.d/wheel \
  && chmod 0440 /etc/sudoers.d/wheel \
  && rm -f /etc/ssh/ssh_host_* \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY prepare.sh /root/prepare.sh
COPY entrypoint.sh /root/entrypoint.sh

USER root
EXPOSE 22
WORKDIR /root
CMD ["/root/entrypoint.sh"]
