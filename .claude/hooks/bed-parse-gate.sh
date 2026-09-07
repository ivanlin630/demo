#!/usr/bin/env bash
# ★★★床解析閘（2026-08-27 血證）：merge 解衝突時 qty_tap_bed.gd 留下孤兒縮排 ⇒ Parse Error，
#   而三道 merge-gate【全綠而且是正確地綠】—— 憲法閘/裸 tick 閘/headless 都不載入 debug 床。
#   ★★而那張床正是產出全部 S2/S3 數字的那一張。
#   ★★★所以這不是「再小心一點」能解的：要一道【會載入每一張床】的閘。
#
# ★偵測形狀：GDScript 端只負責 load 每一張床；★★Parse Error 由 Godot 吐 stderr，shell 端 grep。
#   （第一版用 load()==null 判 ⇒ 假綠：load 對 parse error 不回 null。★陽性對照抓到的。）
set -u
# ★★★2026-09-06:拿不到 git 時【不准靜默 exit 0】。
#   血證:detached 跑法的 bash 找不到 git(rc=127) ⇒ 這一行讓本閘 0 秒無輸出地 exit 0
#   ⇒ ★runner 判成 no-verdict(它幸好不只看 exit code)——★★但看 log 的人會讀成「這支紅了」
#   ⇒ ★★★而真相是【它根本沒有驗過任何東西】。守衛不准輸出「要被解讀的狀態」。
if ! _gc=$(git rev-parse --git-common-dir 2>/dev/null); then
  echo "[BED-PARSE-GATE] ★git 不可用 ⇒ 本閘【沒有判過】—— 這不是紅也不是綠,是工具缺件"
  echo "  ⇒ 多半是 detached/精簡 PATH 少了 mingw64\bin(互動 bash 的 git 在那裡)"
  exit 1
fi
WT="${1:-.}"
OUT=$(mktemp)
# ★★★2026-09-02：先重建 class 快取再驗床。
#   血證：A#14 新增 `class_name FullStateHash` 後，本閘印 "Identifier not declared" ——
#   ★看起來像【床壞了】，實際是【快取沒建】⇒ 若照報上游，會去撤掉一個正確的修法（工具騙人形態③）。
#   ⇒ 守衛不輸出「要被解讀的狀態」：自己把快取建掉，之後的紅【一定】是真的紅。
powershell -NoProfile -File ./tools/godot.ps1 --headless --path "$WT" --import > /dev/null 2>&1
powershell -NoProfile -File ./tools/godot.ps1 --headless --path "$WT" --script scripts/debug/bed_parse_gate.gd > "$OUT" 2>&1
if grep -qa "Parse Error\|Failed to load script" "$OUT"; then
  echo "[BED-PARSE-GATE] FAIL：有床載不起來 ⇒ ★這不是「沒有床」，是床壞了"
  grep -a "Parse Error\|Failed to load script" "$OUT" | head -6
  rm -f "$OUT"; exit 1
fi
grep -a "BED-PARSE-GATE" "$OUT" || echo "[BED-PARSE-GATE] ★沒有輸出 ⇒ 先查工具狀態，不要讀成通過"
rm -f "$OUT"
