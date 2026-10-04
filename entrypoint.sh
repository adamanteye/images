#!/bin/sh
set -eu

if [ ! -s /etc/ssh/ssh_host_ed25519_key ]; then
	echo 'missing SSH host key: /etc/ssh/ssh_host_ed25519_key' >&2
	exit 1
fi

if [ ! -s /etc/ssh/authorized_keys/wine ]; then
	echo 'missing SSH authorized key: /etc/ssh/authorized_keys/wine' >&2
	exit 1
fi

if ! runuser -u wine -- mkdir -p /data/prefix /data/downloads; then
	echo 'The PVC at /data must be writable by UID/GID 1000.' >&2
	exit 1
fi

install -d -m 0700 -o wine -g wine /run/user/1000

exec /usr/sbin/sshd -D -e -f /etc/ssh/sshd_config
