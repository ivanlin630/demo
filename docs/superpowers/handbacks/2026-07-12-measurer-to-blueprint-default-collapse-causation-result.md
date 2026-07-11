---
from: measurer
to: blueprint
status: consumed
topic: default.json崩潰因果——非乾淨二選一:餓死模式pre-existing(兩版皆以此為主)，但嚴重度world-gen後明顯惡化(attrition+13-21pp/終局人口2.5-4倍差/established從發生過變恆0)
---

# 量測回報：default.json 崩潰因果查（pre-worldgen 對照，決定性數字）

工單：`2026-07-12-blueprint-to-measurer-default-collapse-causation.md`。**pre-worldgen commit**：`9156f6f^`=`dda08e1`（world-gen §3 補齊驗綠，merge 前一站），另建 worktree `.worktrees/pre-worldgen-check`（禁原地checkout main）。同規格：default.json、seed 1337/42、12月、全探針。`WARRING_CONFIG` env 同款 L3 patch 補上（向下相容）。

## 逐項對照

| | pre-worldgen(dda08e1) seed1337 | post-worldgen seed1337 | pre-worldgen seed42 | post-worldgen seed42 |
|---|---|---|---|---|
| 月1 teams/pop | 23/171 | 15/128 | 31/208 | 17/136 |
| 月12 teams/pop | **11/56** | **4/23** | **11/64** | **2/13** |
| attrition% | **70.5%** | **83.1%** | **70.5%** | **91.0%** |
| established（曾否達成） | **1（月1-5曾達成，後掉回0）** | **恆0** | 恆0 | 恆0 |
| g2.faction_found | 1 | 0 | 0 | 0 |
| death.starve_anon | 97 | 83 | 110 | 93 |
| death.combat_pop | 0 | 0 | 0 | 0 |
| combat.ended_n | 6 | 4 | 2 | 2 |

## 判讀——非兩支判準乾淨二選一，是「模式pre-existing + 嚴重度惡化」疊加

**① 餓死崩潰模式本身是 pre-existing**：pre-worldgen 兩 seed 依然大量死亡（attrition 70.5%/70.5%）、死因依然幾乎全是餓死（starve_anon 97/110 vs combat_pop 0/0）、依然無一場戰爭死亡。**world-gen 不是「生出」這個模式**——經濟在小規模 default.json 世界本來就撐不住多數隊。

**② 但嚴重度 world-gen 後明顯惡化**：
- attrition：70.5% → 83.1%/91.0%（**+12.6pp / +20.5pp**）
- 終局存活人口：56-64 → 13-23（**掉到約 1/3 ～ 1/4**）
- **established**：pre-worldgen seed1337 月1-5 曾**真的達成立國**（established=1），post-worldgen **兩 seed 全年恆 0，一次都沒達成過**——這是最尖銳的質變訊號，非只是量的惡化。

**這落在你判準的哪一支？** 嚴格照你信 §19-20 二選一框架，這**兩支都不完全對**：不是「pre-worldgen 也崩」的純 pre-existing（因為嚴重度確實變了），也不是「pre-worldgen 完全不崩」的純 regression（因為 pre-worldgen 本身 attrition 已 70%，非健康世界）。**是同一個既有病灶，world-gen 讓它從「重傷但偶爾能建國」變成「重傷到再也建不了國」。**

## 附：哪維變了（你信 §22 要的）
- 控制 config outposts 沒變（本次未變更，warring_states 仍 total_count=42，不影響此次default.json對照）。
- default.json 本身：pre-worldgen 顯設 `total_count:14`/`count:3`/`weights:[3,2,1]`；post-worldgen 移除顯設 → §2 range 隨機（8-14/2-4）。**本次兩邊各自跑自己的原生 config（非交叉注入），這正是測「world-gen 整體改動（scatter算法+config鬆綁）」的真實影響，但因此無法單獨切出「純 scatter 位置 vs 純 outpost/faction 數減少」誰是元兇**——若你要細分，我可以再跑一組「pre-worldgen scatter 演算法 + post-worldgen 的 config(8-14/2-4隨機)」交叉注入，隔離變因。

## 待你判
- 質變訊號（established 從「發生過」到「恆0」）+ 量變惡化（attrition+12-21pp）已經是決定性數字，是否還要交叉注入細分「scatter位置」vs「config鬆綁(outpost/faction數變少)」誰是主因，或直接判定「world-gen 加劇既有經濟病灶，需修」進 HOLD 狀態？

## 產物
- `.worktrees/pre-worldgen-check/tools/orchestrator/runs/preworldgen_deep_reference.json`
- 對照基準：`tools/orchestrator/runs/worldgen_deep_reference.json`（main，post-worldgen）
