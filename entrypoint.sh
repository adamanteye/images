#!/bin/bash
set -euo pipefail

declare -a pids=()
stopping=0

start_service() {
	"$@" &
	pids+=("$!")
}

stop_services() {
	local pid

	if [ "$stopping" -eq 1 ]; then
		return
	fi

	stopping=1
	trap - EXIT INT TERM HUP QUIT

	for pid in "${pids[@]}"; do
		kill -TERM "$pid" 2>/dev/null || true
	done

	wait "${pids[@]}" 2>/dev/null || true
}

handle_signal() {
	stop_services
	exit 0
}

cleanup() {
	local status=$?

	stop_services
	exit "$status"
}

trap handle_signal INT TERM HUP QUIT
trap cleanup EXIT

start_service syslogd -n
/root/prepare.sh

mkdir -p /run/nginx
start_service spawn-fcgi -n -a 127.0.0.1 -p 9000 -u git -g git -F 1 -f /usr/bin/fcgiwrap

start_service /usr/sbin/sshd -D -e
start_service nginx -g 'daemon off;'

wait -n "${pids[@]}"
