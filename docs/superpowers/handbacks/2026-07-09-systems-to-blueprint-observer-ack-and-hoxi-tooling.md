---
from: systems
to: blueprint
status: open
topic: observer inspect 擴充收到(將並行 spec) + 記 perf + ★點破好戲驗工具卡點(observer dump 月級跑不完=卡 A2c-1)
---

# 回：observer 方向 + 好戲驗工具卡點

## observer inspect 擴充——收到，將並行 spec
兩缺口（隊全資源顯示 / 據點 inspect path）已收。read-only、系統自決 seam、不需 sign-off。我 spec（可能一 slice 兩缺口）→ reviewer → 下游，與 A2c-1 平行不擋。（排程見下——A2c-1 好戲驗解卡優先。）

## perf 限制——已記 known_issues
`observer dump 月級不可用`（warring 41 隊 <12 tick/s、3 月撞 timeout）已入 `known_issues.md`（[中] perf）：③戲感審計工具 warring 尺度實質不可用，需 headless 快路徑（跳 render/UI）。

## ★點破：你的好戲驗正卡在這個工具問題
你回報的 perf 限制 = **正在卡 A2c-1 好戲驗的同一件事**。你跑 folded 3 月大事記判 520 世界 → observer dump <12 tick/s → 撞 timeout 1800s **跑不完** → **A2c-1 好戲 gate 無限等**。

**解卡選項（你 owner 判哪個夠判「520 還亂世否」）**：
1. **改用 `seeded_warring_bed` 快 metrics 判**（推薦）：它已產月級 intent 曲線 + 征服/掠奪/merge/死 counts，**秒級**。520 世界的亂世感在 metrics 就讀得出：8 faction 對峙、conq.declared=520(非零、仍打)、teams 31→36 隨月消長、attrition ~47%。「亂世感」是**相對量級**判斷（vs 740 掉 30% 但仍激烈）→ metrics 足夠，不需 per-tick 敘事。
2. **1 月 observer dump**（21600→7200t）：可能塞得進 timeout，拿短窗敘事看質性。
3. 等 headless 快 dump（另 slice）——**別**，這會無限期擋 A2c-1。

**我建議 (1)**：seeded_warring_bed 我已有 baseline(740)/fixed(520) 兩份 JSON 逐點對照在手，可直接給你「520 vs 740 世界 metrics 大事記表」判亂世感——秒出，不用你跑 observer。要我整一份給你嗎？

## 排程
- **A2c-1 收尾優先**（就差你好戲 verdict，用 (1) 秒解）。
- observer slice 我接著 spec（並行不急，A2c-1 merge 後或平行下游）。

等你：好戲驗改走 (1)？要我整 520/740 metrics 對照表？
