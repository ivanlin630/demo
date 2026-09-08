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
  # ★★★ 2026-09-08 血證（systems 揭）：【連載入都失敗卻判綠】。
  #   data_test.gd 是 `extends Node`，--script 載不起來，而它的錯誤訊息
  #   沒有任何 PASS/FAIL 標記 ⇒ 一路掉到函式最後那行預設 `green`。
  #   ★而它進了第一份 baseline（green 184s）―― 假綠差一步就被當成基準。
  #   ★★樣本取自用戶螢幕上那個對話框的原句（非我照偵測器形狀造）。
  if printf '%s' "$t" | grep -qa '無法載入腳本\|沒有繼承自\|Cannot load script\|does not inherit\|doesn.t inherit'; then echo "crash"; return; fi
  # ★硬紅：引擎級錯誤，任何情況都算紅
  if printf '%s' "$t" | grep -qaE 'Assertion failed|SCRIPT ERROR'; then echo "red"; return; fi
  # ★★優先讀【床自己的總結行】——它是權威自報，勝過在內文裡撈字串
  if printf '%s' "$t" | grep -qaE 'HAS FAILURE|FAILS=[1-9]'; then echo "red"; return; fi
  # ★★★放寬【完成標記】（systems 裁定 B 的第一步：先讓【認得出來】變多）。
  #   影子跑量出 fall-through 佔綠的 33%，而逐支查完發現：
  #     它們大多【有】完成標記，只是寫法不同 ―― 不是【沒有判決通道】。
  #   ★樣本全部取自真實的床（不是照偵測器形狀造）：
  #     belief_freshness_invariant_test.gd → [TEST-SUITE-COMPLETE]
  #     map_render_test.gd               → === ASSERTIONS PASSED ===
  #     encounter_sim_test.gd            → 全部通過
  if printf '%s' "$t" | grep -qaE 'ALL PASS|FAILS=0|fail=0|TEST-SUITE-COMPLETE|ASSERTIONS PASSED|全部通過'; then echo "green"; return; fi
  # ★★★沒有總結行才退回逐行掃，且【只認行首】的失敗標記
  #   血證 2026-09-07：不錨行首會把 `  PASS 對照:...=v1 FAIL 根` 判成紅（假紅）
  if printf '%s' "$t" | grep -qaE '^[[:space:]]*(\[FAIL\]|FAIL[[:space:]])'; then echo "red"; return; fi
  # ★★★這一行是【認不出來就算綠】―― 一個預設也是一個判決。
  #   data_test.gd 就是從這裡掉出去的（載入失敗 ⇒ green 184s）。
  #   systems 准了改成 no-verdict，★但要先【影子跑一輪】量出會翻幾支，
  #   否則把【假綠】換成【什麼都蓋不了】。
  #   ⇒ 先只記錄，不改行為（SWEEP_SHADOW 指一個檔就會收到名單）。
  [ -n "${SWEEP_SHADOW:-}" ] && printf '%s
' "${bed:-?}" >> "$SWEEP_SHADOW"
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
# ★★★血證樣本（2026-09-07）：PASS 訊息【內文】含 FAIL 字樣 —— 不錨行首就會判成假紅
for _s in "  PASS  ok" "=== ALL PASS（fail=0）===" "ok" "=== DONE === ALL PASS" "  PASS 對照:舊 fill 式 level 相消(old L1 2.00==L3 2.00=v1 FAIL 根)" "[bed] 這是說明:預期 FAIL 根已修"; do
  [ "$(printf '%s
' "$_s" | classify)" = "green" ] || {
    echo "[SWEEP] ★ABORT：分類器把通過樣本判成非綠（過度匹配）：$_s ⇒ 本輪作廢"; exit 3; }
done
[ "$(printf '' | classify)" = "no-output" ] || {
  echo "[SWEEP] ★ABORT：分類器把空輸出判成有結果 ⇒ 本輪作廢"; exit 3; }
echo "[SWEEP] 分類器自檢通過（5 種真實紅形狀 + 4 種通過樣本不誤判 + 空輸出）"

