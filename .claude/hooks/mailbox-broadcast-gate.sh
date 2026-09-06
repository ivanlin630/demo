#!/usr/bin/env bash
# ★廣播信閘：`to: all` 且【還開著】的信 ⇒ 紅。
#
# ★★為什麼:2026-09-06 血證,HALT 那封用 `to: all (systems/implementer/...)`,
#   而 inbox-watch 的比對式是 `^to:<我>` ⇒ ★它對【每一個角色】都不命中(連 systems 也是)
#   ⇒ ★★那封廣播【沒有喚醒任何人】—— 四個角色 HALT 期間沒有違規動作【純屬僥倖】。
#   （matcher 已修成認得 `to: all`,但那只是 defense in depth,不是這道閘的理由。）
#
# ★★★真正修不掉的是【第二個缺陷】:一封廣播只有【一個 status 欄位】
#   ⇒ 第一個 consume 它的角色,就讓其他所有人【再也收不到】(inbox-watch 要求 status: open)
#   ⇒ 而那已經發生過:measurer 說「主信已被別 session 標 consumed」
#   ⇒ 所以規矩是【一人一封】,而這道閘是那條規矩的機械面。
#
# ★閘只擋【還開著】的廣播(可行動:把它拆成一人一封);已 consumed 的歷史信不擋。
set -u
if ! _gc=$(git rev-parse --git-common-dir 2>/dev/null); then
  echo "[mailbox-broadcast] ★git 不可用 ⇒ 本閘【沒有判過】(不是 PASS 也不是 FAIL)"; exit 1
fi
cd "$(cd "$(dirname "$_gc")" && pwd)" || exit 1
HB="docs/superpowers/handbacks"
bad=$(grep -l '^to:[[:space:]]*all' "$HB"/*.md 2>/dev/null | while read -r f; do
        grep -q '^status:[[:space:]]*open' "$f" && echo "$f"; done)
if [ -n "$bad" ]; then
  echo "[mailbox-broadcast] FAIL：有【還開著的廣播信】——"
  printf '%s\n' "$bad" | sed 's/^/    /'
  echo "  ★廣播只有【一個 status 欄位】⇒ 第一個 consume 它的角色會讓其他人再也收不到"
  echo "  ⇒ ★★改成【一人一封】（收件人各一個檔），不要靠一封 to: all"
  echo "  ★★★血證 2026-09-06：HALT 那封 to: all 沒有喚醒任何人，四個角色沒違規是僥倖"
  exit 1
fi
echo "[mailbox-broadcast] PASS：沒有還開著的 to: all 廣播信"
exit 0
