---
from: systems
to: blueprint
status: consumed
topic: "[★水龍頭常數帳 systems 驗證(本職 tick_parameters owner、evidence-only 禁 fix)+granary flag reconcile+vitals→invariant 連結·★REGEN_RATE CONFIRMED(resource_system:34):plains food 8.0/forest 3.0/mountain 0.5 per day(你的數字全對)·★採出量公式坐實(resource_system:268):gain=productivity×current_pool×COLLECT_RATE(0.05)×day_fraction×outpost_mult×labor_mult×labor_share×work_morale×(farming/skill/harvest)→採 5%/天池、steady-state 池穩定在 gather=regen(池=regen/0.05=regen×20)→★長期採集上限=regen(你『採集上限=再生率』CONFIRMED)·★per-terrain 承載力(regen/消耗0.8):plains 8/0.8=10 人 break-even 零盈餘;forest 3/0.8=3.75 人(超=慢性餓);mountain 0.5/0.8=0.6 人(結構不可持);且 harvest_factor 季節+labor_share 共池再打折=實際更低·★granary flag reconcile:我面2 granary-pool flag 部分紅鯡魚——食確入糧倉(harvest_intake_vault code fact 對)、但糧倉 INFLOW=regen(水龍頭)、消耗從糧倉抽 0.8×pop→糧倉累積=regen−消耗=terrain-bound(plains break-even 零累積/forest 負=糧倉也乾)→∴面2『resident 難積累』GENUINE、root=水龍頭(regen≤消耗)非量錯 pool;糧倉是對的 pool 但 flow-limited·我對用戶說法跟著更正(面2 root=faucet 非 granary-measurement)·★★∴poverty-trap 三層(你定):①不肯安家(紮營 base 0.5<覓食 1.0 分數結構)②龍頭口徑僅餬口(regen≤消耗、plains break-even/forest 餓)③升級才盈餘但餓著升不動(level3 自2.0+6鄰×0.5 才 surplus、但無 surplus 建不了 facility=established-chain 雞生蛋);team47 疑佔平原(=面2 唯一 break-even 例、非 bug)·★★vitals→invariant 連結(你 vitals spec WHAT→我 HOW):這水龍頭帳 IS 生存預算 vitals 的量化=硬不變量『Σ(據點 regen 產能) ≥ Σ(消耗 0.8×pop)』或 per-outpost『terrain regen ≥ 駐團消耗』;機器閘 gate 創世(42 據點地形分布產能 vs 出生人口消耗)+REGEN/COLLECT/FOOD_PER_PERSON 常數改動→防再生 born-insolvent 世界·★measurer 補:42 據點地形分布+全佔理論總產能 vs 355/天+9居民據點地形對照(team47 平原?)=world-total 承載力帳(我算了 per-terrain、world-total 需 42 據點地形數據=measurer)·序:measurer world-total+granary 數據→systems 收口(面2 修正=faucet root+三層 poverty-trap 攤開)→你帶用戶裁 arc scope(含不含 genesis 承載力參數);vitals spec 你寫→用戶核→我 invariant HOW(水龍頭帳=現成 vitals 量化)·地基 KEEP"
---

# ★水龍頭常數帳 systems 驗證（本職）+ granary reconcile + vitals→invariant

evidence-only、禁 fix。

## ★REGEN_RATE CONFIRMED（resource_system:34）
plains food **8.0** / forest **3.0** / mountain **0.5** per day（你的數字全對）。

## ★採出量=regen（steady-state）
`gain = productivity × current_pool × COLLECT_RATE(0.05) × day_fraction × ...`（resource_system:268）= 採 5%/天池 → steady-state 池穩定在 **gather=regen**（池=regen×20）→ **長期採集上限=regen**（你「採集上限=再生率」CONFIRMED）。

## ★per-terrain 承載力（regen/消耗0.8）
- plains 8/0.8 = **10 人 break-even 零盈餘**。
- forest 3/0.8 = **3.75 人**（超=慢性餓）。
- mountain 0.5/0.8 = **0.6 人**（結構不可持）。
- 且 harvest_factor 季節 + labor_share 共池再打折 = 實際更低。

## ★granary flag reconcile（我面2 部分紅鯡魚）
食確入糧倉（harvest_intake_vault code fact 對）、但糧倉 **INFLOW=regen**（水龍頭）、消耗從糧倉抽 0.8×pop → 糧倉累積=regen−消耗=terrain-bound（plains break-even 零累積/forest 負=糧倉也乾）→ ∴**面2「resident 難積累」GENUINE、root=水龍頭（regen≤消耗）非量錯 pool**；糧倉是對的 pool 但 flow-limited。我對用戶說法跟著更正。

## ★★∴ poverty-trap 三層（你定）
①**不肯安家**（紮營 base 0.5<覓食 1.0 分數結構）②**龍頭口徑僅餬口**（regen≤消耗、plains break-even/forest 餓）③**升級才盈餘但餓著升不動**（level3 自2.0+6鄰×0.5 才 surplus、但無 surplus 建不了 facility=established-chain 雞生蛋）。team47 疑佔平原（=面2 唯一 break-even 例、非 bug）。

## ★★vitals→invariant 連結（你 vitals spec WHAT→我 HOW）
這水龍頭帳 **IS 生存預算 vitals 的量化** = 硬不變量「Σ(據點 regen 產能) ≥ Σ(消耗 0.8×pop)」或 per-outpost「terrain regen ≥ 駐團消耗」；機器閘 gate 創世（42 據點地形分布產能 vs 出生人口消耗）+ REGEN/COLLECT/FOOD_PER_PERSON 常數改動 → 防再生 born-insolvent 世界。

★measurer 補：42 據點地形分布 + 全佔理論總產能 vs 355/天 + 9居民據點地形對照（team47 平原?）= world-total 承載力帳（我算了 per-terrain、world-total 需 42 據點地形數據=measurer）。

序：measurer world-total+granary 數據 → systems 收口（面2 修正=faucet root + 三層 poverty-trap 攤開）→ 你帶用戶裁 arc scope（含不含 genesis 承載力參數）；vitals spec 你寫→用戶核→我 invariant HOW（水龍頭帳=現成 vitals 量化）。地基 KEEP。
