FROM archlinux:base
RUN pacman -Syu --noconfirm \
  bash bind ca-certificates \
  curl fish gdu git gnupg helix htop \
  iproute2 ripgrep iputils kubectl make nodejs \
  npm openbsd-netcat openssh chromium \
  rsync shadow sudo tcpdump devtools tmux tree \
  unzip wget zip openai-codex \
  typst less opencode \
  && cd /usr/local/bin && ln -s ../../bin/helix hx \
  && echo "root:alpine" | chpasswd \
  && echo 'PubkeyAuthentication yes' >>/etc/ssh/sshd_config \
  && echo 'PasswordAuthentication no' >>/etc/ssh/sshd_config \
  && echo 'PermitRootLogin yes' >>/etc/ssh/sshd_config \
  && echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >>/etc/sudoers \
  && rm -f /etc/ssh/ssh_host* \
  && pacman -Scc --noconfirm
COPY prepare.sh /root/prepare.sh
COPY entrypoint.sh /root/entrypoint.sh
USER root
EXPOSE 22
WORKDIR /root
CMD ["/root/entrypoint.sh"]
