#!/usr/bin/env bash
# 出站 Telegram ping。
#   ASCII:  send.sh "message"
#   UTF-8:  send.sh --file /path/to/utf8.txt   (中文必走此,避開 Windows CP950)
# 機密讀自 config.local.sh(gitignored)。本地工具,不進 git(根 .gitignore tools/*)。
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/config.local.sh"
if [ -z "${TG_CHAT_ID:-}" ]; then
  echo "ERR: TG_CHAT_ID 空 — 先私訊 bot,再跑 fetch_chat_id.sh" >&2; exit 1
fi
API="https://api.telegram.org/bot${TG_TOKEN}/sendMessage"
# 判成功看 body 的 ok 欄，不只看 http code
if [ "${1:-}" = "--file" ]; then
  F="${2:?用法: send.sh --file <utf8檔>}"
  BODY="$(curl -s "$API" --data-urlencode "chat_id=${TG_CHAT_ID}" --data-urlencode "text@${F}")"
else
  MSG="${1:?用法: send.sh 訊息 或 --file 檔}"
  BODY="$(curl -s "$API" --data-urlencode "chat_id=${TG_CHAT_ID}" --data-urlencode "text=${MSG}")"
fi
if printf %s "$BODY" | grep -q '"ok":true'; then
  MID="$(printf %s "$BODY" | grep -o '"message_id":[0-9]*' | head -1 | cut -d: -f2)"
  echo "OK msg_id=${MID:-?}"
else
  echo "推送失敗: $BODY" >&2; exit 1
fi
