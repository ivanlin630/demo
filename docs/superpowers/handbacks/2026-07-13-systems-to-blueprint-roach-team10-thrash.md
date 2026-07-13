---
from: systems
to: blueprint
status: consumed
topic: [★蟑螂確診·待用戶定序] Team10非-unified求生override thrash致死=比crisis-381更根本;decision-core結構fix,要不要現在修
measured_at_head: 98a9841
---

# 蟑螂普查有真貨：Team10 求生 override thrash 致死

measurer 普查（`2026-07-13-measurer-to-systems-roach-scan-result.md`，consumed）找到 1 真蟑螂 Team10（seed1337），我逐行讀 code 坐實根因。**這比 ②crisis-381 更根本**（381 只是重評太頻＝perf/頻率；這條是**真殺隊**）。

## 現象（血證）
非-unified 隊 Team10 絕境(days_left=0)時 task 每 tick 在 `建設→貿易→idle→建設…` livelock，`[Order] buy food` 有下但 task 從不穩定執行滿週期 → famine 7→13 天累加 → day89 三 anon 餓死、滅團。log：`docs/measurements/2026-07-13-roach-scan-team10-thrash-1337.log:1-71`。

## 根因（補丁閘/dual-owner，逐行坐實）
1. **兩個決策生產者同 tick 打架**（tick loop `:680 _evaluate_solo` + `:737 _evaluate_survival`）：
   - `_evaluate_solo`(rank_scored)：idle 時挑 ambient「建設」。
   - `_evaluate_survival`(:3029 legacy override)：缺糧翻成「買糧→貿易」。
   - 二者不收斂 → 每 tick 互蓋。
   - **unified 隊無此病**：`:3046 if uses_unified: return` 跳過 override（求生走引擎）。∴ **override 是 unification arc 沒退役的 legacy 補丁**——非-unified 隊還跑雙生產者。
2. **加劇缺陷**：`SURVIVAL_TASKS`(:80)=[RETURN_HOME,BEG,JOIN,FORAGE,CAMP] **不含 TASK_TRADE**。買糧 maps 貿易，但 survival-latch(:3076-3094，本該 hold 住 survival task + cadence 節流)**認不得 貿易＝求生** → override 每 tick 無節流重觸發（正常 survival task 會被 latch 壓住不狂跳，貿易漏在外）。

∴ 完全命中診斷通則（補丁閘：legacy override pre-empt 引擎）+ 統一決策 arc 未竟（dual owner）。

## 修向（de-patch，非疊補丁）
**非-unified 求生也走引擎**——退役 `_evaluate_survival` override、鏡射 unified `:3046-3047` 讓求生溶進 rank_scored（survival option 已在引擎 repertoire）。**這是 decision-core 結構 fix = L1/L2，需 spec→reviewer R②→implementer**，非 inline。
（★不可 naive「加 貿易進 SURVIVAL_TASKS」了事＝會誤把商隊常態交易當求生鎖住，補丁疊補丁。）

## ★待你/用戶定序（genuine 裁決點）
這是 decision-core 結構改，且用戶正親判 main fidelity＋要收斂省 token。三選一，你/用戶定：
- **(a) 現在修**：我出 spec→reviewer→implementer 退役非-unified override。**真殺隊 bug，價值高**，但動決策核心（fidelity 判會被擾動）。
- **(b) 併 crisis de-patch 一起做**：兩者都在「求生決策層 override/throttle」家族，可能同一 spec 收斂（crisis-381 的 crisis level-trigger + 此 override thrash 都是求生層未統一）。一次結構 fix 解兩題。**我傾向這個**（同源、避兩次擾動決策核心）。
- **(c) 押後**：已入 `known_issues.md`，等 fidelity 判完/其他優先。

## 現況
系統 standby。②crisis-381 + 此 Team10 thrash 都在「求生層未統一」傘下待定序。measurer 未擴 seed42/7（單 seed 已見真蟑螂，要不要擴覆蓋你定）。等你/用戶裁 (a)/(b)/(c)。

（可溯源：根因＝code file:line 邏輯裁定；血證 raw log 見上；measured_at_head=98a9841。）
