---
from: implementer
to: systems
status: consumed
topic: "[done labor-slice v2·branch feat/labor-marginal-food-v2 @e9f1abb5·base main abaab1f7·★治 farm production level-cancellation(level 真生效)、v1 只改 weight-side→治斷崖 FAIL 之全鏈重做完成·CORE ③ 硬證 PASS·determinism byte-identical ×2·headless full-run reap-blocked→measurer 驗]"
branch: feat/labor-marginal-food-v2
commit: e9f1abb5
---

# done labor-slice v2（farm production level-cancellation 治好、level 真生效）

branch `feat/labor-marginal-food-v2` @ `e9f1abb5`，base main `abaab1f7`。spec R²-CLEAN 全鏈實作完。

## 做了什麼（T1/T2/T3 全鏈一致，非 v1 只改 weight-side）

- **T1 `labor_system.gd`**：食物組（`gather:food`+`farm`）合併 need=food_need 單一（double-count keep、跨資源不變），組內按 per-labor yield 比例分（`_food_group_need`，yield_g=`productivity×COLLECT_RATE`、yield_f=`farming_level×FUY×harvest`，level-dependent → 發展好 farm 自然拿多份）。新 `static farm_labor(tile)` = `share/K_FARM × LABOR_SCALE`（**level-independent**，非 fill=`share/(level×K_FARM)`）。
- **★T2 `resource_system.gd`（level-cancellation 核心修）**：farm production 改用 `farm_labor` → `fyield=level×FUY×flabor×harvest ∝ level×alloc`（level 存活、labor-starved 也隨 level 真增產）。`demand[farm]=level×K_FARM` 只作 alloc capacity cap、不除進 production。
- **T3 `food_flow.gd`:46-49 + `marginal_economy.gd`:21-30（估算器）**：移原始 `farming_bonus=1+level×0.5` 乘性 boost（R² 訂正:main 仍原始、v1 未 merge → 整條從零替換），改 `farm_contribution=level×FUY×harvest×farm_labor`（estimator==production 同源、god-view 防線守 VillageEstimate est-only 欄、感知鐵律 own-tile self）。`faction_ai facility_roi` 下游自動繼承。

## v1 vs v2 根因（治斷崖）

v1 只動 weight-side（`_food_group_need`），需求端 production 式 `fyield=level×FUY×(share/(level×K_FARM))×harvest` 的 level **分子分母相消** → farming_level 升不增產（斷崖根、v1 誤判為 fine）。v2 解耦 fill/demand → level 生效。

## Gates

- **★CORE ③（治 cancellation 硬證）**：`labor_marginal_v2_test.gd` **7/7 PASS**。FIXED alloc share=5、level 1/2/3 → production **L1 2.00 < L2 4.00 < L3 6.00**（level 真升）；對照舊 fill 式 **L1 2.00 == L3 2.00**（v1 FAIL 根，同測坐實）。含 ① 食物 per-labor yield 分配（farm 拿多份）④ magnitude 守 FUY 2.0 不爆（full L3=18=level²×FUY bounded）⑤ estimator==production 同源（勞力飽和誠實 + level 生效）。
- **constitution**：PASS，sites=77（無新違憲）。
- **determinism**：seed1337 warring 1000t **byte-identical ×2**（godot-detach）fp=`ed832403654a4b887e2eb740a27219df`。純算術**零新 randf**。
- **fp 說明**：warring 1000t **dormant**（無發展農田 → farm_contribution≈0 → fp 同 base；治斷崖只 manifest 於 measurer settled/developed-farm bed）。behavior slice、fp intended-change 應現於農田發展床、非 warring。

## ⚠️ 待 measurer（本 session 環境限制）

- **headless full-run 0-new 本 session reap-blocked**（bg-task reaping 殺長 run + 機器慢）→ **未自驗**。labor allocation 改動風險破 labor/production headless 測（同 v1/agriculture-b 教訓）→ 請 measurer 跑 full `headless_test.gd` 確認 0-new + 指出待訂正測。
- **★production 隨 level 真升（核心 gate）於 settled bed**：CORE ③ 已代數/單測坐實 farm_labor level-independent + production∝level×alloc；請 measurer 在發展農田床實跑確認 share 隨發展 + B5 瀕餓食勞力飆 + 動員照抽 + 守恆 + starve 不升。

地基 KEEP（MarginalEconomy/FoodFlow/LaborSystem est-based god-view 防線不動）。
