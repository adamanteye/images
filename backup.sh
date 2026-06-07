#!/bin/sh
set -eu

backup_dir="${BACKUP_DIR:-/backup}"
cert_dir="${ETCD_CERT_DIR:-/etc/kubernetes/pki/etcd}"
endpoint="${ETCD_ENDPOINT:-https://[::1]:2379}"
retention_days="${BACKUP_RETENTION_DAYS:-30}"

cacert="${ETCD_CACERT:-${cert_dir}/ca.crt}"
cert="${ETCD_CERT:-${cert_dir}/server.crt}"
key="${ETCD_KEY:-${cert_dir}/server.key}"

mkdir -p "${backup_dir}"

ts="$(date -u +%Y%m%dT%H%M%SZ)"
tmp="${backup_dir}/.etcd-${ts}.db.tmp"
snapshot="${backup_dir}/etcd-${ts}.db"

cleanup() {
  rm -f "${tmp}" "${tmp}.part"
}
trap cleanup INT TERM HUP EXIT

etcdctl \
  --endpoints="${endpoint}" \
  --cacert="${cacert}" \
  --cert="${cert}" \
  --key="${key}" \
  snapshot save "${tmp}"

etcdutl --write-out=table snapshot status "${tmp}"
mv "${tmp}" "${snapshot}"
chmod 0400 "${snapshot}"
printf '%s\n' "$(basename "${snapshot}")" > "${backup_dir}/latest"

trap - INT TERM HUP EXIT
find "${backup_dir}" -maxdepth 1 -type f -name 'etcd-*.db' -mtime "+${retention_days}" -delete
