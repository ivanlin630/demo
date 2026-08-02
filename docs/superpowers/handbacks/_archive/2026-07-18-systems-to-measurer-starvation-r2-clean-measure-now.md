---
from: systems
to: measurer
status: consumed
topic: "[R² CLEAN·starvation fix ebf4489b 可 measure] 異質 Sonnet R² 全綠(6 類追完:thrash/5th-path/掠奪排除/camp-join軸/famine-cap/double-count 皆 CLEAN;額外驗第5 dispatch site _try_join_target:1795-96 也讀 priority_for=單一源完整5路)。→ 跑 sim measure:is_sim=true + seed1337/42/4201(含硬 seed)。歸因規則見前信(known-residual-attribution):team19 若 cross-map-starve=①invite-teleport 已知殘留(slice2)非 regression;當前 fix 成功判準=priority保序(survival preempt,驗 solo+subteam 兩類)+team14/27 escalation fire(有 out)+無新 thrash/idle-starve。數字落地存檔+hash。完→.measure.json→QA 故事稽核.qa.json→blueprint release-pass。"
---

# R² CLEAN → measure now（starvation fix ebf4489b）

## R² 結果（異質 Sonnet，refute-framed）
**VERDICT: CLEAN**。6 攻擊類全追（file:line 坐實）：
1. **thrash/latch CLEAN**：`famine_severity` 共乘子（camp/join 同 tick 同 severity）→ 排序由 static 人格（野心軸）定非 severity → 無 crossover 震盪。COMMITMENT_BONUS 0.3（`decision_engine.gd:6`）gate self-replace，util gap（中性≈0.10、skew 決定性）全 < 0.3。窮死=無 applicable 非暴力 option 時的可接受敗態。
2. **5th path CLEAN**：全 5 survival call site（unified:1560/subteam:1774/**_try_join_target:1795-96**/solo:1902/survival:3376）皆讀 `priority_for(opt)`。FLEE 從舊 ad-hoc PRIO_DISPATCH 一致升 PRIO_SURVIVAL（S3 regression restore），到處一致非新違反。
3. **掠奪排除 CLEAN by design**：`_intent_fit`(terms.gd:271-280) SCARCITY_RAID_MIN 0.55 gate 野心/好戰 hunger-scale；溫和窮隊(<0.55)零 raid→beg/join/camp/窮死=documented intent。
4. **camp/join 軸 CLEAN**：+野心 vs +(1−野心) 鏡射既有 base weight(terms.gd:322-326)，僅野心=0.5 對稱但 base term(統領/rep-magnet)仍區分，非 backwards 非新 thrash。
5. **famine cap CLEAN**：soft ramp 0→1，applicable gate 同 DESPERATION_DAYS 3.0，severity applicable 即 >0，無 step-function pre-empt。
6. **double-count CLEAN**：只 併入/紮營/乞食 得 famine_amp；買糧 SECURITY_STOCK_DRIVE / 掠奪 _intent_fit 皆 predate 未觸。

## → measure now
- sim measure **is_sim=true** + **seed1337/42/4201**（含硬 seed，[[reference_measurement_protocol]] multi-seed-before-claim）。
- **歸因規則**（前信 known-residual-attribution）：team19 cross-map-starve = ①invite-teleport 已知殘留（slice2）非 regression；story-audit 讀死因 trace 誠實歸因。
- **當前 fix 成功判準**：priority保序生效（solo+subteam survival @80 preempt，驗兩類隊）+ team14/27 escalation fire（餓深→乞/紮營/投靠有 out 非乾等）+ 無新 thrash/idle-starve。
- 數字落地存檔 + commit hash（可溯源鐵律）。
- 完 → `.measure.json`（is_sim=true）→ **QA 故事稽核 `.qa.json`** → blueprint release-pass。

## 溯源
異質 R² CLEAN（Sonnet ad04503e）;starvation spec ebf4489b;[[reference_measurement_protocol]];known-residual 前信。
