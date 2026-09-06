#!/usr/bin/env bash
# ★131 支【自稱 _test 而沒有任何閘讀它判決】的床 —— 分診掃描（blueprint 裁 2026-09-07）
#
# ★★裁定的理由不是「綠紅」：沒接電的紅今天不咬人。
#   ★★★真價值 = 這 131 支裡【可能有床在保護一個真 invariant，而它已經靜默紅了】= 無聲回歸，
#   而那種東西【只有掃才會現形】。
#
# ★紀律（blueprint 明訂）：
#   ①掃描中【禁修】—— 量測不修，紅的記下來就走
#   ②不佔 critical path：批 2 照跑，本掃描用機器空檔
#   ③per-bed timeout 封頂
#   ④產物 = 分診表（綠/紅/crash/timeout + 牆鐘秒）——它同時是之後「刪/接電/標手動」的底稿
#
# ★★而分類【必須先自檢】：若分類器抓不到一個【合成的紅】，整輪結果作廢 ——
#   否則「全綠」與「分類器瞎了」印出來一樣（今天踩過太多次）。
set -u
LIST="${1:?usage: bed-triage-sweep.sh <bed-list-file> <out-tsv>}"
OUT="${2:?}"
PER_BED_TIMEOUT="${PER_BED_TIMEOUT:-90}"
REPO="$(cd "$(dirname "$(git rev-parse --git-common-dir)")" && pwd)"
cd "$REPO" || exit 2

classify() {   # stdin = bed output; echo one of green/red/crash/no-output
  local t; t="$(cat)"
  if [ -z "${t//[[:space:]]/}" ]; then echo "no-output"; return; fi
  if printf '%s' "$t" | grep -qa 'Parse Error\|Failed to load script\|Could not find type\|not declared'; then echo "crash"; return; fi
  if printf '%s' "$t" | grep -qaE 'Assertion failed|SCRIPT ERROR|\[FAIL\]|(^|[[:space:]])FAIL[[:space:]]|HAS FAILURE|FAILS=[1-9]'; then echo "red"; return; fi
  echo "green"
}

# ★★★分類器自檢 —— ★★樣本【必須從真實床的輸出形狀採來】，不得自己照偵測器的形狀造
#   血證 2026-09-07：舊自檢用 'SCRIPT ERROR: Assertion failed: boom'（＝我的偵測器認得的形狀）
#   ⇒ 它永遠抓不到【偵測器不認得的紅】。實際漏掉 31/131 支用裸 `FAIL `（無方括號）的床，
#   ⇒ 那些床失敗時會被判 green（假綠）。★陽性對照要用真實樣本，不是合成樣本。
for _s in "SCRIPT ERROR: Assertion failed: boom" "  FAIL  agriculture yield mismatch" "=== HAS FAILURE（fail=2）===" "FAILS=3" "[FAIL] x"; do
  [ "$(printf '%s
' "$_s" | classify)" = "red" ] || {
    echo "[SWEEP] ★ABORT：分類器抓不到真實紅形狀：$_s ⇒ 本輪作廢（不得讀成任何結果）"; exit 3; }
done
for _s in "  PASS  ok" "=== ALL PASS（fail=0）===" "ok" "=== DONE === ALL PASS"; do
  [ "$(printf '%s
' "$_s" | classify)" = "green" ] || {
    echo "[SWEEP] ★ABORT：分類器把通過樣本判成非綠（過度匹配）：$_s ⇒ 本輪作廢"; exit 3; }
done
[ "$(printf '' | classify)" = "no-output" ] || {
  echo "[SWEEP] ★ABORT：分類器把空輸出判成有結果 ⇒ 本輪作廢"; exit 3; }
echo "[SWEEP] 分類器自檢通過（5 種真實紅形狀 + 4 種通過樣本不誤判 + 空輸出）"

if [ -f "$OUT" ]; then echo "[SWEEP] 續掃:$OUT 已有 $(( $(wc -l < "$OUT") - 1 )) 筆,跳過它們"
else printf 'bed	verdict	wall_s	note
' > "$OUT"; fi
n=0
while IFS= read -r bed; do
  [ -n "$bed" ] || continue
  if cut -f1 "$OUT" 2>/dev/null | grep -qxF "$bed"; then continue; fi   # ★已掃過就跳(續掃)
  n=$((n+1))
  t0=$SECONDS
  # ★★★2026-09-07 血證:只靠【內層工具的 timeout】不夠 ——
  #   第 34 支(game_sim_test.gd)卡了【59 分鐘】,而當時★沒有任何 Godot 在跑、
  #   ★★wrapper 的 powershell 也不在 ⇒ 子進程早就沒了,
  #   ★★★卡住的是 bash 的 `$(...)` 在等一個【沒有人關閉的管道】。
  #   ⇒ 通則:【不要依賴被呼叫者自己會準時回來】—— 封頂要設在【呼叫端】。
  o="$(timeout -k 5 "$((PER_BED_TIMEOUT + 30))" env GODOT_TIMEOUT="$PER_BED_TIMEOUT" powershell -NoProfile -File ./tools/godot.ps1 --headless --path "$REPO" --script "$bed" 2>&1)"
  outer_rc=$?
  dt=$((SECONDS-t0))
  if [ "$outer_rc" = "124" ] || [ "$outer_rc" = "137" ]; then v="hang"
  elif printf '%s' "$o" | grep -qa 'GODOT TIMEOUT'; then v="timeout"
  else v="$(printf '%s' "$o" | classify)"; fi
  note=""
  [ "$v" = "red" ] && note="$(printf '%s' "$o" | grep -am1 'Assertion failed\|\[FAIL\]' | tr '\t' ' ' | cut -c1-90)"
  printf '%s\t%s\t%s\t%s\n' "$bed" "$v" "$dt" "$note" >> "$OUT"
  echo "[SWEEP] $n $(basename "$bed") ⇒ $v (${dt}s)"
done < "$LIST"
echo "[SWEEP] === DONE === 共 $n 支｜表在 $OUT"
