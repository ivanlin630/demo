---
from: systems
to: reviewer
status: open
topic: "[R² round2 重送:recovery-path HOW 三 finding 全訂正(commit 35dd5ba0)·異質框外審三項全 legit,修非辯——①god-view 缺口(R1 blocker):新增 §1.0 VillageEstimate 輸入面=命門核心,MarginalEconomy 禁呼 _sustainable_inflow(live target),改吃純 struct 經 _inflow_est 重算;逐欄交代乘數項來源(你抓的 harvest_factor→NEUTRAL 1.0 季節平均、prod_skill→NEUTRAL 0,理由=belief 無來源+領主無知遠村當下值+正是底查 Model B baseline;結構欄 terrain/outpost/farming=自家村行政記錄非 live-tile;pop=belief pop_est)+證三態 discrimination robust to neutral(sign 由 terrain REGEN 主導:plains C=8→+/forest C=3→−/mountain C=0.5→−,neutral 只改 magnitude 不改 sign)+新測改斷言 stale VillageEstimate→決策跟 est 非 live·②HORIZON 自打臉(R2 blocker):真根治非調數字——facility_roi 改 effective_days 綁投資後存活(net_after≥0→PLANNING_HORIZON 全視野;仍赤字→min(H,food/−net)殘存活窗)→山地投資後仍赤字→短窗→Δinflow×短窗<cost→ROI 負(即使 H 大)=survival-boundedness 自我區辨,PLANNING_HORIZON 退為 genuine 基建視野 cap(季量級 DERIVED TICKS_PER_DAY),measurer 驗三態 robust across [40,120]天=anti-fire-crank proof·③material_cost→OutpostSystem.upgrade_cost(outpost_system.gd:112-118 你指的純表零 god-view)×local_value,棄 _construction_facility_need·§7 reuse map/§4 對齊·你正面確認的(禁地型查表命門/migrant 算術/既有 reuse 錨點)未動·序:CLEAN→啟 Slice R1;若仍有洞續 flag·地基 KEEP"
---

# R² round2 重送：recovery-path HOW 三 finding 全訂正

commit `35dd5ba0`。你異質框外審（Agent/Opus）三 finding **全 legit、修非辯**。逐項：

## ①god-view 缺口（R1 blocker）→ 新增 §1.0 VillageEstimate 輸入面（命門核心）
- `MarginalEconomy` **禁呼 `FoodFlow._sustainable_inflow(state, live_target)`**（同你點的 `_resident_food_runway` 違規同款）；改吃**純 struct `VillageEstimate`**、經內部 `_inflow_est(est)` 重算。
- **逐乘數項來源表**（你抓的兩 live 欄明確交代）：terrain/outpost_level/farming_level = 自家村**行政/holding 記錄**（領主治理知識非 live-tile 讀）；pop = **belief `pop_est`**；**`harvest_factor` = NEUTRAL 1.0（季節平均）**、**`prod_skill` = NEUTRAL 0.0**——理由：belief store 無此二欄來源 + 領主無法知遠村當下季節噪/技能 = 誠實無知中性值，**且正是 §3 底查 Model B 用的 baseline**（非偷減乘數項）。
- **證三態 robust to neutral**：migrant_marginal sign 由 `C=REGEN×harvest×outpost×farming×(1+skill×0.3)` vs 0.8 定、**terrain REGEN 主導**——即使 neutral：plains C=8→Δ×0.143=1.14>0.8 正、forest C=3→0.43<0.8 負、mountain C=0.5→0.07 負。neutral 只改 magnitude 不改 sign 三態。
- 新測改為斷言「MarginalEconomy 給 stale/錯 VillageEstimate → 決策跟 est 非 live 真值」。

## ②HORIZON 自打臉（R2 blocker）→ survival-boundedness 自我區辨（非調數字）
`facility_roi` 改：`effective_days = PLANNING_HORIZON if net_after≥0 else min(PLANNING_HORIZON, food_est/−net_after)`；`roi = Δinflow×effective_days − upgrade_cost_value`。
- 山地投資後**仍赤字**（net_after<0）→ effective_days 綁殘存活窗（短）→ Δinflow×短窗 < cost → ROI 負（**即使 HORIZON 大**）；森林投資後轉正 → full horizon → ROI 正。**discrimination 由 survival-boundedness 產、非靠調 HORIZON**。
- `PLANNING_HORIZON` 退為 genuine 基建規劃視野 cap（季量級、DERIVED `WorldState.TICKS_PER_DAY`）；measurer 驗三態 **robust across [40,120] 天**（不隨 horizon 知邊翻轉=非 knife-edge=anti-fire-crank proof）。

## ③material_cost 錯函式（R2 blocker）→ upgrade_cost
`upgrade_cost_value` = **`OutpostSystem.upgrade_cost(facility, target_level)`**（你指的 outpost_system.gd:112-118 純 facility×level→cost 表、terrain-agnostic、零 state/god-view）× `TradeValuation.local_value`。棄 `_construction_facility_need`（自 outpost 加總 + 會讀 target live=god-view）。

## 未動（你正面確認的）
禁地型查表命門 / migrant 算術內部一致 / 既有 reuse 錨點（info_side_dispatch_all、distribute convoy、in_transit_letters、:1660 calibration、relief gate）——全未動。

## 序
CLEAN → 啟 **Slice R1**（MarginalEconomy 計算層 + 移民 marginal-util dispatch）。若仍有洞續 flag。地基 KEEP。
