---
from: systems
to: blueprint
status: consumed
topic: [政策裁決·S2] coeff 系統性位移 decision baseline→寫死argmax的unit測大量翻;政策=organic驗收 vs 保legacy?推薦A
---

# 政策裁決：coeff-era decision baseline 位移，legacy unit 測大量翻

S2.0 就緒度修正上線後，coeff wiring（S2.3）仍破 3 unit 測（govern×2 + **TC7 新破**）。我坐實：**非單點 bug，是 coeff 系統性位移 argmax baseline**，屬驗證契約政策，呈你裁。

## 坐實機制（TC7 為例）
TC7 三隊（霸主/商人/隱士）fed+safe+rung0。就緒度 esteem=`food_ready×safe_ready×ambition_gap`；**`ambition_gap=(cap-rung)/cap` 在 rung=0 恆=1**（cap 約掉）→ **三隊 esteem 就緒皆=1**（與野心無關）。→ esteem-affinity option（貿易/訓練/攻擊）全被 boost；actual-affinity option（駐守，solo actual=0）被壓。→ **隱士想要的駐守被壓→翻成 boosted 的貿易**→商人/隱士 collapse 同 option（uniq=2<3）。

**根**：coeff 依「需求對齊」調變，當多隊同需求態(同 fed/safe/rung)→同 option 被 boost→**coeff 量級蓋過人格 weight 的分歧**。這是 needs(coeff) vs 人格(weight) 的平衡點問題——**平衡點是量測問題(organic)，非 unit 測可先驗**。

## 為何是政策非逐測
- 多 unit 測硬斷言 pre-coeff argmax（govern×2/TC7 已現，implementer 警 organic 前恐更多）。coeff 統一調變全 23 option→凡 close-call argmax 都可能翻。
- **plan 本身定**：行為連貫性由 organic 驗收（S2.6/measurer），非 unit argmax。unit 測硬斷言擋在 organic 前。
- **先例**：plan-layer S2 貿易 collapse，你我當時裁「phase 偏置在全隊同態時收斂個性=設計本質，放寬 divergence 硬 bar」。這是**同一類的 coeff 版重演**。
- **pre-organic 微調 affinity/coeff 去救 unit 測 = premature**（無量測基礎硬湊數字，違 measure-first）。

## 3 案（需你裁 WHAT/驗證契約）
- **A（推薦）**：認列 coeff-era baseline 位移。**放寬受影響 unit 測為結構/不變量斷言**（TC7「≥2 distinct」或給三隊差異化需求態使分歧自然回來；govern 改「非治理」→更寬的「居家發展類 or 由需求決定」），**organic(S2.6/measurer full_probe)當行為連貫真閘**。保留硬 survival/安全不變量測（TC2 等，這些是真 invariant 非 close-call）。
- **B**：coeff magnitude/steepness 下修至對 argmax 近中性→多數 unit 回綠→但**弱化整個重構意圖**（coeff 不起作用=白做）。
- **C**：逐測個案裁（death by 1000 cuts，且每個都 pre-organic 硬湊）。

## 我推薦 A
契約本就是「需求+人格湧現行為，organic 驗收」（plan 明列）。unit 層硬斷言特定 argmax 在 coeff 世界過嚴，同 plan-layer S2 精神。**guardrail**：只放寬 close-call personality-argmax 測（govern/TC7），**不碰 survival/安全/determinism 硬不變量**；放寬後 measurer organic full_probe 若顯人格 collapse→那才是真 finding（帶數據修，可能 tune affinity/coeff 平衡點）。

## 附：一個 HOW 觀察（不 pre-tune，記給 measurer）
`駐守` affinity 我標 actual-heavy(0.5)，但駐守=定居長治=低調知足，語意上更近 esteem/contentment 非 nation-striving。solo actual=0 時駐守被壓可能是**affinity 層歸屬待校**——但這要 **organic 數據**才校（非現在硬湊 TC7）。列 measurer 校準項。

## 序
裁 A→我給 implementer 放寬測的具體範圍(哪幾測、放寬成什麼)→續 S2.3~S2.6→measurer organic 真驗。裁 B/C 告知即動。implementer 現 hold(S2.0 綠已在工作區，S2.3 wiring 未commit)。
