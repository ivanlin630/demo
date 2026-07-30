---
from: systems
to: implementer
status: open
topic: "[實作·founding-completion fix active-construction persist floor·spec=2026-07-30-founding-completion-construction-persist-floor-HOW.md(R²確認CLEAN)·persist_strength.gd加CONSTRUCTION_ACTIVE_FLOOR(0.15>PERSIST_HOLD_THRESHOLD 0.1)·_value施工中隊(current_task==TASK_BUILD AND tile construction_ticks_left>0)persist_eff=max(computed,FLOOR)·均一floor非floor×lean(R²判合理例外)·★★不凍紅線TDD(seed1337 6mo attrition非→0+世界churn+三跑determinism)+complete_build>0+★persist.hold真對founding子隊fire斷言(非只信complete_build)+own-outpost upgrade不退化(≥6)+crisis照打斷施工(food→0 survival@≥THREAT離TASK_BUILD)·純算術零RNG] founding persist floor。均一floor 0.15。★不凍紅線+persist.hold真fire+crisis打斷 TDD必全綠。"
branch: feat/founding-persist-floor
---

# 實作：founding-completion fix — active-construction persist floor

R² 確認 CLEAN（5 項訂正到位）。★**本 session 最高風險改動**（觸 RELEASED persist arc、唯一真 regression 前科區＝latch 凍）——不凍紅線 TDD 必全綠才交。

## spec
`docs/superpowers/specs/2026-07-30-founding-completion-construction-persist-floor-HOW.md`（讀它，R²確認版 §1/§4/§5/§5b/§5c）。

## scope（persist_strength.gd）
1. 加常數 `CONSTRUCTION_ACTIVE_FLOOR: float = 0.15`（TEST VALUE，> `PERSIST_HOLD_THRESHOLD` 0.1、< `PERSIST_CAP` 0.3）。
2. `_value`（or compute）：**施工中隊 persist floor**——`team.current_task == TeamData.TASK_BUILD` AND 其施工 tile `construction_ticks_left > 0`（即現 safe_factor 那條「真施工中」判定，persist_strength:65-67 已讀 tile）→ `persist_eff = max(computed_persist_eff, CONSTRUCTION_ACTIVE_FLOOR)`。
   - computed = 現行 `base_persist × safe_factor`（TASK_BUILD 路）。floor 是**最小值**（safe_factor 可升過 floor；糧見底 computed→0 但 floor 撐 routine 保護）。
   - **★均一 floor（非 floor×lean）**——R² 判合理例外（floor×lean 務實隊 0.03<threshold=永遠 0%完工）。
3. **零其他改**：不動 `_should_reeval`/argmax/`_try_resume_construction`（那是 reverted latch 的凍源，本 fix **不碰**）。純改 persist_strength 的**值**餵既有 `try_set:64-70` 單點 gate。

## ★★TDD（不凍紅線 + 完工 + persist.hold 真 fire + crisis + own-outpost）
- **★★不凍紅線（latch 前科）**：seed1337 6mo `attrition 非 →0` + 世界 churn（Δteams/pop 逐月變）+ 三跑 determinism byte-identical。**這條紅、全部作廢**。
- **founding 完工**：和平床（`peaceful_economy_bed.gd`，已 merge main）re-run `complete_build > 0` + `construct.stall` 大降（vs 29101）。
- **★★persist.hold 真對 founding 子隊 fire（§5 R²③）**：斷言 founding 子隊 cold-start 窗口內 **`persist.hold` Probe 真對它 bump 過**（被 argmax 搶班時 try_set return false 擋下）——**非只倒推 complete_build>0**（[[feedback_verify_execution_end]]）。
- **own-outpost 升級不退化**：`complete_upgrade_facility ≥ 6`。
- **★crisis 照打斷施工（team14 保留）**：construction 隊 food→0 → survival @≥THREAT → 照離 TASK_BUILD 放手求生（floor 不擋 crisis，task_arbiter:66 `<PRIO_THREAT` bypass）。
- 純算術零 RNG（persist_strength 零 RNG 延續）；constitution 74 + observability PASS + headless 0-new + determinism 三跑 byte-identical。

## 交付
handback `to:systems` → R²（實作：floor 值/範圍/不凍 TDD 真綠/persist.hold fire 斷言真驗）→ **measurer 和平床 re-run（complete_build>0 + 不凍 + ★§5b team14 timing：對比 fix 前後多餓死否）→ QA**。★execution-verified：founding 真完工 + 世界不凍 + crisis 照打斷 + persist.hold 真 fire。卡住報 `to:systems`（別空等、別碰 skip-reeval latch）。
