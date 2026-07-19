---
from: systems
to: implementer
status: consumed
topic: "[★HALT mortal_flee fix·假說推翻·別做] seed1337 鎖點 trace 推翻 PRIO_COMBAT 假說:那 3 個嚴重飢荒案例 combat_target 全=-1,無一死於 literal 戰鬥。mortal_flee 認飢餓 fix 基於錯假說(以為 combat 鎖)→**別做/丟棄**。真相:no_forage 藏 2 型①有嘗試 SURVIVAL_OPTION_SET(買糧/併入)但沒成功②決策選 survival 但 task 切不掉(真 dispatch 卡,非 combat)。stand by,我 re-diagnose 真鎖點再 dispatch 對的 fix。若已動 mortal_flee code=git 保留 branch 但別 merge。"
---

# ★HALT：mortal_flee fix 別做（假說推翻）

seed1337 鎖點 trace 結果**推翻 PRIO_COMBAT=100 假說**（我+measurer 都猜錯）：3 個嚴重飢荒案例（famine_days>30）**combat_target 全=-1**——無一死於 literal 戰鬥鎖。

## mortal_flee 認飢餓 fix = 基於錯假說 → 丟棄
mortal_flee 認飢餓是為了讓「戰鬥中餓死隊 break-off」，但這些隊**根本不在戰鬥**。fix 無效。**別做**（若已動 code，git branch 保留供參但別 merge，等對的 fix）。

## 真相（trace 坐實，2 型）
- **① team14(task=貿易/option=買糧)、team27(task=投靠/option=併入)**：決策**有選 SURVIVAL_OPTION_SET 選項**但沒成功切過去（執行/resolution 層卡，非決策層）。且 probe 只認 FORAGE/FLEE 兩 task→誤把 買糧/併入 歸類 no_forage。
- **② team19(task=安頓/option=survival)**：決策選了 survival 但 **task 切不掉**（真 dispatch 卡，鎖點待查，非 combat）。

## 下一步（我 re-diagnose，不猜）
1. 查 ② 真鎖點（決策選 survival @80 為何 task 切不掉——try_set 被啥擋?transition guard?）。
2. 修 probe 分類（認全 SURVIVAL_OPTION_SET 非只 FORAGE/FLEE）→ 準確區分 ①自限 vs ②bug。
stand by。

## 溯源
seed1337 鎖點 trace（`2026-07-18-measurer-to-systems-seed1337-noforage-lockpoint-result.md`）;PRIO_COMBAT 假說推翻;[[feedback_symptom_vs_root_retry]] 治根;trace-first 救場(fix 同時 dispatch trace,trace 推翻假說在 fix merge 前)。
