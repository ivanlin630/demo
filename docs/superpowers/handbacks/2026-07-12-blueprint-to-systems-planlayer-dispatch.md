---
from: blueprint
to: systems
status: consumed
topic: [dispatch請求] 中長期計畫層——R①R②全CLEAN,請writing-plans排4-slice實作;★澄清establishment-redesign(B1+tenure主閘)已被用戶否決取代,非平行進行,勿同時做
---

# 中長期計畫層 —— dispatch請求（R①R②全CLEAN）

## ★重要澄清（防重疊/衝突）
reviewer R②發現一個協調風險：「立國門整體重思」（`2026-07-12-blueprint-to-systems-establishment-redesign.md`，B1+tenure為主閘的小改版）與這份計畫層spec，是**兩份同時被批准、都動『隊伍發展階段』概念的獨立spec**。

**但establishment-redesign那份已經被用戶否決，不是平行進行的東西**——用戶原話：「小修沒用，沒中長期計畫又看不出建國立國系統有無缺失，另外目前目標錨直接做行動，我認為會產生很多誤導我們的數據」。用戶決定**用計畫層取代**establishment-redesign的小修方案。我先前已發過`2026-07-12-blueprint-to-systems-establishment-redesign-PAUSE.md`暫停信，這裡再次確認：**establishment-redesign(B1+tenure主閘那版)不要實作，不要dispatch，已被計畫層取代**。

計畫層完成後，established的判定邏輯會走計畫層的milestone/rung機制，不再需要另外設計B1+tenure主閘——這件事本身就是計畫層驗收標準之一（`established>0`）。

## dispatch請求
`docs/superpowers/specs/2026-07-12-midlong-term-plan-layer-design.md` —— R①對抗(premise/factcheck，兩輪四靶全解)+R②(dispatch可行性)皆CLEAN。

**請你用writing-plans skill排實作計畫**，依reviewer建議4-slice拆分序：
1. **rung事件驅動化**——先獨立驗determinism/穩定性，不碰phase。
2. **phase導出+偏置term**——讀rung但不碰rung本身。
3. **survival-bypass**——掛在①的rung update邏輯上，可獨立測。
4. **GUI可讀性**——最後，純顯示層（需擴展既有Observer GUI slice顯示新`plan_phase`欄位，非現成可用）。

## reviewer附加確認（供你排plan參考）
- command-tenure與plan-layer的rung系統**正交無衝突**（`ambition_ladder.gd`全文grep「統領」零匹配，target_rung只讀food_flow/population/faction隊數）。
- HOW細節（TEST VALUE留白項：phase導出公式權重/停滯門檻α,N,K/劇變幅度門檻）足夠排writing-plans，不需再細化。
- 驗收：`warring_harness.gd`可承接determinism/collapse矩陣/established>0；GUI可讀性需額外擴展工作。

## 序
writing-plans排4-slice計畫 → 依序dispatch → build → measurer驗（determinism/established>0/GUI湧現軌跡/collapse矩陣對照）。
