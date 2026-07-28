---
from: implementer
to: systems
status: consumed
topic: "[★execution-verified·持守統一 arc 機制達標但 A1 build=0 未閉·上游根非 persistence·請 systems 判] feat/persistence-slice4-A1-close c9544b2e off main 309ae38b。Slice 4 execution-verified(seed1337 2mo specimen-off aggregate):persistence 閉『committed builder 被搶』(facility complete=8/persist.hold=376 門檻真保護/attrition 7.88% 世界活不凍) 但 ★construct.complete_BUILD=0(新 outpost founding 從不 start_build,非 stall——1mo start=6 全 upgrade_facility/0 build)。根:founding 子隊遠地跋涉 dissolved/never-arrive(stall samples ct_task=gone)=persistence 範圍外上游根(founding viability/never-start,非被搶)。persistence arc 達機制目標;A1 原 concern(forest founding 新 outpost)需 systems 判 viability-gap vs warring-非-founding-measure。per-action tap+whitelist done。headless 0-new+gate 74。"
branch: feat/persistence-slice4-A1-close
commit: c9544b2e
base: 309ae38b (local main HEAD，Slice 1-3 merged)
spec: docs/superpowers/specs/2026-07-28-persistence-decision-layer-HOW.md §8-Slice4
---

# ★execution-verified：持守統一 arc 機制達標，但 A1 build=0 未閉（上游根非 persistence）——請 systems 判

誠實 execution-verified 報告：不宣稱 A1 閉（build=0 違硬指標）。

## 做（Slice 4）
- per-action-type completion tap（`construct.complete_<action>`）+ warring_harness whitelist（build/upgrade_facility/…/persist.hold）——A1 閉環硬確認 build vs facility。純觀測。

## ★execution-verified measure（seed1337 2mo，specimen-off，aggregate）
| 指標 | 值 | 解讀 |
|---|---|---|
| `construct.complete` | 8 | 全 upgrade_facility |
| **`construct.complete_build`** | **0** | ★新 outpost founding **未閉**（對照 A1-FAIL baseline build=0=沒進步） |
| `persist.hold` | 376 | Slice 3 門檻**真保護** committed BUILD 族不被非危機搶 |
| attrition / teams | 7.88% / 49→68 | **世界活不凍**（persistence 無凍世界，Slice 3 過度壓制修後健康） |

1mo 診斷：**start=6 全 `action=upgrade_facility`（build founding 0 starts）**——founding **從不 start_build**（非 stall）。stall samples `ct_task=gone`（builder 隊 dissolved，ticks_left=336=facility）。

## 根（execution-verified 坐實）
1. **persistence arc 達機制目標**：committed builder「被非危機 argmax 搶」問題**已閉**——facility 建完（8）、persist.hold（376）門檻真保護、世界不凍。這是 Slice 1-3 targeting 的核心（手不聽腦：committed 被搶）。
2. **但 A1 原 concern（forest founding 新 material outpost）未閉**：`build=0`，且**從不 start_build**（1mo 6 starts 全 facility）。∴ 非「founding 被搶」（persistence 修得到），是 **founding 子隊遠地跋涉中 dissolved / never-arrive → never start_build**（`ct_task=gone`）= **persistence 範圍外的上游根**（founding 子隊 viability，非 committed-steal）。

## 需 systems 判（arc 邊界）
- **(a) A1 build=0 = founding 子隊 viability gap**（遠地 forest founding 子隊 pop 6 跋涉中餓死/被殲/merge→never arrive）→ 需**獨立 founding-viability slice**（非 persistence；如 founding 子隊補糧/護送/近地優先），非本 arc。
- **(b) warring 非 founding measure**：warring（combat-heavy）teams 忙戰不 found forest（合理 emergent）→ `construct.complete_build` 在 warring 本就近 0，A1 founding 該用**和平 economy measure** 驗非 warring。
- 我傾向先 systems/measurer 判 (a)/(b)：若 (b)，persistence arc 可收（機制達標+世界不凍），A1 forest-founding 另開 economy-measure/viability slice；若 (a)，補 founding viability。

## 閘（persistence 側全綠）
- headless 0-new（6 baseline）+ gate 74 removed=0。
- Slice 3 `persist_tryset_test` 7/7 沿用（try_set 門檻）。
- 世界不凍（attrition 7.88% 活）。
- per-action tap 純觀測（sim 碼未動→determinism 不受影響；Slice 3 已驗 byte-identical）。

## 待
systems 判 (a)/(b) → dispatch measurer 獨立 A1 focused（判 warring vs economy measure 對 founding）+ persistence arc whole measure（4 slice 建完當 whole）→ blueprint release-pass。★不宣稱 A1 閉（build=0）；persistence 機制達標誠實回報。material PARK。
