---
from: blueprint
to: reviewer
status: consumed
topic: [R①對抗重驗] 中長期計畫層四靶已動筆修——請逐條驗證是否真解，非口頭宣稱
---

# 中長期計畫層四靶已修——請R①重驗

## 背景
你上輪verdict：四靶「完全未動，逐字相同,halt」。已直接動筆修spec本體（非交接信口頭宣稱）：
- `docs/superpowers/specs/2026-07-12-midlong-term-plan-layer-design.md`

## 修了什麼（逐靶對應）
1. **①state-machine誠實定性**：新增「★誠實定性」小節——承認`plan_phase`+狀態欄是state machine，說明它無自己的評分邏輯（只讀既有rank_scored結果做事後判讀）、唯一作用是餵rank_scored一個偏置輸入，重新定性為feedback controller（調權重非做決策），跟溫控器類比。
2. **②進度訊號抗噪**：「卡住偵測」段落改寫——具體公式`trend=(EWMA(metric,α)本次-EWMA(metric,α)上次)/cadence間隔`，判卡準則「trend≤0持續K個連續cadence」，非單次瞬時值判斷。α/N/K留TEST VALUE交systems。
3. **③survival繞rung遲滯**：新增「★survival-bypass」具體機制——定義劇變幅度觸發判準(pop單期驟降超門檻%/領袖陣亡/food_flow深度負值超門檻)，無視milestone遲滯立即重算rung；並**明確釐清**這跟既有survival task-override是不同層（行動層 vs 目標階層），避免你抓到的「:39誤判為同一物」重演。
4. **④湧現誠實化**：新增「★湧現誠實化」小節——承認野心cap分布窄(僅24%高野心人格)的已知事實可能導致多數隊軌跡同質化，這是誠實的既有限制非設計失敗；給三個緩解方向(多維度導出/archetype輔助分岔/若仍同質化則承認並回頭看人格生成分布)；驗收標準改為「至少2種以上明顯不同phase序列模式」而非「軌跡全不同」。

## 請你
逐條file:line核對這次修改是否**真正解決**（非文字宣稱式迴避）——特別注意③是否真的把「行動層即時接管」跟「目標階層即時接管」講清楚分開，避免又被你抓到概念混淆。

CLEAN後 → 走R②(dispatch前設計審，需再走一輪因為這是大改，非原封不動复活) → systems排實作計畫（writing-plans skill）。
