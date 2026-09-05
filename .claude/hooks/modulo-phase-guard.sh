#!/usr/bin/env bash
# ★★★相位守衛（第⑦票 2026-09-05）——禁【新出現的】裸 `current_tick % INTERVAL` 當閘。
#
# ★病（實測，不是假想）：far pass 每 FAR_ZONE_INTERVAL(600) 才跑一次，
#   而 salary 的閘是 `current_tick % SALARY_INTERVAL(10080) == 0`
#   ⇒ 10080k % 600 = 480k % 600，k=1..4 全非 0
#   ⇒ ★遠隊的前四個發薪日【整個落在相位縫裡】—— 不是少發，是一次都沒發。
#   ⇒ ★★而無玩家世界裡「遠隊」＝【全部】⇒ 整條薪資軸在所有 headless 床上都是死的。
#
# ★★為什麼要機械化：這一類是【靜默】的 —— 沒有錯誤、沒有例外、沒有 0 以外的症狀，
#   而那個 0 又跟「本來就沒發生」長得一模一樣。★★★人不會發現第 4 顆。
#
# ★判準（R² 指出【不用發明】）：`sim_runner.gd` 的 SYSTEMS registry 自己的 `shape` 欄位
#   —— `state`＝每 tick 都跑到的 whole-state step ⇒ 精確 modulo 安全；
#      `teams`／`teams_cadence`＝【被 pass 相位過濾過】⇒ 精確 modulo 會掉進縫裡。
#   本閘不蓋 call-graph（母體只有十幾筆）⇒ flat grep ＋【具名 allowlist】＋ 新出現一律 FAIL。
#
# ★★誠實限（三條）：
#   ①文字比對：把 tick 存進別的變數再取模，它看不到。
#   ②它不判斷 allowlist 裡那些【判得對不對】—— 只保證【有人判過】。
#   ③它不證明已遷移的三顆遷對了 —— 那是 far/near 次數對照那條驗收在管的。
#
# ★★★而本檔第一版【印了 PASS 卻什麼都沒比】（TAB 欄位在 shell 的 read 裡被吃掉）——
#   ⇒ 比對整段改用 awk（原生吃 TSV）；★而陽性對照從此是這支閘自己的驗收條件。
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2
ALLOW="docs/process/modulo-phase-allowlist.txt"

if [ ! -f "$ALLOW" ]; then
  echo "[MODULO-PHASE] FAIL：allowlist 不存在（$ALLOW）—— ★沒有 allowlist 不等於沒有候選"
  exit 1
fi

TMP=$(mktemp)
# 掃描 → 正規化 → 聚合成 `count <TAB> file <TAB> code <TAB> 行號們`（跳過純註解行）
# ★行號要進去：閘說「有問題」卻不說【在哪一行】，下一個人得自己重跑一次 grep。
grep -rn "current_tick *%" scripts/simulation/ scripts/data/ 2>/dev/null \
| awk -F: '
  {
    f=$1; ln=$2; line=""
    for (i=3; i<=NF; i++) { line = line (i>3 ? ":" : "") $i }
    sub(/^[ \t]+/, "", line)
    if (substr(line,1,1) == "#") next
    gsub(/[ \t]+/, " ", line); sub(/ +$/, "", line)
    k = f SUBSEP line
    cnt[k]++
    lines[k] = ((k in lines) ? lines[k] "," ln : ln)
  }
  END {
    for (k in cnt) { split(k, p, SUBSEP); print cnt[k] "\t" p[1] "\t" p[2] "\t" lines[k] }
  }' > "$TMP"

TOTAL=$(awk -F'\t' '{s+=$1} END{print s+0}' "$TMP")
if [ "$TOTAL" = "0" ]; then
  echo "[MODULO-PHASE] FAIL：一筆都沒掃到 —— ★先查工具（grep/路徑），不要讀成「已經清乾淨了」"
  rm -f "$TMP"; exit 1
fi
echo "[MODULO-PHASE] 掃到 $TOTAL 筆（scripts/simulation + scripts/data，已跳過純註解行）"

awk -F'\t' -v allow="$ALLOW" '
  BEGIN {
    while ((getline l < allow) > 0) {
      if (l ~ /^#/ || l == "") continue
      n = split(l, a, "\t")
      if (n < 3) continue
      k = a[2] SUBSEP a[3]
      want[k] = a[1] + 0
    }
    close(allow)
    fail = 0
  }
  {
    k = $2 SUBSEP $3
    seen[k] = 1
    if (!(k in want)) {
      printf "  ✗ 【新出現，沒人判過】%s:%s\n      %s\n", $2, $4, $3
      fail = 1
    } else if (want[k] != $1 + 0) {
      printf "  ✗ 【次數變了】%s:%s —— allowlist 記 %d，實得 %d\n      %s\n", $2, $4, want[k], $1, $3
      fail = 1
    }
  }
  END {
    for (k in want) if (!(k in seen)) {
      split(k, p, SUBSEP)
      printf "  ⚠ allowlist 有、code 已無：%s\n      %s\n", p[1], p[2]
      printf "      ★不是 FAIL（刪掉是好事），而 allowlist 要跟著瘦 —— 沒有人負責讓東西變少\n"
    }
    exit fail
  }
' "$TMP"
RC=$?
rm -f "$TMP"

if [ "$RC" != "0" ]; then
  echo "[MODULO-PHASE] FAIL"
  echo "  ★處置不是把它加進 allowlist 了事 —— 先問：這一行在不在【被 pass 相位過濾過】的 step 裡？"
  echo "    ①whole-state step（sim_runner 的 shape:\"state\"／advance_tick 頂層）⇒ 安全，加 allowlist 並寫理由"
  echo "    ②teams／teams_cadence step 裡 ⇒ ★★改用 CadenceStagger（與 last_eval_tick 比較），不要加 allowlist"
  echo "  ★★★禁：把 INTERVAL 調成 FAR_ZONE_INTERVAL 的倍數 —— 那是把相位問題偽裝成調參問題，"
  echo "     而任何人改 FAR_ZONE_INTERVAL 都會讓它【靜默】復發。"
  exit 1
fi
echo "[MODULO-PHASE] PASS"
