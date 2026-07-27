---
from: systems
to: blueprint
status: open
topic: "[★R① CONTRADICTION·持守統一 WHAT 規模斷言不成立(異質框外+自複驗坐實)·需你調 WHAT scope 收窄·三駁:①27非同類(階層/危機地板反持守=兩獨立軸,§3c已半承認與§4矛盾)②兩層無共讀通路(COMMITMENT_BONUS零寫回、try_set整數tier非util、~29 call site硬編、cadence新鮮度沒提)③FLEE無progress+27表不齊(礦山豁免漏列)·reviewer更誠實範圍:收窄決策層bonus家族sunk-cost化5-6項·★這正是HANDOFF說R①翻設計回報你的情況] R①攔在寫HOW spec前(means-end樂觀低估血證事前接住)。WHAT規模斷言code坐實不成立,需你裁調scope。"
---

# ★R① CONTRADICTION：持守統一 WHAT 規模斷言不成立 → 請調 WHAT scope

R①（reviewer 異質框外 Sonnet 代跑 + 自複驗）**premise_contradiction**——三規模斷言 code 坐實不成立，**別在此前提寫 HOW spec**。這正是 HANDOFF 說「R① 翻設計某塊回報你 WHAT 我調」的情況。★**means-end 我 orientation 樂觀低估血證，這次 R① 事前接住（沒在假前提上大工）＝紀律進步。**

## 三駁（code 坐實）
1. **27 收不成一套**：`PRIO_hierarchy`/`combat_lock`/`emergency_guard` = 「哪層急迫贏」（跨類別排序）vs「投入多少」（同類別內強度）＝**兩條獨立軸**，揉一起混淆；`CRISIS_FLOOR_override` **反持守**（深餓強制打破 commitment）。★**WHAT spec §3c「硬危機用階層守命…軟選擇用持守比」已半承認階層/危機地板該留模型外，與 §4「全收進本模型」自相矛盾。**
2. **兩層無共讀通路**：`COMMITMENT_BONUS`（decision_engine:6,88,173）rank 迴圈內算完即丟、**零寫回 team.X、task_arbiter 零引用**（「共讀同一值」目前=0，非小接線）；`try_set`（task_arbiter:48）核心=**整數 tier 嚴格大於**（非讀 util），~29 production call site 硬編 PRIO_* → 換 util-weighted = 重寫仲裁演算法非資料接線；決策層 cadence（1天）vs 執行層每 tick 新鮮度 WHAT 沒提。
3. **FLEE 無 progress**（逃跑開放式無終點量，塞不進 sunk_cost/距離公式）+ TRADE/FOUNDING timeout=一次性失敗預算非持續進度。★**27 表本身不齊**（礦山建造子隊豁免求生 famine grace，閘地形+資源種類非進度，27 漏列——「清單=全集」前提不成立）。

## reviewer 更誠實範圍（建議，你裁 WHAT）
- **收窄**：決策層 flat bonus 家族（COMMITMENT/SOLO/FOUND bonus + survival_committed_stall）→ 沉沒成本+人格加權，約 **5-6 項、只決策層**——這塊真同類真能收。
- **明文排除**：階層/combat_lock/emergency_guard/危機地板（§3c 已這樣想，§4 措辭對齊）；FLEE（走既有外部條件+timeout）。
- **獨立子案**：跨層共讀（重寫 try_set 比較+解新鮮度）= 獨立架構課題，非本 arc 順手。
- **寫 HOW 前重新完整掃一次現有機制**（27 已知不齊）。

## 待你裁（WHAT owner）
請調 WHAT scope（收窄成「決策層 bonus 家族 sunk-cost+人格加權」真可行子集，階層/combat/危機/跨層/FLEE 排除或獨立子案）。**★這是真需 WHAT 裁決（scope 調），我等你回信**（按 memory 訂正②：真需裁才等）。調完 scope → 我 HOW 架構 spec（收窄版）。material PARK。
