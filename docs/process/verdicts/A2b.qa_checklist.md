---
slice: A2b
from: qa
status: in_progress
date: 2026-07-09
---

# A2b QA 驗收清單

## 協議前置（已收、入賬）

✓ 藍圖協議：2 硬前置（GODOT_TIMEOUT=600 + before/after 雙 checkout）
✓ A2b spec 讀完（D1/D2/D3/D4 + 呈報藍圖 3 項）

## 機械面驗收（量測員已交、QA 複驗中）

| # | 項目 | 量測員數據 | QA 複驗 | 狀態 |
|---|---|---|---|---|
| 1 | leader_bypass → 0 | 達成 | ✓ worktree HOB 驗證 0 | ✓ |
| 2 | subteam_bypass → 0 | ✓ | 同上 | ⏳ |
| 3 | unified 路由 99.7% | ✓ | 同上 | ⏳ |
| 4 | determinism PASS | ✓ | 同上 | ⏳ |
| 5 | Constitution Gate | ✓ | 讀代碼待驗 | ⏳ |

## 邏輯面驗收（硬閘 2 項；待補數據）

| # | 項目 | 指標 | 量測員數據 | 狀態 |
|---|---|---|---|---|
| **守衛 A** | 征服稀有非零 | leader 攻擊 count > 0（seeded 長跑 ≥數千 tick） | ❌ 缺 | **待補** |
| **守衛 B** | 遠距貢賦 | treasury 增 > 0（dist > DISPATCH_DIST_THRESHOLD member） | ❌ 缺 | **待補** |

### 守衛 A 需驗項

- [ ] seeded 長跑（≥3000 tick），list 所有 leader 主動發起的攻擊（print 或 counter）
- [ ] 對照 A2b 前 baseline（hand forced cascade），驗征服仍稀有（多數 tick 經濟意圖勝）
- [ ] 驗定向：攻擊 target = `_nearest_independent`（同舊代碼 1390）

### 守衛 B 需驗項

- [ ] seeded 遊走，抽驗 dist > DISPATCH_DIST_THRESHOLD 的富 member，檢查 tribute 成交 / treasury 增
- [ ] 無持續無守：leader 離家徵收期間，capital outpost 無駐守隊（threat 自然 preempt）

## 呈報藍圖 3 項（code 遊走中）

| # | 項目 | 需求 | QA 進度 |
|---|---|---|---|
| 3a | target 保真 | 攻擊/徵收/外交 target 同 A2b 前，純路由無改 | ✓ code 驗證：decision_context 205-217 無改 |
| 3b | prio 降無 latch | leader 攻擊(50) 不 preempt threat(70)/survival(80) | ✓ code 驗證：arbiter line 30 嚴格大於 |
| 3c | 離家無暴露 | leader 選 徵收 離家時，threat 自然 preempt | logic OK（threat>dispatch） |

---

## 下一步

1. **等 worktree HOB 完成** → 複驗 1-4
2. **要量測員補守衛 A/B 數據** → 或 QA 自跑遊走
3. **code 遊走** → 3a/3b/3c 邏輯驗證
4. **出判決表** → 狀態改 consumed

