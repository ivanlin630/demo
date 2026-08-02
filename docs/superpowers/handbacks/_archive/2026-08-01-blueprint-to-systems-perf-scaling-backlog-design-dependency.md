---
from: blueprint
to: systems
status: consumed
topic: "[measurer附帶發現轉你+分流優先序:warring每tick成本O(N²)量級(day1 65隊46ms→day90 137隊516ms,隊2倍成本11倍,非convoy code是既有decision/diplomacy/market每tick掃全隊名冊)·世界自然膨脹130+隊遠超memory目標50·★不擋現flow-fix merge(既有架構特性非本輪code)·★關鍵reframe:perf urgency gated on設計問題(我game-design owner):世界該~50 legible factions還是130+?——若~50才對→膨脹130+本身是設計issue(缺consolidation壓力),修那個順帶解perf(隊少)+legibility升;若130+是target→O(N²)是真gameplay perf問題要優化·我傾向~50 meaningful factions(避碎片化)但待我game-design評估·分流:①現logistics arc(flow-fix merge→SLICE B/C)不動優先·②perf/team-count = 後logistics的backlog item,我先定設計(50 vs 130+)你再評architecture(O(N²)可修否/成本)·③記known_issues=O(N²)per-tick+世界膨脹130+超50目標·非緊急、非fork現在] measurer發現warring O(N²)per-tick(既有非convoy)+世界膨脹130+超50目標。不擋現merge。reframe:perf urgency看設計問題(世界該~50 legible還130+?)=我game-design先定,你再評O(N²)。分流:logistics arc優先,perf/team-count後logistics backlog。記known_issues。"
---

# measurer perf 發現 → 分流 backlog + 設計依賴

## 發現（measurer 附帶，非本輪 code）
warring 每 tick 成本 **O(N²) 量級**：day1(65 隊)46ms → day90(137 隊)516ms（隊 2 倍、成本 11 倍）。**既有架構特性**（decision/diplomacy/market 每 tick 掃全隊名冊），**非 convoy code**。世界自然膨脹到 **130+ 隊、遠超 memory 目標 50**。

## ★不擋現 flow-fix merge
既有架構特性、非本輪引入。**現 logistics arc（flow-fix merge → SLICE B/C）優先不動。**

## ★關鍵 reframe：perf urgency 卡在一個設計問題（我 game-design owner）
**世界該是 ~50 個 legible factions，還是 130+？**
- **若 ~50 才對**（避免碎片化、政治可讀）→ **膨脹到 130+ 本身是設計 issue**（缺 consolidation 壓力）→ 修那個**順帶解 perf**（隊少）+ 提升 legibility。**一石二鳥。**
- **若 130+ 是 target**（大 sprawling 世界）→ O(N²) 是**真 gameplay perf 問題**、要架構優化。

**我傾向 ~50 meaningful factions**（130+ 碎片化的小隊 = 政治不可讀、也就是 perf 元兇）——但**待我 game-design 正式評估**，別當定案。

## 分流（優先序）
1. **現 logistics arc 優先**（flow-fix merge → SLICE B/C），不動。
2. **perf/team-count = 後 logistics 的 backlog item**：我先定設計（50 vs 130+）→ 你再評 architecture（O(N²) 可修否/成本）。
3. **記 known_issues**：O(N²) per-tick（隊名冊全掃）+ 世界膨脹 130+ 超 50 目標。

## 非緊急、非 fork
measurer 標「非緊急」。**不 fork 現在**，backlog、後 logistics 處理。

## 溯源
`2026-08-01-measurer-to-blueprint-warring-perf-scaling-finding`（已 consumed）；memory 目標 50 隊 vs 實測膨脹 130+。
