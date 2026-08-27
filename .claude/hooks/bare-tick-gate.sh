#!/usr/bin/env bash
# ★★★裸 tick 守衛（S1b 結案後才掛，與 constitution_gate 同級）。
#   ★它擋的是【新出現而沒人判過的】裸 tick 候選 —— 不是擋「有候選」。
#   ★★判準：跑掃描器 → 跑分類器 → `NEEDS_HUMAN` 必須為 0。
#     （已結案的 143 筆全部落在 b_defer / c_whitelist / d_not_time 三桶裡。）
#   ★★★為什麼判 NEEDS_HUMAN 而不是判總數：
#     總數會隨 code 長大而長大（新加一行 `Probe.bump_sample(..., 200)` 就 +1）——
#     ★用總數當閘 ＝ 每次都紅 ＝ 沒有閘。而「有沒有沒人判過的形狀」才是真的要擋的東西。
#   ★誠實限：掃描器是文字比對，看不到「tick 存進改名變數後再比裸值」（見清單輸出頭）。
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2
WT="${1:-.}"
OUT_C="docs/measurements/.bare-tick-gate-candidates.txt"
OUT_T="docs/measurements/.bare-tick-gate-triage.txt"
# ★★★崩潰不得變成綠燈（2026-08-27 血證）：
#   舊版把 stderr 丟 /dev/null、不看 exit code、也不看產物新不新
#   ⇒ triage 發生 Parse error 完全沒跑，而閘讀到【上一輪的舊檔】照樣印 PASS。
#   ★而那時候它印的母體是 142（舊的），而候選已經是 156 —— 兩個數字就在磁碟上對不起來。
STAMP=$(mktemp); : > "$STAMP"
SCAN_OUT="$OUT_C" powershell -NoProfile -File ./tools/godot.ps1 --headless --path "$WT" --script scripts/debug/bare_tick_scanner.gd > "$STAMP.scan" 2>&1
if grep -q "Parse Error\|Failed to load script" "$STAMP.scan"; then
  echo "[BARE-TICK-GATE] FAIL：掃描器自己掛了（Parse error / 載不起來）—— ★這不是「沒有候選」"
  grep -m3 "Parse Error\|Failed to load" "$STAMP.scan"; exit 1
fi
SCAN_IN="$OUT_C" TRIAGE_OUT="$OUT_T" powershell -NoProfile -File ./tools/godot.ps1 --headless --path "$WT" --script scripts/debug/bare_tick_triage.gd > "$STAMP.tri" 2>&1
if grep -q "Parse Error\|Failed to load script" "$STAMP.tri"; then
  echo "[BARE-TICK-GATE] FAIL：分類器自己掛了（Parse error / 載不起來）—— ★閘會讀到舊產物，那是假綠"
  grep -m3 "Parse Error\|Failed to load" "$STAMP.tri"; exit 1
fi
if [ ! "$WT/$OUT_T" -nt "$STAMP" ]; then
  echo "[BARE-TICK-GATE] FAIL：分類產物比本次執行還舊 ⇒ ★這一輪沒有真的重跑"
  exit 1
fi
if [ ! -f "$WT/$OUT_T" ]; then
  echo "[BARE-TICK-GATE] FAIL：分類器沒有產出 —— ★先查工具狀態（class 快取 / --import），不要先解讀成「沒有候選」"
  exit 1
fi
# ★★跨檔對帳（systems 2026-08-27 揭）：閘原本只問「候選集裡的都結案了嗎」，
#   ★它對【候選集本身完不完整】完全無知。這裡至少把【兩檔筆數】釘起來：
#   候選掉了一筆而分類沒少，或反過來，都是【有東西被靜默吐掉】。
C_ROWS=$(grep -vc '^#' "$WT/$OUT_C" 2>/dev/null || :); C_ROWS=${C_ROWS:-0}
T_ROWS=$(grep -vc '^#' "$WT/$OUT_T" 2>/dev/null || :); T_ROWS=${T_ROWS:-0}
if [ "$C_ROWS" -ne "$T_ROWS" ]; then
  echo "[BARE-TICK-GATE] FAIL：候選 $C_ROWS 筆但分類只有 $T_ROWS 筆 ⇒ ★有 $((C_ROWS - T_ROWS)) 筆被靜默吐掉"
  exit 1
fi
N=$(grep -c '^NEEDS_HUMAN' "$WT/$OUT_T" 2>/dev/null || :); N=${N:-0}
TOT=$(grep -vc '^#' "$WT/$OUT_T" 2>/dev/null || :); TOT=${TOT:-0}
if [ "$N" -gt 0 ]; then
  echo "[BARE-TICK-GATE] FAIL：$N 筆【沒人判過】的裸 tick 候選（母體 $TOT）"
  grep '^NEEDS_HUMAN' "$WT/$OUT_T" | head -20
  echo "★逐顆判成 (a)改／(b)延後／(c)白名單，理由寫進 code 註記，再把形狀加進 bare_tick_triage.gd 的規則表"
  exit 1
fi
echo "[BARE-TICK-GATE] PASS：母體 $TOT，全部已結案（NEEDS_HUMAN=0）"
