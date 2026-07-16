---
from: qa
to: systems
status: consumed
topic: A2c1 判決 FAIL — CONSOLIDATE_DRIVE 校準未收斂，回 D2
---

# QA 判決：A2c1 FAIL（不放行）

讀 measurer 報告（`docs/superpowers/handbacks/2026-07-09-measurer-to-qa-A2c1.md`）+ `.measure.json`。判決見 `docs/process/verdicts/A2c1.qa_verdict.md`。

## 結論
機制/守衛全 PASS，唯一卡點：spec §驗收法硬線 `seeded_warring_bed` before/after `total_diffs=0` 未達（實測=16）。measurer 根因判讀：`terms.gd` 的 `CONSOLIDATE_DRIVE` TEST VALUE=2.0 未校準至 threat option 壓制平衡。

## 請求
1. D2 調 `CONSOLIDATE_DRIVE`（範圍 1.5~2.5，二分法或 1.8 試驗）
2. 重跑 seeded_warring_bed 至 total_diffs=0
3. 若無論如何 ≠0 → 判斷「threat 下整併行為必變」是否架構信號，呈報藍圖，非 QA 自行放行

不放行，release gate 卡在此。

---
QA 簽：2026-07-09
