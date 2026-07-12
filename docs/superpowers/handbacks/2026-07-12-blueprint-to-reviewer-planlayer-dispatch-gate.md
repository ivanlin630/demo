---
from: blueprint
to: reviewer
status: consumed
topic: [R②設計審·dispatch前] 中長期計畫層——R①四靶已CLEAN，這輪審整體dispatch可行性(範圍/拆分/風險)，非再查premise
---

# 中長期計畫層 —— dispatch前設計審（R②）

## 背景
`docs/superpowers/specs/2026-07-12-midlong-term-plan-layer-design.md`——R①對抗（premise/factcheck）已CLEAN（兩輪，四靶皆真解）。這輪R②審**dispatch可行性**，非重查premise。

## 用戶裁定脈絡
established調查鏈六輪查到B2/B3/B4機械閘後，用戶否決「小修加立國意圖層」，判斷：沒有中長期計畫層，看不出建國/立國系統真缺陷（目標錨直接驅動行動、無phase緩衝，數據可能是反應式抖動假象非真結構問題）。決定復活此設計，取代局部小修。

## 設計摘要（複用非新建）
四層模型：目標階(rung)→milestone→phase(求糧/成長/聚勢)→承諾+偏置(rank_scored既有偏置term)。phase由缺口×個性×隊形導出，非手寫。複用既有階梯條件/archetype/COMMITMENT_BONUS/survival·投靠·整併·遷移option/敗北模型/threat——不建bespoke planner。

## R②審查重點（dispatch風險，非premise）
1. **範圍是否過大需拆分**：這是四層模型+rung重構(事件驅動)+survival-bypass+phase導出公式，牽涉多檔案(faction_ai/decision_context/resource_system等)。建議評估能否拆成多個independent slice（例如①rung事件驅動化 ②phase導出+偏置term ③survival-bypass機制 ④驗收GUI可讀性），分批dispatch降風險，而非單一大commit。
2. **HOW細節完整度**：spec §「交systems的HOW」列了TEST VALUE項目（phase導出公式/停滯門檻/劇變幅度門檻等）——確認這些是否足夠讓systems排出writing-plans可執行的實作計畫，或還需要再細化才能dispatch。
3. **與既有merged工作的交互**：forage-floor-tune/command-tenure-growth已merge/待merge，計畫層是否會跟這些既有改動衝突或需要重新對齊（例如rung reactive改成計畫驅動後，command-tenure的「日常成長」偏置是否還適用同一套邏輯）。
4. **驗收可行性**：§驗收要求「GUI跑幾seed看不同軌跡」+「established>0」+「collapse矩陣對照」——這些驗收手段目前是否都有既有工具鏈可用（warring_harness/GUI slice），或需要額外建置。

## 序
CLEAN（或給出拆分/風險建議）後 → 推systems用writing-plans skill排實作計畫（可能分slice）→ 依計畫dispatch → build → measurer驗established/GUI湧現軌跡/collapse矩陣。
