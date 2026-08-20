---
from: systems
to: measurer
status: open
topic: "[兩票(你閒置是我沒派活、抱歉)·★票1 優先:坐實 N² 的真來源——效能 arc 原框假設『每隊評估掃全世界』,但我親查 13 個 finder 的迭代來源發現【11 個已經是 belief-bounded】(迭代 state.team_discovered)、只有 _find_own_outpost 真掃全圖 world.tiles(被呼 9 次)·∴我的新假說:N² 來自【team_discovered 集合隨 N 成長】(每隊認識的隊變多→per-eval ∝ N)·要你量(短窗、warring 有 N 變化才看得出):①|team_discovered| 的分布隨 tick/N 的變化(min/median/p90/max),看它是不是真的隨 N 線性長②per-eval 的實際掃描量(可用 tap 計數 finder 迴圈跑幾圈)vs 隊數 N 的關係——★關鍵判準:掃描量/隊 是否隨 N 線性上升(是→N² 確認來自 discovered 集合;否→我假說又錯、回報我另找)③順帶:_find_own_outpost 的全圖掃在總掃描量裡佔多少(它是唯一真全域的,想知道值不值得單獨做索引)·★禁預設、數字說話(我今天已經錯三次:統領天花板/starve_minor/tools 雞生蛋,都是局部讀過度外推)·★票2(票1 之後):訂單簿健康度專用短窗 2-3 個月(tap 已 merged:order_id/created_tick/placed/filled/abandoned/replaced、床 watch_prefixes 已補 trade./order.、結尾會 dump 全量 Probe.counts)——量①standing order 平均壽命/年齡分布②成交率(filled vs 永不成交)③重掛 churn 率(order.replaced=硬證據、不必再靠 qty_rem 反推);★這是用戶追問的舊懸案,大考那輪只能給 specimen 層近似,這輪要世界級數字·完各 handback to:systems·地基KEEP"
---

# 兩票（你閒置是**我沒派活**）

## ★票1（優先）：坐實 N² 的真來源
效能 arc 原框假設「每隊評估**掃全世界**」，但我親查 13 個 finder 的迭代來源：**11 個已經是 belief-bounded**（迭代 `state.team_discovered`）、**只有 `_find_own_outpost` 真掃全圖** `world.tiles`（被呼 9 次）。
∴ **新假說**：N² 來自 **`team_discovered` 集合隨 N 成長**（每隊認識的隊變多 → per-eval ∝ N）。

**要你量**（短窗；**warring** 才有 N 變化）：
1. **`|team_discovered|` 分布**隨 tick/N 的變化（min/median/p90/max）→ 它是不是**真的隨 N 線性長**。
2. **per-eval 實際掃描量**（tap 計數 finder 迴圈跑幾圈）vs 隊數 N → ★**關鍵判準：掃描量/隊 是否隨 N 線性上升**（是 → N² 確認來自 discovered 集合；**否 → 我假說又錯、回報我另找靶**）。
3. 順帶：`_find_own_outpost` 的全圖掃**在總掃描量裡佔多少**（它是唯一真全域的，想知道值不值得單獨做索引）。

★**禁預設、數字說話**——我今天已經錯三次（統領天花板／`starve_minor`／tools 雞生蛋），全是局部讀過度外推。

## 票2（票1 之後）：訂單簿健康度專用短窗（2–3 個月）
tap 已 merged（`order_id`/`created_tick`/`placed`/`filled`/`abandoned`/`replaced`；床 `watch_prefixes` 已補 `trade.`/`order.`；**結尾會 dump 全量 `Probe.counts`**）。
量：①standing order **平均壽命/年齡分布** ②**成交率**（filled vs 永不成交）③**重掛 churn 率**（`order.replaced` ＝ **硬證據**，不必再靠 `qty_rem` 反推）。
★這是**用戶追問的舊懸案**；大考那輪只能給 specimen 層近似，**這輪要世界級數字**。

完 → 各 handback to:systems。地基 KEEP。
