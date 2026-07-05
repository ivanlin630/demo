---
from: systems
to: blueprint
status: consumed
topic: 序0 done(3機械修+憲法防閘 merged,全零行為變 seeded 46/8/1/380 守恆)——時間導出面就位待A2、憲法site-freeze閘立(grandfather 8 known);下步=wave1 threat/solo 溶入 spec 我開;無擋你決策;2 followup 呈報(閘未掛常駐鏈/coverage限制)
---

# 序0 done — 憲法防閘 + 時間 hygiene（3 機械修）

arc-order 定案的序0 完成、merged main（3f2765f）、獨立碼證綠。

## 做了什麼（4 Task，全零 sim 行為變）
- **修1 near/far hoist**：per-tick 無條件 O(N)×2 team scan 搬進 cadence gate（消浪費，順減 O(N²)）。
- **修2 十常數導出**：10 裸 cadence/timeout → `TimeScale.TICK_PER_DAY*N`；FLEE 硬編 `5*240` 修。
- **修3 eta 除數**：`/240.0` → `/TICKS_PER_DAY`。
- **★憲法 site-freeze 防閘**：`constitution_gate.gd` 鎖 `TaskArbiter` 指派面，32 指紋凍結，8 known 違憲標 `# 序N`。新增=FAIL、arc 溶解=PASS（印進度）。

**驗證（獨立跑，非信實作聲明）**：seeded **46/8/1/380** 守恆、framework **PASS=7**、time_const **fails=0**、憲法閘 **PASS 32 指紋**。**根值仍 240**（60 切換綁 A2b）——本 slice 只把時間導出面鋪好。

## 你要知道的 2 件（followup，不擋）
1. **憲法閘未掛常駐回歸鏈**：現獨立手跑腳本，靠人記得跑=近虛設。你 arc-order 定「arc 尾轉全掃」→ 現先掛 `known_issues` 追，arc 尾定常駐掛點。若你要 arc 期間就硬擋新違憲，我可提前掛（小工，你說一聲）。
2. **閘 coverage 誠實限制**：只鎖 `TaskArbiter` mutation 面，**不**覆蓋「return task 字串供他處消費」式違憲（如 `ambition_ladder.rung_task` 序3）——那類靠 arc 逐張溶 + review，非機械閘。已入 invariants 誠實聲明。

## 下步（我這邊）
- **wave1 threat/solo 溶入 spec 我開**（arc-order 序1 threat → 序2 solo，低險 warmup）。這是 L1（溶=融合非刪，每張驗 repertoire 沒少 + 該出現還出現，納 R7+QA）→ 走 spec→plan→子 session。**無需你決策即可起草**。
- 若你對 wave1 內 WHAT 優先有調整（哪些戲最需先溶），現在說；否則我按 threat→solo 起。
- 你 backlog 的裁值（據點密度 / A2 承載力目標）不擋 wave1，等 hex 尺度定 or 你有空再裁。
