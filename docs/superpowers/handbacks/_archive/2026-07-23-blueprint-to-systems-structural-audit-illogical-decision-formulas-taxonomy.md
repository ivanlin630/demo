---
from: blueprint
to: systems
status: consumed
topic: "[用戶提·跑結構稽核掃『不合邏輯決策公式』的siblings·認可(同病family本場重複~5次=結構信號,結構稽核互補memory,趁臭味清晰窗口,藍圖主動盲點掃描)·WHAT我定臭味分類5種子pattern+3紀律,HOW你scope·★紀律1只掃決策常數非世界物理常數(憲法:代謝flat該留,gate人格/決策的常數才是標的)·紀律2稽核只出ranked嫌疑名單不出fix(靜態這場錯3次=靜態提名measure定罪,每候選照新R①measure坐實才spec)·紀律3平行跑不擋三腿修]用戶提議跑檢測掃有沒有其他地方同型不合邏輯公式。認可:本場同病family重複~5次=結構信號(結構稽核互補:measure-first只抓近端,同型重複需結構視圖別打地鼠),且臭味特徵現在特別清晰=掃sibling最佳窗口。WHAT我定,HOW你scope(你owner結構稽核工具+measure-first)。★5種子pattern(本場實例):①錯位=同名量在兩子系統語意不同被混用(117:vault領料target當建造預算)②flat人格硬閘=`人格運算式>常數`結構性排除一類agent(extract 0.4排除中位人格)③全域壓制套錯資源=suppression/scaling均勻套語意不同資源/決策(reserve_factor壓committed投資material)④magnitude被clamp消掉=clamp/飽和套在該用量級驅動優先序的信號(deficit clamp[0,1]快餓死vs略缺都1.0)⑤means-end脫鉤=『想要多少』被常數拍死非由『目標需要多少』推導(build target flat cap100)。★3紀律:(1)只掃決策常數非世界物理常數——憲法定代謝物理(FOOD_PER_PERSON_PER_DAY0.8)該flat不是bug,標的=gate決策/人格、該need/utility湧現卻被拍死的常數;這filter是關鍵免噴幾百false positive(2)★稽核只出ranked嫌疑名單不出fix:靜態讀code本場錯3次(117→1.13→實測),稽核靜態→只提名不定罪,每候選是hypothesis照新R①measure坐實才spec=靜態提名measure定罪(3)平行跑不擋現在三腿修,掃出ranked候選餵triage queue。★掃描範圍建議:決策相關modules(faction_ai_system/trade_valuation/need_oracle/task_arbiter/decision*)優先,非全codebase。★可能與既有constitution_gate.gd是sibling(那個抓scripted behavior/task指派,這個抓flat-constant決策閘)——要不要建tooling還是先人工結構讀你判。輸出=ranked候選表(每筆:file:line+哪種臭味+gate什麼決策+疑似排除哪類/混用什麼)→我+你triage定哪些真值measure。序:平行thread,不擋extraction merge/material-hold/GATE-A。"
---

# 結構稽核：掃「不合邏輯決策公式」的 siblings（用戶提）

## 認可 + 為何現在做
用戶提議跑檢測掃其他同型不合邏輯公式。**認可**：
- **本場同病 family 重複 ~5 次 = 結構信號**（[[feedback_structural_audit_complement]]：measure-first 只抓近端，同型缺口重複 = 該結構視圖，別繼續打地鼠）。
- **臭味特徵現在特別清晰** = 掃 sibling 的最佳窗口，晚了 pattern 糊掉。
- 藍圖主動盲點掃描義務（[[feedback_blueprint_proactive]]）。

## ★WHAT：5 種子 pattern（本場實例）
| # | 臭味 | 本場實例 |
|---|---|---|
| ① | **錯位**：同名量在兩子系統語意不同被混用 | 117（vault 領料 target 當建造預算） |
| ② | **flat 人格硬閘**：`人格運算式 > 常數` 結構性排除一類 agent | extract gate 0.4（排除中位人格） |
| ③ | **全域壓制套錯資源**：suppression/scaling 均勻套語意不同的資源/決策 | reserve_factor 壓 committed 投資 material |
| ④ | **magnitude 被 clamp 消掉**：clamp/飽和套在該用量級驅動優先序的信號 | deficit clamp[0,1]（快餓死 vs 略缺都 1.0） |
| ⑤ | **means-end 脫鉤**：「想要多少」被常數拍死，非由「目標需要多少」推導 | build target flat cap 100 |

深層統一臭味 = **一個該由 need/utility 湧現的決策，被 flat 常數 gate 或錯位公式取代**（憲法「utility 餵 utility 非 scripted」的反面）。

## ★3 紀律（免變噪音/反向打地鼠）
1. **只掃決策常數，非世界物理常數**：憲法定代謝物理（`FOOD_PER_PERSON_PER_DAY=0.8`）**該 flat、不是 bug**。標的 = **gate 決策/人格、該 need/utility 湧現卻被拍死的常數**。這 filter 是關鍵——否則噴幾百個 false positive。
2. **★稽核只出 ranked 嫌疑名單，不出 fix**：靜態讀 code 本場**錯 3 次**（117→1.13→實測）。稽核是靜態 → **只提名不定罪**。每候選是 hypothesis，照**新 R① measure 坐實才 spec**。**靜態提名、measure 定罪。**
3. **平行跑，不擋現在三腿修**：獨立 thread，掃出 ranked 候選餵 triage queue；extraction merge / material-hold / GATE-A 照做。

## HOW（你 scope）
- **範圍建議**：決策相關 modules 優先（`faction_ai_system` / `trade_valuation` / `need_oracle` / `task_arbiter` / `decision*`），**非全 codebase**。
- **可能與 `constitution_gate.gd` 是 sibling**：那個抓 scripted behavior / task 指派，這個抓 **flat-constant 決策閘**。要不要建 tooling 還是先人工結構讀，你判。
- **輸出 = ranked 候選表**：每筆（`file:line` + 哪種臭味 + gate 什麼決策 + 疑似排除哪類/混用什麼）→ 我 + 你 triage 定哪些真值 measure。

## 序
平行 thread，**不擋** extraction merge / material-hold / GATE-A。候選表回來 → triage → measure-convict 的排進現有 queue。

## 溯源
用戶「要不要跑檢測看有沒有其他地方也是這種不合邏輯的公式」；本場 5 實例（117 / extract-0.4 / reserve_factor-material / deficit-clamp / build-cap-100）；連 [[feedback_structural_audit_complement]]、[[feedback-patch-gate-first]]、[[feedback_blueprint_proactive]]、[[project_desperation_economy]] 死常數人格化。
