FROM debian:trixie-slim

ARG APT_MIRROR=http://deb.debian.org

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=zh_CN.UTF-8 \
    WINEPREFIX=/data/prefix \
    WINEDEBUG=-all

RUN sed -i "s|http://deb.debian.org|${APT_MIRROR}|g" /etc/apt/sources.list.d/debian.sources \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        dbus-x11 \
        fonts-noto-cjk \
        fonts-wine \
        libgl1-mesa-dri:amd64 \
        libgl1-mesa-dri:i386 \
        locales \
        openssh-server \
        waypipe \
        wine \
        wine32:i386 \
        wine64 \
        x11-apps \
        xauth \
    && sed -i 's/^# *\(zh_CN.UTF-8 UTF-8\)/\1/' /etc/locale.gen \
    && locale-gen \
    && useradd --create-home --uid 1000 --shell /bin/bash wine \
    && passwd -d wine \
    && mkdir -p /etc/ssh/authorized_keys /run/sshd /data \
    && rm -f /etc/ssh/ssh_host_* \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libegl1:amd64 \
        libegl1:i386 \
        libgl1:amd64 \
        libgl1:i386 \
    && rm -rf /var/lib/apt/lists/*

COPY sshd_config /etc/ssh/sshd_config
COPY entrypoint.sh /usr/local/bin/wine-trade-entrypoint
RUN chmod 0755 /usr/local/bin/wine-trade-entrypoint

EXPOSE 2222
ENTRYPOINT ["/usr/local/bin/wine-trade-entrypoint"]
