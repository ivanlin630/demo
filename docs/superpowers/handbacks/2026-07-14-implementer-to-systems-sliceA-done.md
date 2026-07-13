---
from: implementer
to: systems
status: open
topic: [全 Slice A 完] 人格化資源預算架構 (feat/survival-layer-unify 67d4a47)——層0 boost 頻率初值 9.46%(偏高,回報) + Fix3c barter fire ✓
---

# Hand Back：全 Slice A（人格化資源預算架構）

branch `feat/survival-layer-unify` @ `67d4a47`（push 完，併上 v1 4-fix + v2）。全部做完，一次量測（用戶鐵律）。

## 觸及檔（Slice A 增量）
- `decision_engine.gd`：層0 survival boost（`u *= _coeff` 之後，寫死此序）+ `SURVIVAL_BOOST_FLOOR/MAX` const + `survival.boost_fire` probe。
- `need_hierarchy.gd`：真根3 註解翻正（刪「野心餓死=特色」）；退役 ESTEEM_REF consts/esteem_food_ref → 呼 `DecisionTerms.food_security_target`；§2 注解人格 trait 合規（v2 已補）。
- `terms.gd`：候選2 單一 `food_security_target(慎重/野心)` helper + `FOOD_SEC_*`/`SECURITY_STOCK_DRIVE` const；層5 buyfood_drive 加食物安全 gap-to-target 驅力。
- `decision_context.gd`：Fix3c has_specie 加武器超留底。
- `trade_valuation.gd`：候選1 food reserve 人格化（`food_security_target×pop×FOOD_PER_PERSON_PER_DAY`，退役 pop×0.1×20 死常數）+ `leader_vals(state,team)` helper。
- `interaction_system.gd`/`player_trade_system.gd`：thread leader_values 到 barter/market/player sell 路徑（候選1）。
- `specimen_tracer.gd`：dump 加 leader traits（性格顯性化，補充信）。
- `scripts/debug/survival_layer_unify_test.gd`（TDD 擴充）、`slice_a_observe.gd`（新觀測 bed，measurer 可用）。

## Sanity（全綠）
- **TDD unit（27 斷言）**：ALL PASS——含層0 boost 破頂（food=1 覓食 util 1.73 奪 argmax）+ 邊界 food=FLOOR 平滑（boost=0）+ 層5 gap 人格分化（謹慎買糧驅>賭徒）+ 候選1 reserve（謹慎64>中性32>賭徒16）+ 候選2 target + Fix2/Fix3 v2。
- **headless ≥1000tick**：主 sim 無崩，assertion 只剩 **3 個既存 baseline 失敗**（p2a join/戰鬥 resolve/擴張 intent，與 main 一致，非本 slice）。**slice A 零新增失敗**（2 個 buyfood 微測已隨層5 遷移）。
- **憲法閘**：`PASS (sites=29, removed=0)`。
- **determinism**：`seeded warring reproducible OK (seed=1337, pop=444)`——全新 const/函式純算術零 randf。
- **reeval_attribution_bed**：reeval.crisis=48（未爆回千位）。

## ★驗收 0b：層0 boost 觸發頻率初值（measurer 要，我回報不自判）
`slice_a_observe.gd`（seed1337 default 3mo）：
- **survival.boost_fire = 1886 / decision.coeff_applied_n = 19944 → 9.46%**。
- **★偏高**：願景要「正常隊幾乎不觸發（安全氣囊非日常剎車）」。9.46% 暗示**層1/2/5 安全網未攔住隊掉到 <2 天危機區**（驗收鐵律 0b「常觸發＝安全網失職」）。
- **回報非自判**：這是安全網 tuning 訊號（層1 GRADUAL/層2 target/層5 SECURITY_STOCK_DRIVE 皆 TEST VALUE，可能太保守），**非 boost 壞**。measurer 全維度驗後，systems/blueprint 評是否調安全網常數。boost 本身機制正確（unit 證破頂+平滑）。

## Fix3c barter 驗（headline 第三條）
`slice_a_observe.gd`：coinless 武備隊（食5、coin0、weapon_melee_low 30）→ **has_specie=true**（Fix3c 前=false 機械餓死）；`_attempt_barter` fire：**food 5→142，weapon 30→11**（賣 19 超留底、守 11 reserve）。★武器換糧存活路徑真通，Team14 型「滿手武器餓死」消除。

## ★待確認 / scope 註（層5 範圍誠實回報）
- **層5 concrete 落地 = 食物簇（buyfood_drive gap）**。**軍備/發展類別 gap**：`生產/建設` 已由既有 `ambition_drive`(∝ambition_gap) 承載「發展 gap」；**「軍備採購」無獨立 spending option**（武器經 order/貿易/生產，非離散 decision option）→ 本 slice **無法對「軍備類別」接離散 gap drive**。∴ 層5 新 wiring 集中在買糧食物 gap（headline attrition 相關）。若你要軍備類別獨立 target/drive，需先定義軍備 spending option（超本 slice scope，建議 follow-up）。**請確認此 scope 詮釋 OK**（我依「無新 option」原則未捏造軍備 option）。
- candidate1 food reserve default（無 leader_values 的 caller）= BASE target 4 天；主 sell 路徑（barter/market/player）已 thread 人格值。

## 完成判定歸 systems+reviewer（我不自判）
待你 + reviewer merge-time 複審 + measurer 全維度驗（headline: attrition 回落≈baseline / boost 頻率健康度 / 性格顯性化分化 / Fix3c 武備隊存活 / 層4 鋸齒三態）。我 hold warm 等 `to:implementer` 裁決信。**未自寫 consumed、未自判 done。**
