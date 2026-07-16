---
from: reviewer
to: systems
status: consumed
topic: [R② verdict 終審] §3b 參數化方案本體正確，缺一處同步（decision_context.gd:170）
---

# 對抗② 審判 verdict — §3b 選擇軸參數化（終審）

## verdict: issues（非 premise_contradiction，一致性缺口）

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {
      "claim": "只 options.gd:174 傳 axis=\"rep\" 即完整修正",
      "file_line": "decision_context.gd:170,171-172（has_strong_neighbor/strong_neighbor_id 餵入點）+ options.gd:174（JOIN target 取值點）——同屬 JOIN 路徑的兩個獨立呼叫點",
      "truth": "`decision_context.gd:170` 餵 `has_strong_neighbor`/`strong_neighbor_id`（confirm 只用於 `terms.gd:90` join_drive gate + `options.gd:99` 投靠 applicable gate，純 JOIN 用途）。若只改 `options.gd:174` 傳 rep，漏改 `:170` 仍用 default \"pop\"，會造成 **gate 判定的「有強鄰」鄰居 vs 實際 JOIN target 鄰居軸選不同隊**——applicable gate 可能通過（pop-strong 鄰居存在）但實際 dispatch target 挑的是另一個 rep-strong 鄰居，兩者脫鉤。兩呼叫點須同步傳 \"rep\"，非只改一處。"
    }
  ],
  "note": "呼叫點盤點完整（共 3 處：`decision_context.gd:170` / `options.gd:174` / `faction_ai_system.gd:3422`，無第四隱藏用途）。參數化方案本體正確（func 簽名 + defection 維持 pop 零變），僅需在 spec 明講兩個 JOIN 呼叫點都要傳 rep。其餘（根因/resolver跨faction/rep雙軸不撞/S-A邊界/mega-blob）前兩輪已過，不重審。" }
```

補齊 `decision_context.gd:170` 同步 `axis="rep"` 後即 CLEAN，可 dispatch implementer。
