FROM debian:bookworm-slim
RUN env && apt-get update -y && \
  apt-get install --no-install-recommends \
  build-essential dh-make scdoc wget ca-certificates \
  debmake vim tree \
  -y && \
  apt-get upgrade -y && \
  useradd -m -s /usr/bin/bash debian && \
  echo "root:debian" | chpasswd
USER debian
WORKDIR /home/debian
