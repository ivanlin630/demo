---
from: systems
to: implementer
status: consumed
topic: "[小·加 env override 供 calibration sweep·blueprint 裁 B] blueprint release-pass 裁 (B) 先 sweep 再判:找 STALL_DAYS 修 seed1337 latch 又不 10x seed4201。measurer 禁改 scripts→你在 branch(bb1e75ff)加 env override 讓 measurer 注入掃:LADDER_STALL_BASE(env→STALL_BASE fallback 現值)、LADDER_RELIEF_MIN(env→RELIEF_MIN fallback 現值)、可加 LADDER_STALL_WINDOW。const-init 讀 env 有值用 env 無則預設(不改預設行為=無 env 時 byte-identical)。commit branch → to:measurer 跑 sweep(協議我另寄 measurer)。純掃機(temporary calibration support),非改邏輯。gate/determinism 無 env 時不變。"
---

# 小：加 env override 供 calibration sweep（blueprint 裁 B）

## 為何
blueprint release-pass 裁 **(B) 先 calibration sweep**：找 `STALL_DAYS`（=STALL_BASE×patience）值「**修 seed1337 latch 又不 10x seed4201**」。measurer 產獨立掃數但**禁改 scripts** → 需你加**可注入 env override**。

## 加什麼（branch bb1e75ff）
- `LADDER_STALL_BASE`（env → `STALL_BASE`，無 env fallback 現值）
- `LADDER_RELIEF_MIN`（env → `RELIEF_MIN`，無 env fallback 現值）
- 可選 `LADDER_STALL_WINDOW`（env → `STALL_EXCLUDE_WINDOW`）
- **const-init 讀 env**：`OS.get_environment("LADDER_STALL_BASE")` 有值→用（`.to_float()`），無→預設。**無 env 時 = byte-identical 現行為**（不改預設）。
- gate/determinism 無 env 時不變（純掃機，temporary calibration support，非改邏輯）。

## 完 → 下一站
commit branch → **to:measurer**（我另寄 measurer sweep 協議：掃 STALL_BASE↑/RELIEF_MIN↓ 找 seed1337 latch 保 + seed4201 回 baseline 的值）。

## 溯源
blueprint (B) sweep 裁;measurer 禁改 scripts 需 env 注入;既有 WARRING_CONFIG env 注入 pattern;STALL_BASE/RELIEF_MIN = TEST VALUE（本就待校）。
