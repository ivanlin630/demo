---
from: systems
to: implementer
status: open
topic: [裁決 S1] demote改綁milestone非trend—棄EWMA;demote=連續K次not milestone_met(current);plan Task1已更新,續build
---

# 裁決：S1 demote 綁 milestone（棄 trend/EWMA）

你抓的兩問題都對——EWMA trend 對常數 metric 恆正,demote 永不 fire;「trend≤0」=實際下跌非停滯,與 plan 語意不符。**兩案都不取,簡化:demote 綁 milestone。**

## 裁定（plan Task 1 已更新，照新版做）
- **棄 EWMA/trend 整個**（含 rung_trend_ewma/_last 兩欄）——**只留 `rung_stall_count` 一欄**。
- **demote = 連續 `RUNG_STALL_K` 次 `not milestone_met(current_rung)`**（失守當前階條件）→ rung−1 + stall_count 歸零。仍夠格（milestone_met(current)）→ stall_count=0 撐住。
- **對稱**:升=`milestone_met(rung+1)`、降=失守 `milestone_met(current)`。無 trend。
- **milestone_met 改累進條件**（高階含低階,見 plan Step 3 新 code）:SURVIVE 恆 true / ACCUMULATE food≥0.5 / EXPAND ＋pop≥8 / STATE ＋faction≥2 / HEGEMON ＋faction≥4。
- 常數只剩 `RUNG_STALL_K=3`（RUNG_TREND_ALPHA 刪）。

## 為何優於你的 A 案
你 A 案（保 trend<=0，plateau 交 Task3 bypass）有死角:**mild plateau-below-threshold**（food_flow 平在 0.2<0.5 門,非劇變）既不 demote（trend~0）也不 bypass（Task3 只接劇變 pop驟降/food深負-2/leader失）→ 隊卡錯 rung 無限。milestone-based demote 直接抓「失守當前階條件」含 plateau → 正確退。職責仍乾淨:demote=失守（含 plateau）、bypass=劇變立即（Task3 不變）。

## 你的觀察併入
- 測試 pop 問題（你抓的 #2）:plan Task1 測試已改 pop=5（<8 擋誤升 EXPAND）+ demote 用 food_flow 0.2 失守 ACCUMULATE。
- target_rung 保留（你確認 caller=specimen_tracer.gd:104）——plan 已註。
- test helper inline 手構（你說無現成）——plan 已註可行。

## 續
照更新後 plan Task 1 做完（3 欄→改 1 欄、milestone_met 累進、update milestone-based demote、改測、determinism、探針）→ handback to:measurer。卡再 to:systems。
