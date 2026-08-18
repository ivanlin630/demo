---
from: systems
to: reviewer
status: open
topic: "[R² perf刀3=alloc-churn sweep(hot-path FactionAISystem.new() finder靜態化)HOW審·spec=2026-08-18-perf-phase2-cut3-alloc-sweep-HOW.md·R①免(前提quantify+grep坐實)·★審點:①★前提fact-check(負斷言我wc先):FactionAISystem.new()全樹41處/hot decision path 30(options15/goal_resolver7/need_oracle4/decision_context4)確認?呼的全是finder/query method確認?②★★finder statelessness(靜態化安全命門):instance state僅_last_site_sig:3548/_last_dispatch_fail:3550只用dispatch類(_log_dispatch_fail/_dispatch_builder/_evaluate_storage_visit/_evaluate_new_outpost_location)零hot finder用=hot finders stateless→可static→byte-identical?★但finder內部若呼別的instance method鏈可能間接碰state=你逐finder查鏈(尤_find_own_outpost 9×最大量、market finders)有無隱藏instance依賴?③補丁閘static-ize=刀A同族純refactor非新機制④無新常數⑤感知鐵律finder邏輯不變·憲章gate=byte-identical 3跑+quantify n≥2 noise-check(刀D單跑噪聲誤判教訓)·★止損:quantify落噪聲→perf arc收官(blueprint準則)·待R²CLEAN→dispatch·與農業平行·地基KEEP"
---
# R² perf 刀3=alloc-churn sweep（hot-path FactionAISystem.new() finder 靜態化）HOW 審
spec=`docs/superpowers/specs/2026-08-18-perf-phase2-cut3-alloc-sweep-HOW.md`。R① 免。
## ★審點
1. **★前提 fact-check（負斷言、我 wc 先）**：`FactionAISystem.new()` 全樹 41 處 / hot decision path 30（options15/goal_resolver7/need_oracle4/decision_context4）確認？呼的全是 finder/query method 確認？
2. **★★finder statelessness（靜態化安全命門）**：instance state 僅 `_last_site_sig:3548`/`_last_dispatch_fail:3550` 只用 dispatch 類、零 hot finder 用=hot finders stateless→可 static→byte-identical？**★但 finder 內部若呼別的 instance method 鏈可能間接碰 state**=你**逐 finder 查鏈**（尤 `_find_own_outpost` 9× 最大量、market finders）有無隱藏 instance 依賴？
3. 補丁閘 static-ize=刀A 同族純 refactor / 4. 無新常數 / 5. 感知鐵律 finder 邏輯不變。
憲章 gate=byte-identical 3 跑+**quantify n≥2 noise-check**（刀D 單跑噪聲誤判教訓）。★止損：quantify 落噪聲→perf arc 收官（blueprint 準則）。待 R² CLEAN → dispatch。與農業平行。地基 KEEP。
