#!/usr/bin/env bash
# ★★★全掃【不要用 fire-and-forget 的背景跑】（implementer 提、systems 裁 2026-09-08）
#   血證兩次，而兩次都長在【沒有人在看著它的那條路徑】上：
#   ①背景跑 + TaskStop ⇒ ★只殺 shell、不殺子進程樹 ⇒ 殘屍 sweep 活了兩小時，
#     一直把 timeout 列寫進 .bed-sweep-inprogress.tsv，而發起者以為它停了。
#   ②背景跑的父 shell 死掉 ⇒ wrapper 自己的 stdout 成為【沒有讀者的管道】
#     ⇒ 它卡在吐輸出那一步（godot.ps1:302），而 godot 早就結束了。
#   ★★★而這條 2026-09-08 晚間被強化（implementer 實測）：不是「不要 fire-and-forget」，
#     是【任何可能超過前景窗口的跑法都會產生殘屍】——
#     超時就會被 harness 移到背景，而背景 task 被殺時【進程樹會留下】。
#     血證：15:05 移背景 → 16:39 harness 報 killed，而 pid 樹活了 94 分鐘、只產出 8 列。
#     ⇒ 每一段必須【小到保證在前景窗口內結束】，否則每次跑完【主動驗孤兒】。
#   ★★★分段要按【成本】不是按【支數】：實測 15 支床超過 450s，headless_test 一支就 186s。
#   ★★做法：【分段前景跑】——進度可見、不會產生孤兒、被打斷只損失一段。
#   ★★★而若真的要背景跑：結束後必須【逐 PID 驗進程真的不在了】，回傳碼不算。
# Tier2 全床定期掃描 —— ★只在【由綠轉紅】時吵人（blueprint 裁 2026-09-07）
#
# ★★★設計理由：把「哪些床值得接上」的 121 次【事前意圖判斷】
#   換成「什麼變了」的【零判斷事後訊號】。綠→綠不吵、紅→紅不吵（已知的紅不是新聞）、★綠→紅點名。
#   血證：2026-09-04「備戰」下架打紅 4 支床，★沒有人看見，三天後才被考古找到。
#
# 用法：bash .claude/hooks/bed-sweep-tier2.sh [--check-staleness]
#   （無參數）＝跑全掃 + 報 diff + 更新 baseline + 蓋 .sweep-last
#   --check-staleness ＝只檢查上次跑多久以前（給 merge 閘用，★不跑掃描）
set -u
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO" || exit 2
export LC_ALL=C

BASELINE="docs/measurements/bed-sweep-baseline.tsv"
STAMP=".claude/hooks/.sweep-last"
# ★★★systems 裁定 2026-09-08：tier2 【只准從 main 跑】。
#   舊行為：bed-triage-sweep.sh 自己 `cd` 到 git-common-dir 的父目錄（＝主 repo），
#   而 tier2 傳給它的是【相對路徑】⇒ 寫進主 repo、tier2 回頭數的卻是 worktree 那一份
#   ⇒ rows 恆為 0。★而更深的一層：從 worktree 跑實際量的是 main 的 code。
# ⇒ 【靜默改對象】換成【明確拒絕】。
MAIN_ROOT="$(cd "$(dirname "$(git rev-parse --git-common-dir)")" && pwd)"
IS_WORKTREE=0
[ "$(git rev-parse --absolute-git-dir)" != "$(cd "$(git rev-parse --git-common-dir)" && pwd)" ] && IS_WORKTREE=1
# ★戳一律看主 repo 那一份：否則每個 worktree 都有自己的戳，而掃描只有一份。
MAX_AGE_DAYS=7          # ★頻率寫死在這裡，不靠人記得
LIST="docs/measurements/bed-sweep-list.txt"

# ── 三問之三：它停了誰知道 ────────────────────────────────
# ★超期告警【掛在 merge 閘上】——因為 merge 閘是【一定會跑】的東西。
#   排程可能死掉而沒有人發現；merge 不會。
STAMP="$MAIN_ROOT/$STAMP"
BASELINE_ABS="$MAIN_ROOT/$BASELINE"

