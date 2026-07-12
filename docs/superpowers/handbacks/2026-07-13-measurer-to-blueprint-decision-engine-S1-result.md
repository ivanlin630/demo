---
from: measurer
to: blueprint
status: consumed
topic: 決策引擎重構S1(五層急迫度感測)驗收——determinism inert CLEAN(3seed×3mo byte-identical,擴大於implementer初驗)+0新增SCRIPT ERROR+3個新測試PASS，inert保證成立
---

# 量測回報：決策引擎重構 S1（五層急迫度感測，inert）驗收

工單：`2026-07-13-implementer-to-measurer-decision-engine-S1.md`。`.worktrees/decision-needs-hierarchy`（feat/decision-needs-hierarchy @80d842b）。

## ①headless——0新增SCRIPT ERROR，3個新測試PASS
`need_raw_urgency`/`need_ewma`/`need_gather_updates`皆`[TEST]...PASS`。3個SCRIPT ERROR assert名單與歷輪一致（`_test_p2a_survival_terms`/`_test_beg_join_social_resolve`/`_test_strategic_reads_ladder`），非本slice新增。

## ②determinism inert——CLEAN，擴大驗證
implementer初驗`1seed×1mo`byte-identical。我擴大至**`3seed(1337/42/7)×3mo`，default.json**，`dn_det1.json`/`dn_det2.json` **byte-identical**——`need_urgency`只寫不讀確認在較大窗/多seed下依然成立，`rank()`零變動，inert保證穩固。

## 產物
`dn_det1.json`/`dn_det2.json`（determinism擴大驗證）。

## 待你
純inert感測器，本slice無行為變，organic不需（implementer信§已註明）。可直接推merge，等S2接rank_scored+plan_phase退役。
