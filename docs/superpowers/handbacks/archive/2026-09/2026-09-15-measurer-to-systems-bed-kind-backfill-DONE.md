---
from: measurer
to: systems
status: consumed
slice: bed-kind回填
topic: ★歸宿決定:homeless_producer_bed.gd正式commit進repo(commit c14c32871)，補@bed-kind:diagnostic（純聚合無判決邏輯）。★★順手全面檢查我這幾天寫的其他床,發現同型缺口散布在11支(只有frame_time_who_freezes_bed有,implementer幫我加的)——全部一併補上：gen4_checkup_registry_ledger_bed含InvariantAudit PASS/FAIL式輸出標acceptance,其餘10支標diagnostic
---

# 這支的歸宿

```
scripts/debug/homeless_producer_bed.gd 正式commit進repo(c14c32871)，
加@bed-kind: diagnostic（純聚合統計，無_ok/push_error類判決邏輯）。
之前2026-09-11交件時只commit了.measure.json/raw log/handback，
忘了床本身——這次一併補。
```

# ★★順手擴大檢查：同型缺口在我這幾天寫的床裡有11支

```
逐一檢查我寫的12支床(含這支)，只有frame_time_who_freezes_bed有@bed-kind
(implementer幫我加的)，其餘11支全部沒有。這次一次性全部補齊：

acceptance(含InvariantAudit PASS/FAIL式輸出)：
  gen4_checkup_registry_ledger_bed.gd

diagnostic(純聚合，無判決邏輯，已逐一grep確認)：
  homeless_producer_bed.gd／away_distance_task_bed.gd／
  resident_truthset_distance_bed.gd／attack_door_census_bed.gd／
  terrain_density_distance_bed.gd／sustainability_map_bed.gd／
  lord_belief_coverage_bed.gd／promotion_exp_gate_bed.gd／
  train_option_util_dump_bed.gd／resident_identity_vs_position_bed.gd／
  population_and_turnover_specimen_bed.gd
```

commit c14c32871，全部12支--check-only先驗過語法才commit。這次教訓：
以後寫床時開頭就先加@bed-kind，不要等收工才補。
