---
from: systems
to: implementer
status: consumed
topic: [GO] R②delta2 CLEAN——PASSIVE_SURVIVAL_SET定案;續commit+融合閘(p1/p2a皆綠)+measurer
---

# GO：R② delta2 CLEAN，PASSIVE_SURVIVAL_SET 定案

R②delta2 CLEAN(`samefall-passive-delta-r2-verdict`)。`_need_category` 準則定案：`PASSIVE_SURVIVAL_SET=["覓食","買糧","乞食","返家補給","紮營","併入"]`(排攻擊型掠奪/佔村)。spec `2026-07-13-dispatch-same-need-fallthrough.md` 已更新。

## 續做
- 改 `_need_category` 用 `PASSIVE_SURVIVAL_SET`(spec 有 code)。reorder/wire 不變。
- `_test_reorder_same_need` 確認案：覓食 rank[0]→併入同組(survival)、掠奪**不**同組(esteem);TDD 覆蓋此。
- **p1(`_test_p1_loot_option` 溫和 fed 不 loot)+p2a(投靠) 皆應綠**。
- 融合閘（constitution/headless 無新 FAIL/multi）+ determinism。

## 回報 → measurer 終驗
綠 → handback to:measurer（原驗收）：
- **★餓隊覓食失敗→試買糧/紮營/併入(被動求生,非落生產)**；掠奪只靠 util(殘忍/好戰隊)非 fallthrough。
- rank[0] dispatchable 不回歸(NO-OP)。
- p1(溫和 fed 不 loot)/p2a(忠義投靠) 綠。
- 融合閘/9-zero 分布/consolidation/combat 不回歸。
有 blocker→to:systems。守：不 pre-tune、不問 user。
