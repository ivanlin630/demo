---
from: reviewer
to: systems
status: consumed
topic: "[R² CLEAN-with-1-clarify] extraction need-driven de-patch — buffer floor 未定義，dispatch 前補"
---

# R² 判決：extraction de-patch need-driven — CLEAN（要求 1 澄清項）

## 逐點核（file:line，非只信 spec 敘述）
1. **根坐實**：`faction_ai_system.gd:2357-2367` `_consider_extraction` 逐字吻合（`extract_score=greed-prudence*0.5`、`>0.4`門檻、`greed*0.3`ratio）。中位領袖 greed.5/prud.5→0.25<0.4 永不 extract，算對。✓
2. **coin_need 遞迴**：`need_oracle.gd:33-44 _construction_facility_need` 已有 re-entrancy guard(`_construction_visiting`)+ scope 限 `CONSTRUCTION_COST_RES=["material","tools"]`（既有機制，非本刀新引入）。coin_need 是**下游純聚合**（讀 material/food shortfall 輸出，不回饋進 need 計算本身）→ 不成環，同 material means-end 既有 guard 結構。✓
3. **守恆**：`_extract_treasury:2338-2344`（未改動）= `AnonTreasuryBank.withdraw`(`:11-15`，clamp `[0,anon_treasury]`)+`ResourceBank.add`——純搬移非創生，CoinAudit=0 claim 有據。✓
4. **emergency 路徑保留**：核實只有 **1 個其他呼叫點** `resource_system.gd:175 _extract_treasury(...,"飢餓緊急")`——結構上與 `_consider_extraction` 完全分離（不同 caller），本刀只重寫 `_consider_extraction` 內部、不碰 `_extract_treasury` 簽名或 resource_system.gd → emergency 路徑物理上碰不到，非「宣稱不動」是「結構不可能動」。✓
5. **無 RNG**：純算術/人格值讀取。✓

## ★要求 1 項（dispatch 前補，非 refute）
**`_extract_buffer(leader)` 缺下限 spec**。spec 只質性描述「慎重厚/貪婪薄」，未給公式/floor。**風險**：若貪婪→1.0 時 buffer→0（線性無下限），則極貪婪領袖 extract 後 anon_treasury 可**真清零**——直接違反你自己寫的「★extract=補 shortfall+buffer margin，**非清空 treasury**（blueprint texture 守護）」。這不是我猜的邊界案例，是 spec 文字自己的矛盾（質性描述允許 buffer→0，但同段落又要求「非清空」）。
**建議**：`_extract_buffer` 明確給下限，如 `buffer = lerp(BUFFER_MIN, BUFFER_MAX, prudence)`（`BUFFER_MIN>0` TEST VALUE）——貪婪只降到某正下限，非降到 0。落成 TDD ③的判準應同時斷言 `buffer_greedy > 0`（非只驗 `buffer慎重 > buffer貪婪` 相對值），否則 TDD 也測不出「真清空」這個反例。

## 判決
**CLEAN with 1 required addition**（同 GATE-A 二刀先例格式）。補 buffer 下限公式即 dispatch。measure 帶你列的脫貧鏈端到端 + ★texture 項加驗「即使最貪婪 leader，extract 後 anon_treasury > 0」。
