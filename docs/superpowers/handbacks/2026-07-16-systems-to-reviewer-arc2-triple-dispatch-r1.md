---
from: systems
to: reviewer
status: open
topic: "[R①·前提factcheck·Arc2三重dispatch收斂] blueprint啟Arc2(照路線)。前提:威脅/求生有多dispatch路(roadmap稱三重)繞過/平行於統一引擎rank,該收斂全走rank(encounter-north-star:rank_survival/rank_threat/rank_scored/ambient分slice=過渡,終態一個encounter eval)。refute向factcheck:①真有幾條平行rank/dispatch路(rank_survival/rank_threat/rank_scored/rank_ambient?非unified vs unified雙軌?)file:line?②真「繞過」還是同引擎filtered subset?③收斂成一eval前提(語意可併?survival soft vs threat hard語意衝突?)。前提先驗(判斷層被推翻多次)→premise_contradiction回systems"
---

# R① 前提 factcheck：Arc2 三重 dispatch 收斂（前提先驗）

> **[worker 守則] 卡住/疑義 → handback `to:systems`，禁 `AskUserQuestion`。**

blueprint 啟 Arc2（統一路線圖第 2，用戶定照路線）。**大框 + 前提含未驗 code 斷言 → R① 先於 spec**（同 Arc1 判斷層被獨立查證推翻多次，前提務必先驗）。

## 前提（refute 向 factcheck，不臆斷）
roadmap 稱 Arc2 = **收斂三重 dispatch（威脅/求生全走引擎 rank）**。encounter-north-star（invariants）記「`rank_survival`/`rank_threat`/`rank_scored`/`rank_ambient` 分 slice = 過渡，終態一個 encounter eval」。憲法溶解 arc 已 largely 統一 threat/survival（序1 threat/序2 solo/序6 faction dispatch）——但 roadmap 判仍有殘多 dispatch 路。

**請 reviewer 獨立 enumerate + verify（file:line 坐實 + 詮釋成立）：**
1. **真有幾條平行 rank/dispatch 路？** `rank_survival`/`rank_threat`/`rank_scored`/`rank_ambient` 各自存在？unified vs non-unified 雙軌（`_decide_unified` vs loop3 scaffolding）還在？precise 幾「重」？各 file:line。
2. **真「繞過」引擎、還是同引擎的 filtered subset？** 這些 rank_* 是**獨立決策路**（各自 argmax 出 task，繞過主 rank）、還是**同一 DecisionEngine 的 filtered option 子集**（過渡態但同引擎）？——這決定 Arc2 是「收繞過路」還是「合併 filtered subset」，性質不同。
3. **收斂成一 encounter eval 的前提成立？** survival（soft/主 rank）vs threat（hard/rank_threat）**語意可併**嗎？（unification_matrix 記過「survival 雙語意」watch）——併成一 eval 有無語意衝突（如絕境碾壓 vs 威脅權重量級）需先解？

## 流向
- **CLEAN（前提坐實）→ to:systems** → systems 據驗證後的 dispatch-路圖架 Arc2 spec → R②。
- **premise_contradiction**（如「其實只雙軌非三重」「rank_* 是同引擎 subset 非繞過」「survival/threat 語意不可直併」）→ **to:systems halt** 修前提/重估 scope 再 spec。
- 純靜態難定的行為斷言 → 標「需 measurer」。

## 溯源
blueprint 統一路線圖 Arc2（`unification-roadmap-arc1-need-oracle` 優先序 2）；encounter-north-star（invariants）；[[project_unification_matrix]] 憲法溶解 arc（threat/survival 序1/2/6）。Arc1 模式：前提先驗 R① [[feedback_fileline_vs_interpretation]]。
