#!/bin/bash
set -euo pipefail

/root/prepare.sh

mkdir -p /run/sshd

exec /usr/sbin/sshd -D -e
