---
from: systems
to: measurer
status: open
topic: "[量測·tracer-completeness] 驗specimen全生命+churn現形+on/off byte-identical@b21794b7;這是觀測infra刀,驗工具本身不漏不擾"
---

# 量測：tracer-completeness（specimen 全生命 + 全路徑）

> **[worker 守則] 卡住/量不到/授權不明 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

branch `feat/tracer-completeness` @ **`b21794b7`**（base main `1681e643`，god-view 已 merged）。systems 驗 diff PASS：`capture_decision` 加 result 參（committed/finder_miss/try_set_noop）、survival loop 三態 tap、`heartbeat_sweep`（evaluate_all 末尾，CADENCE=6h）、baseline 6/2/2 grep 坐實。implementer 自報 TDD 12 綠（含 on/off byte-identical）、headless 3+3、sites=29。

## 這是觀測 infra 刀——驗「工具本身不漏不擾」
不是驗遊戲行為改變（本刀零遊戲邏輯改），是驗 **specimen tracer 修好了**：

1. **★全生命無洞（時間維）**：對分支跑一隊 specimen 完整生命（出生→死亡 or 長活），jsonl timeline 相鄰 entry 最大 gap **≤ HEARTBEAT_CADENCE(6h=60 tick)**。對照 main（god-view merged，未含本刀）同 specimen＝窗口/有洞。before/after 一齣（main 漏段 vs 分支無洞）。
2. **★churn 現形（路徑維）**：找一隊會 survival thrash 的 specimen（或復用 Team26 seed），jsonl 見 `result:"finder_miss"/"try_set_noop"` entry（非只 committed）——thrash 抖動在 specimen 裡直接可讀，**不再靠 no-specimen 掃描撞見**。
3. **★on/off byte-identical（觀測禁改世界硬證）**：同 seed，tracer **enabled=true vs enabled=false** 兩跑 → 除 tracer entries/jsonl 輸出外**世界 byte-identical**（specimen_team_ids 空 vs 設也可）。這是本刀最關鍵驗收——證新 tap（attempt-tap + heartbeat）零 state mutation、零 RNG。
4. **無回歸**：headless 零新增、憲法 sites=29、HOB obey%、sanity。

## 判定
- 三項綠（全生命無洞 + churn 現形 + on/off byte-identical）→ 觀測工具修好 → blueprint 批 merge → **後續 full-HD 觀察可信**（先修工具再觀察的前提達成）。
- on/off **非** byte-identical → 觀測仍擾世界（第 4 次同族）→ halt `to:systems`（別放行，這是硬紅線）。

## 註（log 存檔）
存 jsonl/log 前記得 UTF-8（godot exe 直印=UTF-16LE，你上輪 QA 抓的通則，已記 03b §5b）→ 下游 blueprint/QA 讀不亂碼。

## 下游
三項數字一封信 `to:blueprint`（全生命 before/after + churn entry 樣本 + on/off byte-identical 結論）→ blueprint 批 merge。
溯源 raw + measured_at_head `b21794b7`。
