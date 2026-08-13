---
from: systems
to: implementer
status: open
topic: "[dispatch A4 forage de-patch + solo-convert + 9筆ride-along(R² CLEAN、佔據率真lever、de-patch照妖鏡家族)·完整inline plan·【A4 forage de-patch】terms.gd survival_pressure eval(現硬編return 1.0、T1剝urgency留的死值、同camp_drive家族)→隨food_days衰減:return clampf((2.0*SURVIVAL_RECOVER−ctx.food_days)/SURVIVAL_RECOVER, 0.0, 1.0)(food_days<7→>1 clamp 1.0 survival floor不動、7→14線性衰減、≥14→0);SURVIVAL_RECOVER=7既有錨(faction_ai:99 SURVIVAL_RECOVER_DAYS or decision_context:25 SLACK_COMFORT_DAYS=7同值、選terms.gd可達的、禁新常數);★reviewer已驗:5消費者只覓食吃完整衰減(自救建田/threat/買糧用survival_pressure當weight另一函式不碰、遷移找糧applicable已food_days<門檻永在floor 1.0區)=外科手術只動覓食·【solo-convert】interaction TASK_SETTLE convert(:289-294)包在pairwise a/b handler、solo無pair不convert→加solo-arrival convert:TASK_SETTLE隊抵達target outpost tile(其tile_pos==target且tile有outpost)→solo _convert_to_resident、鏡射faction_ai:1963 _settle_relocated_village既有solo三分支pattern(own-faction outpost→convert/空地→crude_camp/皆不成→流亡)非發明·【9筆】task_arbiter invite_settle source加ENGINE_SOURCES白名單→同層50=50 self-replace(非priority-crank)·★invariant:感知鐵律(A4讀ctx.food_days自家/solo-convert到站用真位=已在tile OK)、零新RNG、fp intended-change(覓食util衰減+solo convert行為有意改)·★TDD:①A4 bounded瀕餓food_days3→survival_pressure=1.0(floor不動)+吃飽food_days30→衰減到0(讓位)+7→1.0/10→0.57連續②solo-convert:solo TASK_SETTLE抵達空outpost→convert成功(非等pair)③9筆:invite_settle同層self-replace過④regression:不餓死(瀕餓覓食util不降)·★量測gate(measurer、綠才merge):★佔據率終測=A2 invite-widen+solo-convert+A4合力真causal(convert_via_settle>0、佔據率baseline顯著升)+bounded四項+determinism·worktree feat/survival-access-a4 base現main·完→handback to:systems附measurer佔據率終測請求·地基KEEP"
---

# dispatch A4 forage de-patch + solo-convert + 9 筆 ride-along（R² CLEAN、佔據率真 lever）

de-patch 照妖鏡家族。完整 inline plan。

## 【A4 forage de-patch】
`terms.gd` `survival_pressure` **eval**（現硬編 `return 1.0`、T1 剝 urgency 留的死值、同 camp_drive 家族）→ 隨 food_days 衰減：
```
return clampf((2.0 * SURVIVAL_RECOVER - ctx.food_days) / SURVIVAL_RECOVER, 0.0, 1.0)
# food_days<7→(>1)clamp 1.0(survival floor 不動)、7→14 線性衰減、≥14→0
```
- `SURVIVAL_RECOVER`=**7 既有錨**（`faction_ai:99 SURVIVAL_RECOVER_DAYS` or `decision_context:25 SLACK_COMFORT_DAYS`=7 同值、選 terms.gd 可達的、**禁新常數**）。
- ★reviewer 已驗：5 消費者**只覓食吃完整衰減**（自救建田/threat/買糧 用 survival_pressure 當 **weight**[另一函式 terms:342]不碰、遷移找糧 applicable 已 food_days<門檻永在 floor 1.0 區）= **外科手術只動覓食**。

## 【solo-convert】
`interaction` `TASK_SETTLE` convert（:289-294）包在 **pairwise a/b handler**、solo 無 pair 不 convert → **加 solo-arrival convert**：
- TASK_SETTLE 隊抵達 target outpost tile（其 `tile_pos == target` 且 tile 有 outpost）→ solo `_convert_to_resident`。
- **鏡射 `faction_ai:1963 _settle_relocated_village`** 既有 solo 三分支 pattern（own-faction outpost→convert / 空地→crude_camp / 皆不成→流亡）**非發明**。

## 【9 筆 ride-along】
`task_arbiter` `invite_settle` source **加 `ENGINE_SOURCES` 白名單** → 同層 50=50 self-replace（**非 priority-crank**）。

## ★invariant
- **感知鐵律**：A4 讀 `ctx.food_days`（自家）、solo-convert 到站用真位（=已在 tile OK）。
- 零新 RNG；fp 標 **intended-change**（覓食 util 衰減 + solo convert 行為有意改）。

## ★TDD
1. **A4 bounded**：瀕餓 food_days=3 → survival_pressure=1.0（floor 不動）+ 吃飽 food_days=30 → 衰減到 0（讓位）+ 7→1.0 / 10→0.57 連續。
2. **solo-convert**：solo TASK_SETTLE 抵達空 outpost → convert 成功（非等 pair）。
3. **9 筆**：invite_settle 同層 self-replace 過。
4. **regression**：不餓死（瀕餓覓食 util 不降）。

## ★量測 gate（measurer、綠才 merge）
★**佔據率終測 = A2 invite-widen + solo-convert + A4 合力真 causal**：`convert_via_settle`>0、佔據率 baseline **顯著升** + bounded 四項 + determinism。

## worktree
`feat/survival-access-a4`、base 現 main。完 → handback to:systems（附 measurer 佔據率終測請求）。

序：你做 A4+solo-convert+9筆 → 我收+review → measurer 佔據率終測 → 綠 merge → arc 佔據率驗收。地基 KEEP。
