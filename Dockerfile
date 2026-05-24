FROM archlinux:base
RUN pacman -Syu --noconfirm \
  bash bind ca-certificates clang curl fish gdu git gnupg helix htop \
  iproute2 iputils kubectl make mold nodejs npm openbsd-netcat openssh \
  rsync rustup shadow sudo tcpdump devtools paru tmux tree unzip wget zip \
  && npm install -g @openai/codex \
  && npm cache clean --force \
  && echo "root:alpine" | chpasswd \
  && echo 'PubkeyAuthentication yes' >>/etc/ssh/sshd_config \
  && echo 'PasswordAuthentication no' >>/etc/ssh/sshd_config \
  && echo 'PermitRootLogin yes' >>/etc/ssh/sshd_config \
  && echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >>/etc/sudoers \
  && rm -f /etc/ssh/ssh_host* \
  && codex --version \
  && pacman -Scc --noconfirm
COPY prepare.sh /root/prepare.sh
COPY entrypoint.sh /root/entrypoint.sh
USER root
EXPOSE 22
WORKDIR /root
CMD ["/root/entrypoint.sh"]
