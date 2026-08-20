#!/usr/bin/env bash
# 抓 chat id:你私訊 bot 後跑此,印出 chat id 並寫回 config.local.sh
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/config.local.sh"
RESP="$(curl -s "https://api.telegram.org/bot${TG_TOKEN}/getUpdates")"
echo "$RESP"
CID="$(printf '%s' "$RESP" | grep -o '"chat":{"id":[0-9-]*' | head -1 | grep -o '[0-9-]*$')"
if [ -n "$CID" ]; then
  sed -i "s|^export TG_CHAT_ID=.*|export TG_CHAT_ID=\"${CID}\"|" "$DIR/config.local.sh"
  echo "== chat_id=${CID} 已寫回 config.local.sh =="
else
  echo "== 沒抓到 chat id — 確認已私訊 bot =="
fi
