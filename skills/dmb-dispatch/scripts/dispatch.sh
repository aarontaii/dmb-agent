#!/usr/bin/env bash
# Idempotent WhatsApp dispatch for an approved DMB.
# usage: dispatch.sh --date YYYY-MM-DD --group MY|SG|HK
set -euo pipefail

STATE="${DMB_STATE:-$(cd "$(dirname "$0")/../../.." && pwd)/state}"
DELAY="${DMB_SEND_DELAY:-3}"
DATE=""; GROUP=""
while [[ $# -gt 0 ]]; do case "$1" in
  --date) DATE="$2"; shift 2;; --group) GROUP="$2"; shift 2;;
  *) echo "unknown arg $1" >&2; exit 2;; esac; done
[[ -n "$DATE" && -n "$GROUP" ]] || { echo "need --date and --group" >&2; exit 2; }

D="$STATE/drafts/$DATE"
DECISION="$D/decision.json"
RECEIPTS="$D/receipts.jsonl"

# 1. approval must exist and match the files we are about to send
python3 - "$DECISION" "$D" <<'PY'
import json,sys,hashlib,pathlib
dec=json.load(open(sys.argv[1])); d=pathlib.Path(sys.argv[2])
if dec.get("state")!="approved": sys.exit("FAIL: draft not approved")
h=hashlib.sha256(b"".join(sorted(
    p.read_bytes() for p in d.glob("final.*.txt")))).hexdigest()[:16]
if h!=dec.get("draft_hash"): sys.exit(f"FAIL: hash mismatch {h} != {dec.get('draft_hash')}")
PY

# 2. resolve target JID from skills.entries.dmb-dispatch.config.receiving in openclaw.json.
CONFIG_JSON="${DMB_CONFIG:-$HOME/.openclaw/openclaw.json}"
JID="$(python3 -c "
import json, sys
cfg = json.load(open(sys.argv[1]))
receiving = cfg.get('skills',{}).get('entries',{}).get('dmb-dispatch',{}).get('config',{}).get('receiving',{})
jid = receiving.get(sys.argv[2])
if not jid:
    sys.exit(f'unknown group {sys.argv[2]!r}; valid keys: {sorted(receiving)}')
print(jid)
" "$CONFIG_JSON" "$GROUP")" || { echo "$JID" >&2; exit 2; }

# 3. pre-flight: outbound WhatsApp needs an active listener, fail before sending anything
openclaw message send --channel whatsapp --target "$JID" --dry-run --message "preflight" >/dev/null

HASH=$(python3 -c "import json,sys;print(json.load(open('$DECISION'))['draft_hash'])")
send() { # $1 index, $2 file
  local idx="$1" file="$2"
  if [[ -f "$RECEIPTS" ]] && grep -q "\"$HASH\".*\"$GROUP\".*\"idx\": *$idx" "$RECEIPTS"; then
    echo "skip $GROUP/$idx (receipt exists)"; return 0
  fi
  openclaw message send --channel whatsapp --target "$JID" --message "$(cat "$D/$file")"
  printf '{"at":"%s","hash":"%s","group":"%s","idx":%s,"file":"%s"}\n' \
    "$(date -Iseconds)" "$HASH" "$GROUP" "$idx" "$file" >> "$RECEIPTS"
  sleep "$DELAY"
}

send 1 final.msg1.en.txt
send 2 final.msg1.cn.txt
send 3 final.msg2.en.txt
send 4 final.msg2.cn.txt
[[ -f "$D/final.part3.en.txt" ]] && send 5 final.part3.en.txt
echo "dispatched $GROUP for $DATE (hash $HASH)"