if [ "${1:-}" = "--check-staleness" ]; then
  if [ ! -f "$STAMP" ]; then
    echo "[tier2] ★從未跑過（找不到 $STAMP）"
    echo "[tier2]   ★★觸發方式（本閘就是觸發器——它擋著 merge 直到有人跑）："
    echo "[tier2]     bash .claude/hooks/bed-sweep-tier2.sh      # 約 15-25 分鐘，只在【由綠轉紅】時吵人"
    exit 1
  fi
  now=$(date +%s); last=$(cat "$STAMP" 2>/dev/null || echo 0)
  case "$last" in ''|*[!0-9]*) echo "[tier2] ★$STAMP 內容不是時間戳 ⇒ 視為未跑過"; exit 1;; esac
  age=$(( (now - last) / 86400 ))
  if [ "$age" -gt "$MAX_AGE_DAYS" ]; then
    echo "[tier2] ★★超期：上次全床掃描在 $age 天前（上限 $MAX_AGE_DAYS 天）"
    echo "[tier2]   ⇒ 這道閘的意義＝【掃描停了要有人知道】，不是掃描本身"
    echo "[tier2]   ★★★而它同時【就是觸發器】：merge 一定會發生，所以它一定會被跑到"
    echo "[tier2]     修法：bash .claude/hooks/bed-sweep-tier2.sh"
    exit 1
  fi
  echo "[TIER2-STALENESS] PASS 上次全床掃描 $age 天前（上限 $MAX_AGE_DAYS）"
  exit 0
fi

# ── 三問之一/之二：誰觸發＋多久跑 ──────────────────────
# ★★★systems 裁定 v2 2026-09-08：【標註】而不是【拒絕啟動】。
#   ★前一版我寫「有別的 Godot 在跑就 exit 5」，而它有兩個毛病：
#     ①六個 session 平行開，Godot 幾乎沒有真正閒下來的時刻
#       ⇒ 全掃【永遠跑不成】⇒ tier2 閘【永遠紅】―― 把恆空修成了反方向的恆滿。
#     ②它建在【瞬時取樣】上：全掃跑 15-25 分鐘，
#       別人在第 3 分鐘啟動 Godot，這個前置檢查根本不會知道。
#   ⇒ ★★改成逐床標註（見 bed-triage-sweep.sh）：判準是【該床跑的整段期間 run-log 有沒有 COLLISION 列】
#     ―― 單調紀錄，涵蓋【開始之後才來】，而瞬時取樣涵蓋不了。
_running=$(powershell -NoProfile -Command "(Get-Process godot* -ErrorAction SilentlyContinue | Measure-Object).Count" 2>/dev/null | tr -d "[:space:]")
case "$_running" in ""|*[!0-9]*) _running=0;; esac
[ "$_running" -gt 0 ] && echo "[tier2] ℹ 開始時有 $_running 個 Godot 在跑 ⇒ 受影響的床會被標 CONTENDED（不進 baseline）"
if [ "$IS_WORKTREE" = "1" ]; then
  echo "[tier2] ★拒絕：本掃描只准從【主 repo】跑（目前 cwd 是 worktree）"
  echo "[tier2]   理由：bed-triage-sweep.sh 會 cd 到 $MAIN_ROOT ⇒ 從這裡跑會【量到 main 的 code】而不自知，"
  echo "[tier2]   而且產出寫進主 repo、計數場在這裡 ⇒ rows 恆為 0。"
  echo "[tier2]   正確跑法：cd $MAIN_ROOT && bash .claude/hooks/bed-sweep-tier2.sh"
  exit 4
