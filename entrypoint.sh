#!/bin/bash
set -euo pipefail
/root/prepare.sh
mkdir -p /run/sshd
/usr/sbin/sshd -D -e
