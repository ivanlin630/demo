#!/usr/bin/env bash
# ★考程樹凍結閘（blueprint 明令 2026-09-04；systems 實作）
#   規則：用戶 GO 落地起 → 該方案的卷跑完，main【禁 merge 任何改世界的東西】。
#   ★判準＝「會不會改 argmax／世界演化」⇒ 機械化成【路徑集合】：production sim code ＋ config ＋ data。
#   ★★儀器／doc／handback 照常（它們不改世界）。
#   ★★★而凍結【不是永久】：C 方案分段 ⇒ 兩段各自凍結，段間可解凍（解凍＝刪掉那個檔）。
set -uo pipefail
FREEZE=docs/process/.exam-freeze
# ★世界路徑集合（★改這裡＝改凍結範圍，而它是這支閘唯一的判準來源）
WORLD_RE='^(scripts/simulation/|scripts/data/|config/)'

if [ ! -f "$FREEZE" ]; then
  echo "[EXAM-FREEZE] 無凍結窗（$FREEZE 不存在）⇒ 不擋"
  echo "[EXAM-FREEZE] ★誠實限：本閘只在【凍結檔存在時】有鑑別力 —— 沒有凍結窗時它【什麼都沒驗】"
  echo "[EXAM-FREEZE] PASS"
  exit 0
fi

echo "[EXAM-FREEZE] ★凍結中：$(head -3 "$FREEZE" | tr '\n' ' ')"
BASE=$(git merge-base origin/main HEAD 2>/dev/null || echo "")
if [ -z "$BASE" ]; then
  echo "[EXAM-FREEZE] ★★無法取得 origin/main（fetch 失敗？）⇒ 保守判 FAIL（★不猜）"
  echo "[EXAM-FREEZE] FAIL"; exit 1
fi
CHANGED=$(git diff --name-only "$BASE"..HEAD 2>/dev/null | grep -E "$WORLD_RE" || true)
N=$(printf '%s' "$CHANGED" | grep -c . || true)
echo "[EXAM-FREEZE] 待推出的世界路徑改動＝${N}"
if [ "$N" -gt 0 ]; then
  printf '%s\n' "$CHANGED" | sed 's/^/   ★/'
  echo "[EXAM-FREEZE] ★★★FAIL：凍結窗內不得 merge 改世界的東西（考到一半換 code ⇒ 張與張之間不可比）"
  echo "[EXAM-FREEZE] ⇒ 解法：等該段卷跑完 → 刪除 $FREEZE（解凍）→ 再 merge；或確認這改動【真的不改世界】並縮小 WORLD_RE"
  echo "[EXAM-FREEZE] FAIL"; exit 1
fi
echo "[EXAM-FREEZE] ✓ 待推內容【不含】世界路徑（儀器／doc／handback 照常）"
echo "[EXAM-FREEZE] PASS"
