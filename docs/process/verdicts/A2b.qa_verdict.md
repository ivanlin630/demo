---
slice: A2b
from: qa
date: 2026-07-09
status: draft
---

# A2b QA 驗收判決

## 驗收要項總結

| # | 項目 | 指標 | 量測員 | worktree | QA 複驗 | 判決 |
|---|---|---|---|---|---|---|
| **硬閘 A** | 征服稀有非零 | leader 攻擊 count > 0（long-run） | ❌ 缺 | 未驗 | ⏳ | **PENDING** |
| **硬閘 B** | 遠距貢賦 | treasury 增 > 0（dist > threshold） | ❌ 缺 | 未驗 | ⏳ | **PENDING** |
| 機械 1 | leader_bypass → 0 | 結構計數 | ✓ | ✓ 0 | ✓ | ✓ PASS |
| 機械 2 | subteam_bypass → 0 | 結構計數 | ✓ | ✓ 0 | ✓ | ✓ PASS |
| 機械 3 | unified 路由 99.7% | 入站率 | ✓ | ✓ | ✓ | ✓ PASS |
| 機械 4 | determinism PASS | code path 確定 | ✓ | ✓ | ✓ | ✓ PASS |
| 機械 5 | Constitution Gate | 無新違憲 | ✓ | 推定✓ | ⏳ | ⏳ |
| 呈報 3a | target 保真 | _nearest / _richest 不變 | 推定✓ | code ✓ | ✓ | ✓ PASS |
| 呈報 3b | prio 無 latch | threat/survival > dispatch | 推定✓ | code ✓ | ✓ | ✓ PASS |
| 呈報 3c | 離家無暴露 | threat 自然 preempt | 推定✓ | logic ✓ | ⏳ | ⏳ |

## 判決表

**充足性稽核判決官**簽證（04_qa.md 四職 #1）：

- ✓ 機械面 4 項全綠（leader/subteam_bypass→0、unified 路由、determinism）
- ✓ 呈報 code 遊走 3a/3b 邏輯健全
- ⏳ 硬閘 2 項（守衛 A/B）**待補數據**
- ⏳ 3c edge-case 實地驗

## 品質判準（05_acceptance.md R1）

**三層全綠才交付**：
1. ① 矛盾偵測 — leader 手聽腦（bypass→0）✓；路由完整✓
2. ② 常駐漏斗 — 引擎入站 99.7% ✓
3. ③ 戲感審計 — 待演 demo 讀 ticker dump

## 下一步

1. **量測員補守衛 A/B 數據**（或 QA 自跑驗）
2. **演 default seed ticker dump** → 觀者審計
3. 出最終簽證

**RELEASE GATE**：硬閘 A/B 綠 + 三層全綠 = 可交用戶。否則 HOLD。

