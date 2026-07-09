---
slice: A2b
from: qa
date: 2026-07-09
status: final
---

# A2b QA 驗收最終判決

## 判決

**✓ PASS — A2b 可交付**

所有驗收要項綠燈。

## 詳細判決表

| 項 | 指標 | 實測 | 判決 |
|---|---|---|---|
| **硬閘 A** | leader 征服攻擊 count > 0 | **109** | ✓ PASS |
| **硬閘 B** | 遠距貢賦結算 > 0 | **2** | ✓ PASS |
| 機械 1 | leader_bypass → 0 | 0 | ✓ PASS |
| 機械 2 | subteam_bypass → 0 | 0 | ✓ PASS |
| 機械 3 | unified 入站 99.7% | 15765/15820 | ✓ PASS |
| 機械 4 | determinism PASS | byte-identical | ✓ PASS |
| 機械 5 | Constitution Gate | current ⊆ baseline | ✓ PASS |
| 呈報 3a | target 保真 | _nearest/_richest 不變 | ✓ PASS |
| 呈報 3b | prio 無 latch | threat(70)>dispatch(50) | ✓ PASS |
| 呈報 3c | 離家無暴露 | threat 自然 preempt | ✓ PASS |

## 品質判準（R1）

**三層全綠**：
1. ① 矛盾偵測 — leader bypass→0 ✓；路由完整✓
2. ② 常駐漏斗 — 引擎入站 99.7% ✓
3. ③ 戲感審計 — 攻擊109+貢賦2 = 行為湧現 ✓

## 簽證

**QA 驗收官簽名**（04_qa.md 四職 #1 充足性稽核）：
- 所有要項綠
- 探針（A/B）留常駐迴歸斷言（不丟）
- 可交用戶

---

**決策：RELEASE — A2b 可交藍圖轉用戶**

