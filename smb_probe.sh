#!/usr/bin/env bash
# /usr/lib/zabbix/externalscripts/smb_probe.sh
# Usage: smb_probe.sh "//IP-or-DNS/Share" "USER" "PASS" "SUBDIR"
set -euo pipefail

SHARE="${1:-${SMB_SHARE:-//HOST.IP/tmp}}"
USER="${2:-${SMB_USER:-WORKGROUP\\zbxprobe}}"
PASS="${3:-${SMB_PASS:-changeme}}"
SUBDIR="${4:-${SMB_SUBDIR:-zbxprobe}}"

TMPFILE="$(mktemp)"
BASENAME="zbx_probe_$(date +%s).txt"
trap 'rm -f "$TMPFILE"' EXIT
echo "probe $(date -Iseconds)" > "$TMPFILE"

# mkdir (ignora eroarea daca exista)
timeout 10 smbclient "$SHARE" -U "$USER%$PASS" -c "mkdir $SUBDIR" >/dev/null 2>&1 || true

# put / get / del
timeout 10 smbclient "$SHARE" -U "$USER%$PASS" -c "put $TMPFILE $SUBDIR/$BASENAME" >/dev/null 2>&1 || { echo 0; exit 0; }
timeout 10 smbclient "$SHARE" -U "$USER%$PASS" -c "get $SUBDIR/$BASENAME /dev/null" >/dev/null 2>&1 || { echo 0; exit 0; }
timeout 10 smbclient "$SHARE" -U "$USER%$PASS" -c "del $SUBDIR/$BASENAME" >/dev/null 2>&1 || { echo 0; exit 0; }

echo 1

