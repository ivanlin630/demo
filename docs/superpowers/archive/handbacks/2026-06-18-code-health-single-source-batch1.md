# Hand Back: 代碼健康 批次1（共用常數單一真值源）

## 實作摘要

純去重，零行為變更（值與邊界等價）。

### Task 1 — FOOD_PER_PERSON_PER_DAY 單一源
- `scripts/simulation/player_api_mapper.gd`：刪本檔 `const FOOD_PER_PERSON_PER_DAY=2.4` 副本，2 處用法改 `ResourceSystem.FOOD_PER_PERSON_PER_DAY`。
- `scripts/simulation/faction_ai_system.gd`：刪 `const FOOD_PER_PERSON_PER_DAY_SURVIVAL=2.4` 副本，2 處用法（食物天數估算 + 補給判斷）改 `ResourceSystem.FOOD_PER_PERSON_PER_DAY`。
- 唯一源：`resource_system.gd:3`。

### Task 2 — TIER_ORDER 單一源 + tier 名 named const
- `scripts/simulation/anon_cohort.gd`：把 `TIER_ORDER` 字面陣列拆成 4 個 named const（`TIER_PLEB/TIER_SOLDIER/TIER_VET/TIER_ELITE`）+ 由其組成 `TIER_ORDER`（唯一源）。
- `scripts/simulation/anon_tier_system.gd`：刪本檔 `TIER_ORDER` 副本，改 `const TIER_ORDER = AnonCohort.TIER_ORDER`。`TIER_STATS`/`PROMOTION_*` authority dict 表字面不動。

### Task 3 — 散落 tier 字串 → named const
逐站讀確認是 tier 名（非同字 status/其他語意）才改：
- `scripts/simulation/encounter_system.gd:1250`：`exp_tier == "菁英"` → `AnonCohort.TIER_ELITE`（戰後 exp 迴圈跳過菁英）。
- `scripts/simulation/player_command_system.gd:190,198`：2 處 `tier == "菁英"` break → `AnonCohort.TIER_ELITE`。
- `scripts/simulation/training_system.gd:22`：`tier == "菁英"` → `AnonCohort.TIER_ELITE`。
- `scripts/simulation/beast_system.gd:32`：`AnonCohort.add(..., "平民", ...)` → `AnonCohort.TIER_PLEB`。
- `scripts/simulation/population_system.gd:21`：`add_anon(..., "平民", ...)` → `AnonCohort.TIER_PLEB`（未成年成人 mature）。print 顯示字串內的「平民」保留（UI 文字）。
- `scripts/simulation/recruit_tutorial.gd:22`：`add_anon(..., "平民", 3)` → `AnonCohort.TIER_PLEB`。
- `scripts/simulation/game_setup.gd:340`：`AnonCohort.add(..., "平民", ...)` → `AnonCohort.TIER_PLEB`（`_setup_anon_tiers` 預設桶）。`:343` 的 `for tier in TIER_ORDER` 迴圈變數已是引用，不動。

### Task 4 — TRAINING_CAP 接回單一源
- `scripts/simulation/anon_tier_system.gd`：`_training_cap` 由硬編碼門檻（`if tact>0.4:老兵; if tact>0.7:菁英`）改為從 dead const `TRAINING_CAP_THRESHOLDS` 推導（最高「tact > 門檻」對應 tier，嚴格 `>`，floor 預設新兵）。消 dead const + 去重。`TRAINING_CAP_THRESHOLDS` dict（key 數字 / value tier 字面）為 authority 表，不動。

### Task 5 — VISION_RADIUS 單一源
- `scripts/ui/text_map_renderer.gd:4`：`const VISION_RADIUS=3` → `= VisionSystem.VISION_RADIUS`。`VIEW_RADIUS`（視窗半徑，獨立語意）不動。
- `scripts/simulation/day_night_system.gd:60`：`var base=3 # 避免跨系統依賴` → `var base = VisionSystem.VISION_RADIUS`（const 引用為編譯期，無 runtime 跨系統依賴；註解移除）。
- 唯一源：`vision_system.gd:3`。`encounter_view.gd:501 SOUND_RANGE`（聲音範圍，非 vision）**不動**。

## 驗證數據

- `headless_test.gd`：`=== DONE ===`，SCRIPT ERROR=0，無 FAIL/assert。promote/cap 相關測試綠：`AnonTier Task4e OK`（leader 戰術 0.3 不可升老兵→回 0）、`AnonTier Task5 OK`（訓練 exp 5.0）、`AnonTier speed OK`。
- `_training_cap` 邊界等價（手算驗）：tact=0→新兵、0.4→新兵、0.5→老兵、0.7→老兵、0.8→菁英（與原碼 `if >0.4/>0.7` 逐點相同）。
- `game_sim_multi.gd`：SCRIPT ERROR=0；coin_eq delta=0.00（game_sim_test/tyrant/merchant/warzone 全部）；`InvariantSummary` 違反總計=0（4 config 全部）。行為等價（pop/teams/treas 數據正常）。

## 連動風險

- 無已知連動風險。純常數收斂，值與邊界皆未變，跨系統引用為編譯期 const（`ResourceSystem.*` / `AnonCohort.TIER_*` / `VisionSystem.VISION_RADIUS`）。回歸全綠。

## 待主 session 確認

- 批次2（後續，本批未做）：TASK_* enum 補齊 + ResourceKeys 鍵權威模組 + `resources.get` helper。
- 無 spec 未覆蓋的設計決策；`_training_cap` 與各 tier 站判讀均無調整（嚴格按 plan）。
