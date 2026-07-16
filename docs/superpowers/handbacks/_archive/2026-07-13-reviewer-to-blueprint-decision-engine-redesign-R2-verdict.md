---
from: reviewer
to: blueprint
status: consumed
topic: [R②verdict] 決策引擎重構v2 dispatch可行性 = issues，plan_phase去留未交代
---

# R②審判 verdict — 決策引擎架構重構 v2 dispatch可行性

## verdict: issues（非premise_contradiction，一項需明確交代的設計缺口，halt）

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {
      "claim": "五層急迫度混合架構取代現況N個瞎子term，統一協調語意",
      "file_line": "specs/2026-07-13-decision-engine-needs-hierarchy-redesign.md:9-11(動機引用plan_phase症狀) vs :78(驗收準則)",
      "truth": "spec自己在§動機明確以`derive_plan_phase`判「成長」跟`select_strategic_intent`選「征服」各自獨立算、沒人協調，當作『N個瞎子各自為政』的具體症狀範例（本reviewer R①已file:line驗證此症狀真實存在）。但§驗收(:78)措辭『原本沒有plan_phase_drive/intent_fit的12個option』暗示`plan_phase_drive`term維持不動、新五層係數只是疊加在其上（非取代）——這代表新架構上線後，`plan_phase`（判斷『當下哪個需求主導』的舊機制）跟五層急迫度混合（判斷同一問題的新機制）會並存，是把N個瞎子縮減成2個獨立計算而非真正統一成1個，與spec自己宣稱要根治的病同構，只是規模縮小，未根治。"
    }
  ],
  "note": "其餘dispatch風險（係數表定義方式/回寫穩定性/determinism/工具鏈）皆屬合理HOW階段留白，非阻擋。此缺口需systems在正式技術spec明確表態plan_phase去留，三選一：(a)整套retire由五層urgency取代 (b)降級為五層系統內顯示標籤非獨立計算 (c)刻意並存並說明為何不算冗餘。" }
```

## 逐點審查
1. **係數表定義方式**：未動工，無code可查，屬合理HOW細節留給systems設計。建議dispatch時明確要求：affinity表須為純靜態lookup（非含動態計算分支），否則23×5表會膨脹成隱藏邏輯，重演計畫層state machine疑慮的同型風險。
2. **回寫正回饋穩定性**：同上未動工。建議明確要求回寫機制須帶decay（非永久疊加）+ 有上限cap，並列為對應slice的獨立TDD項，非事後補測。
3. **determinism**：五層EWMA（同款S1已驗證的zero-randf pattern）+係數表（純lookup/算術）+回寫（純算術）理論上皆可零randf，風險可控，各slice各自TDD驗證（同前例模式）。
4. **範圍拆分**：同意規模比plan-layer更大需拆分。**但#5的缺口影響拆分順序**——若plan_phase最終要被五層取代，拆分序應把「五層急迫度基礎設施」跟「plan_phase退役/整併」放同一早期slice討論清楚，非留到最後才發現兩套機制打架。
5. **★與plan-layer交互（issue本體）**：見上issue。
6. **驗收工具鏈**：`warring_harness.gd`探針pattern本session已驗證多次可承接新probe（g2.*/worldgen.*/merge.*等），延伸加五層急迫度/係數/回寫探針屬既有pattern擴展，無需新建置。過。

## 結論
一項需明確交代的缺口，非推翻整體設計。halt，待blueprint要求systems在正式技術spec明確表態plan_phase去留（三選一）後回reviewer confirm。
