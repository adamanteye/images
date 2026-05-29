FROM docker.io/library/almalinux:8-minimal
RUN microdnf install -y \
  autoconf automake binutils diffutils gcc gcc-c++ glibc-devel libtool make \
  openssh-clients openssh-server patch pkgconf-pkg-config shadow-utils sudo \
  && echo "root:alpine" | chpasswd \
  && echo 'PubkeyAuthentication yes' >>/etc/ssh/sshd_config \
  && echo 'PasswordAuthentication no' >>/etc/ssh/sshd_config \
  && echo 'PermitRootLogin yes' >>/etc/ssh/sshd_config \
  && echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >>/etc/sudoers \
  && rm -f /etc/ssh/ssh_host* \
  && microdnf clean all
COPY prepare.sh /root/prepare.sh
COPY entrypoint.sh /root/entrypoint.sh
USER root
EXPOSE 22
WORKDIR /root
CMD ["/root/entrypoint.sh"]
