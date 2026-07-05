# Tick 時間參數一覽

> 基準：`ticks_per_day = 240`（`scripts/data/world_state.gd`）  
> 1 tick = 6 分鐘遊戲時間（`TICKS_PER_HOUR = 10`，`TICKS_PER_DAY = 240`）  
> 按一次 UI「推進」= `TICKS_PER_TURN = 24` tick = 1 天

---

## 時間結構

| 參數 | 檔案 | 當前值 | 現在意義 | 建議值 | 建議意義 |
|---|---|---|---|---|---|
| `ticks_per_day` | `data/world_state.gd:4` | **240** | 基準，1天=240tick（10tick/小時×24小時） | — | 不動 |
| `TICKS_PER_TURN` | `ui/sim_bridge.gd:4` | 24 | 按一次推進1天 | — | 不動 |
| `TICKS_PER_SECOND` | `ui/turn_controls.gd:4` | 4 | 自動跑速：4tick/秒=6小時/秒 | 視需求 | |
| world_turn 間隔 | `sim_runner.gd:127` | 每 6 tick | 1 world_turn = 6小時 | — | 不動（顯示用） |
| `SEASON_LENGTH` | `simulation/harvest_system.gd:3` | **30** | **1季=1.25天，1年=5天** ← 太短 | **720** | 1季=30天，1年=120天 |
| Harvest 更新頻率 | `sim_runner.gd:146` | 每 6 tick | 每6小時更新農業乘數 | — | 不動（技術性） |
| `FAR_ZONE_INTERVAL` | `sim_runner.gd:6` | 10 | 遠區每10tick更新 | — | 不動（技術性） |
| `OVERFLOW_CHECK_INTERVAL` | `simulation/population_system.gd:3` | 10 | 人口溢出每10tick檢查 | — | 不動 |

---

## 移動速度

> 2026-07-05 update（time-scale wave **slice A1**：骨架單源,×5 先留=零行為）：BASE_MOVE_TICKS 走 `TimeScale.MOVE_TICKS_PER_HEX = BASE_ACTION_TICKS × ENCOUNTER_MAP_SCALE / WORLD_SPEED_MULT(5) = 48`（連動）。**A2（×5→1→MOVE 240）綁 ④沿途補給+FOOD 重校+gen 重校四件一 landing**（藍圖 timewave-five-rulings,防餓死潮）。

| 參數 | 檔案 | 當前值 | 現在意義 | 建議值 |
|---|---|---|---|---|
| `BASE_MOVE_TICKS` | `movement_system.gd:5` | **48**（= TimeScale.MOVE_TICKS_PER_HEX = 10×24/5）| 平原 speed_mult=1.0：48 tick/hex = 0.2 天（A1 ×5留;A2→240=1天）| A2 |
| `MIN_MOVE_TICKS` | `movement_system.gd:6` | **16**（= BASE/3）| 最快：16 tick/hex | A2 |
| `MAX_MOVE_TICKS` | `movement_system.gd:7` | **144**（= BASE×3）| 最慢：144 tick/hex | A2 |
| `NAMED_WEIGHT` | `movement_system.gd:?` | **3** | named 個人 speed 在 team avg 中加權 ×3 | — |
| `TERRAIN_SPEED_MULT` plains | `movement_system.gd:?` | 1.0 | 平原 ×1 | — |
| `TERRAIN_SPEED_MULT` forest | `movement_system.gd:?` | 0.7 | 林地 ×0.7 | — |
| `TERRAIN_SPEED_MULT` mountain | `movement_system.gd:?` | 0.4 | 山地 ×0.4 | — |

### Tier 速度（AnonTierSystem）

實際 anon speed mult：
- 平民 0.7 → 平原 ~68 tick/hex = 0.29 天
- 新兵 0.8 → ~60 tick = 0.25 天
- 老兵 0.9 → ~53 tick = 0.22 天
- 菁英 1.0 → 48 tick = 0.2 天

---

## 資源與消耗

| 參數 | 檔案 | 當前值 | 現在意義 | 建議值 |
|---|---|---|---|---|
| `FOOD_PER_PERSON_PER_TICK` | `simulation/resource_system.gd:3` | **0.1** | 10人 = 1food/tick = 24food/天 | — |
| `COLLECT_RATE` | `simulation/resource_system.gd:9` | **0.05** | 每次 collect 取 tile 池比例（馬爾薩斯 tune 0.01→0.05；池常駐 cap，遠區村收入 ≈ cap×rate×mults×2.4 次/日） | — |
| REGEN plains food | `simulation/resource_system.gd:7` | 8.0/tick | 平原農業再生（需 outpost） | — |
| REGEN forest material | `simulation/resource_system.gd:9` | 12.0/tick | 林地木材再生 | — |
| `FOOD_RESERVE_TICKS` | `simulation/interaction_system.gd:32` | 20.0 | 交易自留底線=20tick食物 | — |

### 食物存量參考（主場景 test setup，cadence-aware 修正後）
- 初始 food = 300，人口 = 10
- 每天消耗 = 10 × `FOOD_PER_PERSON_PER_DAY (2.4)` = **24 food/天**
- 無 outpost → 300 food ÷ 24 = **約 12.5 天後斷糧**

> 註：2026-06-07 之前公式 bug 導致實際消耗為設計值 1/10（每天 2.4 食物 → 125 天），cadence-aware 修正後對齊設計值。

