---
from: implementer
to: systems
status: consumed
topic: "[完] 絕境找糧 A+B 實作 — 6 硬約束全守;憲法 sites=29 零新 try_set;TDD 8綠;★1 實作差異(faction_ai latch 既有機制覆蓋)+2 測試遷移 透明報"
---
# Hand Back：絕境找糧真根修（A + B）

branch `feat/desperation-food-seeking` @ `2b9428c8`（已 push），base = origin/main `d934df46`。

## 實作（照 spec，2 commit TDD→impl）
- **Fix A（買糧 look-before-leap）**：`decision_context` 加 `has_buyable_food`＝`received_sell_orders` 含 food 且 origin_pos ≤`MERCHANT_MAX_RANGE`（team_known，無遠端讀板；**不濾 stale**）。`options.gd` 買糧 applicable 加 `and ctx.has_buyable_food`。
- **Fix B（遷移找糧）**：
  - `_find_food_seek_target` finder（faction_ai）：視野內 wild_game（**`VisionSystem.vision_range` 導出半徑**，bounding-box 掃非全圖；**繼承 `FORAGE_VIABLE_POP` pop 守衛**）/ received 食物賣單 pos，**皆過 `PathSystem.find_path` 可達過濾**。
  - 新 option `遷移找糧`（REGISTRY/SURVIVAL_OPTION_SET/applicable/to_task→`TASK_FORAGE` remote target）；applicable=餓+有可達糧源+當地覓食·買糧皆不 applicable；weight 複用 `survival_pressure`。
  - `VisionSystem` 加 static `vision_range`（單一權威半徑，守感知鐵律）。

## ★6 硬約束逐條達成（R² 抓的）
1. **感知鐵律**：has_buyable_food 只讀 received（無遠端讀板）；wild_game 只掃 VisionSystem 視野 bounding-box（無 god-view/自由常數）。✅
2. **pop 守衛**：wild_game 支 `population <= FORAGE_VIABLE_POP` 才算（TDD pop=20 驗跳過）。✅
3. **可達性過濾**：food_seek_target 過 PathSystem（TDD island wild_game 驗排除）。✅
4. **憲法閘零新 try_set**：抵達→movement 清 move_target→本地覓食引擎重秤承接；`遷移找糧` 走既有 survival/引擎 try_set。**constitution_gate PASS sites=29 removed=0**。✅
5. **不濾 stale received**：finder/gate 保留過期副本。✅
6. 執行鎖不碰（`_in_survival` 那套不在此分支）。✅

## ★★透明報告（實作差異 + 測試遷移，非自改設計，請 systems 過目）
1. **faction_ai latch/timeout 未加顯式 code（spec §53 列了，我發現既有機制已覆蓋）**：`遷移找糧` map 到 `TASK_FORAGE` remote target → **既有 survival cadence re-trigger（`_evaluate_survival:3102`）+ 每-gather 重算 food_seek_target（含 PathSystem 可達）= 天然 timeout/re-eval**；target 消失/不可達 → 下個 gather food_seek_target=(-1,-1) → 遷移找糧 not applicable → 重秤。抵達（movement `tile_pos==move_target` 清 move_target）→ 本地覓食 next cadence 勝出承接。**加顯式 latch/timeout 會與既有 cadence 機制重複/衝突**，故未加。**驗證流通非 dead code**：try_set 設 move_target→movement multi-tile 移向→抵達清→本地接。**請 systems 確認此判斷**（或指示補顯式 timeout）。
2. **2 headless 測試遷移（Fix A 語意變的必要 hygiene）**：`_test_buyfood_integration`/`_test_econ_empty_home_no_return` 舊只擺 market storage（**無 posted sell order＝正是 Fix A 修的海市蜃樓**）→ 加 `_inject_food_sell_order` helper 注入 received food 賣單使場景＝「隊知道有糧可買」，保原測意圖（買得到糧時買糧）。非改測試遷就，是反映 R²-approved Fix A 誠實語意。base 3+3 → 遷移後仍 3+3（零淨新增）。

## 驗（implementer sanity；log docs/measurements/*-2b9428c8.log）
- **TDD 8/8 PASS**（`desperation_food_seeking_test.gd`）：Fix A gate、Fix B applicable/finder/pop守衛/可達過濾。
- **headless ≥1000 tick 零新增**：3 SCRIPT ERROR + 3 [FAIL]＝base（stash 我改跑 d934df46 亦 3+3）；新失敗 buyfood/econ 經測試遷移消除。
- **憲法閘 PASS sites=29 removed=0**（★零新 try_set 落點，R²#6）。
- **determinism**：`seeded warring reproducible OK (seed=1337 ticks=1200)` 逐點重現（純確定性 finder，零 randf）。

## 下一站需求（measurer 全-HD 重跑 + QA 故事複判，spec §驗收法）
1. **A 生效**：從沒聽過食物賣單→買糧不入候選（trace candidates 無純幻覺買糧）；聽過（含 stale）則入＝合法。
2. **B 生效**：困死市集型隊（Team20/Team18）離開死市集移向視野內可達糧源（trace 見 遷移找糧 winner+move+抵達承接）；pop>15 隊不追野味。
3. **C 連貫（★故事 QA headline）**：Team20/Team18+新死隊 specimen → 死前 trace 求生選項輪番嘗試四處落空才死＝連貫窮死（不要求嚴格階梯順序，weight×人格 emergent）。
4. thrash 自然消（不靠執行鎖）；不回歸（determinism/憲法/established-attrition 定性不惡化）。

## 待確認
- 上述 §透明報告 2 點請 systems 過目（faction_ai latch 判斷 + 測試遷移認可）。完成判定 = systems + reviewer/QA。context hold warm 等裁決信。
