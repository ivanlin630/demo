---
from: systems
to: blueprint
status: consumed
topic: "[★gather-yield WHY 收口(CLOSE、真值逐事件、非 code-guess)·binding=labor_mult(gather:food workstation fill)決定性主兇=240x 差來源、枯池/技能/效率/productivity 全排除(team87 池226.8≈team47 268.7 但 gain 差410x=枯池決定性反例)·5團(70/83/87/109/111)57-80% 採集 tick labor_mult 硬零=多數時候根本沒分到勞力採糧(硬零非低值)·機制(labor_system:36-90):tile 共用勞力池 rebalance()、gather:food 跟 gather:material/mfg:* 搶同一小 pool(pool=Σ共址 PRODUCE 隊 labor_pop、按 _workstation_need weight 比例分)·★systems code-logic 收窄硬零成兩候選根(:66-83、禁預設哪個、measure 定):（a）wgt[gather:food]=0=NeedOracle food need_keep+demand=0(餓著卻不報食物需求=famine-blind need-oracle=bug、連統一矩陣 need-oracle arc)（b）pool=0=共址 PRODUCE 隊 labor_pop 全動員(guns-vs-butter warring 選軍不選糧=genuine tradeoff、連軍民混編 arc)·測法:dump 全 tile.labor_alloc→別工位有勞力但 food 沒=(a)/全 0=(b)·★arc scope 定案含意:單修接入不夠(已 resident 團被 labor 分配餓死、新接入重蹈)、arc 必動 labor→food-under-famine 這條·★9居民 has_tag_produce 全 100% True(排除缺 tag 簡單解)·★ownership-mismatch 這輪 measurer 未報(labor_mult 太決定性、食物幾乎沒採到 where-deposit moot=次要、未跑非結論)·honest:_workstation_need 同格競爭細節+(a)/(b)分辨=下票 pre-spec·禁 over-claim(收窄到兩 testable 根、哪個=measure)·evidence-only 禁 fix·序:你帶用戶(gather-yield 卡 labor 分配非枯池非懶)+定 arc scope(接入+labor-food-allocation)→下票分 a/b·地基 KEEP"
---

# ★gather-yield WHY 收口 — 卡在 labor 分配、非枯池非懶非技能

CLOSE（真值逐 harvest 事件 dump 全乘數、非 code-guess）。evidence-only、禁 fix。

## ★binding = labor_mult（gather:food workstation fill）決定性主兇
- 240x 採集差**全來自 labor_mult**：各團 labor_mult 倍率（47÷團）5x-**415x**、其餘因子（current/productivity/harvest_factor/prod_skill/labor_share）全 0.6-13x，疊乘也解釋不了。
- **枯池決定性排除**：team87 池 226.8 ≈ team47 268.7（僅 1.18x）但 gain 差 **410x**。池普遍健康（62-268）。
- **5 團（70/83/87/109/111）57-80% 採集 tick `labor_mult` 硬零**（精確 0、非低值）= 那 tick 不管池多滿都 gain=0 = **多數時候根本沒分到勞力去採糧**。

## ★機制（labor_system:36-90、file:line 非猜）
`labor_mult = fill × LABOR_SCALE`；`fill` 是 **tile 共用**（非 per-team）由 `rebalance()` 算：
- `pool` = 該 tile 上所有 **TAG_PRODUCE 共址隊 `labor_pop` 加總**（★:42 註「動員後只算未動員勞力 guns-vs-butter」）。
- `gather:food` 跟同格 `gather:material`/`mfg:*` 各有 weight=`_workstation_need()`（:93=Σ共址隊 `NeedOracle.need_keep(food)+demand(food)`）、**按 weight 比例搶同一份 pool**、weight 輸的 workstation share 可低到硬零。

## ★★systems code-logic 收窄：硬零 = 兩候選根（禁預設、measure 定）
`labor_mult` 硬零 ⟺ gather:food share=0（:66-83 分配邏輯）。兩個互斥成因：
- **(a) `wgt[gather:food]=0`** = `NeedOracle food need_keep+demand=0` → **餓著卻不報食物需求 = famine-blind need-oracle = bug**（連 [[project_unification_matrix]] need-oracle arc；食物 need 該隨飢餓升卻沒升）。
- **(b) `pool=0`** = 共址 PRODUCE 隊 `labor_pop` 全動員 → **guns-vs-butter（warring 世界選軍不選糧）= genuine tradeoff**（連 [[project_junmin_militia_arc]]；不是 bug 是「打仗把人抽走沒人種田」）。
- ★**測法（下票）**：dump **全 `tile.labor_alloc` 字典**——**別工位有勞力但 food 沒 = (a)**；**全工位都 0 = (b)**。+ dump per-team mobilized 比例 + `NeedOracle.need_keep/demand(food)` vs famine_days 相關。

## ★arc scope 定案含意（給你帶用戶）
- **單修接入不夠**：已 resident 的團在 labor 分配裡就被餓死（whichever root）、新接入的團大機率重蹈。**arc 必動 `labor→food-under-famine` 這條**（非只讓更多團安家）。
- has_tag_produce 全 100% True（排除「缺 tag」簡單解）。

## honest / 禁 over-claim
- **ownership-mismatch 這輪 measurer 未報**（labor_mult 太決定性、食物幾乎沒採到→where-deposit moot=次要、**未跑非結論**、要可補下票）。
- (a)/(b) 分辨 + `_workstation_need` 同格競爭細節 = **下票 pre-spec**（measurer 已 flag 需讀全 labor_alloc 字典的 tap）。
- 我 code-logic 收窄到**兩 testable 根**、**哪個成立 = measure 定**（不 code-guess 最終 [[feedback_measure_peroption_util_before_decision_claim]]）。

序：你帶用戶（gather-yield 真兇=**labor 分配把採糧工位配到近零**、非枯池非懶非技能）+ 定 arc scope（接入 + labor-food-allocation）→ 下票分 (a) need-oracle famine-blind vs (b) guns-vs-butter mobilization。落地 measurer `gather_factor_trace_samples`（161 筆）。地基 KEEP。
