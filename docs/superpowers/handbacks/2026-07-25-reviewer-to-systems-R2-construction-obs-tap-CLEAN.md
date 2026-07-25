---
from: reviewer
to: systems
status: consumed
topic: "[R② CLEAN] construction pipeline 可觀測性補洞——因果鏈候選親驗準確，tap 設計對症下藥，dispatch implementer"
---

# R② 判決：construction pipeline 可觀測性補洞（A1 stall 一階定位）— CLEAN

## 因果鏈候選——親自逐條驗證，非只信「systems code-trace 到極限」自述
1. **`_tick_construction`（`outpost_system.gd:258-267`）**：確認逐字吻合——同格 `current_task==TASK_BUILD` 才倒數，`active_team==null`→純 return 暫停（非 tile 自倒數）。
2. **TASK_BUILD/TASK_CONSTRUCT 兩族**：`team_data.gd:16/33` 確認 `"建設"`≠`"建造"` 兩獨立常數。
3. **★#2 一階最強候選（transition guard）——親算優先級數字確認合理性**：`start_build:390` 呼 `TaskArbiter.transition(...,"建設",PRIO_DISPATCH)`；`transition`（`task_arbiter.gd:108-123`，非 `try_set`，兩函式分開）的唯一擋點在 `:118 if task_priority>=PRIO_THREAT and priority<task_priority: return`。核實 `PRIO_DISPATCH=50 < PRIO_THREAT=70`（`task_arbiter.gd:9/12`）——**正常情況此 guard 不擋**（TASK_CONSTRUCT 本身也是 PRIO_DISPATCH，同級不觸發 `priority<task_priority`）。∴ 只有子隊在抵達前後被某次 threat/survival re-rank 推到 PRIO_THREAT(70)+ 才會卡——**間歇性、非必然**，spec 標「最強候選需 tap 確認」非「篤定」，信心層級標得準，非誇大。
4. **★#4 高信心候選（resume 失效）——確認為結構性必然非機率性**：`_try_resume_construction`（`faction_ai:2742-2767`）`is_owner=t.team_id==tile.outpost_owner`；核對 `_complete_construction:283` 才 `set_owner`——即施工**過程中** `outpost_owner` 對 founding 荒地恆為未設（-1），`is_owner` 結構上恆假；`resident_here` 需同 faction+TAG_PRODUCE+在場，remote founding 址周邊本來就沒這種隊。∴ 召回對 remote founding **確定性失效，非 runtime 條件式**——spec 標「確定 code 缺,不需 runtime」信心層級也標得準。

兩個信心層級（#2 間歇性需驗 vs #4 結構性確定）標註精確，不是籠統列一堆嫌疑犯，值得肯定。

## tap 設計——對症下藥非泛用 log
5 個 tap 點恰好一一對應上面因果鏈候選，能在一輪 measure 內**區分**到底是哪個環節卡（非只確認「有卡」）：①start_build 後 `current_task_after` 直接驗 #2 是否真被攔②`active_team==null` 時揭departed 隊的 `current_task`/`task_reason`（串連 #2→#3）③complete 基準線④timeout_cancel 驗 #3 預期結果（子隊 10 天後被釋放）⑤resume reject 原因分類直接驗 #4。

## 審點回覆
1. **禁 RNG**：tap 內容全是狀態讀取（tile_pos/current_task/priority/pop/tick 數），無 randf/randi 蹤跡；三跑 byte-identical 硬驗要求已列。
2. **純觀測無副作用**：全走 `Probe.bump`/tap，`if Probe.enabled` gate，無 state 寫入——跟本專案既有 tap 慣例（我這 session 審過的多輪 means-end/GATE-A tap 皆同款）一致。
3. **夠打中一階否**：確認夠——上述分析顯示 5 個 tap 點的資料組合足以區分 #2 vs #3 vs #4 三條假說，非只坐實「卡了」。
4. **file:line 準度**：4 條因果鏈候選全數親驗準確，信心層級標註精確。

## 判決
**CLEAN → dispatch implementer 加 tap → measurer 定位一階。** 不修行為（正確紀律，等資料坐實一階後 systems 一次修全部卡點，別 whack-a-mole）。
