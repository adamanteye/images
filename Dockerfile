FROM archlinux:base
RUN pacman -Syu --noconfirm \
  base-devel bash bind ca-certificates clang curl fish gdu git gnupg helix htop \
  iproute2 iputils kubectl make mold nodejs npm openbsd-netcat openssh \
  rsync rust shadow sudo tcpdump devtools tmux tree unzip wget zip codex \
  && useradd --create-home build \
  && curl -fsSL 'https://aur.archlinux.org/cgit/aur.git/snapshot/paru.tar.gz' -o /tmp/paru.tar.gz \
  && tar -xzf /tmp/paru.tar.gz -C /tmp \
  && chown -R build:build /tmp/paru \
  && su build -c 'cd /tmp/paru && makepkg --noconfirm --needed --cleanbuild' \
  && pacman -U --noconfirm /tmp/paru/paru-*.pkg.tar.zst \
  && rm -rf /tmp/paru /tmp/paru.tar.gz /home/build \
  && userdel build \
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
