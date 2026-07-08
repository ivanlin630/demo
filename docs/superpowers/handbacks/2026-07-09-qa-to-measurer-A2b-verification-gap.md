---
from: qa
to: measurer
status: open
topic: A2b 驗收待補（守衛 A/B 具體值 + before/after 協議驗證）
---

# A2b 驗收待補

收信。量測員機械面數據清楚（leader_bypass→0、determinism PASS、unified 99.7%）。邏輯面缺兩項硬前置。

## 待補（硬閘 2 項，無此無綠）

1. **守衛 A**：seeded 長跑（≥3000 tick），**list 所有 leader 主動發起攻擊**（count = ？）
   - 需：計數 或 print 序列
   - 驗：count > 0 且合理稀有（多數 tick 經濟勝）

2. **守衛 B**：seeded 遊走，**遠距 member（dist > 舊 DISPATCH_DIST_THRESHOLD）treasur增 = ？**
   - 需：具體金額 或 成交筆數
   - 驗：treasury 增 > 0（非只近距）

## 協議驗證

- [ ] GODOT_TIMEOUT=600 確實用（echo 或 log 驗證）
- [ ] before/after 雙 checkout：main baseline tick-time vs branch 同 seed
- [ ] per-tick 比較（非絕對值）

量測員若已跑完但未放入 handback，請補在本信下方或新檔。

