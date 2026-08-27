#!/usr/bin/env bash
# ★★★床解析閘（2026-08-27 血證）：merge 解衝突時 qty_tap_bed.gd 留下孤兒縮排 ⇒ Parse Error，
#   而三道 merge-gate【全綠而且是正確地綠】—— 憲法閘/裸 tick 閘/headless 都不載入 debug 床。
#   ★★而那張床正是產出全部 S2/S3 數字的那一張。
#   ★★★所以這不是「再小心一點」能解的：要一道【會載入每一張床】的閘。
#
# ★偵測形狀：GDScript 端只負責 load 每一張床；★★Parse Error 由 Godot 吐 stderr，shell 端 grep。
#   （第一版用 load()==null 判 ⇒ 假綠：load 對 parse error 不回 null。★陽性對照抓到的。）
set -u
_gc=$(git rev-parse --git-common-dir 2>/dev/null) || exit 0
WT="${1:-.}"
OUT=$(mktemp)
powershell -NoProfile -File ./tools/godot.ps1 --headless --path "$WT" --script scripts/debug/bed_parse_gate.gd > "$OUT" 2>&1
if grep -qa "Parse Error\|Failed to load script" "$OUT"; then
  echo "[BED-PARSE-GATE] FAIL：有床載不起來 ⇒ ★這不是「沒有床」，是床壞了"
  grep -a "Parse Error\|Failed to load script" "$OUT" | head -6
  rm -f "$OUT"; exit 1
fi
grep -a "BED-PARSE-GATE" "$OUT" || echo "[BED-PARSE-GATE] ★沒有輸出 ⇒ 先查工具狀態，不要讀成通過"
rm -f "$OUT"
