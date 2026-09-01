#!/usr/bin/env bash
# ★★★cherry-pick 忠實度閘（systems 建 2026-09-02；blueprint 追問「規矩有、閘呢」）
#   ★病：`git cherry-pick -x` 之後若衝突處理出錯，可能只帶進【一部分】——
#     而 commit message 仍宣稱它帶了那顆。★★血證：只帶進註解、丟掉那一行 code，
#     留下的註解說「下面排除了 camp_level>0」而下面並沒有排除（＝#30 同族，4 小時內自產）。
#   ★★判準：`git patch-id --stable` 逐顆比【本地】與【來源】。
#     ★★★實測校準（2026-09-02，本 repo 200 顆窗）：
#        忠實 cherry-pick 6 顆 ⇒ patch-id 【全部相同】（★零假陽性）
#        事故那顆 1 顆        ⇒ patch-id 【不同】（★★抓到）
#     —— ★兩端都有對照，不是只驗會不會紅。
#   ★誠實限：①只掃最近 N 顆；②來源不可達（別 branch 已刪）⇒ 報 SKIP 不報 FAIL；
#     ★★★③**沒有 `-x` trailer 的 cherry-pick 本閘看不見**（手動 pick／squash 過的）。
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2
N="${1:-40}"; fail=0; checked=0; skipped=0
# ★★★已知歷史事故白名單：★它是本閘的【陽性對照】,永遠會紅 ⇒ 若不排除,閘恆紅＝沒有閘
#   ★★而排除它【不是洗綠】:那顆的損害已經修好(9a18f0c9 原樣還原 + s2b ALL PASS 親跑)
KNOWN_INCIDENT="326923a7"   # recamp：只帶進註解、丟掉那一行 code（2026-09-02，已還原）
for c in $(git log -n "$N" --format=%H); do
  src=$(git log -1 --format=%B "$c" | grep -oE 'cherry picked from commit [0-9a-f]{7,40}' | awk '{print $NF}' | head -1)
  [ -z "$src" ] && continue
  if ! git cat-file -e "$src^{commit}" 2>/dev/null; then skipped=$((skipped+1)); continue; fi
  checked=$((checked+1))
  a=$(git show "$c"   | git patch-id --stable | awk '{print $1}')
  b=$(git show "$src" | git patch-id --stable | awk '{print $1}')
  if [ "$a" != "$b" ]; then
    case "$c" in ${KNOWN_INCIDENT}*) echo "[CHERRYPICK-FIDELITY] （已知歷史事故 ${c:0:9}，已修復並白名單 —— ★它是本閘的陽性對照）"; continue;; esac
    echo "[CHERRYPICK-FIDELITY] ★FAIL：${c:0:9} 宣稱 cherry-pick 自 ${src:0:9}，而【內容不等價】"
    echo "   ⇒ ★★可能只帶進一部分 hunk ——【而 message 仍宣稱它帶了那顆】"
    echo "   ⇒ ★★★查法：git show ${src:0:9} 與 git show ${c:0:9} 逐 hunk 比"
    fail=$((fail+1))
  fi
done
echo "[CHERRYPICK-FIDELITY] 掃 $N 顆｜比對 $checked 顆｜跳過(來源不可達) $skipped 顆｜★不等價 $fail"
echo "[CHERRYPICK-FIDELITY] ★誠實限：沒有 -x trailer 的 cherry-pick【本閘看不見】"
[ $fail -gt 0 ] && exit 1
exit 0
