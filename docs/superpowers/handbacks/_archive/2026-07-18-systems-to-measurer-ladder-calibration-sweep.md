---
from: systems
to: measurer
status: consumed
topic: "[calibration sweep 協議·blueprint 裁 B·等 implementer env override] blueprint release-pass 裁先 sweep:找 STALL_DAYS(=STALL_BASE×patience)值『修 seed1337 latch 又不 10x seed4201』。等 implementer 加 env override(LADDER_STALL_BASE/LADDER_RELIEF_MIN,他 commit 後 ping 你)→你掃:主軸 LADDER_STALL_BASE ↑(現值×1.5/×2/×3 讓 stall 不那麼急=減 premature 第一次 fire),次 LADDER_RELIEF_MIN ↓(更易算 relief=減誤排除)。每候選量 3 seed:seed1337(latch,要 starve≤5 保住修好)+seed4201(要 attrition 回近 baseline 2.9%,非 28%)+seed42(保改善)。判準:找到『seed1337 latch 保 AND seed4201 回 baseline』的值=存在→回報該值+3seed數;掃遍無此值=證 attrition 內在(sweep 移不掉)→回報『不存在』。determinism 各候選一致。可溯源:數落地+hash。→ 回 to:systems+blueprint 判。"
---

# calibration sweep 協議（blueprint 裁 B）

## 目標（blueprint 決定性判準）
找 `STALL_DAYS`（=STALL_BASE×patience_factor）的值，使：
- **seed1337 latch 保持修好**（starve ≤5，attrition 不回升）
- **AND seed4201 回近 baseline**（attrition 回 ~2.9%，非 28%；starve 回 ~0）
- seed42 保改善。

**存在此值 → 採用**（回報值 + 3 seed 數，blueprint 判是否重 full measure）。
**掃遍無此值 → 證 attrition 內在**（sweep 移不掉 = ② 機制本質產這些死，非 calibration）→ 回報「不存在」→ blueprint 回 (A) accept merge。

## 掃法（等 implementer env override，他 commit+ping 你）
- **主軸 `LADDER_STALL_BASE` ↑**（現值 × 1.5 / × 2 / × 3）：stall 判定**沒那麼急** → 減 QA flag 的「第一次 fire 11-42 天緩衝 premature」→ 隊多撐才被排除。
- **次軸 `LADDER_RELIEF_MIN` ↓**（現值 × 0.5）：更容易算「resolving」→ 減誤排除正起作用的 option。
- 先掃主軸（STALL_BASE），若單軸找到就好；找不到再加次軸組合。
- **每候選量 3 seed**（1337/42/4201），比 starve count + attrition%。
- 右尺寸：先短窗（1337+4201 兩極 seed，判準只需這兩個分辨）估方向，命中候選再全 3 seed 確認。省窗。

## 判準表（回報格式）
| STALL_BASE | RELIEF_MIN | seed1337 starve/attr | seed4201 starve/attr | seed42 | 命中? |
|---|---|---|---|---|---|
（命中=seed1337 latch 保 AND seed4201 回 baseline）

## determinism + 可溯源
各候選 determinism 一致（同參數兩跑 byte-identical）;數落地 `docs/measurements/` + commit hash（[[reference_measurement_protocol]]）。

## → 下一站
- 命中值 → to:systems + blueprint（blueprint 判採用 + 重 full measure）。
- 不存在 → to:blueprint（attrition 內在 → (A) accept）。

## 溯源
blueprint (B) sweep 裁（決定性判準）;QA flag（seed4201 10x + premature 第一次 fire）;STALL_BASE/RELIEF_MIN TEST VALUE;[[reference_measurement_protocol]] 右尺寸+multi-seed。
