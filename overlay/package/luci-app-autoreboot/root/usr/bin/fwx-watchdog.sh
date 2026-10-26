#!/bin/sh
# fanchmWrt network watchdog
# Monitors connectivity by pinging target hosts. After enough consecutive
# failures it optionally re-dials WAN, then reboots the router if still down.
# Runs as a procd instance managed by /etc/init.d/autoreboot.

uciget() {
	uci -q get "autoreboot.global.$1"
}

INTERVAL=$(uciget check_interval)
INTERVAL=${INTERVAL:-30}
case "$INTERVAL" in ''|*[!0-9]*) INTERVAL=30;; esac

THRESHOLD=$(uciget fail_threshold)
THRESHOLD=${THRESHOLD:-10}
case "$THRESHOLD" in ''|*[!0-9]*) THRESHOLD=10;; esac

HOSTS=$(uciget ping_hosts)
HOSTS=${HOSTS:-"223.5.5.5 119.29.29.29"}

RECOVER=$(uciget recover_enabled)
RECOVER=${RECOVER:-1}

RWAIT=$(uciget recover_wait)
RWAIT=${RWAIT:-60}
case "$RWAIT" in ''|*[!0-9]*) RWAIT=60;; esac

log() {
	logger -t fwx-watchdog "$*"
}

ping_any() {
	local h
	for h in $HOSTS; do
		if ping -c 1 -W 3 "$h" >/dev/null 2>&1; then
			return 0
		fi
	done
	return 1
}

log "watchdog started: interval=${INTERVAL}s threshold=${THRESHOLD} hosts=[$HOSTS] recover=${RECOVER}"

FAILS=0
RECOVERED_ATTEMPT=0

while :; do
	if ping_any; then
		if [ "$FAILS" -gt 0 ]; then
			log "network recovered after $FAILS failed checks"
			FAILS=0
			RECOVERED_ATTEMPT=0
		fi
	else
		FAILS=$((FAILS + 1))
		log "check failed ($FAILS/$THRESHOLD)"

		if [ "$FAILS" -ge "$THRESHOLD" ]; then
			if [ "$RECOVER" = "1" ] && [ "$RECOVERED_ATTEMPT" -eq 0 ]; then
				RECOVERED_ATTEMPT=1
				log "network down for $FAILS checks, trying to re-dial WAN interfaces"
				ifup wan 2>/dev/null
				ifup wan6 2>/dev/null
				sleep "$RWAIT"
				if ping_any; then
					log "network recovered after re-dial, no reboot needed"
					FAILS=0
					RECOVERED_ATTEMPT=0
					continue
				fi
				log "still no connectivity after re-dial"
			fi
			log "network down for too long, rebooting now"
			sleep 5
			reboot
		fi
	fi

	sleep "$INTERVAL"
done
