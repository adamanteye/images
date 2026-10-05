#!/bin/sh
set -eu

if [ ! -s /root/ssh_host_ed25519_key ]; then
	echo 'missing SSH host key: /root/ssh_host_ed25519_key' >&2
	exit 1
fi

install -m 0600 -o root -g root /root/ssh_host_ed25519_key /etc/ssh/ssh_host_ed25519_key
ssh-keygen -y -f /etc/ssh/ssh_host_ed25519_key >/etc/ssh/ssh_host_ed25519_key.pub

if [ ! -s /etc/ssh/authorized_keys/wine ]; then
	echo 'missing SSH authorized key: /etc/ssh/authorized_keys/wine' >&2
	exit 1
fi

install -d -m 0700 -o wine -g wine /home/wine/.ssh
install -m 0600 -o wine -g wine /etc/ssh/authorized_keys/wine /home/wine/.ssh/authorized_keys

if ! runuser -u wine -- mkdir -p /data/prefix /data/downloads; then
	echo 'The PVC at /data must be writable by UID/GID 1000.' >&2
	exit 1
fi

install -d -m 0700 -o wine -g wine /run/user/1000
install -d -m 0755 -o root -g root /run/sshd

exec /usr/sbin/sshd -D -e -f /etc/ssh/sshd_config
