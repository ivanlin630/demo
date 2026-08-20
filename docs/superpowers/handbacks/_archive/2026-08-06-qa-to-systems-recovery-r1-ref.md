---
from: qa
to: systems
status: consumed
topic: "★QA:2026-08-06-qa-to-measurer-recovery-r1-verdict.md 通行證(供merge R1):recovery-r1移民三態湧現分化=CONFIRM——plains(team1)pop獨立驗證2→4→6真跳(specimen逐筆讀非信聚合)、forest/mountain全程pop={2}單一值零波動真沒收過移民；commit 5810f95c diff讀過三根修皆真在code(MIGRANT_RATION_DAYS口糧扣款/_TRANSIT_TASKS補TASK_MIGRATE/anchor改lord tile)。過程排除一假警報:raw log裡[Merge]Team0←Team4事件初看像migrant被吸回舊bug復發,深查是無關的獨立NPC隊(有自己succession/外交/覓食)投靠領主既有機制,非migrant路徑。限制:migrant走anon側派無專屬print/不進標準specimen tap,決策細節(marginal算式)無法逐tick獨立追,只驗outcome+code,跟今天side-action稽核同款限制非本輪弱點。forest樣本n=0缺口measurer已誠實聲明非阻塞,我同意不影響核心分岔故事。可merge"
---

# ★recovery-r1移民三態湧現分化 verdict ref（供 merge）

完整 verdict 見 `2026-08-06-qa-to-measurer-recovery-r1-verdict.md`。

**通行證摘要**：recovery-r1 移民三態湧現分化 = **CONFIRM**。plains(team1) pop 獨立驗證 2→4→6 真跳（自己讀 specimen 逐筆非信聚合 JSON），forest/mountain 全程 pop 恆 2、零波動，真沒收過移民。`5810f95c` diff 讀過，三根修（口糧扣款/`_TRANSIT_TASKS`補`TASK_MIGRATE`/anchor改lord tile）皆真在 code 裡。

過程中排除一個假警報：raw log `[Merge] Team0 ← Team4` 事件初看像migrant被吸回領主的舊bug復發，深查後 Team4 是無關的獨立 NPC 隊（自己有 succession/外交/覓食活動），是既有「弱勢隊投靠強鄰」機制，非 migrant 路徑——已排除，未污染判斷。

限制：migrant 走 anon 側派無專屬 print、不進標準 specimen tap，決策細節無法逐 tick 獨立重建，只驗證了 outcome+code——跟今天其他側動作稽核（herald/scout/care-loop）同款限制，非本輪特有弱點。forest 樣本 n=0 不影響核心分岔故事（plains真升+forest/mountain真零波動兩頭都證了）。**可 merge R1。**

---
*QA 驗收官 · 2026-08-06*
