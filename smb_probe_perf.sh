#!/usr/bin/env bash
# smb_probe_perf.sh — write/read perf probe (JSON). Unified interface: argv > env, no risky defaults.
# Usage:
#   smb_probe_perf.sh "//IP-or-DNS/Share" "USER" "PASS" "SUBDIR" SIZE_MB
# Env fallbacks (optional):
#   SMB_SHARE, SMB_USER, SMB_PASS, SMB_SUBDIR, SMB_SIZE_MB
set -euo pipefail

SHARE="${1:-${SMB_SHARE:-}}"
USER="${2:-${SMB_USER:-}}"
PASS="${3:-${SMB_PASS:-}}"
SUBDIR="${4:-${SMB_SUBDIR:-zbxprobe}}"
SIZE_MB="${5:-${SMB_SIZE_MB:-8}}"

WRITE_TO=20
READ_TO=20

ts_ms() { date +%s%3N 2>/dev/null || echo $(( $(date +%s) * 1000 )); }
safe() { tr -d '\r\n' | sed 's/\\"//g; s/"/\\"/g'; }
fail() { local msg="$1"; echo -n '{"ok":0,"err":"'"$(printf "%s" "$msg" | safe)"'"}'; exit 0; }

[ -n "$SHARE" ] || fail "Missing SHARE"
[ -n "$USER" ]  || fail "Missing USER"
[ -n "$PASS" ]  || fail "Missing PASS"

TMPDATA="$(mktemp)"
BASENAME="zbx_perf_$(date +%s)_${SIZE_MB}M.bin"
trap 'rm -f "$TMPDATA"' EXIT

if ! dd if=/dev/urandom of="$TMPDATA" bs=1M count="$SIZE_MB" status=none 2>/dev/null; then
  fail "Failed to generate ${SIZE_MB}MB payload"
fi

timeout 5 smbclient "$SHARE" -U "$USER%$PASS" -c "mkdir $SUBDIR" >/dev/null 2>&1 || true

t0=$(ts_ms)
timeout "$WRITE_TO" smbclient "$SHARE" -U "$USER%$PASS" -c "put $TMPDATA $SUBDIR/$BASENAME" >/dev/null 2>&1 || fail "SMB put failed"
t1=$(ts_ms)
write_ms=$(( t1 - t0 ))

timeout "$READ_TO" smbclient "$SHARE" -U "$USER%$PASS" -c "get $SUBDIR/$BASENAME /dev/null" >/dev/null 2>&1 || fail "SMB get failed"
t2=$(ts_ms)
read_ms=$(( t2 - t1 ))

timeout 5 smbclient "$SHARE" -U "$USER%$PASS" -c "del $SUBDIR/$BASENAME" >/dev/null 2>&1 || true

total_ms=$(( write_ms + read_ms ))
if [ "$total_ms" -gt 0 ]; then
  mb_s=$(awk -v s="$SIZE_MB" -v ms="$total_ms" 'BEGIN { printf "%.3f", s / (ms/1000.0) }')
else
  mb_s="0.000"
fi

echo -n '{"ok":1,"size_mb":'"$SIZE_MB"',"write_ms":'"$write_ms"',"read_ms":'"$read_ms"',"total_ms":'"$total_ms"',"mb_s":'"$mb_s"'}'

