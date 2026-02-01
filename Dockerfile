FROM alpine:edge
RUN printf "%s\n" \
    "https://dl-cdn.alpinelinux.org/alpine/edge/main" \
    "https://dl-cdn.alpinelinux.org/alpine/edge/community" \
    > /etc/apk/repositories \
  && apk update \
  && apk add --no-cache \
    bind-tools ca-certificates curl fish git gnupg htop sudo bash \
    iproute2 iputils kubectl make ncdu netcat-openbsd openssh-server \
    rsync rustup tcpdump tmux tree unzip helix wget zip shadow \
  && echo "root:alpine" | chpasswd \
  && echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config \
  && echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config \
  && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
  && echo '*.* /dev/stdout' > /etc/syslog.conf \
  && echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && rm -f /etc/ssh/ssh_host*
COPY prepare.sh /root/prepare.sh
COPY motd /etc/motd
USER root
EXPOSE 22
WORKDIR /root
CMD syslogd -n & \
  /root/prepare.sh && \
  /usr/sbin/sshd -D
