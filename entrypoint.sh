#!/bin/sh
set -eu

copy_postfix_config() {
	install -m 0644 /config/postfix/main.cf /etc/postfix/main.cf
	install -m 0644 /config/postfix/master.cf /etc/postfix/master.cf

	for name in virtual_mailbox_domains virtual_mailbox_maps virtual_aliases; do
		if [ -f "/config/postfix/${name}" ]; then
			install -m 0644 "/config/postfix/${name}" "/etc/postfix/${name}"
			postmap "/etc/postfix/${name}"
		fi
	done

	if [ -f /run/secrets/postfix/sasl_passwd ]; then
		install -m 0600 /run/secrets/postfix/sasl_passwd /etc/postfix/sasl_passwd
		postmap /etc/postfix/sasl_passwd
	fi
}

init_postfix_spool() {
	if [ ! -d /var/spool/postfix/private ]; then
		tar -C /var/spool -xf /usr/share/mail-stack/postfix-spool.tar
	fi

	mkdir -p /var/spool/postfix/private
	postfix set-permissions >/dev/null 2>&1 || true
}

copy_dovecot_config() {
	install -m 0644 /config/dovecot/dovecot.conf /etc/dovecot/dovecot.conf
	mkdir -p /etc/dovecot/conf.d

	for file in /config/dovecot/[0-9][0-9]-*.conf; do
		[ -e "$file" ] || continue
		install -m 0644 "$file" "/etc/dovecot/conf.d/$(basename "$file")"
	done

	if [ -f /run/secrets/dovecot/users ]; then
		install -m 0600 /run/secrets/dovecot/users /etc/dovecot/users
	fi

	install -d -o vmail -g vmail -m 0750 /var/vmail
	mkdir -p /var/spool/postfix/private
}

case "${1:-}" in
	postfix)
		copy_postfix_config
		init_postfix_spool
		exec postfix start-fg
		;;
	dovecot)
		copy_dovecot_config
		exec dovecot -F
		;;
	*)
		echo "usage: mail-entrypoint postfix|dovecot" >&2
		exit 64
		;;
esac