fi
[ -f "$LIST" ] || ls -1 scripts/debug/*_test.gd > "$LIST"
# ★★★進度可見（2026-09-07 血證）：原本寫在 mktemp ⇒ 外面【無法回答「它還在跑嗎」】
#   當天首跑 16 分鐘只掃完 1 支（殘留進程搶 Godot），而我是靠翻 /tmp 才發現的。
#   ⇒ 進度表寫在【固定可見路徑】，任何人 wc -l 就知道它活著、走到哪。
TMP="docs/measurements/.bed-sweep-inprogress.tsv"
: > "$TMP"
echo "[tier2] 全床掃描開始（$(grep -c . "$LIST") 支）"
PER_BED_TIMEOUT="${PER_BED_TIMEOUT:-600}" bash .claude/hooks/bed-triage-sweep.sh "$LIST" "$TMP" >/dev/null 2>&1
rc=$?
# ★★★ 2026-09-08 血證（implementer）：原本接了 || echo 0。
#   grep -c 沒中時【自己就會印 0】且 exit 1 ⇒ || echo 0 再印一個 0
#   ⇒ rows 實際是兩行的 0 ⇒ 跟字串 0 比對【為假】
#   ⇒ ★這個 ABORT 守衛在它【唯一存在的情境】下永遠不會 fire，
#     而後果是【掃了 0 支卻蓋了時間戳】⇒ tier2 閘變假綠。
#   ★★修法：不接 || echo 0，改成【非純數字也算 ABORT】――
#     母體壞掉跟母體為空是同一類處置，不是兩類。
rows=$(grep -c '^scripts/' "$TMP" 2>/dev/null)
case "$rows" in ''|*[!0-9]*) rows="NaN";; esac
if [ "$rc" != "0" ] || [ "$rows" = "0" ] || [ "$rows" = "NaN" ]; then
  echo "[tier2] ★ABORT：掃描沒有產出（rc=$rc rows=$rows）⇒ ★不更新 baseline、不蓋時間戳"
  echo "[tier2]   （★空結果不得被讀成「沒有變化」——那正是恆綠）"
  exit 3
fi

# ★★★退化守衛（2026-09-08 血證）：★我原本只防「沒有結果」（rows=0），
#   ★★而真正發生的是【全部都是同一種壞結果】——137/137 全 timeout，
#     腳本照樣接受、覆蓋 baseline、蓋戳記，超期閘還說 PASS。
#   ⇒ ★★★後果比空結果更糟：diff 機制被【毒化】——基準說「本來就是 timeout」，
#     於是下一輪真正的 green→red 【看不見】。
#   ⇒ 判準：非 green 佔比 > 60% ⇒ 視為【這一輪壞了】，不是【世界壞了】。
_bad=$(awk -F'\t' '/^scripts\//{n++; if($2!="green") b++} END{printf "%d %d", b+0, n+0}' "$TMP")
_b=${_bad% *}; _n=${_bad#* }
if [ "${_n:-0}" -gt 0 ]; then
  _pct=$(( _b * 100 / _n ))
  if [ "$_pct" -gt 60 ]; then
    echo "[tier2] ★ABORT：非 green 佔 ${_pct}%（$_b/$_n）⇒ ★這一輪【壞了】，不是世界壞了"
    echo "[tier2]   ★★不更新 baseline、不蓋戳記 —— 因為【全部同一種壞結果】會毒化 diff："
    echo "[tier2]   基準若寫成「本來就是 timeout」，下一輪真正的 green→red 就看不見了"
    echo "[tier2]   ⇒ 常見成因：Godot 爭用／wrapper 起不來 ⇒ 先查誰在跑，再重跑"
    exit 4
  fi
fi
# ── diff：只報【綠→紅】 ────────────────────────────────
alerts=0
if [ -f "$BASELINE" ]; then
  while IFS=$'\t' read -r bed v _rest; do
    case "$bed" in '#'*|'') continue;; esac
    old=$(awk -F'\t' -v b="$bed" '$1==b{print $2}' "$BASELINE" | head -1)
    [ -z "$old" ] && { echo "[tier2] ＋新床：$bed（$v）"; continue; }
    if [ "$old" = "green" ] && [ "$v" != "green" ]; then
      echo "[tier2] ★★由綠轉紅：$bed（$old → $v）"
      alerts=$((alerts+1))
    fi
  done < <(grep '^scripts/' "$TMP")
else
  echo "[tier2] 首次建立 baseline（本次不報 diff）"
fi

# ★★★systems 裁定② 2026-09-08：timeout / hang / crash【不得進 baseline】。
#   它們是 no-verdict,而 baseline 是【拿來比對的】——
#   ★把 no-verdict 寫進去,下一輪的「由綠轉紅」就會被一次沒判決的跑污染一整輪。
#   ★★而丟掉了多少要印出來:靜默過濾跟「本來就沒有」長得一樣。
_keep=$(awk -F"	" 'NR==1 || (($2=="green" || $2=="red") && $4 !~ /CONTENDED/)' "$TMP")
_kept=$(printf "%s" "$_keep" | grep -c "^scripts/")
_dropped=$(( rows - _kept ))
echo "[tier2] baseline 只收判決列:收 $_kept 支｜★丟 $_dropped 支 no-verdict(timeout/hang/crash) 或 CONTENDED"
if [ "$_kept" = "0" ]; then
  echo "[tier2] ★ABORT:一支判決都沒有 ⇒ 不更新 baseline、不蓋時間戳(全 no-verdict 不是結果)"
  exit 6
fi
printf "%s
" "$_keep" > "$BASELINE"
date +%s > "$STAMP"
echo "[tier2] 完成：$rows 支｜★綠→紅 $alerts 支｜baseline 已更新｜時間戳已蓋"
[ "$alerts" -gt 0 ] && exit 1
exit 0
