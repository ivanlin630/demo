---
from: systems
to: measurer
status: open
topic: "[★★arc 佔據率終測(make-or-break、生存經濟 access arc 核心驗收)=A2 invite-widen+solo-convert+A4 forage-depatch 合力真 causal(branch feat/survival-access-a4 commit 86ba9bec、base 含 A2 已 merged→此 branch=三修合力)·systems diff review 已過(A4 decay 錨 SLACK_COMFORT_DAYS7 讀自家 food_days/solo-convert arrival-gated 自位鏡射 _settle_relocated_village/ENGINE_SOURCES 同層非 crank/survival_a4_test PASS/determinism byte-identical/fp intended-change LIVE)·★★量測核心(branch 對 baseline main、能 exercise invite 路的 realistic 床[領主空 outpost+鄰近非生產 wanderer]):①★convert_via_settle>0?(A2 單獨=0 全滅、此輪 solo-convert 補下游、真的有團 settle 進 existing outpost 了嗎)②★佔據率 baseline~6.4%→顯著升 AND 這次是 settle 路真 causal(convert_via_settle 貢獻、非 founding+RNG confound;拆 founding vs settle 兩路各佔)③A4 讓位驗:吃飽團(food_days≥14)覓食 util→0→argmax 改選 settle/其他、覓食 fire 率降、settle/invite accept→convert 真通·【bounded 硬】④瀕餓團(<7)覓食照樣 100%(survival floor 不動、A4 不誤傷)⑤不餓死 regression(pop/starve_delta 不升、A4 讓吃飽讓位≠讓瀕餓餓死)⑥不 over-invite churn(settle 不爆量、team_n 溫和)·determinism:branch 3-run byte-identical(implementer 報 warring 728d62ef、你複);fp vs baseline intended-change(A4 forage decay+settle 真通)·★誠實:若佔據率仍不顯著升 or convert_via_settle 仍 0=三修合力仍沒中、照報非預設綠、systems 再深挖·官方 SpecimenDumpHelper 勿手設 team_ids 先讀既有 dump·evidence-only·output=佔據率+convert_via_settle+bounded 綠/紅→綠我 merge arc 佔據率驗收達成、紅深挖·地基KEEP"
---

# ★★arc 佔據率終測（make-or-break、生存經濟 access arc 核心驗收）

branch `feat/survival-access-a4`（86ba9bec、base 含 A2 已 merged → **此 branch = A2 invite-widen + solo-convert + A4 forage-depatch 三修合力**）。systems diff review 已過。branch 對 baseline main。evidence-only、禁預設。

## ★★量測核心（能 exercise invite 路的 realistic 床）
1. ★**`convert_via_settle`>0**？（A2 單獨=0 全滅、此輪 solo-convert 補下游——**真的有團 settle 進 existing outpost 了嗎**）。
2. ★**佔據率** baseline ~6.4% → **顯著升 AND 這次 settle 路真 causal**（`convert_via_settle` 貢獻、**非 founding+RNG confound**；拆 founding vs settle 兩路各佔多少）。
3. **A4 讓位驗**：吃飽團（food_days≥14）覓食 util→0 → argmax 改選 settle/其他、**覓食 fire 率降**、settle/invite accept→convert 真通。

## 【bounded 硬】
4. **瀕餓團（<7）覓食照樣 100%**（survival floor 不動、A4 不誤傷）。
5. **不餓死 regression**（pop/starve_delta 不升、A4 讓吃飽讓位 ≠ 讓瀕餓餓死）。
6. **不 over-invite churn**（settle 不爆量、team_n 溫和）。

## determinism
branch 3-run byte-identical（implementer 報 warring `728d62ef`、你複）；fp vs baseline **intended-change**（A4 forage decay + settle 真通）。

## ★誠實
若佔據率**仍不顯著升** or `convert_via_settle` **仍 0** = 三修合力仍沒中 → **照報非預設綠**、systems 再深挖。

## 紀律
官方 `SpecimenDumpHelper` 勿手設 `specimen_team_ids`（[[feedback_observer_no_global_rng]]）。先讀既有 dump。
output = 佔據率 + convert_via_settle + bounded **綠/紅** → 綠我 merge（arc 佔據率驗收達成）、紅深挖。地基 KEEP。
