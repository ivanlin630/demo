#!/usr/bin/env bash
# ★靜默吞寫 setter 閘：`set(_value): pass` 這種【賦值不會報錯、而且什麼都不做】的屬性。
#
# ★★為什麼要有：2026-09-07 血證 —— team_data.gd 有【五個】這種 setter，
#   而它們的用途是【讓舊的賦值站繼續編得過】＝ 遷移鷹架；
#   ★遷移完成之後【沒有人回來拆】⇒ 它變成永久的【靜默失敗產生器】：
#   ★★床裡寫 `team.population = 5` 不報錯，而 pop 就是 0
#   ⇒ ★★★於是那些床一直在量【另一個世界】，而卷面上看不出來。
#
# ★★★本閘擋的是【新出現的】，不是既有的：既有 5 個已掛 defers.tsv: scaffold-swallowing-setters
#   （blueprint 立「鷹架出生必掛拆除 token」，而那五個是那條規矩的第一個實例）。
#   ⇒ 基準線 = docs/process/swallow-setter-baseline.txt（★錨在【file+count】，不是 file:line）。
#   ★★錨行號的話，檔案一插註解基準線就對不上 ⇒ 假紅 —— 而假紅的代價跟假綠一樣大。
#   （★今天早上 `defer-phrase` 才因為錨行號造成過一次假紅，這裡不重蹈。）
set -u
if ! _gc=$(git rev-parse --git-common-dir 2>/dev/null); then
  echo "[SWALLOW-SETTER] ★git 不可用 ⇒ 本閘【沒有判過】（不是 PASS 也不是 FAIL）"; exit 1
fi
cd "$(cd "$(dirname "$_gc")" && pwd)" || exit 1
BASE="docs/process/swallow-setter-baseline.txt"
[ -f "$BASE" ] || { echo "[SWALLOW-SETTER] FAIL：基準線不存在 $BASE"; exit 1; }
NOW="$(mktemp)"; trap 'rm -f "$NOW"' EXIT
git grep -c 'set(_value):' -- scripts/ | LC_ALL=C sort > "$NOW"
NEW=$(comm -13 <(LC_ALL=C sort "$BASE") "$NOW")
GONE=$(comm -23 <(LC_ALL=C sort "$BASE") "$NOW")
if [ -n "$NEW" ]; then
  echo "[SWALLOW-SETTER] FAIL：靜默吞寫 setter 的【檔案或數量】變了 —"
  printf '%s\n' "$NEW" | sed 's/^/    /'
  echo "  ★這種 setter 讓【賦值不報錯而且什麼都不做】⇒ 呼叫端會靜默量到另一個世界"
  echo "  ⇒ ★★要嘛不要 setter（賦值變 parse error＝叫得出聲），要嘛 push_error 含【合法寫入路徑】"
  echo "  ★★★若這是刻意的遷移鷹架 ⇒ 往 docs/process/defers.tsv 掛【拆除 token】再更新基準線"
  exit 1
fi
[ -n "$GONE" ] && { echo "[SWALLOW-SETTER] ★基準線有而現況沒有（＝有人拆掉了，好事）："; printf '%s\n' "$GONE" | sed 's/^/    /'; echo "  ⇒ 請更新 $BASE"; }
echo "[SWALLOW-SETTER] PASS：無新增（基準線 $(wc -l < "$BASE" | tr -d ' ') 處）"
exit 0
