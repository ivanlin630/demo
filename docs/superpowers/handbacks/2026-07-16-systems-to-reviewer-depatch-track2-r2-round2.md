---
from: systems
to: reviewer
status: open
topic: "[R² round2·軌2解閘2/3後] blueprint裁乙-陡+RNG判準精修3案。systems驗曲線(非臆斷):consider_betrayal已陡(driver≥HARD→100%/中間才randf)→gate-ok/try_proactive 0.2~0.7平→陡化(非de-patch)/_check_discipline fail-under-stress=outcome案②→gate-ok。閘4 randi=event-ID→gate-ok(我own錯)。閘7 calc_attack_score孤兒→刪。de-patch實標的=閘1 _threat_recent+閘5 tribute FLEE+閘6 _calc_diplomacy硬門檻+try_proactive陡化。審:曲線判定對?陡化非de-patch對?de-patch真拆?CLEAN才dispatch"
---

# R² round2：軌2（解閘2/3 曲線驗證後）

> **[worker 守則] 卡住/疑義 → handback `to:systems`，禁 `AskUserQuestion`。**

blueprint 裁乙-陡 + RNG 判準精修 3 案（入 invariants）。**systems 驗曲線陡度（非臆斷，讀實碼）**，spec 更新。re-R² 整軌2。

## spec（更新）
`docs/superpowers/specs/2026-07-16-depatch-track2-value-gates.md`

## 軌2 最終標的（R² round1 issues 全解）
- **de-patch（真行為閘）**：閘1 `_threat_recent`→intent/好戰軍備 / 閘5 tribute FLEE override→膽識-絕望秤 / 閘6 `_calc_diplomacy_score` 硬門檻→軟化 / **閘2b `try_proactive_diplomacy` 陡化**（0.2~0.7 平→性格推兩端）。
- **gate-ok（legit，systems 驗）**：閘2a `consider_betrayal`（已陡：driver≥HARD→100%、中間才 randf=案③陡）/ 閘3 `_check_discipline`（fail-under-stress=案②outcome）/ 閘4 `_maybe_request_join`（randi=event-ID 非決策，我 own 錯）。
- **刪**：閘7 `calc_attack_score`（孤兒零 caller）。

## 審什麼
1. **曲線判定對**？consider_betrayal 真夠陡（清楚案例 deterministic）→gate-ok；try_proactive 真平→陡化；_check_discipline 真 outcome（非決策）→gate-ok？
2. **陡化非 de-patch 對**？try_proactive 陡化=改機率曲線（性格推兩端），保 RNG（案③合法-IF-陡），非拆成 deterministic——符 blueprint 乙-陡？
3. **de-patch 真拆非搬家**（閘1/5/6）？人格映射 sound？
4. 非回歸（行為變非 byte-identical、感知鐵律、守恆、閘 removed）。

## 流向
CLEAN → to:systems → dispatch implementer（de-patch 閘1/5/6+try_proactive陡化 / gate-ok 標 baseline 2a/3/4+A類~60 / 刪7）→ measurer 乾淨全量（行為分化+陡曲線+無回歸+閘 removed）→ 批。
