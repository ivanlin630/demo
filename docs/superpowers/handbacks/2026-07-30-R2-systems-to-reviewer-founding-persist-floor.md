---
from: systems
to: reviewer
status: open
topic: "[R²·founding-completion fix active-construction persist floor·spec=2026-07-30-founding-completion-construction-persist-floor-HOW.md·坐實根(bed dump 0b6523db):remote founding子隊construct.stall=29101/complete_build=0,stall samples ct_task=覓食/外交 ct_reason=unified ticks_left>0=argmax搶班非timeout·cold-start機制:_progress TASK_BUILD=(total-left)/total→起點progress≈0→base_persist≈0<PERSIST_HOLD_THRESHOLD(0.1)→persist.hold不fire→routine搶班不擋→progress永不累積惡性循環·fix=施工中隊persist_eff floor到≥threshold+margin(CONSTRUCTION_ACTIVE_FLOOR 0.15)→persist.hold擋routine argmax搶班→留TASK_BUILD完工·non-freeze(只floor active-construction+≥THREAT crisis照bypass打斷+完成釋放+re-eval照跑≠skip-reeval)·★不凍紅線TDD(seed1337 attrition非→0)·★人格WEIGH不GATE疑點+floor vs safe_factor scaling R² judge] founding persist floor修cold-start。審不凍紅線+人格gate疑點+crisis bypass保留+floor值。"
---

# R²：founding-completion fix — active-construction persist floor

## spec
`docs/superpowers/specs/2026-07-30-founding-completion-construction-persist-floor-HOW.md`（讀它）。

## 坐實根（bed dump 0b6523db，非猜）
remote founding 子隊 `construct.stall=29101`/`complete_build=0`（vs own-outpost `complete_upgrade_facility=6`）。stall samples `ct_task=覓食/外交` `ct_reason=unified` `ticks_left>0`＝**argmax try_set 搶班**（非 timeout：timeout_cancel=0/resume=0）。**cold-start**：`_progress`(TASK_BUILD)=(total−left)/total→起點 progress≈0→`base_persist≈0`<PERSIST_HOLD_THRESHOLD(0.1)→persist.hold gate 不 fire→routine 覓食/外交搶班不擋→progress 永不累積＝惡性循環。

## fix（persist_strength.gd）
施工中隊（TASK_BUILD + ticks_left>0）`persist_eff = max(computed, CONSTRUCTION_ACTIVE_FLOOR)`（≈0.15 > threshold 0.1）→ persist.hold 擋 routine argmax 搶班 → 留 TASK_BUILD 完工。progress 累積後自然升過 floor（floor 只保護 cold-start 空窗）。

## ★reviewer focus（異質 refute）
1. **★★不凍紅線（latch 凍過）**：floor 真不凍否？只 floor active-construction 隊（子集）+ ≥PRIO_THREAT crisis 照 bypass + 完成釋放 + **re-eval 照跑（非 skip-reeval）**——這跟 latch 的 skip-reeval 差別真夠、seed1337 不會 attrition→0 否？（★這是紅線、R² 最重）
2. **★人格 WEIGH 不 GATE 疑點**：floor 對所有人格給同一最小保護＝弱化 cold-start 人格分化。這算違反 WEIGH-not-GATE、還是 pipeline 完整性合理例外（如 crisis handling 也不分人格）？替代 `floor × lean`（人格分化但低 lean 隊不保證完工）——**保證完工 vs 純人格分化** trade-off 哪邊對？
3. **crisis bypass 真保留否**（team14 餓死施工隊照放手）：floor 是硬 min，但 survival @≥THREAT 走 task_arbiter:64-70 的 `< PRIO_THREAT` 條件 bypass persist.hold → 照打斷。這真成立否（floor 不擋 crisis）？
4. **floor vs safe_factor scaling**：硬 floor（crisis 才放）vs `FLOOR × safe_factor`（糧見底 routine 也放）——我傾向硬 floor（routine 覓食不該打斷剛開工 build），對否？
5. floor 值 0.15 合理否（> threshold 0.1、< PERSIST_CAP 0.3）？

## 判
CLEAN → implementer（floor + TDD：★不凍 seed1337 attrition非→0 + 完工 complete_build>0 + own-outpost 升級不退化 + crisis 照打斷）→ measurer 和平床 re-run。有洞（尤其 1 不凍 / 2 人格 gate）→ 回 `to:systems`。★這修觸我 RELEASED persist arc、不凍是紅線，R² 從嚴。
