---
from: systems
to: implementer
status: open
topic: "[dispatch build recovery-path Slice R3 遷村令(復甦 arc 收官末 slice、R² CLEAN reviewer 直接 code 驗證 compound reuse)·feat/recovery-r3 off 更新後 main(含 R1+R2 merged:MarginalEconomy/VillageEstimate/_inflow_est/in_transit_letters/_dispatch_convoy 皆在)·spec §2C+§3·範圍:①MarginalEconomy 加 relocate_value(current_est, target_est)=_inflow_est(target)前景−_inflow_est(current)−sunk_penalty(persist_strength 沉沒);全 belief VillageEstimate(同 R1/R2 結構防線、_inflow_est 拿不到 live target)②_try_relocate_order 掛 info_side_dispatch:領主秤自家村 relocate_value+領主人格→下遷村令=in_transit_letters kind='relocate' payload=target_tile(reuse letter infra kind-agnostic、只 deliver 分支加 relocate case、真送達非瞬間 throttle 一令/村);★relocate 目標 god-view gate=領主令 target 限領主已知領土(own-faction 行政知、同 §1.0 結構欄來源)、禁 god-view 全地掃最佳③村自願遷:村秤 relocate_value>閾→自發;target 限 vision-explored/reachable(鏡射遷移找糧 options.gd:288)④★★村遷村執行端(驗執行端命門、reviewer 直接 code 驗 compound):整村 relocate=generalize _action_abandon_outpost(player_command:525-536 單行 OutpostOwnerBank.set_owner(tile,-1)零耦合)→AI 棄據點→村轉 mobile population 隨隊→TASK_SETTLE target→_convert_to_resident(★實在 interaction_system:1363-1382 非 faction_ai:2142[呼叫點/行號 drift]、函式夠通用 TAG 條件移除+detach 無 parent no-op)於新 tile 落腳·★reviewer 點的具體風險=整 team(非 subteam)走這條 compound 是否有被略過細節、測試必含此⑤遷村令收令 handler=村從抗人格秤(忠懼→從帶怨 unrest 累積 reuse cohesion/傲戀土→抗命=genuine 人格秤非死常數門檻);抗命後果=領主人格(算了/斷賑濟停 distribute/武力押遷=軍事 arc 只留鉤 P5 起義叛離出口承接暴君逼反、本 slice 不實作強遷)·守:god-view 結構防線/零死常數(從抗 relocate util 真值)/真成本(棄據點沉沒+路程)/determinism byte-identical/constitution 74·★★驗執行端(R1/R2 血證、reviewer 硬標):測試跑真全 advance_tick pipeline 驗村真完成遷(棄據點→抵 target→settle→resident 於新 tile、非只決策 fire)+從抗分化(忠村從/傲村抗)+tap relocate.ordered/abandoned/arrived/resettled/comply/resist/unrest_added·完成 handback to:systems R²(merge-gate 核 compound 執行端整 team 真完成遷+從抗 genuine+god-view 防線)→measurer 量(令送達+從抗分化+怨→叛/起義劇情鏈+爛地村真遷走)→QA→merge=復甦 arc 收官→轉框架收尾·地基 KEEP"
---

# dispatch build recovery-path Slice R3 遷村令（復甦 arc 收官末 slice）

R² **CLEAN**（reviewer 直接 code 驗證 compound reuse 非文字類比）。`feat/recovery-r3` off 更新後 main（含 R1+R2 merged：MarginalEconomy/VillageEstimate/_inflow_est/in_transit_letters/_dispatch_convoy 皆在）。spec §2C+§3。

## 範圍
1. **`MarginalEconomy.relocate_value(current_est, target_est)`** = `_inflow_est(target)` 前景 − `_inflow_est(current)` − `sunk_penalty`（persist_strength 沉沒）；全 belief `VillageEstimate`（同 R1/R2 結構防線、`_inflow_est` 拿不到 live target）。
2. **`_try_relocate_order`** 掛 info_side_dispatch：領主秤自家村 relocate_value + 領主人格 → 下遷村令 = `in_transit_letters` kind=`'relocate'` payload=target_tile（reuse letter infra kind-agnostic、只 deliver 分支加 relocate case、真送達非瞬間、throttle 一令/村）。
   - ★**relocate 目標 god-view gate**：領主令 target 限**領主已知領土**（own-faction 行政知、同 §1.0 結構欄來源）；禁 god-view 全地掃最佳。
3. **村自願遷**：村秤 relocate_value>閾→自發；target 限 **vision-explored/reachable**（鏡射遷移找糧 options.gd:288）。
4. ★★**村遷村執行端**（驗執行端命門、reviewer 直接 code 驗 compound）：整村 relocate = generalize **`_action_abandon_outpost`**（player_command:525-536 單行 `OutpostOwnerBank.set_owner(tile,-1)` 零耦合）→ AI 棄據點 → 村轉 mobile population 隨隊 → `TASK_SETTLE` target → **`_convert_to_resident`（★實在 interaction_system:1363-1382、非 faction_ai:2142[呼叫點/行號 drift]、函式夠通用 TAG 條件移除+detach 無 parent no-op）** 於新 tile 落腳。
   - ★**reviewer 點的具體風險**：整 team（非 subteam）走這條 compound 是否有被略過細節、**測試必含此**。
5. **遷村令收令 handler** = 村**從抗人格秤**（忠懼→從帶怨 unrest 累積 reuse cohesion / 傲戀土→抗命 = genuine 人格秤非死常數門檻）；抗命後果 = 領主人格（算了/斷賑濟停 distribute/武力押遷=**軍事 arc 只留鉤** P5 起義叛離出口承接暴君逼反、本 slice **不實作強遷**）。

## 守 + ★★驗執行端（R1/R2 血證、reviewer 硬標）
- 守：god-view 結構防線 / 零死常數（從抗/relocate util 真值）/ 真成本（棄據點沉沒+路程）/ determinism byte-identical / constitution 74。
- 測試跑**真全 advance_tick pipeline** 驗村真完成遷（棄據點→抵 target→settle→resident 於新 tile、**非只決策 fire**）+ 從抗分化（忠村從/傲村抗）+ tap `relocate.ordered`/`abandoned`/`arrived`/`resettled`/`comply`/`resist`/`unrest_added`。
- 完成 → handback `to:systems`（R²、merge-gate 核 compound 執行端整 team 真完成遷 + 從抗 genuine + god-view 防線）→ measurer 量（令送達 + 從抗分化 + 怨→叛/起義劇情鏈 + 爛地村真遷走）→ QA → merge = **復甦 arc 收官 → 轉框架收尾**。地基 KEEP。
