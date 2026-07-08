---
from: blueprint
to: systems
status: consumed
topic: A2a revise 裁定——子隊納統一框架，紀律走通用 loyalty/duty，禁子隊專屬補丁
---

# 藍圖裁定：A2a spec revise 方向（★優先於 review 字面）

review 兩點成立，但**修法**藍圖已裁定（與用戶討論定案）。照這個改，別自行詮釋 review。

## 核心：A2a = 拆補丁，不是加補丁
現況 `_evaluate_idle_subteam`（faction_ai_system.gd:1699-1720）手算 `martial*0.4+greed*0.2` argmax 選攻擊/掠奪＝**繞過統一引擎的 bypass**（code 自標 `HandBrainProbe.note_bypass(sub,"subteam")`）。A2a 目的 = **把子隊決策從這個手算 bypass 移進統一 DecisionEngine**（options.gd REGISTRY 的 Σ term×weight argmax）。

## 對 review #1（攻擊「窄化」）——窄化是對的，別保真舊行為
- 舊裸-martial 攻擊**本身是錯的**：無紀律軍隊不會沒命令亂打敵人。子隊是**紀律執行者**，不自己宣戰。
- 統一框架攻擊 applicable（options.gd:91-98）= faction 攻擊令 / intent==征服（只 leader team）/ 血仇≥0.5。**子隊走不到 intent==征服 是設計正確**（只有 faction leader 決定開戰）。
- **spec 改：丟掉「行為忠實映射裸 martial」的講法**，改述「子隊攻擊紀律化：只經 faction 攻擊令或血仇，不由裸人格分驅動」。這是**修正舊 bug**，明示接受。

## ★紅線：紀律是通用維度，複用既有 loyalty/duty，禁子隊專屬 term/分支
**別加 `if subteam and on_mission: suppress` 這種子隊專屬手刻分支或 discipline term。** 紀律=「對權威的忠誠義務」，本來就通用：
- 獨立隊→聽自己(intent)；faction 成員→聽 faction 指令(faction_stakes→faction_duty term)；**子隊→聽母團命令**。
- `faction_duty` term 已 key 在 loyalty 上（decision_context.gd:178-179，`_loyalty` 注入）。**忠誠→盡義務→不 freelance 的機制 faction 成員早有。**
- **子隊複用它**：母團命令建模成一種 **directive**（結構鏡射 faction_stakes）→ 被命令的 option 拿 duty weight；loyalty 驅動 duty 強度＝忠誠子隊聽令、不忠→掠奪/脫離贏（正是現況 `_check_deviation` greed×(1-loyalty) 想表達的，搬進框架用同一 loyalty 機制）。
- 一套 duty/loyalty 管 faction 成員 + 子隊，**子隊沒有一行特例**。

## 要保留（子隊納框架後自動拿到，別漏）
- **threat_react 被動防禦**（迎戰/備戰/求和，options.gd:117-123，threat 過閾才候選）——紀律單位遇襲會還手。子隊要保留。
- **掠奪/weak_prey 投機**（has_weak_prey gated）——沒紀律的出口，loyalty-gated（忠誠壓制、不忠釋放）。
- 「回程遇很弱敵」= 現有 weak_prey 機制；**執行命令中→duty 壓制投機（任務優先）；idle/回程→loyalty-gated 可**。不新造。

## 對 review #2（逐 tick 全量 gather 效能）
- 子隊 dispatch（faction_ai:658-661）逐 tick 呼、現況 O(1) 手算。改呼 `DecisionContext.gather` 會掃全 world tiles + finders＝重。
- **加 cadence gate**：子隊決策別逐 tick（比照 solo/faction 的 cadence；查現有 cadence 機制複用）。
- **驗收法加 tick-time budget 檢查項**（before/after sim tick-time 不顯著退化）。

## 交付
改：①spec（含上述設計，file:line 改點對到 options.gd REGISTRY row + directive 建模 + cadence + 驗收加 perf）②scope.json ③重點 handback。★全走框架 row/term/gate，零 bypass 補丁。★重讀當前 code 查證。
