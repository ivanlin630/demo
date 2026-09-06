#!/usr/bin/env bash
# ★信箱歸檔【觸發器】—— SessionStart 掛這支，不是掛 handback-archive.sh 本體。
#
# ★★為什麼要多一層：本體要跑 1888 次 `git mv`，實測【超過 5 分鐘】。
#   ★把它直接掛 SessionStart ⇒ 開場被拖死 ⇒ ★★而那正是 911 封那次的死法
#     （SessionStart 掃描超時被殺 ⇒ 所有角色【靜默】失去角色 context）。
#   ⇒ 這支只做【數個數 + 判斷 + 丟到背景】，本身幾十毫秒。
#
# ★★★三個問題（blueprint 2026-09-06 要求寫進機制本體，因為上一次修完【沒人回答第三問】，
#    於是 326 → 修一次 → 911 → 修一次 → 1997）：
#
#   ①【誰觸發】＝ SessionStart（每個角色開場）。★不是「誰記得跑」——
#      上一版的答案是「人」，而人沒有跑，所以它從 2026-08-27 建好之後【一次都沒被觸發過】。
#   ②【多久跑】＝ 熱目錄 > THRESHOLD 且 距上次 > MIN_GAP_H 小時才跑。
#      ★不是每次開場都跑：六個角色開場會互相踩 index.lock。
#   ③★★★【怎麼驗證它有在跑】＝ 兩層，缺一層就會再靜默長回去：
#      (a) 本體每次跑完寫 .archive-last（時戳＋搬了幾封＋剩幾封）——【它有在跑】的正面證據
#      (b) ★merge gate `mailbox-size`：熱目錄超過硬上限就【紅】
#          ⇒ 觸發器若哪天靜默壞掉，症狀會【變成紅燈】而不是【信箱悄悄長到 2000】
#      ★(b) 才是真正的答案：(a) 只證明它跑過，(b) 在它【停下來】時會叫。
set -u
THRESHOLD=300
MIN_GAP_H=20
_gc=$(git rev-parse --git-common-dir 2>/dev/null) || exit 0
cd "$(cd "$(dirname "$_gc")" && pwd)" || exit 0
HB="docs/superpowers/handbacks"
[ -d "$HB" ] || exit 0
n=$(ls "$HB"/*.md 2>/dev/null | wc -l | tr -d ' ')
[ "${n:-0}" -le "$THRESHOLD" ] && exit 0
stamp=".claude/hooks/.archive-last"
if [ -f "$stamp" ]; then
  last=$(head -1 "$stamp" 2>/dev/null | awk '{print $1}')
  case "$last" in (*[!0-9]*|'') last=0 ;; esac
  [ $(( $(date +%s) - last )) -lt $(( MIN_GAP_H * 3600 )) ] && exit 0
fi
# 丟背景，不等它；★開場不因此變慢
nohup bash .claude/hooks/handback-archive.sh > .claude/hooks/.archive-run.log 2>&1 &
echo "[mailbox] 熱目錄 ${n} 封 > ${THRESHOLD} ⇒ 已在背景啟動歸檔（不擋開場）。驗證：.claude/hooks/.archive-last"
exit 0
