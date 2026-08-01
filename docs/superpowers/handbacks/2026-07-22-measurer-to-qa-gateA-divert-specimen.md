---
from: measurer
to: qa
status: consumed
topic: "[故事稽核·gate A market-seek re-rank·合理優先切換 vs broken churn] blueprint 要 QA 讀具體案例判 gate A(seek→arrive 36% 那條)。附 40 個 market-seeker(TASK_TRADE 在途)cadence re-rank 事件逐筆(team/tick/pos/move/food/threat)。★關鍵發現:23/40 其實 pos==move_target(已抵市場)卻仍逐 cadence re-rank、17/40 en-route;同~10 隊重複(56/57/49 各 7-8 次=churn);24/40 食物充裕(food_days≥10)、僅 4/40 餓(<3)、零 in_crisis。我讀=多在市場/近市場 food-fine 卻 re-rank churn(非急事打斷),疑 opportunistic 非 reasonable;但市場 sell_no_surplus 100%(Gate B 無貨)→『沒得交易就走』或許合理。ambiguous,你判。"
measured_at_head: main (pre-fix, dealflow verdict 那輪)
---

# gate A market-seek re-rank 具體案例 → QA 故事稽核

blueprint 糾正（用戶戳破）：gate A verdict 只給聚合（seek 2207→arrive 798 36%）沒附案例，違 §④b。附逐筆 divert-decision 具體案例供你判**合理優先切換 vs broken churn**。

## specimen（40 事件，`docs/measurements/2026-07-22-gateA-divert-specimen-1337.txt`）
每筆 = 一 market-seeker（TASK_TRADE 在途、非 crisis）在 cadence 到點時 re-rank（可能 divert）的當下狀態：
```
tick=2480 team=66 pos=(22,4) move=(22,4) food_days=21.2 combat=-1 in_crisis=false
tick=3180 team=68 pos=(22,4) move=(22,4) food_days=14.4 combat=-1 in_crisis=false
tick=4480 team=56 pos=(11,10) move=(9,11) food_days=36.1 combat=-1 in_crisis=false
tick=4800 team=54 pos=(13,24) move=(13,24) food_days=0.0  combat=-1 in_crisis=false
… 40 筆
```

## ★關鍵發現（幫你判）
1. **23/40 其實 pos==move_target（已抵達市場 tile）** 卻仍逐 cadence re-rank——不是「半路被打斷」，是**到了市場還一直重新決策**（g1.market_arrive 計數可能漏這些=「arrive 36%」被低估）。17/40 en-route。
2. **同 ~10 隊重複**（team56 8 次、57 7 次、49 7 次…）= 同幾隊反覆 re-rank = **churn**。
3. **食物充裕主導**：24/40 food_days≥10、僅 4/40 <3、**零 in_crisis** → **絕大多數沒有急事**（餓/威脅/危機）逼它放棄市場行程。

## 我的初判（供對照，你獨立判）
- 多數在市場/近市場、food-fine、無威脅卻 re-rank churn → 看似 **opportunistic re-rank（非合理急事切換）**——該留下交易卻一直重想。
- **但**：市場 sell_no_surplus=100% meet（Gate B 市場無貨可交易）→「到了發現沒得買/賣就走」**或許合理**（市場空，留著也沒用）。
- ∴ **ambiguous**：是 broken churn（該 commit 交易卻 thrash）還是 reasonable（市場空所以離開）？取決於市場當下有無貨——這跟 Gate B under-production 糾纏。**你判**。

## 為何找你（承 §④b + 血證）
blueprint：gate A 不能只憑「36%」聚合下結論，要讀故事。你判 broken→systems 修 routing stickiness 有理；你判 reasonable(市場空所以走)→真根還是 Gate B under-production（市場給不了貨），routing fix 治標。判完 `to:blueprint`。

## 注意（相關進展）
implementer 已做 market-sticky fix（我另量：doom 大改善 attr 21→1.4，但 arrive% 沒升、機制是 thrash 減——我 verdict 另發 blueprint，也 pending 你這故事判）。你這判 + 我 sticky verdict 合流定 gate A 真相。

## 溯源
raw 上檔（40 事件）。instrumentation 純 print gated（TASK_TRADE 在途非 crisis）、將 revert。measured_at_head main（dealflow verdict 那輪 pre-fix）。
