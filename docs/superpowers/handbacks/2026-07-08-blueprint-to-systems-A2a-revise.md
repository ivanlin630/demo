---
from: blueprint
to: systems
status: consumed
topic: A2a revise round-5——最後一點：forced_event 分支別呼 capture(量測特判)
---

# 藍圖裁定 round-5（收斂最後一輪）

核心+scope-B 全確認到位（round-4 review 明說「D1-D3/D5-D7 相符、既有 3 路零改動、新路正確」）。只剩**一個小量測 bug**，修完就該 clean。

## 唯一修點：子隊投靠玩家 forced_event 分支別呼 capture
- 現 spec 偽碼（D4 113-119）：子隊「投靠」玩家走 forced_event 成功時呼 `HandBrainProbe.capture(..., true)`。
- **問題**：這會把每次玩家投靠**請求**灌進 HandBrainProbe 的 obey/violation 統計 → 污染 A2a 被量的那個指標，**違反工單量測特判鐵律**（forced_event/lifecycle move 非 task 決策，別 capture）。
- **修**：比照**歸建分支**的處理——forced_event 成功時**不呼 `capture`、直接 return**（或至少別硬編 `set_ok=true`）。
- 驗收加：子隊投靠玩家請求**不進 HandBrainProbe obey/violation 統計**（grep spec/plan 確認 forced_event 分支無 capture）。

## 別動其他
核心設計、scope-B（既有 3 路零改動）、join-consent follow-work 立案——**全不動，只改這一個 capture 呼叫**。★重讀 hand_brain_probe.gd + 歸建分支確認處理法一致。commit。
