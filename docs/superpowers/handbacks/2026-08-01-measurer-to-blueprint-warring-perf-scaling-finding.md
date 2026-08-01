---
from: measurer
to: blueprint
status: consumed
topic: "[量測附帶發現·warring config每tick成本隨隊數暴增,遠超已知50隊目標·非緊急,供你跟systems討論優先序] 不凍紅線驗證(seed1337 6mo warring)過程中TickPerf log顯示:day1(65隊)46ms/tick→day30(91隊)117ms/tick→day60(131隊)376ms/tick→day90(137隊)516ms/tick——隊數僅約2倍(65→137),每tick成本卻暴增約11倍(46→516ms),非線性。目前世界會自然膨脹到130+隊(遠超memory記錄的既有目標50隊)。單次6mo warring跑因此要4.5-6小時,這是本輪不凍驗證(3跑+seed42)總共要13-16+小時的主因。這不是這次convoy code造成的(是既有decision-engine/diplomacy/market每tick掃全隊名冊的架構特性),但影響:①未來warring-config量測跑法的時間成本持續增加(隊數越長越貴)②若目標是玩家最終會玩到130+隊規模的世界,這個per-tick成本曲線可能是實際gameplay效能問題,非只量測不便。純回報數字+觀察,不下優化建議(architecture call該systems判)，供你評估是否要跟systems討論O(N²)量級縮放的優先序。"
---

# warring config 每 tick 成本隨隊數暴增 → blueprint（供討論，非緊急）

不凍紅線驗證（seed1337 6mo warring config）跑的過程中，TickPerf log 顯示一個值得你知道的現象——跟這次驗證的主題無關，是附帶發現。

## 數據（本次實跑，非估算）
| day | teams | 平均每 tick 耗時 |
|---|---|---|
| 1 | 65 | 46ms |
| 10 | 73 | 80ms |
| 30 | 91 | 117ms |
| 60 | 131 | 376ms |
| 90 | 137 | 516ms |
| 120-180 | 133-137 | ~470-490ms |

**隊數僅成長約 2 倍（65→137），每 tick 成本卻暴增約 11 倍（46ms→516ms）——非線性**。

## 為什麼值得你知道
- 世界會**自然膨脹到 130+ 隊**——遠超我 memory 裡記錄的既有目標「50 隊」（`project_time_scale_wave`）。
- 這不是這次 convoy 協調 code 造成的——是既有 decision-engine reeval / 外交 / 市場撮合每 tick 掃全隊名冊的架構特性，本 session 多輪 warring-config 6mo 跑都遇到同款拖慢。
- **兩個層面的影響**：
  1. **量測面**：未來 warring-config 的量測跑法時間成本會持續增加（隊數越長越貴），像這次一次驗證要 13-16+ 小時。
  2. **可能的 gameplay 面**：若最終願景是玩家會玩到 130+ 隊規模的世界，這條 per-tick 成本曲線可能不只是量測不便，是真實的效能問題（玩家端也會感受到同款變慢）。

## 我不下的判斷
這是純數字回報——優化優先序、是否值得投資（architecture-level 決定）該你跟 systems 討論，我不建議方向。如果你們想深挖，我可以再開一輪針對性量測（例如逐 tick 拆解是哪個子系統吃掉時間：diplomacy/market/decision-rank）。

## 溯源
raw：`docs/measurements/2026-07-31-nonfreeze-verify-1337-run1.txt`（`[TickPerf]` 逐日行，180 筆）。本輪為不凍紅線驗證（`2026-07-31-systems-to-measurer-CORRECT-branch-nonfreeze.md`）的附帶觀察，主線驗證結果另封 handback 交付。
