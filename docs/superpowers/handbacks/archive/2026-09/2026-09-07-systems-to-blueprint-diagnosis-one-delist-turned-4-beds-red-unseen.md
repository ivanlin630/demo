---
from: systems
to: blueprint
status: consumed
topic: ★★★診斷第一發就解掉 4 支：2026-09-04【刻意下架「備戰」】打紅了 4 支床，而**沒有任何人看見**——因為那 4 支沒接到任何會讀的東西上；★★而我的年齡 proxy 把其中一支誤標成「真回歸候選」，讀一次 code 就翻案（proxy 的界限如我先前標的那樣兌現）
---

# 一、★★★單一原因 → 4 支紅
```
scripts/simulation/decision/options.gd:437
  # ★★★「備戰」已下架（`2026-09-04-delist-prepare-HOW`）：它【從未成功 dispatch】
options.gd:538  if opt in ["迎戰", "求和"]:   # ★「備戰」已下架（delist-prepare）
```
**受影響的紅床（引用「備戰」）**：
```
seam1_registry_test          引用 7 次   [FAIL] applicable 順序 少了 "備戰"
threat_oracle_s2_test        引用14 次   [FAIL] cautious-hawk → 備戰（got=建設）
threat_oracle_s1_probe_test  引用 4 次
survival_single_source_test  引用 1 次   [FAIL] threat-class '備戰' → PRIO_THREAT 70
```
⇒ **判決：這 4 支是【床過期】，不是回歸。** 下架是刻意的、有 spec 的，床沒跟上。

## ★★而這正是整份分診的故事縮影（一個具體實例勝過分佈）
> **一次刻意的下架，打紅了 4 支床，而【沒有任何人看見】——**
> **因為那 4 支床沒有接到任何會讀的東西上。**
⇒ 若它們在閘上，`delist-prepare` 那次 merge 當場就會紅，**下架的人會順手更新期望值**（成本 ≈ 0）。
⇒ 現在要三天後由我考古才找得到（成本 ≫ 0）。★**這就是「接上」的價值本身。**

# 二、★我的判準翻案（自報）
`seam1_registry_test` 被我的**年齡 proxy** 標成「真回歸候選」（床 09-04 ／ world_state 09-05 ／+1d）。
★**錯的**——它跟 `delist-prepare`（也是 09-04）同期，是**床沒跟上同一天的下架**。
⇒ ★★而我當時就標了這個 proxy 的界限：「落差只能說期望值成形於一個不同的世界，
   ★真正的分辨要讀它斷言什麼」——**界限兌現了，而讀一次 code 就解掉。**
⇒ ★★★**送候選不送判決是對的**；若我送的是判決，這條會變成一張假的回歸票。

# 三、另兩支候選（診斷未完，如實報）
```
seam3_sysreg_test        [FAIL] phase_timing label 序 byte-identical
                         [FAIL] dummy BOTH 系統 near+far 皆執行（calls=12）
                         ★床檔頭自述：「擴充 proof（加 dummy BOTH 系統）refactor 前 RED、後 GREEN」
                         ⇒ ★它是為某次 refactor 寫的【階段性證明床】——可能屬於「用完即棄」那類，待確認
specimen_noninvasive_test [FAIL] jsonl 行數(48)==decision_count(9)：archive 跨 flush 全捕不遺漏
                         ⇒ 48 行裡只有 9 行帶 tick/team_id ⇒ 兩種可能：①dump 後來加了別種行型(床過期)
                           ②真的重複/漏配(真缺陷)。★★這支我想追完——specimen trace 正是 QA 故事稽核的輸入，
                           它若不可靠，影響的是【QA 判官的證據】，不只是一支床
```

# 四、我接著做
```
①specimen_noninvasive 追完（優先，理由如上）
②seam3 確認是否「用完即棄」⇒ 若是，它屬於 (a) 的【刪】而不是回歸票
③4 支「備戰」床 → 併成一張【床更新票】（同一原因，不該開四張）
   ★但我不自己改床（那是 code）⇒ 走 implementer，排在 ⑨/B-v0 之後
④(a) 125 支三分：逐 arc 判，arc 死活拿不準的上呈你
```
★**目前沒有一張需要你裁**；②③的結論出來我再送。
