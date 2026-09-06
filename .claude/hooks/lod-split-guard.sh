#!/usr/bin/env bash
# ★★★分班反向斷言（第⑧票 2026-09-06，憲法「世界存在性法」）——
#   ★禁【重新引入】按 player_pos 把世界切兩半的任何形狀。
#
# ★病（今天坐實過一次）：far pass 每 600 tick 才跑，而「遠」的定義是【離玩家遠】
#   ⇒ ★★無玩家世界裡「遠隊」＝【全部】⇒ 遠隊的四個發薪日一次都沒發。
#   ⇒ ★★★而那一類失效【是靜默的】：沒有錯誤、沒有例外、只有一個 0，
#      而那個 0 跟「本來就沒發生」長得一模一樣 ⇒ 人不會發現第二次。
#
# ★判準（機械、不解析語意）：
#   ①scripts/simulation 與 scripts/data 裡的 player_pos 只允許出現在 allowlist 的行
#     —— ★★allowlist 裡的都是【玩家指令 glue 與觀察者守衛】，★★★沒有一條是【排程判斷】
#   ②退場成員的【code 形狀】不得再出現：SimRunner.<退場成員> 的限定引用、_get_*_teams( 的呼叫
#
# ★★為什麼只找 code 形狀不找字面：註解與 print 字串裡提到這些名字【是好事】
#   （歷史說明有價值）。用字面比對會把它們全判紅 ⇒ ★★★那會逼下一個人【刪掉說明來換綠燈】，
#   而那正好是讓知識消失的機制 —— 閘不該獎勵刪註解。
#
# ★★★誠實限（兩條）：
#   ①文字比對：有人把 player_pos 存進別的變數再比距離，它看不到。
#   ②scripts/ui/ 【不掃】—— 憲法 §5③ 明文允許表現層 LOD（鏡頭旁畫細＝表現非模擬）。
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2
ALLOW="docs/process/lod-split-allowlist.txt"
FAIL=0

if [ ! -f "$ALLOW" ]; then
  echo "[LOD-SPLIT] FAIL：allowlist 不存在（$ALLOW）—— 沒有 allowlist 不等於沒有候選"
  exit 1
fi

STRIP='{
  f=$1; ln=$2; line=""
  for (i=3; i<=NF; i++) { line = line (i>3 ? ":" : "") $i }
  sub(/^[ \t]+/, "", line)
  if (substr(line,1,1) == "#") next
  sub(/[ \t]+#.*$/, "", line)
  gsub(/[ \t]+/, " ", line); sub(/ +$/, "", line)
  if (line !~ /[A-Za-z_]/) next
  print f "\t" ln "\t" line
}'

TMP=$(mktemp)
grep -rn "player_pos" scripts/simulation/ scripts/data/ 2>/dev/null | awk -F: "$STRIP" > "$TMP"
N=$(cut -f1,3 "$TMP" | sort -u | wc -l | tr -d ' ')
echo "[LOD-SPLIT] player_pos 在 simulation+data 的非註解出現：$N 種（ui/ 不掃：憲法允許表現層 LOD）"
while IFS=$'\t' read -r f ln code; do
  if ! grep -qF -- "$f	$code" "$ALLOW"; then
    echo "  ✗ 【新的 player_pos 用法，沒人判過】$f:$ln"
    echo "      $code"
    FAIL=1
  fi
done < "$TMP"
rm -f "$TMP"

for k in 'SimRunner\.LOD_NEAR_RADIUS' 'SimRunner\.FAR_ZONE_INTERVAL' '_get_near_teams *\(' '_get_far_teams *\(' 'SimRunner\.force_full_hd' 'SimRunner\.LOD_NEAR\b' 'SimRunner\.LOD_BOTH\b'; do
  HITS=$(grep -rnE -- "$k" scripts/ 2>/dev/null | awk -F: "$STRIP" | grep -E -- "$k" || true)
  if [ -n "$HITS" ]; then
    echo "  ✗ 【已退場的成員又被 code 引用】$k"
    echo "$HITS" | sed 's/^/      /'
    FAIL=1
  fi
done

if [ "$FAIL" != "0" ]; then
  echo "[LOD-SPLIT] FAIL"
  echo "  ★這道閘擋的是【把世界按玩家距離切兩半】重新長回來。"
  echo "  ★★處置不是加進 allowlist —— 先問：這一行是不是【排程判斷】？"
  echo "    是 ⇒ 憲法判死，改成【全世界一個 pass】；不是（玩家指令 glue／觀察者守衛）⇒ 加 allowlist 並寫理由。"
  echo '  ★★★而 scripts/ui/ 的距離用法是【允許】的：表現層 LOD ≠ 模擬層 LOD。'
  exit 1
fi
echo "[LOD-SPLIT] PASS"
