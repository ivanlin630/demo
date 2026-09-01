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
    # ★★第二關（2026-09-02 加）：patch-id 不同【不等於】內容遺失。
    #   血證 A#14：來源是【改檔】(+25/-2)、我這邊是【新建】(+117)（前一顆沒撿），
    #   ⇒ patch-id 天生不同，而【結果內容逐位元相同】。
    #   ★★★patch-id 只是代理判準；閘真正要答的是「內容有沒有掉」⇒ 直接比【落地後的檔案內容】。
    same=1
    for f in $(git show --name-only --format="" "$src"); do
      git cat-file -e "$src:$f" 2>/dev/null || continue   # 來源刪掉的檔：第二關看不見（誠實限③）
      # ★比 blob hash，不比工作區檔案：對 $c 自己的 tree 比，這樣「後來的 commit 又改了它」不會變成假紅
      hs=$(git rev-parse "$src:$f" 2>/dev/null)
      hc=$(git rev-parse "$c:$f"   2>/dev/null)
      if [ -z "$hc" ] || [ "$hs" != "$hc" ]; then same=0; break; fi
    done
    if [ "$same" = "1" ]; then
      echo "[CHERRYPICK-FIDELITY] ✓ ${c:0:9}：patch-id 異但【內容 = 來源落地後版本，逐檔逐位元同】"
      echo "   ⇒ ★成因通常是「來源改檔 vs 本地新建」（前面的 commit 沒撿）——不是遺失"
      continue
    fi
    echo "[CHERRYPICK-FIDELITY] ★FAIL：${c:0:9} 宣稱 cherry-pick 自 ${src:0:9}，而【內容不等價】"
    echo "   ⇒ ★已過第二關比對：不是 patch-id 假紅，是【檔案內容真的不同】"
    echo "   ⇒ ★★可能只帶進一部分 hunk ——【而 message 仍宣稱它帶了那顆】"
    echo "   ⇒ ★★★查法：git show ${src:0:9} 與 git show ${c:0:9} 逐 hunk 比"
    fail=$((fail+1))
  fi
done
echo "[CHERRYPICK-FIDELITY] 掃 $N 顆｜比對 $checked 顆｜跳過(來源不可達) $skipped 顆｜★不等價 $fail"
# ★★★self-test（2026-09-02）：白名單那顆通常【不在預設視窗內】⇒ 平常跑的那次不含陽性對照。
#   ⇒ 每次都對它跑一遍第二關：★若它變綠＝【判準被調過頭】，閘要當場說自己壞了，而不是安靜地全綠。
st_bad=0
if git cat-file -e "${KNOWN_INCIDENT}^{commit}" 2>/dev/null; then
  st_src=$(git show -s --format=%B "$KNOWN_INCIDENT" | grep -oE 'cherry picked from commit [0-9a-f]{7,}' | grep -oE '[0-9a-f]{7,}' | tail -1)
  [ -z "$st_src" ] && echo "[CHERRYPICK-FIDELITY] ★★SELF-TEST 壞了：抽不出 ${KNOWN_INCIDENT} 的 -x trailer"
  for f in $(git show --name-only --format="" "$st_src"); do
    git cat-file -e "$st_src:$f" 2>/dev/null || continue
    [ "$(git rev-parse "$st_src:$f" 2>/dev/null)" != "$(git rev-parse "$KNOWN_INCIDENT:$f" 2>/dev/null)" ] && st_bad=1
  done
  if [ "$st_bad" = "1" ]; then
    echo "[CHERRYPICK-FIDELITY] ✓ self-test：已知事故 ${KNOWN_INCIDENT} 在第二關【仍然是紅的】⇒ 判準沒被調過頭"
  else
    echo "[CHERRYPICK-FIDELITY] ★★★SELF-TEST FAIL：已知事故 ${KNOWN_INCIDENT} 現在【過關了】⇒ 本閘已失去鑑別力，全綠不可信"
    fail=$((fail+1))
  fi
else
  echo "[CHERRYPICK-FIDELITY] ★★SELF-TEST 跳過：${KNOWN_INCIDENT} 不可達（★這代表本輪沒有陽性對照）"
fi
echo "[CHERRYPICK-FIDELITY] ★誠實限①：沒有 -x trailer 的 cherry-pick【本閘看不見】"
echo "[CHERRYPICK-FIDELITY] ★誠實限③：來源【刪除】的檔，第二關跳過（只比來源留下內容的檔）"
echo "[CHERRYPICK-FIDELITY] ★誠實限②：第二關比的是【來源動過的檔】——來源沒動、而我這邊被改壞的檔，本閘看不見"
[ $fail -gt 0 ] && exit 1
exit 0
