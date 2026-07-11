---
from: measurer
to: blueprint
status: consumed
topic: world-gen variety §4 全探針參照基線完成——18seed×3mo無異常(annih=0/floor18/18全綠/無寡頭化)，標記為新baseline存檔
---

# 量測回報：world-gen variety 全探針長跑參照（§4 重 baseline，addendum 用戶要求項）

`worldgen_final18`（18seed×3mo，控制config `warring_states.json`，用標準 `WarringHarness` 全探針）**跑完，18/18 seed 齊**。依 addendum 指示標記為此次 world-gen variety 的新基線參照。

## 全維度異常掃描（無異常）
| 探針 | 數值 |
|---|---|
| combat.end_annihilation | 0 |
| combat.end_mortal_flee | 167 |
| combat.end_rout | 14 |
| combat.end_retreat | 4 |
| capture.total | 15 |
| worldgen.floor_pass / fail | 18 / 0（全綠） |
| worldgen.build_outpost | 322（18 seed 合計，均~18/seed） |
| conq.declared | 16562 |
| merge.consolidate_dispatch | 25654 |
| 平均終局隊數 | 32.72（無寡頭化/滾雪球跡象） |

annih=0、floor 100%、無寡頭化，戰鬥面（flee 主端 167、rout/retreat 次要）與先前系列同型態分布，**無異常維度**。

## §4 重 baseline 定位
此份即為 world-gen variety（§1 scatter 生效於控制 config）造成的位移後基線，**標「world-gen variety 位移，非迴歸」**。存檔：
- `.worktrees/worldgen-variety/tools/orchestrator/runs/worldgen_final18.json`（原始）
- `.worktrees/worldgen-variety/tools/orchestrator/runs/worldgen-variety-baseline-reference.json`（同檔複本，明確命名供未來對照用）

## 至此 world-gen variety 全部量測項清單
1. ✅ 地板/variety 純生成掃（30 seed，控制config+default.json 各一輪）
2. ✅ build-outpost 短窗（控制config 7/7、default.json 7/7 皆 fire）
3. ✅ determinism（setup層 + sim層皆驗）
4. ✅ §4 全探針長跑參照/新 baseline（本信）

全部四項 gate 綠。質感（GUI 人驗）留你/user。
