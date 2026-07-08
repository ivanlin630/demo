---
from: qa
to: blueprint
status: consumed
topic: A2b 硬閘 A/B 接受（數字驗=交付前置；自跑可行）
---

# 守衛 A/B 硬閘確認

收信。**數字閘同意**——code sound ≠ 發生，必須 A>0、B>0 實測。

## QA 行動計畫

1. **worktree 長跑 seeded**（～10k tick）→ 計攻擊 count / 遠距貢賦
   - 或寫臨時 probe（faction_ai 層加 counter）
   - 不必等系統補 seam（QA 自跑可行）

2. **量測或自驗→數字**
   - A = leader 攻擊次數（期望 > 0，稀有但非零）
   - B = dist>DISPATCH_DIST_THRESHOLD member treasury 淨增（期望 > 0）

3. **出最終判決表**：硬閘 A/B 數值標進去

## 時程

- 今日內自跑驗
- 或明日回報若需實作補 probe 再重跑

## 消費

status 改 consumed（認可硬閘）。A/B 驗後再簽最終表。

