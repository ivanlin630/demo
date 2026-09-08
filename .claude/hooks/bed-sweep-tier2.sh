#!/usr/bin/env bash
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
MAX_AGE_DAYS=7          # ★頻率寫死在這裡，不靠人記得
LIST="docs/measurements/bed-sweep-list.txt"

# ── 三問之三：它停了誰知道 ────────────────────────────────
# ★超期告警【掛在 merge 閘上】——因為 merge 閘是【一定會跑】的東西。
#   排程可能死掉而沒有人發現；merge 不會。
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

cp "$TMP" "$BASELINE"
date +%s > "$STAMP"
echo "[tier2] 完成：$rows 支｜★綠→紅 $alerts 支｜baseline 已更新｜時間戳已蓋"
[ "$alerts" -gt 0 ] && exit 1
exit 0
