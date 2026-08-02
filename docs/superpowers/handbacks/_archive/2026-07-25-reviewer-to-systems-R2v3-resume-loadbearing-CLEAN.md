---
from: reviewer
to: systems
status: consumed
topic: "[R②v3 CLEAN] resume 治本(2nd-layer load-bearing)——orig 召回設計嚴謹，好流程值得記一筆，dispatch implementer續修"
---

# R②v3 判決：resume 治本（2nd-layer load-bearing）— CLEAN

## ★先記一功：execution-verified 抓到我 R②綠燈沒抓到的真洞
latch 邏輯上對（fires 8332，94.6% held）但 implementer 沒有「R②過了就交差」，自己拿 1mo tap 測 complete 數字，發現真完工率沒動、老實回報「禁 ship」——這正是本 arc 上一輪教訓（execution-verified≠R②CLEAN）該長出來的紀律，值得肯定非只是走流程。

## orig 召回設計——逐項核對
1. **繞 owner/resident gate 合理**：`orig=state.teams.get(tile.construction_team_id)` 是這 tile 記錄在案的原施工隊本人，不是「找別隊接手」——owner/resident 兩道 gate 本來就是為了篩「陌生隊有沒有資格代管」，對「本來就是這個案子的人」不適用，語意站得住。
2. **release→transition 繞 guard 機制我親算過**：`TaskArbiter.release(orig)` 先把 `task_priority` 歸零（release 定義如此），`transition(...,PRIO_DISPATCH=50)` 的唯一擋點 `task_priority>=PRIO_THREAT(70)` 此時 `0>=70` 恆假 → guard 不擋，正常轉入 TASK_BUILD——非繞過安全機制，是先清狀態再走正常轉換路徑。
3. **`_tick_construction` 不在乎「誰」在蓋、只認「同格 current_task==TASK_BUILD」**（我上兩輪已核過），orig 被召回後直接接手繼續倒數，非重開——「續建」語意屬實非誇大。
4. **邊角案例覆蓋**：`orig!=null`(死/晉升/detach) / `orig.tile_pos==tile.tile_pos`(離格/改建別址正確排除，因為若它去了別的合法工地，tile_pos 自然不匹配這格) / `combat_target==-1`(戰鬥鎖) / 糧≥3天(跟現有 candidate 篩選同源門檻非新魔數)——四項 guard 覆蓋你列的三個疑慮情境（stale/detach/改建別址），無遺漏。
5. **插入點位置**：`:2746` 後、candidates 掃描前——核對現有程式碼，:2745-2746 正是「已有人施工→return」的早退，插入點精確吻合「這裡開始才是『沒人在蓋』的情況」的語意邊界。

## (3)(4) 執行驗收/thrash 風險
(B) directive-immunity 延後為 followup、先看 (A) 效果——spec 自己已誠實標「若 thrash 兇需(B)」非樂觀假設沒事。`_tick_construction` 進度不因 task 中斷歸零（只是暫停+resume 接續），即使有 directive-leak→resume 反覆循環，進度仍該單調累積趨向完工，非原地打轉——這點推理合理，但**最終仍要靠 execution-verified 數字說話**（跟你自己定的硬標準一致，非我特別要求）。

## 判決
**CLEAN → dispatch implementer 續修 → execution-verified（`outpost_built>0`）才收。** 若這輪 measure 顯示 thrash 仍拖累完工率，(B) 是你已經排好的下一手，不用我這輪重複交代。
