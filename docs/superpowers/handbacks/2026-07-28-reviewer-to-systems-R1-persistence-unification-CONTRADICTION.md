---
from: reviewer
to: systems
status: consumed
topic: "[R①異質框外審 CONTRADICTION] 持守統一 WHAT 規模斷言不成立——27機制非同類、兩層無共讀通路、FLEE無progress概念，別在此前提寫HOW spec"
---

# R① 判決：持守統一 WHAT 規模斷言 — **premise_contradiction**

用不同模型（Sonnet 代跑，明確 refute prompt）獨立驗證三規模斷言，我自己另外複驗三項最關鍵發現（非只信 agent）。判決：**premise_contradiction**——別在此前提上寫 HOW spec。

## ★我自己複驗確認（非只轉述 agent）
1. **`COMMITMENT_BONUS` 零跨層通路**：`decision_engine.gd:6,88,173`——`u += COMMITMENT_BONUS` 只在 rank 迴圈內部算完即丟，從未寫回 `team.X` 欄位，`task_arbiter.gd` 全檔零引用。「兩層共讀同一值」目前是 0，非「小接線」。
2. **FLEE 無 progress 概念**：`faction_ai_system.gd:394-398` 逃跑結束判定 = 外部條件（`_has_active_threat` 消失）+ 純 flat timeout（`FLEE_TIMEOUT`），全檔 grep `TASK_FLEE` 找不到任何「逃了多遠/多接近安全」的量——逃跑本質開放式、無終點量，塞不進「sunk_cost/距離完成」公式。
3. **★27 張表本身不完整**：`faction_ai_system.gd:3451-3463` 有個表外機制——礦山(ore_gold/ore_silver) 建造子隊豁免所有求生打斷（famine grace），閘的是**地形+資源種類**非進度/沉沒成本。27 項清單漏了這條，而「一套收全部」的前提正是「清單=全集」——清單本身就不齊。

## agent 逐項發現（我認可，證據扎實）
- **①「27 收成一套」**：`PRIO_*_hierarchy`(#15)/`combat_lock_absolute`(#16)/`emergency_respect_guard`(#17) 答的是「哪個急迫層級贏」（跨類別排序），跟「我對這個具體動作投入多少」（同類別內強度）是**兩條獨立軸**——揉進同一 persistence 純量會混淆兩個不同關注點。`CRISIS_FLOOR_override`(#20) 更是**反持守**（深餓時強制打破 commitment，非強化）。**WHAT spec 自己 §3c 講「硬危機用階層守命…軟選擇用持守比湧現」——已經半承認階層/危機地板該留在模型外**，跟 §4「全收進本模型」自相矛盾。
- **②兩層共讀**：`try_set`（`task_arbiter.gd:48`）核心比較是**整數 tier 嚴格大於**（`priority>task_priority`），非讀 util 值；agent 數過 **~29 個 production call site** 直接用硬編 `PRIO_*` 常數呼 `try_set`/`transition`——這是深度依賴的既有機制，換成「util-weighted」比較是重寫仲裁演算法，非資料接線。且決策層 cadence（1天）vs 執行層每 tick 檢查，中間的新鮮度問題 WHAT spec 完全沒提。
- **③一套 progress 公式**：construction 真有 `construction_ticks_left`（可信）；但 TRADE/FOUNDING 的「距離縮放 timeout」是**一次性算好的失敗預算**（dispatch 時定值），非「持續更新的當下進度」——跟公式要的即時輸入是不同性質的東西，「absorbed」用詞掩蓋了這其實要重做。

## 更誠實的範圍（agent 建議，我認可方向）
①收窄成「決策層 flat bonus 家族（COMMITMENT/SOLO/FOUND bonus + survival_committed_stall）→ 沉沒成本+人格加權」，約 5-6 項、只決策層——這塊是真的同類、真能收。②階層/combat lock/emergency guard/危機地板明文排除在外（§3c 已經這樣想，§4 措辭要對齊）。③跨層共讀是獨立的架構課題（重寫 `try_set` 比較邏輯+解新鮮度），非本 arc 順手完成。④FLEE 明確排除在 progress 公式外，走既有外部條件+timeout 形狀。⑤寫 HOW 前重新完整掃一次現有機制（27 已知不齊）。

## 回覆
`premise_contradiction` → halt，回 blueprint 調整 WHAT 範圍（收窄成「決策層 bonus 家族 sunk-cost 化」的真正可行子集，階層/combat-lock/危機地板/跨層共讀/FLEE 明確排除或列獨立子案）。你 R①若翻設計某塊回報 blueprint 的邊界已寫在 HANDOFF 裡——這正是那個情況。
