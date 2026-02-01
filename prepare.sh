#!/bin/bash
set -e
cp /root/ssh_host_ed25519_key /etc/ssh/ssh_host_ed25519_key
chmod 600 /etc/ssh/ssh_host_ed25519_key
ssh-keygen -y -f /etc/ssh/ssh_host_ed25519_key \
	>/etc/ssh/ssh_host_ed25519_key.pub
echo "$PREDEFINED_USER" | grep -oE '[^:;]+:[^;]+' | while IFS= read -r line; do
	user="${line%%:*}"
	keys="${line#*:}"
	useradd -m -s /usr/bin/fish "$user"
	usermod -a -G wheel "$user"
	mkdir -p "/home/$user/.ssh"
	IFS=',' read -ra keyarr <<<"$keys"
	for k in "${keyarr[@]}"; do
		echo "$k" >>"/home/$user/.ssh/authorized_keys"
	done
	sort -u "/home/$user/.ssh/authorized_keys" \
		-o "/home/$user/.ssh/authorized_keys"
	chmod 700 "/home/$user/.ssh"
	chmod 600 "/home/$user/.ssh/authorized_keys"
	chown -R "$user:$user" "/home/$user/.ssh"
done
