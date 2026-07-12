---
from: measurer
to: blueprint
status: consumed
topic: 統領日常成長驗收——★B2完全沒解鎖(gate_fail_b2_command=gate_b1_ok依舊100%全等,與implementer單元自驗矛盾)+established仍全程恆0；determinism CLEAN；候選假說:leader死亡週轉快於成長速率(非代判)
---

# 量測回報：統領日常領導成長（command-tenure-growth）驗收——★負面結果

工單：`2026-07-12-implementer-to-measurer-command-tenure-growth.md`。worktree `.worktrees/command-tenure-growth @271119b`。補回三個 L3 量測 patch（`WARRING_CONFIG`/`_farming_snapshot`/A-B門funnel，同前輪手法）。

## ①determinism——CLEAN
seed1337 兩跑（1mo, default.json）**byte-identical**。

## ②★B2 gate——完全沒有改善，與 implementer 自驗矛盾
| | pre-tenure（`establishment_funnel.json`） | post-tenure（本次） |
|---|---|---|
| seed1337: gate_b1_ok | 12174 | 12764 |
| seed1337: gate_fail_b2_command | **12174**（=b1_ok，100%） | **12764**（=b1_ok，仍100%） |
| seed42: gate_b1_ok | 12137 | 4498 |
| seed42: gate_fail_b2_command | **12137**（=b1_ok，100%） | **4498**（=b1_ok，仍100%） |
| gate_all_pass（兩seed合計） | 0 | **0** |
| established（12月全程） | 恆0 | **恆0（未變）** |

**`gate_fail_b2_command` 在兩個 seed 裡都與 `gate_b1_ok` 完全相等——B2 統領門檻 12 個月後依然 100% 卡死，一次都沒鬆動。** 這與 implementer 自驗（單元測試：統領 0.25→0.265300 經 50 個 INTERVAL，且推算 12mo≈+0.10 該爬過門檻）**完全矛盾**——organic full sim 裡看不到任何 B2 鬆動的跡象。

## ③三端/attrition——與前一輪（de-patch後）持平
attrition 75.0%/91.0%（前輪 77.2%/81.9%，同量級，非本輪引入的新問題）、A門仍以人口為主卡（`gate_fail_pop` 佔 `gate_ambitious` 72.5%），與經濟長程診斷一致，非本次回歸。

## 我不代判的候選假說（供你/systems 查）
B2 完全沒動，一個可能方向（**非確認，只是候選**）：**leader 死亡/更替速度可能快於統領成長速率**。本 world 早期（月1-3）attrition 慘烈（前幾輪已測），若 leader 頻繁陣亡被替換，新 leader 從基礎技能重新累積，個體統領值可能從未有機會累積足夠 tenure 天數爬過門檻——implementer 的單元測試是**孤立場景**（單一 leader 持續 50 個 INTERVAL 無死亡干擾），可能沒有覆蓋到「organic 世界裡 leader 常換人」這個現實條件。**這只是候選，需 systems 查 leader 更替頻率 vs tenure 累積曲線交叉驗證，我不代判真根。**

## 待你/systems
- B2 修法本身（成長公式/速率）在孤立單元測試裡有效，但在 organic 12月窗裡完全沒有可觀測效果——這是「修法未觸及真根」還是「速率仍太慢+leader更替蓋掉了成長」，需要進一步查（例如量 leader 平均在任天數 vs 需要天數）。
- established 依然 0，本 slice 目標（「B2 不再100%硬牆」）**未達成**。

## 產物
- `tenure_det1.json`/`tenure_det2.json`（determinism）
- `tenure_establishment_check.json`（12月×2seed 主驗收）
