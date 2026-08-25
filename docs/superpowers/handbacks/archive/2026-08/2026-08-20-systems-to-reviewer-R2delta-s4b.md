---
from: systems
to: reviewer
status: consumed
topic: "[R² delta 審 §4b(三動機+擴點純邊際帳+overflow margin 決策化)·spec=2026-08-20-settlement-S4b-expansion-marginal-HOW.md·前置 §4a MERGED f003ebe5·R①免(前提=結構事實 file:line:紮營 applicable not has_own_outpost=擴張缺口/_evaluate_new_outpost_location:4058/_dispatch_builder:3617/faction_ai:4307-4312 既有評估→派樣板/ctx.idle_labor decision_context:37,229/MarginalEconomy._inflow_est:15 只吃 VillageEstimate/check_overflow_for_team:24-41 無條件)·★審點:①★零新旋鈕真的成立嗎:util=分點期望邊際−建置成本−家內邊際、我宣稱只讀既有(idle_labor/_inflow_est/settler 配額/construction ticks)——哪一項會被迫發明常數?尤其『家內每手邊際』與『分點期望邊際』兩者量綱可比嗎(前者來自 idle_labor 手數、後者來自 _inflow_est 食物/日)?量綱不可比=偷偷需要換算係數=新旋鈕②★VillageEstimate 構造候選地 est 的合法性:terrain/harvest_factor 讀候選 tile 地理(公共知識、比照既有選址評分)、pop 用擬派 settler 數——這樣構造出來的 est 會不會變成 god-view 後門(用真實地理算未來村產、繞過 belief)?既有 camp_marginal/migrant_marginal 怎麼構 est 的、我該沿用哪個 pattern③overflow margin=1.15:R² 上輪你判 margin 優於純 delay、我採納;但 1.15 這個值+『決策層有機會先動作』的假設要不要 gate 驗(擴點 util 真的會在 pop 接近 cap 時升到贏過其他 option 嗎?還是只是理論)④delegate 路的 zombie 風險:擴點 to_task 回 delegate、實際寫入在 _dispatch_builder 內——這條路有沒有跟 §4a 同款『try_set 前先寫世界』的 race?(我沒細追、請你查 goal_resolver/dispatch 那條既有 delegate 路)⑤三動機互斥性:紮營(not has_own_outpost)vs 擴點(has_own_outpost)天然互斥、但『有家但家很爛』的隊會不會兩邊都不 fire(=新的靜默死角)·gate 已含 §4a deferred empirical 兩項·CLEAN→我 dispatch·地基KEEP"
---
# R² delta 審：§4b（三動機 + 擴點純邊際帳 + overflow margin 決策化）
spec=`docs/superpowers/specs/2026-08-20-settlement-S4b-expansion-marginal-HOW.md`。前置 §4a MERGED `f003ebe5`。R① 免（前提=結構事實、file:line 可查）。
## ★審點
1. **★零新旋鈕真的成立嗎**：`util = 分點期望邊際 − 建置成本 − 家內邊際`，我宣稱只讀既有（`idle_labor`/`_inflow_est`/settler 配額/construction ticks）——**哪一項會被迫發明常數**？尤其**「家內每手邊際」與「分點期望邊際」量綱可比嗎**（前者來自 `idle_labor` **手數**、後者來自 `_inflow_est` **食物/日**）？**量綱不可比=偷偷需要換算係數=新旋鈕**。
2. **★`VillageEstimate` 構造候選地 est 的合法性**：terrain/harvest_factor 讀候選 tile 地理（公共知識、比照既有選址評分）、pop 用擬派 settler 數——**會不會變成 god-view 後門**（用真實地理算未來村產、繞過 belief）？既有 `camp_marginal`/`migrant_marginal` 怎麼構 est、**我該沿用哪個 pattern**？
3. **overflow margin=1.15**：你上輪判 margin 優於純 delay、我採納；但**這個值 + 「決策層有機會先動作」的假設要不要 gate 驗**（擴點 util 真的會在 pop 接近 cap 時升到**贏過其他 option** 嗎、還是只是理論）？
4. **delegate 路的 zombie 風險**：擴點 `to_task` 回 delegate、實際寫入在 `_dispatch_builder` 內——**這條路有沒有跟 §4a 同款「try_set 前先寫世界」的 race**？（我沒細追、請你查既有 delegate 路。）
5. **三動機互斥性**：紮營(`not has_own_outpost`) vs 擴點(`has_own_outpost`) 天然互斥，但**「有家但家很爛」的隊會不會兩邊都不 fire**（=新的靜默死角）？
gate 已含 §4a deferred empirical 兩項。CLEAN → 我 dispatch。地基 KEEP。