---

## 薪水 / 士氣

| 參數 | 檔案 | 當前值 | 現在意義 | 建議值 | 建議意義 |
|---|---|---|---|---|---|
| `SALARY_INTERVAL` | `simulation/salary_system.gd:3` | **1680** | 每週發薪 | — | — |
| `SALARY_PER_SKILL_POINT` | `simulation/salary_system.gd:4` | 2.0 | 每點技能 = 2 coin/次 | — | |
| `OVERPAY_BONUS` | `simulation/salary_system.gd:5` | 0.02 | 超薪忠誠 +0.02/次 | — | |
| `SALARY_LOYALTY_PENALTY` | `simulation/salary_system.gd:6` | 0.03 | 欠薪忠誠 -0.03/次 | — | |

---

## 疲勞

| 參數 | 檔案 | 當前值 | 現在意義 | 建議值 |
|---|---|---|---|---|
| `FATIGUE_PER_TICK` | `simulation/sim_runner.gd:6` | 0.002 | 行軍每tick +0.002（500tick=20天達滿） | — |
| `FATIGUE_RECOVERY` | `simulation/sim_runner.gd:7` | 0.01 | 紮營每tick -0.01（100tick=4天恢復） | — |
| `FATIGUE_LOYALTY_PENALTY` | `simulation/sim_runner.gd:8` | 0.005 | 滿疲勞時每tick忠誠 -0.005 | — |

---

## 玩家指令常數

| 參數 | 檔案 | 值 | 說明 |
|---|---|---|---|
| `RECRUIT_COST_ANON` | `simulation/player_command_system.gd` | 50.0 | 招募匿名人口費用（coin） |
| `RECRUIT_COST_NAMED` | `simulation/player_command_system.gd` | 150.0 | 招募記名 NPC 費用（coin） |
| `TRAIN_COST_COIN` | `simulation/player_command_system.gd` | 30.0 | 玩家一次訓練 coin（守恆:餉銀入公庫 anon_treasury，2026-06-17） |
| `TRAIN_EXP_GAIN` | `simulation/player_command_system.gd` | 20.0 | 一次訓練給最低 tier 的 exp |
| `CAMP_BUILD_TICKS` | `simulation/player_command_system.gd` | 240 | 玩家紮營施工 ticks |
| `CAMP_FOOD_CAP` | `simulation/player_command_system.gd` | 40.0 | 玩家紮營抬 tile food cap（**非即時糧**） |
| `JOIN_ONBOARD_MEAL` | `simulation/player_command_system.gd` | 0.8 | 收留 onboarding 食物/人 |

---

## AI 週期

| 參數 | 檔案 | 當前值 | 現在意義 | 建議值 | 建議意義 |
|---|---|---|---|---|---|
| `STRATEGIC_INTERVAL` | `simulation/strategic_ai_system.gd:3` | 10 | 戰略AI每10tick（10小時）執行 | — | |
| `ALLIANCE_CHECK_INTERVAL` | `simulation/strategic_ai_system.gd:4` | **30** | **每1.25天**檢查同盟 | **240** | 每10天 |
| `BETRAY_CHECK_INTERVAL` | `simulation/diplomatic_ai_system.gd:4` | **50** | **每2天**檢查叛盟 | **480** | 每20天 |
| `PRISONER_CHECK_INTERVAL` | `simulation/encounter_system.gd:7` | 5 | 俘虜每5tick檢查（技術性） | — | |

---

## 視野

| 參數 | 檔案 | 當前值 | 說明 |
|---|---|---|---|
| `VISION_RADIUS` | `simulation/vision_system.gd:3` | 3 | 基礎視野 3 hex |
| `SCOUT_BONUS` | `simulation/vision_system.gd:4` | 2.0 | 偵查=1.0 → +2 hex |
| 偵測門檻 | `vision_system.gd:41` | `exposure + scout×0.3 > 0.5` | — |
| 基礎暴露值公式 | `vision_system.gd:45` | `0.2 + pop×0.04`（上限0.9） | pop < 7.5 時 < 0.5 → 難偵測 |

### 暴露值參考
| 人口 | 暴露值 | 零偵查可見？ |
|---|---|---|
| 5 | 0.40 | ❌ 不可見 |
| 8 | 0.52 | ✅ 可見 |
| 10 | 0.60 | ✅ 可見 |
| 20 | 0.80 | ✅ 可見 |

→ **test setup 人口從 10 降到 7 以下後，其他 team 會從地圖消失**

---

## 主要問題清單

| 問題 | 根因 | 修改參數 |
|---|---|---|
| 季節/年份太短 | `SEASON_LENGTH = 30` | 改 720（30天/季） |
| 薪水太頻繁 | `SALARY_INTERVAL = 30` | 改 720（30天/次） |
| 同盟檢查太頻繁 | `ALLIANCE_CHECK_INTERVAL = 30` | 改 240（10天/次） |
| NPC 消失（人口掉） | 暴露公式 + test setup 食物不足 | main.gd 加食物 or 降門檻 |
| 食物/疲勞 1/10 速率 bug | 公式 /TICKS_PER_DAY 假設每 tick 跑，實際每 hour | ✅ 已修（2026-06-07，cadence-aware）|

---

*最後更新：2026-06-02*
