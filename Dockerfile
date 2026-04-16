FROM alpine:edge
RUN printf "%s\n" \
    "https://dl-cdn.alpinelinux.org/alpine/edge/main" \
    "https://dl-cdn.alpinelinux.org/alpine/edge/community" \
    > /etc/apk/repositories \
  && apk update \
  && apk add --no-cache \
    bash bind-tools ca-certificates cgit curl fcgiwrap fish git gnupg \
    gdu helix htop iproute2 iputils kubectl make netcat-openbsd nginx \
    openssh-server rsync rustup shadow spawn-fcgi sudo tcpdump tmux \
    tree unzip wget zip \
  && echo "root:alpine" | chpasswd \
  && echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config \
  && echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config \
  && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
  && echo '*.* /dev/stdout' > /etc/syslog.conf \
  && echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && rm -f /etc/ssh/ssh_host* \
  && rm -f /etc/nginx/http.d/default.conf
COPY prepare.sh /root/prepare.sh
COPY entrypoint.sh /root/entrypoint.sh
COPY cgitrc /etc/cgitrc
COPY cgit.conf /etc/nginx/http.d/cgit.conf
USER root
EXPOSE 22 80
WORKDIR /root
CMD ["/root/entrypoint.sh"]
