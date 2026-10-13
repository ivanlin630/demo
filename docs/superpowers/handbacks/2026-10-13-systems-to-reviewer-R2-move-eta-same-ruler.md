---
from: systems
to: reviewer
status: open
slice: 移動預計時間與實走不符（藍圖小票）
topic: R² 請審 docs/superpowers/specs/2026-10-13-move-eta-same-ruler-HOW.md
---

# R²：移動預計時間＝物理同一把尺

spec：`docs/superpowers/specs/2026-10-13-move-eta-same-ruler-HOW.md`

想請你特別看：
1. 估算器「空跑物理迴圈」是否真的只呼叫物理那一支（move_cost_pure 拆 pos／time_mult 版、晝夜改 static）——有沒有我漏掉的倍率來源。
2. 容差「一個 hour 組」是否站得住（移動步在 hour 組）。
3. 疲勞 0% 的三種可能是否列全。
4. AI 的 `_estimate_eta_to` 留在範圍外（會動 world-fp）是否合理。
