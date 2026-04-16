#!/bin/bash
set -euo pipefail

ensure_user() {
	local user="$1"
	local shell="$2"
	local extra_group="${3:-}"

	if id -u "$user" >/dev/null 2>&1; then
		usermod -s "$shell" "$user"
	else
		useradd -m -s "$shell" "$user"
	fi

	if [ -n "$extra_group" ]; then
		usermod -a -G "$extra_group" "$user"
	fi

	# `useradd` creates a locked shadow entry on Alpine. Set a known
	# password so the account is unlocked; SSH password auth is still
	# disabled by sshd_config unless that is changed separately.
	printf '%s:%s\n' "$user" "alpine" | chpasswd
}

install_authorized_keys() {
	local user="$1"
	local keys="$2"
	local ssh_dir="/home/$user/.ssh"
	local authorized_keys="$ssh_dir/authorized_keys"

	install -d -m 700 -o "$user" -g "$user" "$ssh_dir"
	touch "$authorized_keys"
	chown "$user:$user" "$authorized_keys"
	chmod 600 "$authorized_keys"

	if [ -z "$keys" ]; then
		return
	fi

	IFS=',' read -ra keyarr <<<"$keys"
	for k in "${keyarr[@]}"; do
		[ -n "$k" ] && echo "$k" >>"$authorized_keys"
	done
	sort -u "$authorized_keys" -o "$authorized_keys"
}

cp /root/ssh_host_ed25519_key /etc/ssh/ssh_host_ed25519_key
chmod 600 /etc/ssh/ssh_host_ed25519_key
ssh-keygen -y -f /etc/ssh/ssh_host_ed25519_key \
	>/etc/ssh/ssh_host_ed25519_key.pub

ensure_user git /usr/bin/git-shell
install -d -m 755 -o git -g git /home/git/repositories

while IFS= read -r line; do
	user="${line%%:*}"
	keys="${line#*:}"

	if [ "$user" = "git" ]; then
		ensure_user "$user" /usr/bin/git-shell
	else
		ensure_user "$user" /usr/bin/fish wheel
	fi

	install_authorized_keys "$user" "$keys"
done < <(printf '%s\n' "${PREDEFINED_USER:-}" | grep -oE '[^:;]+:[^;]+' || true)
