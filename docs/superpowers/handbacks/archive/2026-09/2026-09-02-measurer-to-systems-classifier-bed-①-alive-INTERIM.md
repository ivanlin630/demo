---
from: measurer
to: systems
status: consumed
topic: subteam-idle-latch classifier床 ①答案先出（②跑中,ETA~70min）
---

★①答案：床【還跑得起來】——七週改動沒弄壞它

## 證據
- 1mo smoke(seed1337)：`scripts/debug/starvation_lockpoint_trace_bed.gd` 乾淨執行，無 SCRIPT ERROR/parse error，真實模擬輸出(Order/SoloAI/CampL0…)照常
- 3mo正式跑(seed1337)：header正常印出，`[progress]` 逐 tick 累積(tick=30000時 teams=105 near_death_tracked=97)，無錯誤，只被我自己 900s timeout 砍（自然，非壞徵兆）
- 依賴的 API（`TaskArbiter.PRIO_SURVIVAL`/`DecisionOptions.options_in_set`/`t.survival_committed_option`/`t.survival_stall_cooldown`/`FactionAISystem.CRISIS_FLOOR`/`BeliefSystem.belief_pos`…）全部 resolve 成功，七週的重錨/belief化/decision重構沒斷這條依賴鏈

## ②進度
死因分類只在整趟跑完後才印（`vanished` team 迴圈在 tick loop 結束後），所以中途 kill 拿不到分類結果——已重新用 GODOT_TIMEOUT=4200s 跑滿 3mo(129600 ticks，依 900s→30000t 實測速率推算約需 3900s)，背景跑中，ETA 約 70 分鐘。完後立刻補②③數字。

## 誠實限
③（8mo 全窗）兩次直接跑都 0-byte 瞬殺(連 header 都沒印出來，非我 timeout 砍的，疑同機多 session Godot 資源競爭)，已改用 3mo 分段跑法規避——3mo 是否滿足判準⑨（≥被量機制一週期）：這個訊號本質是【latch，一旦卡住就不會自己解】非週期性震盪，3mo內 near_death 已大量出現(97隊)，理論上夠捕；若3mo命中0，不代表病好了，需再拉長窗確認（會在②回報時一併說明）。
