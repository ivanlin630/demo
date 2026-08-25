#!/usr/bin/env bash
# ★★★零產出偵測（2026-08-25 HOLD 批 #6，warn-only、永不阻擋）
#   ★我的唯讀診斷結論：現有三道防線【全都要求「已經有某種產出物存在」】——
#     implementer-cleanup 要有 [DONE] 信 / _promise_check 要有他寫的信 / watchdog COMMIT-NO-LETTER 看 main。
#   ★★沒有一道問：★★★「你這回合做了事，卻【什麼都沒送出去】嗎？」
#   ⇒ 本 hook 補那一格：本回合【有 commit】但【沒有新的 open 信】⇒ 提醒（不擋）。
#   ★注意：這條【偵測】只有在【送達層】也修好時才有意義——fire 給沒人聽等於沒 fire。
set -u
case "${SESSION_ROLE:-}" in ''|none) exit 0 ;; esac
IN=$(cat 2>/dev/null || echo '{}')
printf '%s' "$IN" | grep -q '"stop_hook_active":[[:space:]]*true' && exit 0
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 0
D=docs/superpowers/handbacks
[ -d "$D" ] || exit 0
# 近 20 分鐘：我有 commit 嗎？
c=$(git log --since="20 minutes ago" --author="$(git config user.name 2>/dev/null || echo .)" --oneline 2>/dev/null | wc -l | tr -d ' ')
[ "${c:-0}" -eq 0 ] && exit 0
# 近 20 分鐘：有沒有新的 status:open 信（任何寄件者）
o=$(find "$D" -maxdepth 1 -name '*.md' -mmin -20 2>/dev/null | while read -r f; do grep -q '^status: open' "$f" 2>/dev/null && echo x; done | wc -l | tr -d ' ')
[ "${o:-0}" -gt 0 ] && exit 0
echo "[zero-output] 🟡 近 20 分鐘有 ${c} 個 commit，但【沒有任何新的 status:open 信】"
echo "               ★做了事卻沒送出去 ＝ 下游不會被喚醒（Monitor 靠信，不靠 commit）。"
echo "               ★若這回合本來就不需要推下一站，忽略即可（warn-only，不阻擋）。"
exit 0
