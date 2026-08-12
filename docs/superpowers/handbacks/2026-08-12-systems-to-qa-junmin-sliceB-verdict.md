---
from: systems
to: qa
status: consumed
topic: "[QA adversarial release verify:军民混编 Slice B(charter/mobilization split guns-vs-butter)·feat/junmin-militia-slice-b d9d396df·★systems merge-gate 硬讀 CLEAN+一個我方訂正(bucket-D 誤分類)·merge-gate 確認:①_update_mobilization=clampf(charter梯度 base[軍團0.7/後備0.3/居民0.05]+belief-threat×0.5+好戰×0.15−0.075,0,1)genuine 湧現 bounded 無 randf、belief-threat 走 Slice A _max_belief_threat 感知鐵律②labor_pop=pop×(1−mob)、pool_of/rebalance 用之=guns-vs-butter③finding④ labor_share=labor_pop/pool_of 分子分母同步分數化(manufacturing+resource)→≤1 Σ≤1④F 裝備 equip gate mob≥0.5 取代靜態 TAG_MILITARY⑤finding③ 動員態變>EPS→labor_eval_next_tick=0 觸重算⑥charter A 路由 uses_unified/E 薪資pop/C 居民鎖 UNCHANGED(diff 未觸=正交零 churn)、無新 randf determinism byte-identical·★★systems 訂正(誠實、我 spike/dispatch 誤):bucket-D(interaction:395 prey_resident/301/303 pacify/521 tribute/diplomatic:263)硬讀=charter-分類(村=劫掠目標/可撫/可稅、村動員與否仍是村-target)非 mobilization-脆弱度→讀 charter(TAG)正確、我誤歸 D「讀 fraction」;implementer 誠實 flag 行號 stale 未 guess-edit=正確紀律;genuine mobilization-脆弱度=戰力弱(解甲→equip gate false→高階武跳過→armed 低→combat 弱)=F-emergence 達、無 gap D 不需顯式改·★請 QA adversarial(讀 code+親算+specimen、6gap+committed-task 教訓):①★威脅→動員→產出掉(mobilized_fraction 0.05→0.55、labor_pop 降、labor_share/worker_rate 掉=guns-vs-butter 真成本 machine-demonstrate)②★和平解甲(威脅除→mob 降→labor 回產出回)③團型梯度分化(軍團0.7>後備0.3>居民0.05 base+威脅回應)④★labor_share≤1 硬證(finding④、全動員 labor_pop=0/多隊 Σ≤1)⑤★charter 消費者零 churn 正交性(路由/薪資/居民鎖 byte-identical、村動員民兵時 uses_unified 不翻=split 正交硬證)⑥★D-脆弱度 F-emergence sanity(解甲隊 combat 真弱否 or charter-target 正確否、覆核我訂正)⑦finding③ cache+determinism byte-identical+constitution 75(TAG_MILITARY equip gate→mob 記錄)+regression·★fp 前後對照 warring DIVERGED mobilize_peak 0→1.0·CLEAN→systems merge(stale-base 先驗)→blueprint 推用戶(军民混编完整 guns-vs-butter+團型分化);有洞→halt·地基 KEEP"
---

# QA adversarial release verify：军民混编 Slice B（charter/mobilization split）

`feat/junmin-militia-slice-b` `d9d396df`。★systems merge-gate 硬讀 **CLEAN** + 一個我方訂正（bucket-D 誤分類）。

## merge-gate 硬讀確認
1. `_update_mobilization = clampf(charter梯度 base[軍團0.7/後備0.3/居民0.05] + belief-threat×0.5 + 好戰×0.15 − 0.075, 0, 1)` genuine 湧現、bounded、無 randf、belief-threat 走 Slice A `_max_belief_threat`（感知鐵律）。
2. `labor_pop = pop×(1−mob)`、pool_of/rebalance 用之 = guns-vs-butter。
3. **finding④** `labor_share = labor_pop/pool_of` 分子分母同步分數化（manufacturing+resource）→ ≤1、Σ≤1。
4. F 裝備 equip gate `mob≥0.5` 取代靜態 TAG_MILITARY。
5. **finding③** 動員態變>EPS → `labor_eval_next_tick=0` 觸重算。
6. charter A 路由 uses_unified / E 薪資pop / C 居民鎖 **UNCHANGED**（diff 未觸=正交零 churn）、determinism byte-identical。

## ★★systems 訂正（誠實、我 spike/dispatch 誤）
bucket-D（`interaction:395 prey_resident`/`301/303 pacify`/`521 tribute`/`diplomatic:263`）硬讀 = **charter-分類**（村=劫掠目標/可撫/可稅、村動員與否仍是村-target）**非 mobilization-脆弱度** → 讀 charter(TAG) **正確**、我誤歸 D「讀 fraction」。implementer 誠實 flag 行號 stale 未 guess-edit = **正確紀律**。genuine mobilization-脆弱度 = **戰力弱**（解甲→equip gate false→高階武跳過→armed 低→combat 弱）= F-emergence 達、**無 gap、D 不需顯式改**。

## ★請 QA adversarial（讀 code + 親算 + specimen）
1. ★**威脅→動員→產出掉**（mobilized_fraction 0.05→0.55、labor_pop 降、labor_share/worker_rate 掉 = guns-vs-butter 真成本）。
2. ★**和平解甲**（威脅除→mob 降→labor 回產出回）。
3. **團型梯度分化**（軍團0.7>後備0.3>居民0.05 base + 威脅回應）。
4. ★**labor_share≤1 硬證**（finding④、全動員 labor_pop=0 / 多隊 Σ≤1）。
5. ★**charter 消費者零 churn 正交性**（路由/薪資/居民鎖 byte-identical、村動員民兵時 uses_unified 不翻 = split 正交硬證）。
6. ★**D-脆弱度 F-emergence sanity**（解甲隊 combat 真弱否 or charter-target 正確否、**覆核我訂正**）。
7. finding③ cache + determinism byte-identical + constitution 75（TAG_MILITARY equip gate→mob 記錄）+ regression（junmin_guard/active_promotion/named_scarcity_ab）。
- ★fp 前後對照 warring DIVERGED、mobilize_peak 0→1.0。

CLEAN → systems merge（stale-base 先驗）→ blueprint 推用戶（军民混编完整 guns-vs-butter+團型分化）；有洞→halt。地基 KEEP。
