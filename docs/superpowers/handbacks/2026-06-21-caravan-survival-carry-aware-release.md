# Hand Back: 商隊 survival carry-aware 釋放 — **BLOCKER（未實作）**

狀態：**停工，未改 code，未 commit code**。plan 根因前提算錯 → 修為 no-op、測試不可滿足。需 systems 重診。

## 為何停工（plan 前提算術錯誤）

plan §關鍵常數（line 20）：
> `BASE_CARRY=10.0 → carry-cap-in-days=10/2.4≈4.17 < 7 = 旅途隊永到不了釋放閾（本 bug）`

此式 = `BASE_CARRY / FOOD_PER_PERSON_PER_DAY = 10/2.4`，**隱含假設 1 食物=1 載重單位**。實際 `_resource_weight("food") = 0.1`（movement_system.gd:114）。

→ 1 人 `BASE_CARRY=10` 載重單位裝 `10/0.1 = 100` 食物 = `100/2.4 ≈ 41.7` 天。
**真實 carry-cap-in-days ≈ 41.7 ≫ RECOVER(7)。結構 carry latch 不存在。**

### 三個連鎖後果

1. **carry 不卡**：旅途隊經 case①(`days_left>=RECOVER`) 釋放只需 `7×pop×2.4 = 16.8 食物/人`（5 人=84）。carry cap 裝 `100 食物/人`（5 人=500）。84 ≪ 500 → 達 RECOVER 前 carry 永不綁死。

2. **`foraged_full` 分支是死碼**：`carry_space_for_res(team,"food") <= 0` 需 `food ≥ pop×100`，即 `days_left = (pop×100)/(pop×2.4) ≈ 41.7 ≥ RECOVER(7)`。即 `foraged_full` 為真時 case① 早已成立 → 新 OR 增加 **0** 個釋放。修了等於沒修。

3. **測試案A 不可滿足**：前置 `carry_space_for_res(food)<=0`（→ 5 人需 food≥500）與目標 `days_left≈4.17 ∈[3,7)` 互斥。`food=50` 時 `carry_space_for_res = int((50−5)/0.1) = 450`，第一行 `assert(... <= 0)` 即失敗。要過只能改測試掩蓋 → plan Step4 明文禁止。

## 驗證事實（worktree code）

| const | 值 | 來源 |
|---|---|---|
| BASE_CARRY | 10.0 | movement_system.gd:16 |
| MOUNT_BONUS / WAGON_BONUS | 15.0 / 40.0 | movement_system.gd:17-18 |
| food weight | **0.1** | movement_system.gd:114 |
| FOOD_PER_PERSON_PER_DAY | 2.4 | resource_system.gd:3 |
| URGENCY / WARNING / RECOVER | 1.0 / 3.0 / 7.0 | faction_ai_system.gd:46-48 |
| effective_food(旅途隊,無自家糧倉) | 僅攜帶 food | resource_system.gd:354-357 |
| carry_space_for_res | `int(remaining_carry_space/weight)` | movement_system.gd:106-110 |

`_evaluate_survival` 現有釋放分支（faction_ai_system.gd:2114-2119）與 plan 引用一致，無偏差。

## 連動風險

- 無（未改 code）。

## 待主 session（systems）確認 — 重診方向

`merchant_survival≈164` latch **非 carry-cap**。真因須 measure-first，候選：

1. **供給面**：旅途商隊根本累積不到 ~84 食物（5 人）→ forage 產出 < 消耗，或商隊不 forage（archetype=商業，survival 觸發的 task 是 return_home/乞食而非 forage？）。若如此屬乾糧/forage 平衡，非釋放邏輯。
2. **re-trigger thrash**：釋放後同 tick/次 tick `days_left<WARNING` 立即重進 survival（band 太窄或承諾 cadence）。
3. **effective_food 旅途語意**：商隊離家後 effective_food=攜帶，若攜帶長期偏低 → days_left 長期 <7 = 真餓非假卡。需 trace 一支 `TAG_MERCHANT` 看 `current_task`/`days_left`/攜帶 food 連續數十 tick。

建議：先跑 `world_sim.gd` + `team_trace.gd` 抽樣一支商隊，確認 latch 是「假卡」（有糧卻不放）還是「真餓」（無糧）。若真餓 → 經濟供給問題（商隊出發前糧 / 沿途補給），開新 spec；釋放邏輯本身（hysteresis RECOVER/WARNING）目前正確，無需動。

## 建議後續

- 撤回/改寫此 plan 與其上游 spec（`2026-06-21-...survival-latch...`）：carry-aware 釋放前提不成立。
- 若仍要「forage 已盡力」釋放語意，門檻不能用 carry-cap（永達不到），需另定（如 forage 連續 N tick 無淨增 = 採盡）。
