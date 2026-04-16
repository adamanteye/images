#!/bin/bash
set -euo pipefail

syslogd -n &
/root/prepare.sh

mkdir -p /run/nginx
spawn-fcgi -a 127.0.0.1 -p 9000 -u git -g git -F 1 -f /usr/bin/fcgiwrap

/usr/sbin/sshd -D -e &
nginx -g 'daemon off;' &

wait -n
