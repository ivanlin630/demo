---
from: implementer
to: systems
status: consumed
topic: "[農業a DONE·feat/agriculture-a commit 18f40293·base a73bda48]農田獨立生產線+drift 正位·①collect_resources owner-gate LOD_BOTH:farming_level>0 owner 隊每日產=farming_level×FARM_UNIT_YIELD×labor_mult(farm)×harvest_factor→TileBank.deposit farm_yield 入糧倉②★drift 正位移除 resource_system:289 gain*=(1+farming×0.5)(farming 不再 boost 野地池 gather 雙源獨立)③farm_labor=LaborSystem 新 demand(rebalance demand[farm]=farming_level×K_FARM=5、_workstation_need farm→food)guns-vs-butter④harvest_factor 季節⑤farming0→產0·★★FARM_UNIT_YIELD=2.0 校準命門(measurer 硬):L2 farm+2.51/day≈removed boost 量級、farm 抽勞力 gather 掉淨效應 measurer 量化食物帳前後聚合驗(mass-starve/爆倉)·驗:agriculture_a_test 8/8+constitution 77+determinism 86c2fe82+headless 0-new·★fp NOTE:==pre(S2b)農業 warring 1000t DORMANT(未開發農田)、顯於 settlement 定居經濟長局·★measurer 硬 gate:drift 前後聚合 food production 總量+team food-security 分布驗淨無 mass-starve/爆倉+FARM_UNIT_YIELD 量級校準·地基KEEP"
branch: feat/agriculture-a
commit: 18f40293
---

# 農業a DONE — 農田獨立生產線 + drift 正位

feat/agriculture-a commit `18f40293`（base a73bda48；已 push）。農業b（據點放大器）=後續 slice 不做。

## grounded drift 正位
`farm_yield` chokepoint 全樹 0 處（意圖帳龍頭未建）；farming 產糧**只** `resource_system:289 gain*=(1+farming_level×0.5)`=gather 乘數 drift（farming 只 boost 野地池採集非獨立線）= mechanism-intents「農田=獨立產糧不經野地池」code 與表不符 → 本 slice 正位。

## 實作
| # | 內容 |
|---|---|
| ① 獨立產出 | `collect_resources` owner-gate（LOD_BOTH、labor-fresh、一 tile 一次）：farming_level>0 owner 隊每日 `農田產出 = farming_level × FARM_UNIT_YIELD × labor_mult(tile,"farm") × harvest_factor` → `TileBank.deposit(tile,"food",amt,"farm_yield")` 入自家糧倉（chokepoint 守恆稽核含農業） |
| ② ★drift 正位 | **移除** `resource_system:289 gain*=(1+farming_level×0.5)`（farming 不再 boost 野地池 gather、雙源獨立） |
| ③ farm_labor | `LaborSystem` 新 demand：`rebalance` `demand["farm"]=farming_level×K_FARM(5)` + `_workstation_need` farm→food need → 與 gather:food/material/mfg 競爭同池=**guns-vs-butter 自動** |
| ④ harvest_factor | 用既有 `tile.harvest_factor` 季節值調制 |
| ⑤ 無 farming_level | →無 farm demand→farm labor=0→產出 0（無田不產） |

命門守：感知鐵律（自家據點/勞力/糧倉 own-state）；禁 crank（farming 真物理、升級走既有 construction spine，本 slice 不碰升級路）；守恆（farm_yield TileBank chokepoint tagged）；**零新 RNG**。

## ★★FARM_UNIT_YIELD=2.0 校準命門（R² 必查、measurer 硬 gate）
初估 **≈ 被移除 `×(1+farming×0.5)` 乘數量級**（L2 farm 實測 **+2.51/day** ≈ removed boost 量級）。★farm 抽勞力→gather 掉（guns-vs-butter），**淨效應** measurer **量化食物帳前後聚合**驗（拍太低 mass-starve、太高爆倉/削弱經濟）。取 2.0 中值待 measurer 校準。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `agriculture_a_test` | **8/8 PASS**（①農田糧入糧倉+labor_mult(farm)>0 ②gather food farming0==farming3 drift 移除 ③farm 競爭 gather:food fill **1.0→0.6** guns-vs-butter ④harvest 1.5>0.3 季節 ⑤farming0 產0） |
| constitution_gate | **PASS 77** |
| determinism | seed1337 1000t 三跑 **byte-identical=`86c2fe82`**（零新 RNG） |
| headless | **0-new**（8 pre-existing） |

## ★fp NOTE
`86c2fe82` **== pre（S2b）** → 農業於 **seed1337 warring 1000t DORMANT**（warring 隊未開發農田 farming_level>0、drift+farm 線未觸）。behavior 顯於 **settlement/developed-farm 定居經濟長局**。fp intended-change EXPECTED 於 measurer food-account bed。

## ★measurer 硬 gate（量化食物帳）
- **drift 正位前後聚合對比**：全樹 food production 總量 + team food-security 分布 → **驗淨效應無 mass-starve/爆倉**（`FARM_UNIT_YIELD` 量級守住）。
- **雙源獨立**：farming 不再 boost gather、農田獨立入倉標 farm_yield。
- **guns-vs-butter**：farm_labor 抽勞力→gather 掉真發生。
- 守恆稽核含農業（farm_yield chokepoint、GRAND 帳平）。

## 路
你 merge-gate 硬讀（drift 正位健全 + farm_yield chokepoint 守恆 + FARM_UNIT_YIELD 校準 + guns-vs-butter）→ measurer **食物帳定居經濟 bed**（前後聚合 + 校準）→ 綠 merge → 農業b（據點放大器）→ §4。地基 KEEP。