MAX_ATTEMPTS="${MAX_ATTEMPTS:-2}"
# ★★★systems 裁定 2026-09-08：timeout/hang/crash 【不算掃過】。
#   舊版的續掃判準是【這支床有沒有一列】，而不是【有沒有判決】
#   ⇒ 上一輪 137/137 全 timeout 的殘留檔會讓下一輪【全部跳過】，瞬間 rc=0 零新列。
# ★★而【重掃】不能無限：同一支累積 $MAX_ATTEMPTS 次無判決 ⇒ 標 timeout-persistent 停手，
#   ★★★而那個標記必須印出來 ―― 否則【不再重試】跟【掃過了】又長得一樣。
if [ -f "$OUT" ]; then
  _done=$(awk -F"	" '$2=="green"||$2=="red"{c++} END{print c+0}' "$OUT")
  _pend=$(awk -F"	" '$2=="timeout"||$2=="hang"||$2=="crash"{c++} END{print c+0}' "$OUT")
  echo "[SWEEP] 續掃:$OUT 已有判決 $_done 筆（跳過）｜無判決 $_pend 筆（★重掃，上限 $MAX_ATTEMPTS 次）"
else
  printf "bed	verdict	wall_s	note
" > "$OUT"
fi
n=0
while IFS= read -r bed; do
  [ -n "$bed" ] || continue
  _last=$(awk -F"	" -v b="$bed" '$1==b{v=$2} END{print v}' "$OUT")
  _tries=$(awk -F"	" -v b="$bed" '$1==b{c++} END{print c+0}' "$OUT")
  case "$_last" in
    green|red|timeout-persistent) continue;;
    "") ;;
    *)
      if [ "$_tries" -ge "$MAX_ATTEMPTS" ]; then
        printf "%s	%s	%s	%s
" "$bed" "timeout-persistent" 0 "attempts=$_tries last=$_last" >> "$OUT"
        echo "[SWEEP] ★$(basename "$bed") 連 $_tries 次無判決 ⇒ 標 timeout-persistent，停止重試"
        continue
      fi
      echo "[SWEEP] ↻ $(basename "$bed") 上次=$_last ⇒ 重掃（第 $((_tries+1)) 次）";;
  esac
  n=$((n+1))
  # ★★★ 2026-09-08 血證（用戶擞到彈框）：不繼承 SceneTree/MainLoop 的檔
  #   用 --script 跑時 Godot 會彈一個【阻斷式錯誤對話框】（連 --headless 也彈）
  #   ⇒ 進程卡在那裡等人按【確定】，一路燒到 GODOT_TIMEOUT。
  #   ★★而它彈在【用戶螢幕上】―― 掃描是背景工作，卻中斷了人。
  #   ⇒ ★★★看檔頭就能判，根本不要啟動 Godot；
  #     而判決寫成 not-a-bed（【可見】而不是靈默跳過）。
  if ! head -5 "$bed" 2>/dev/null | grep -q "^extends \(SceneTree\|MainLoop\)"; then
    printf "%s	%s	%s	%s
