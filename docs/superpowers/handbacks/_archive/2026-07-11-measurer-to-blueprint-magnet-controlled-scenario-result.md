---
from: measurer
to: blueprint
status: consumed
topic: 名聲磁鐵控制場景掃描——翻盤點抓到:rep 0.1輸survival、0.3贏，因果落在(0.1,0.3)區間約0.23；低rep該逃/高rep該投確認雙端對
---

# 量測回報：名聲磁鐵控制場景掃描（protector_rep 因果點）

工單：`2026-07-11-blueprint-to-measurer-magnet-controlled-scenario-method.md`。照方法學：擴充既有 `consolidation_decision_trace.gd`，複用場景 E 的世界結構（faction member/food夠/外部強鄰打不過/威脅過門檻）**固定不變，只變 `protector_rep`**。worktree `.worktrees/consolidation-s-a @7dfc620`。完整 log：`tools/orchestrator/runs/consolidation-decision-trace.log.txt`（場景F段）。

## 掃描結果（同世界，僅 protector_rep 變）
| protector_rep | 併入 util | survival util | 首選 |
|---|---|---|---|
| 0.1（近暴君） | 0.8976 | 1.0000 | **survival**（逃/求生）|
| 0.3 | 1.0608 | 1.0000 | **併入**（投靠）★翻盤 |
| 0.5（中性） | 1.2240 | 1.0000 | 併入 |
| 0.7 | 1.3872 | 1.0000 | 併入 |
| 0.9（近仁君） | 1.5504 | 1.0000 | 併入 |

## 因果確認
- **翻盤點落在 (0.1, 0.3) 之間**，用兩點斜率內插約 **rep≈0.23**（併入 util 對 rep 呈線性：斜率 0.816/0.2=4.08，從 0.1 點 util=0.8976 推到 survival 的 1.0 需 rep 再加 ~0.125 → 0.1+0.125≈0.23）。
- **低 protector_rep（暴君端）該逃、不投**：rep=0.1 時 survival 贏（0.216 之差）——弱隊不會盲目投靠低名聲強鄰，磁鐵「避暴君」端邏輯生效。
- **高 protector_rep（仁君端）該投**：rep≥0.3 起併入穩定贏，且隨 rep 線性拉開差距（rep=0.9 時併入贏 0.55）——磁鐵「投仁君」端生效，非線性飽和或死鎖。
- **兩端皆對，機制方向正確**：這不是「投靠恆輸」也不是「投靠恆贏」，是**乾淨的名聲門檻行為**，正是磁鐵設計意圖（避暴君偏仁君）在單團決策層級真實存在的證據。

## 一個待你注意的觀察（非阻塞，誠實揭露）
本次重跑（加入場景F後）場景E本身（未顯式設 protector_rep，走預設值 0.5）的併入 util 從先前回報的 0.8160 變成 1.2240——與本次F掃描 rep=0.5 那行（1.2240）一致，但與**上一封回報**（trace-result，寫的是 0.8160）不一致。兩次 run 之間我唯一改動是在腳本尾端新增場景F的程式碼區塊（未碰場景A-E本身邏輯），數值卻變了。可能原因未查證（不影響本次F掃描本身的內部一致性——F掃描5個點都在**同一次腳本執行**內產生，橫向比較有效）。**若你要拿E的絕對值（0.82 vs 1.0 那個具體差距）做精確判斷，建議讓我先查清這個跑間差異的根因，避免拿到不穩定的絕對值**；但F掃描揭示的「翻盤點存在、方向正確」這個定性結論，不受此影響。

## 待你判
控制場景已證：**磁鐵有真因果、方向對、翻盤點約 rep=0.23**。這是否已足夠回答 blueprint 的驗收問題，或需要我先查清上述 E 數值跑間差異之後再進多 seed robustness 階段，請裁示。

## 產物
- 床：`.worktrees/consolidation-s-a/scripts/debug/consolidation_decision_trace.gd`（場景F新增）
- log：`tools/orchestrator/runs/consolidation-decision-trace.log.txt`
