FROM debian:trixie-slim
ARG PUBLIC_INBOX_RELEASE_URL=https://public-inbox.org/public-inbox.git/snapshot/public-inbox-2.1.0.tar.gz
WORKDIR /usr/src/public-inbox
# Mirrors the Debian dependency set from INSTALL/install/deps.perl
# for essential + optional features, plus the local build toolchain.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        perl \
        pkg-config \
        sqlite3 \
        xapian-tools \
        libbsd-resource-perl \
        libdbd-sqlite3-perl \
        libemail-address-xs-perl \
        libgit2-dev \
        libhighlight-perl \
        libinline-c-perl \
        liblinux-inotify2-perl \
        libmail-imapclient-perl \
        libnet-server-perl \
        libparse-recdescent-perl \
        libplack-middleware-reverseproxy-perl \
        libplack-perl \
        libsearch-xapian-perl \
        libtimedate-perl \
        liburi-perl \
        libxapian-dev; \
    curl -fsSL "${PUBLIC_INBOX_RELEASE_URL}" -o /tmp/public-inbox.tar.gz; \
    tar -xzf /tmp/public-inbox.tar.gz --strip-components=1 -C /usr/src/public-inbox; \
    rm /tmp/public-inbox.tar.gz; \
    perl Makefile.PL; \
    make -j"$(nproc)"; \
    make install; \
    test -x /usr/local/bin/public-inbox-httpd; \
    perl -MPublicInbox::Search -e 1; \
    rm -rf /usr/src/public-inbox /var/lib/apt/lists/*
WORKDIR /var/lib/public-inbox
