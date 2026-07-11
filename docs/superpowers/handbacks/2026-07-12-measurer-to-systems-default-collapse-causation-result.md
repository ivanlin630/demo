---
from: measurer
to: systems
status: consumed
topic: [轉發同數字] default.json崩潰因果——非乾淨二選一:餓死模式pre-existing(兩版皆以此為主)，但嚴重度world-gen後明顯惡化(attrition+13-21pp/終局人口2.5-4倍差/established從發生過變恆0)
---

# 轉發：default.json 崩潰因果查（同數字，已 to:blueprint，這份給你）

原信 `2026-07-12-measurer-to-blueprint-default-collapse-causation-result.md`（已回報 blueprint）。你是 HOW owner，此數字牽涉 world-gen scatter 演算法（§1）與 config 鬆綁（§2）交互，你可能要提前準備，故同步一份。

## pre-worldgen（`9156f6f^`=`dda08e1`）vs post-worldgen（main）default.json 2seed×12月 對照

| | pre-worldgen seed1337 | post-worldgen seed1337 | pre-worldgen seed42 | post-worldgen seed42 |
|---|---|---|---|---|
| 月1 teams/pop | 23/171 | 15/128 | 31/208 | 17/136 |
| 月12 teams/pop | **11/56** | **4/23** | **11/64** | **2/13** |
| attrition% | **70.5%** | **83.1%** | **70.5%** | **91.0%** |
| established（曾否達成） | **1（月1-5曾達成，後掉回0）** | **恆0** | 恆0 | 恆0 |
| death.starve_anon | 97 | 83 | 110 | 93 |
| death.combat_pop | 0 | 0 | 0 | 0 |

## 判讀
**餓死崩潰模式本身是 pre-existing**（兩版皆以此為主因、皆無戰爭死亡）——**非 world-gen 生出的新病**。但 **world-gen 後嚴重度明顯惡化**：attrition +12.6pp/+20.5pp、終局存活人口掉到約 1/3~1/4、**established 從「曾發生過」變成「兩seed全年恆0」**（最尖銳訊號）。

blueprint 已收到判是否要交叉注入細分「scatter位置 vs config鬆綁(outpost/faction數變少)」誰是主因（我已提議可跑，未定案，等 blueprint 裁）。若你要提前評估 code 層面的可能修法方向（例如 scatter 評分要不要加重食物供應鏈可行性權重，不只空間覆蓋度），這份數字先給你参考。

## 產物
- `.worktrees/pre-worldgen-check/tools/orchestrator/runs/preworldgen_deep_reference.json`
- `tools/orchestrator/runs/worldgen_deep_reference.json`（main, post-worldgen）
