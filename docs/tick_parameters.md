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

| 參數 | 檔案 | 當前值 | 現在意義 | 建議值 |
|---|---|---|---|---|
| `BASE_MOVE_TICKS` | `simulation/movement_system.gd:3` | **10** | 平原無負重：10tick/hex = 10小時 | — |
| `MIN_MOVE_TICKS` | `simulation/movement_system.gd:4` | 3 | 最快：3tick/hex = 3小時 | — |
| `MAX_MOVE_TICKS` | `simulation/movement_system.gd:5` | 30 | 最慢：30tick/hex = 1.25天 | — |
| `TERRAIN_SPEED_MULT` plains | `movement_system.gd:7` | 1.0 | 平原 ×1 | — |
| `TERRAIN_SPEED_MULT` forest | `movement_system.gd:8` | 0.7 | 林地 ×0.7 → 14tick/hex | — |
| `TERRAIN_SPEED_MULT` mountain | `movement_system.gd:9` | 0.4 | 山地 ×0.4 → 25tick/hex | — |

---

## 資源與消耗

| 參數 | 檔案 | 當前值 | 現在意義 | 建議值 |
|---|---|---|---|---|
| `FOOD_PER_PERSON_PER_TICK` | `simulation/resource_system.gd:3` | **0.1** | 10人 = 1food/tick = 24food/天 | — |
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
