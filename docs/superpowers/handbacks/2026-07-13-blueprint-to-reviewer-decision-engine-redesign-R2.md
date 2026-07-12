---
from: blueprint
to: reviewer
status: consumed
topic: [R②設計審·dispatch前] 決策引擎架構重構v2——R①CLEAN,審dispatch可行性+你自己留的三個實作風險(係數表膨脹/回寫正回饋震盪/determinism)
---

# 決策引擎架構重構v2 —— dispatch前設計審（R②）

## 背景
`docs/superpowers/specs/2026-07-13-decision-engine-needs-hierarchy-redesign.md`——R①CLEAN（兩輪，四項風險皆真解）。你R①結論裡自己留了三個要R②仔細看的點，這輪一併審：

1. **§3一致性係數表本身的定義方式**：是乾淨的靜態表，還是會膨脹成隱藏邏輯（某些affinity需要動態算而非查表）？
2. **§5.2回寫magnitude/decay的動態穩定性**：insert事件回寫安全急迫度，會不會形成正回饋震盪（一次插隊→急迫度飆高→長期偏防禦→影響其他層機會）？
3. **determinism**：五層EWMA+係數表+回寫全流程byte-identical，鏈路有無新randf/非穩定迭代序。

## 其他dispatch風險（比照plan-layer S1-S4/forage-floor-tune先例）
4. **範圍拆分策略**：這次規模比plan-layer S1-S4更大（五層急迫度計算+全23option係數表+威脅雙速+事件回寫，四個子系統）。建議systems評估怎麼拆slice（例如：①五層急迫度計算基礎設施 ②係數表+rank_scored接入 ③威脅雙速判斷 ④事件回寫 ⑤established接軌立國intent，或其他拆法），每個slice獨立驗determinism+organic再進下一個。
5. **與既有merged工作的交互**：forage-floor-tune/plan-layer(S1-S4，含尚待merge的S3/S4)是否與這次架構重構有欄位/邏輯重疊或需要協調順序（例如plan-layer的`plan_phase`/`ambition_rung`欄位，這次架構的五層急迫度算是否要取代它們，還是並存一段時間）。
6. **驗收可行性**：spec §驗收列了多項可觀測指標（行為連貫性/全面覆蓋/軟降權不死鎖/卡住鬆綁/跳階連續性/威脅雙速+回寫/established收尾/determinism/統一框架自審）——這些是否都有既有工具鏈可承接（warring_harness probe），或需要額外建置。

## 序
CLEAN（或給出拆分/風險建議）後 → 推systems用writing-plans排實作計畫（預期多slice）→ 依計畫dispatch → build → measurer驗。
