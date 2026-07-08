#!/bin/sh
set -eu

copy_postfix_config() {
	install -m 0644 /config/postfix/main.cf /etc/postfix/main.cf
	install -m 0644 /config/postfix/master.cf /etc/postfix/master.cf

	for name in virtual transport; do
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
		tar -C /var/spool -xf /usr/share/mlmmj-stack/postfix-spool.tar
	fi

	mkdir -p /var/spool/postfix/private
	postfix set-permissions >/dev/null 2>&1 || true
}

ensure_list() {
	list="$1"
	domain="$2"
	owner="$3"
	subscribers="$4"
	spool="/var/spool/mlmmj/${domain}"
	listdir="${spool}/${list}"
	answer="$(mktemp)"

	install -d -o mlmmj -g mlmmj -m 0750 "$spool"

	if [ ! -d "$listdir" ]; then
		cat >"$answer" <<EOF
SPOOLDIR='${spool}'
LISTNAME='${list}'
FQDN='${domain}'
OWNER='${owner}'
TEXTLANG='en'
ADDALIAS='n'
DO_CHOWN='y'
CHOWN='mlmmj'
ADDCRON='n'
EOF
		mlmmj-make-ml -f "$answer"
		rm -f "$answer"
	fi

	printf '%s\n' "$owner" >"${listdir}/control/owner"
	printf '%s@%s\n' "$list" "$domain" >"${listdir}/control/listaddress"
	chown -R mlmmj:mlmmj "$listdir"

	if [ -n "$subscribers" ]; then
		old_ifs="$IFS"
		IFS=,
		for subscriber in $subscribers; do
			[ -n "$subscriber" ] || continue
			/usr/bin/mlmmj-sub -L "$listdir" -a "$subscriber" -f -q -s
		done
		IFS="$old_ifs"
	fi
}

init_lists() {
	install -d -o mlmmj -g mlmmj -m 0750 /var/spool/mlmmj
	install -d -o mlmmj -g mlmmj -m 0750 \
		/var/lib/public-inbox/maildir \
		/var/lib/public-inbox/maildir/cur \
		/var/lib/public-inbox/maildir/new \
		/var/lib/public-inbox/maildir/tmp

	if [ ! -f /config/mlmmj/lists ]; then
		return
	fi

	while IFS=: read -r list domain owner subscribers; do
		case "$list" in
			"" | \#*) continue ;;
		esac
		ensure_list "$list" "$domain" "$owner" "${subscribers:-}"
	done </config/mlmmj/lists
}

start_maintd_loop() {
	(
		while :; do
			for domain_dir in /var/spool/mlmmj/*; do
				[ -d "$domain_dir" ] || continue
				/usr/bin/mlmmj-maintd -F -d "$domain_dir" || true
			done
			sleep 7200
		done
	) &
}

case "${1:-postfix}" in
	postfix)
		copy_postfix_config
		init_postfix_spool
		init_lists
		start_maintd_loop
		exec postfix start-fg
		;;
	check)
		copy_postfix_config
		init_postfix_spool
		init_lists
		exec postfix check
		;;
	*)
		echo "usage: mlmmj-entrypoint postfix|check" >&2
		exit 64
		;;
esac
