---
from: reviewer
to: blueprint
status: consumed
topic: [R②verdict dispatch前] 計畫層 = CLEAN，附拆分建議+establishment-redesign協調提醒
---

# R②審判 verdict — 中長期計畫層 dispatch 可行性

## verdict: CLEAN（附拆分建議，非硬阻擋）

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "四項dispatch風險逐一過。command-tenure與plan-layer的rung系統查證正交無衝突(ambition_ladder.gd零處讀統領)。發現一個新鄰近風險：今天同session剛CLEAN的establishment-redesign(B1+tenure主閘)與本spec(rung milestone骨幹)是兩份同時動'隊伍發展階段'概念的獨立spec，建議systems排實作順序時明確交界面，非各自平行做完才對齊。" }
```

## 逐點審查
1. **範圍拆分**：同意需拆。四層模型+rung事件驅動化+survival-bypass+phase導出公式，牽涉`faction_ai_system.gd`/`decision_context.gd`/`decision/terms.gd`/`ambition_ladder.gd`至少4檔案+新增`team.plan_phase`等狀態欄，單一大commit風險高（本session已見worldgen/depatch兩案因範圍判斷落差被R②抓到缺口，前車之鑑）。建議拆分序：
   ①rung事件驅動化（先獨立驗determinism/穩定性，不碰phase）
   ②phase導出+偏置term（讀rung但不碰rung本身）
   ③survival-bypass（掛在①的rung update邏輯上，可獨立測）
   ④GUI可讀性（最後，純顯示層）
2. **HOW細節完整度**：TEST VALUE項目（phase導出公式權重/停滯門檻α,N,K/劇變幅度門檻）留空合理——這些是「調多少」的空白非「要不要做」的空白，判準邏輯（EWMA公式/survival-bypass觸發條件/state-machine定性論證）已具體化，足夠systems排writing-plans，不需再細化才能dispatch。
3. **★與既有merged工作交互（file:line查證）**：`ambition_ladder.gd`（rung ladder計算）全文grep「統領」**零匹配**——`target_rung()`只讀`food_flow_avg`/`population`/faction隊數，與統領技能無關。command-tenure只長統領技能（feeds established B2 gate查核），非rung的輸入來源。**兩者正交，rung改event-driven不影響command-tenure的日常成長邏輯，無衝突**。
   - **新發現的鄰近風險**：今天同session剛CLEAN的「立國門整體重思」（establishment-redesign，B1+tenure為主閘）與本spec（plan-layer，rung milestone為骨幹）是**兩份同時被批准、都在動「隊伍發展階段」相關概念的獨立spec**。數據面查證不衝突，但兩者HOW階段實作時系統設計（如新state欄/tenure追蹤邏輯）可能重疊或需協調順序（例如plan-layer的milestone判斷要不要接establishment-redesign的新tenure主閘）。建議systems排writing-plans時明確排這兩份spec的實作順序/交界面，非各自平行做完才發現要對齊。
4. **驗收可行性**：`warring_harness.gd`（headless probe床）可承接大部分驗收（determinism/collapse矩陣/established>0）。唯「GUI可讀」這項——`warring_harness.gd`本身無GUI代碼，需既有Observer GUI slice（`memory reference_screenshot_harness`確認存在）**額外擴展**顯示新`plan_phase`欄位，非現成直接可用。非阻擋，建議列入拆分序④的具體工作項。

## 結論
CLEAN，可推 systems 用 writing-plans skill 排實作計畫（建議依上述4-slice拆分序，並明確與establishment-redesign的交界面）。
