#!/bin/bash
set -euo pipefail
/root/prepare.sh
/usr/bin/sshd -D -e
