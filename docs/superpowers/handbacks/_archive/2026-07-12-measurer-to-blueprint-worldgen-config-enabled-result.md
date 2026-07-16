---
from: measurer
to: blueprint
status: consumed
topic: world-gen §2/§3 config啟用驗證——default.json跨seed真變(outpost8-14/faction2-4符合硬上限)+地板30/30全綠+determinism一致+build-outpost 7/7seed fire
---

# 量測回報：world-gen §2/§3 range 啟用（default.json，非控制config）

工單：`2026-07-12-implementer-to-measurer-worldgen-config-enabled.md`。worktree `.worktrees/worldgen-variety @40bb665`（`config/default.json` 移除顯設 total_count/count/weights）。**控制 config（warring_states/tyrant/warzone）不動**——前次快答的量測基準不受影響，`worldgen_final18`（控制config全探針參照）續背景跑。

## ①§2/§3 跨 seed 真變——30 seed 純生成掃（`worldgen_floor_scan.gd` 加 `WORLDGEN_CONFIG` env）
| | 分布 | 唯一值數 |
|---|---|---|
| outpost 數 | [8,14] 全域內，min=8 max=14 | 7 種 |
| faction 數 | [2,4] 全域內，min=2 max=4 | 3 種 |

**硬上限守住**（未見超出 8-14/2-4 範圍）、**無截斷/error**（weights 自生機制正常，符合 implementer 描述）。地板 `floor_pass=1/fail=0` **30/30 全綠**。跨seed據點座標平均重疊率 6.6%（真散布，與控制config的7.5%同量級）。

## ②determinism——setup 層一致
seed=1337 兩次獨立跑（`worldgen_floor_scan.gd`）：teams=15/factions=2/persons=39/outposts=9/floor_pass=1，**兩跑逐項相同**。

## ③build-outpost + regression——default.json 7seed×1月短窗
`seeded_warring_bed.gd` 加 `WARRING_CONFIG` env 支援後跑：**7/7 seed 皆 fire**（101→6、111→1、1337→2、202→1、222→1、42→2、7→2次）——量級比控制config（2-10次）略低但確實普遍 fire、非罕見/不fire。floor 全 pass，跑完無 SCRIPT ERROR，正常收尾。

## ④headless_test pre-existing FAIL（implementer 附帶提及）
implementer 信中提及「弱目標未加入攻擊 goal :3180」FAIL，自查為 hand-constructed 場景（world-gen-independent）。**我未重驗此項**（非本次 gate 範圍，implementer 已自證非本次改動所致）——若你要我獨立確認，另開工單即可。

## 綜合判讀
§2/§3 range 在 default.json 上**確認真實觸發、硬上限守住、地板全綠、determinism 一致、build-outpost 普遍 fire**——四項 gate 全過。控制 config 基線不受影響（隔離乾淨）。

## 待你（§4 重 baseline）
implementer 工單提到「§4 重 baseline（世界結構變，一次性重生標位移）」——**這是針對控制 config**（warring_states 等，world-gen §1 scatter 已影響其座標分布，即便 §2/§3 range 本身在控制 config 未觸發）。`worldgen_final18`（18seed×3mo 全探針）跑完即可直接標記為此次 world-gen variety 的新 baseline 參照，我會在它完成時處理並回報。default.json 本身無既有 baseline 可比（新啟用的路徑），不需重 baseline 動作。

## 產物
- 床：`.worktrees/worldgen-variety/scripts/debug/worldgen_floor_scan.gd`（加 `WORLDGEN_CONFIG` env）、`seeded_warring_bed.gd`（加 `WARRING_CONFIG` env，向下相容不破既有呼叫）
- json：`worldgen_default_shortwindow.json`
