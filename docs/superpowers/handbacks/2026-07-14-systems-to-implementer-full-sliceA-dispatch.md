---
from: systems
to: implementer
status: open
topic: [GO·全slice A整包] 求生預算人格化架構(層0+1+2+3+5+候選1+候選2)一次做完再一次量測;reviewer二次異質框外審CLEAN
---

# [GO] 全 Slice A 整包 dispatch

reviewer 兩輪異質框外審 CLEAN（架構 `64f0fb70` + 層0 `2026-07-14-reviewer-to-systems-layer0-survival-magnitude-r2-verdict.md`）。spec **全讀**：`2026-07-14-survival-budget-personality-architecture.md`（傘）+ `2026-07-13-survival-layer-unify-3fix.md`（層1-3 本體/Fix3c）。

**改同一 branch `feat/survival-layer-unify`**（層1-2 已在，補其餘）。**★用戶鐵律：全部做完再一次量測，不半套 bisect**。HOLD 解除。

## 做什麼（spec 內部 build 序）

### ★層0 求生 util 量級復原（地基，優先，真根）
`decision_engine.gd rank_scored_ctx`：算完 `u *= _coeff`(:29) **之後**（★★寫死此序，別在 coeff 前，否則被 0.15 floor 打折失效）加：
```
if ctx.food_days < SURVIVAL_BOOST_FLOOR and opt in DecisionOptions.SURVIVAL_OPTION_SET:
    u += SURVIVAL_BOOST_MAX * (SURVIVAL_BOOST_FLOOR - ctx.food_days) / SURVIVAL_BOOST_FLOOR
```
- const `SURVIVAL_BOOST_FLOOR`(~2 天)、`SURVIVAL_BOOST_MAX`(~2.5) TEST VALUE。**全 SURVIVAL_OPTION_SET，勿縮範圍**（reviewer #1）。
- 效果：極低糧統一隊 survival 破 1.0 封頂奪 argmax，不再發展死。純算術零 randf。

### 真根3 立場翻正
`need_hierarchy.gd:70-71` 註解刪「野心餓死=特色/角色缺陷致死非 bug」→ 改「性格調日常風格(層2/5)，層0 boost 保證極端不結構性餓死」。（純註解，grep 確認無 code 依賴。）

### 層3 Fix3c 償付能力認武器
`decision_context.gd:211-214` has_specie 加武器超留底（見 3fix spec §Fix3c）。★順手跑 coinless+武器 specimen trace 確認 barter 真 fire。

### 候選2 統一人格門檻框架 + 層2 收編
- `DecisionTerms` 立單一 `food_security_target(leader_values)` = f(慎重/野心)（收編現 Fix3-v2 `esteem_food_ref`——別雙常數；need_hierarchy import DecisionTerms，有先例）。TEST VALUE clamp [MIN~2, MAX~8]。
- 本輪**只接食物簇**（食物安全/軍備/發展三類別 + 相關 option）；非食物 gate（佔村/血仇/匱乏搶/capability）不動（known_issues follow-up）。

### 層5 預算分配（類別 gap-to-target drive）
- 定 `food_security_target`/`military_target`/發展 default 類別目標(f 人格)。
- 花費 option（買糧/囤貨/軍備採購/生產/建設）drive 改吃「該類別 gap-to-target」（連續信號，沿用既有 terms drive + coeff 架構，**無新 band/判斷器、無 spending ledger、stateless**）。
- 處境 override 接既有 survival coeff 饑荒攀升，不新增硬閘。

### 候選1 賣糧 reserve 人格化
`trade_valuation.gd:58-63` food reserve `pop×0.1×FOOD_RESERVE_TICKS` → `food_security_target(leader)×pop×FOOD_PER_PERSON_PER_DAY`（同一 target；對齊 aid-reserve `interaction_system:1000-1002` 人格化先例）。

## TDD + sanity
- failing test 先行：層0 boost（food_days=1 統一隊 survival 破頂勝建設 / food_days=5 不觸發）、候選2 target 人格分化、層5 類別 gap drive、候選1 賣糧 reserve 人格化。
- headless（只剩 3 既存 baseline 失敗）+ determinism（新 const/函式純算術）+ 憲法閘綠 + reeval_attribution_bed 跑得動。

## 完成判定歸 systems+reviewer（你不自判）
全 slice A 做完 handback `to:systems status:open`，附觸及檔 + sanity + **層0 boost 觸發頻率初值**（measurer 要）+ specimen trace(Fix3c barter) + 意外。★別自寫 consumed/自判 done。hold warm 等裁決。

## 觸及檔
`decision_engine.gd`(層0)、`decision_context.gd`(Fix3c has_specie + 類別 gap/target)、`need_hierarchy.gd`(真根3 註解 + import target)、`terms.gd`(單一 food_security_target + 層5 drive)、`trade_valuation.gd`(候選1)、`team_data.gd`(若需 target 快取)。