" "$bed" "not-a-bed" 0 "extends $(head -1 "$bed" | sed "s/^extends //") ⇒ --script 跑不了（會彈阻斷對話框）" >> "$OUT"
    echo "[SWEEP] ★$(basename "$bed") ⇒ not-a-bed（不啟動 Godot）"
    continue
  fi
  t0=$SECONDS
  _ts0=$(date +%Y-%m-%dT%H:%M:%S)
  # ★★★2026-09-07 血證:只靠【內層工具的 timeout】不夠 ——
  #   第 34 支(game_sim_test.gd)卡了【59 分鐘】,而當時★沒有任何 Godot 在跑、
  #   ★★wrapper 的 powershell 也不在 ⇒ 子進程早就沒了,
  #   ★★★卡住的是 bash 的 `$(...)` 在等一個【沒有人關閉的管道】。
  #   ⇒ 通則:【不要依賴被呼叫者自己會準時回來】—— 封頂要設在【呼叫端】。
  # ★★★systems 裁定 2026-09-08：拿掉 `$( )`，改導檔案。
  #   ★卡點實測：triage 的 `$( )` 那一層【沒有任何子進程】卻回不來――
  #     godot 與 powershell 都已結束，而 bash 還在等 EOF。
  #   ★★EOF 不來的唯一原因是【還有別的東西握著寫端】（孫進程繼承了 handle）
  #     ⇒ 外層 `timeout` 救不了它：它包的 powershell 已經死了。
  #   ⇒ ★★★把管道拿掉，就沒有 EOF 可等；檔案有確定的結尾。
  _of="$(mktemp)"
  timeout -k 5 "$((PER_BED_TIMEOUT + 30))" env GODOT_TIMEOUT="$PER_BED_TIMEOUT" powershell -NoProfile -File ./tools/godot.ps1 --headless --path "$REPO" --script "$bed" 2>&1 > "$_of" 2>&1
  outer_rc=$?
  o="$(cat "$_of")"
  rm -f "$_of"
  dt=$((SECONDS-t0))
  # ★★★systems 裁定 v2：逐床標註競爭。判準不是「開始時有沒有人在跑」（瞬時取樣）,
  #   而是「這支床跑的【整段期間】run-log 有沒有出現 COLLISION 列」――
  #   ★單調紀錄,涵蓋【開始之後才來】的情形。
  # ★★★ 2026-09-08 訂正：這個標記【只是標記】―― 它不再把列排出 baseline。
  #   它原本的根據是【競爭會讓判決變錯】,而那個因果已被撤回
  #   （真因是 godot.ps1 的 $tempOut null；帶 COLLISION 的對照跑三次都正常）。
  #   ⇒ ★★【裁定的壽命不得比它的根據長】―― 撤回一個因果時,
  #     要 grep 它在註解裡的引用並一併訂正（systems 2026-09-08 的機械修法）。
  _ts1=$(date +%Y-%m-%dT%H:%M:%S)
  _coll=$(awk -F"	" -v a="$_ts0" -v b="$_ts1" '$2 ~ /COLLISION/ && $1>=a && $1<=b' .claude/hooks/.godot-runs.log 2>/dev/null | wc -l | tr -d "[:space:]")
  case "$_coll" in ""|*[!0-9]*) _coll=0;; esac
  if [ "$outer_rc" = "124" ] || [ "$outer_rc" = "137" ]; then v="hang"
  elif printf '%s' "$o" | grep -qa 'GODOT TIMEOUT'; then v="timeout"
  else v="$(printf '%s' "$o" | classify)"; fi
  note=""
  [ "$v" = "red" ] && note="$(printf '%s' "$o" | grep -aE -m1 'Assertion failed|\[FAIL\]|(^|[[:space:]])FAIL[[:space:]]|HAS FAILURE|FAILS=[1-9]' | tr '\t' ' ' | cut -c1-90)"
  [ "$_coll" -gt 0 ] && note="CONTENDED(collisions=$_coll) $note"
  # ★★★timeout/hang 的床：把【它卡住前印了什麼】存下來。
  #   ★舊版把 `$o` 整份丟掉 ⇒ 每一次 timeout 都只剩一個數字（604），
  #     而那個數字對【為什麼卡】零資訊。今天我花了四輪拼 log 拼不出來，
  #     而【卡在哪一行】本來就在手上，只是被丟了。
  #   ★★同時存當下的外部狀態（進程清單 + run-log 尾）：
  #     失效是【間歇且有狀態】的，事後補不回來。
  case "$v" in timeout|hang)
    _dg="docs/measurements/.sweep-timeout-$(basename "$bed" .gd)-$(date +%H%M%S).txt"
    { echo "=== bed: $bed  verdict=$v  wall=${dt}s  collisions=$_coll ==="
      echo "=== 進程（timeout 當下）==="
      powershell -NoProfile -Command "Get-Process godot*,powershell -ErrorAction SilentlyContinue | Select-Object Name,Id,StartTime | Format-Table -AutoSize" 2>/dev/null
      echo "=== run-log 尾 15 ==="; tail -15 .claude/hooks/.godot-runs.log
      echo "=== 床的輸出（★卡住前的最後 60 行）==="
      printf "%s" "$o" | tail -60
    } > "$_dg" 2>&1
    echo "[SWEEP] ★timeout 診斷已存：$_dg"
    note="diag=$_dg $note" ;;
  esac
  printf '%s\t%s\t%s\t%s\n' "$bed" "$v" "$dt" "$note" >> "$OUT"
  echo "[SWEEP] $n $(basename "$bed") ⇒ $v (${dt}s)"
done < "$LIST"
echo "[SWEEP] === DONE === 共 $n 支｜表在 $OUT"
