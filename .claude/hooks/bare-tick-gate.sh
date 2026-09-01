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
if [ -f "$STAMP.scan" ] && grep -q "Parse Error\|Failed to load script" "$STAMP.scan"; then
  echo "[BARE-TICK-GATE] FAIL：掃描器自己掛了（Parse error / 載不起來）—— ★這不是「沒有候選」"
  grep -m3 "Parse Error\|Failed to load" "$STAMP.scan"; exit 1
fi
SCAN_IN="$OUT_C" TRIAGE_OUT="$OUT_T" powershell -NoProfile -File ./tools/godot.ps1 --headless --path "$WT" --script scripts/debug/bare_tick_triage.gd > "$STAMP.tri" 2>&1
if [ -f "$STAMP.tri" ] && grep -q "Parse Error\|Failed to load script" "$STAMP.tri"; then
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
# ★★★延後判決的到期檢查（deferred-judgement-expiry）：
#   `b_defer` 是唯一【自帶到期日】的判決（「延到 S2」），
#   ★而在這之前沒有任何東西在到期日檢查它 —— S2 merge 後兩條都還活著。
#   ⇒ 命中 0 = 它守的形狀不在了 ⇒ ★★讓人回來看【病好了】還是【regex 靜默失效】。
#
# ★★★誠實限（reviewer 找到的反例，寫在閘裡而不只寫在信裡）：
#   本檢查只看得見【碰運氣被治好】那一半。
#   「延到里程碑 X」型的判決，X 發生後若沒人主動去改那個物件，
#   物件會原封不動留著 ⇒ 命中數依然 > 0 ⇒ ★本閘照樣綠。
#   ⇒ ★★【被彻底遺忘】那一半仍然不可見 —— 而那才是本來要防的。
# ★§1 與 §2 【兩檢都跑完再退】—— ★★不要抓到第一個就 exit：
#   那會變成【修一個、再跑、再冒出下一個】，而人會以為只剩一個問題。
DEFER_BAD=0
DEFER0=$(grep -E '^# RULEHIT\|b_defer\|0\|' "$WT/$OUT_T" 2>/dev/null || :)
if [ -n "$DEFER0" ]; then
  echo "[BARE-TICK-GATE] FAIL：有 b_defer 規則命中數 = 0 ⇒ ★延後判決已到期而沒人回來看"
  echo "$DEFER0" | sed 's/^# RULEHIT|/  /'
  echo "★處置：人回來判它是【病好了、規則該退場】還是【regex 靜默失效、規則該修】"
  echo "★★退場票的硬條款：必附【目標常數現況的 file:line】—— 0 命中有兩種讀法"
  DEFER_BAD=1
fi
# ★逐規則命中數合計 + NEEDS_HUMAN == 母體（不平 = 有東西被靜默吐掉）
RHS=$(grep '^# RULEHITSUM|' "$WT/$OUT_T" 2>/dev/null || :)
case "$RHS" in
  *"|MISMATCH") echo "[BARE-TICK-GATE] FAIL：逐規則命中數對帳不平 → $RHS"; exit 1 ;;
esac
# ★★★§2 延後到期：token 已落地 ⇒ FAIL（§1 抓【對象消失】，§2 抓【milestone 已過】）
#   ★兩檢並存不是替代：reviewer 的反例（對象還在、理由已過期）由 §2 覆蓋一部分。
#   ★★而【缺 token 也要紅】：否則「不寫 token」就成了繞過閘的方法。
LANDED="$WT/docs/process/landed-slices.tsv"
if [ ! -f "$LANDED" ]; then
  echo "[BARE-TICK-GATE] FAIL：找不到已落地清單 $LANDED ⇒ §2 無法判（★不静默放行）"
  exit 1
fi
while IFS='|' read -r _h _d HITS TOK SRC; do
  [ "$_d" = "b_defer" ] || continue
  if [ "$TOK" = "MISSING" ]; then
    echo "[BARE-TICK-GATE] FAIL：b_defer 規則【沒寫 defer_until token】⇒ $SRC"
    echo "  ★缺 token 也算紅：否則「不寫」就成了繞過到期檢查的方法"
    DEFER_BAD=1
  elif grep -qE "^${TOK}\s" "$LANDED"; then
    echo "[BARE-TICK-GATE] FAIL：b_defer 的 defer_until: $TOK 【已落地】而規則還在 ⇒ $SRC"
    echo "  ★處置：回來判它【病好了⇒退場】還是【理由仍成立⇒改 token】"
    DEFER_BAD=1
  fi
done < <(grep -E '^# RULEHIT\|' "$WT/$OUT_T" 2>/dev/null | sed 's/^# //')
[ "$DEFER_BAD" -eq 1 ] && exit 1
# ★★★母體空的情況要【明印】，不要長得像一個通過的檢查：
#   退場兩條死規則之後，b_defer 規則數 = 0
#   ⇒ ★§1（命中 0）與 §2（token 到期）【沒有東西可檢】。
#   ★★而那個綠的意思是「沒有東西可檢」，不是「檢過了沒問題」。
#   ★★★不列 FAIL（0 條是合法狀態），但它必須自己講出來 ——
#     守衛不要輸出【需要被解讀的狀態】，要輸出【已處置的結果】。
DEFER_N=$(grep -cE '^# RULEHIT\|b_defer\|' "$WT/$OUT_T" 2>/dev/null || :); DEFER_N=${DEFER_N:-0}
if [ "$DEFER_N" -eq 0 ]; then
  echo "[BARE-TICK-GATE] 註記：b_defer 規則 0 條 ⇒ 延後到期兩檢【本輪無母體】（★不是通過）"
fi

# ★★★§3 零命中【全 bucket】註記（systems 裁定②，2026-09-01）：
#   ★動機（血證）：S6 §1 把 CAMP_BUILD_TICKS 改成 CAMP_BUILD_PERSON_HOURS
#     ⇒ 它退出本 triage 的 *TICK* 母體 ⇒ 守它的那條 c_whitelist 規則變成【零命中死規則】。
#   ★★而 §1 只看 b_defer ⇒ 這種死規則【靜默】—— 每一次改名都會製造一批。
#   ★★★為什麼是【註記】不是 FAIL：規則退場是正常演化，用 FAIL 會恆紅＝沒有閘
#     （同「總數當閘＝恆紅」那條）。要的是【看得見】，不是【擋下來】。
#   ★誠實限：本註記只證明「這條規則現在沒守到任何東西」，
#     ★★它分不出【病好了】與【regex 靜默失效】—— 那兩種讀法仍然要人判。
ZERO_ALL=$(grep -E '^# RULEHIT\|' "$WT/$OUT_T" 2>/dev/null   | awk -F'|' '$3 == 0' | grep -v '^# RULEHIT|b_defer|' || :)
if [ -n "$ZERO_ALL" ]; then
  ZN=$(printf '%s
' "$ZERO_ALL" | grep -c .)
  echo "[BARE-TICK-GATE] 註記：零命中規則 $ZN 條（★b_defer 以外；b_defer 由 §1 判 FAIL）"
  printf '%s
' "$ZERO_ALL" | sed 's/^# RULEHIT|/  /'
  echo "  ★意義＝這些規則現在【沒守到任何東西】；★★分不出「病好了」還是「regex 靜默失效」，要人判"
fi
echo "[BARE-TICK-GATE] PASS：母體 $TOT，全部已結案（NEEDS_HUMAN=0）"
