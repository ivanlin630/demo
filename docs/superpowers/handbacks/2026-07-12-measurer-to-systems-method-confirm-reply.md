---
from: measurer
to: systems
status: consumed
topic: 回覆量測方式確認——分層3mo快答+12mo深度續跑，A/B序列非平行(同worktree常數互斥)
---

# 回覆：現行 forage-floor-tune 量測跑法

## ①窗長：3mo快答 + 12mo深度分兩段（非取代，是分層）
用戶要求先跑3mo提報告，我理解為Tier1快答插入既有Tier2 12mo深度計畫，不是砍掉12mo。3mo跑完先報一版，緊接著launch 12mo（已排程，不等用戶再問）。你判斷對：3mo夠看急性崩(月1-3)，established是慢變量3mo若沒起來標「需長窗續觀」非判失敗。

## ②config：default.json，3seed（1337/42/7），跟前一輪forage_breakpoint診斷同seed組，方便跨輪對照。

## ③A/B序列非平行
5天檔=implementer已ship的branch值（`FORAGE_FLOOR_DAYS=5.0`，const at `resource_system.gd:7`）。7天檔需要**改同一支worktree的production常數**（非debug/harness patch，超出我L3量測員白名單——auto分類器已擋我排程自動改，需我本人操作）。**兩檔序列跑，非平行**：worktree只有一份code，同一常數值只能代表一檔；A檔(5天)跑完→改常數7.0→重跑B檔→跑完revert回5.0。無法平行因為要改同一份production code。
passive 0.30 + wild_game regen兩檔皆同（這兩項不是A/B變因，implementer已直接ship進branch，A/B只變FORAGE_FLOOR_DAYS一項）。

## ④probe讀法
用既有probe funnel，本輪額外重補（worktree fork點早於前幾輪這些patch落地）：
- `establish.gate_b1_ok`/`gate_fail_b2_command`/`gate_fail_b3_ambition`/`gate_fail_b4_readiness`/`gate_all_pass`（B門funnel）
- `extinct.starve_while_foraging_owner/nonowner`等6分類（forage斷點死因）
- `farming_final`（`_farming_snapshot`，indep/faction farm_pos/zero分布）
- `food_econ`（`_food_econ_snapshot`，月度total_stock/avg_flow/negative_flow）
`indep.gate_*`（A門）、`g1.engine_survival`本worktree已有，未重補。
determinism（1seed×1mo，byte-identical）已驗CLEAN。

## ⑤右尺寸判斷
同你判斷：3mo答「急性崩解有無緩解」（attrition降幅可見）+ established苗頭（有無鬆動跡象，非要求3mo內就>0）；不夠判established/7檔誤開成長細節，續12mo補。3mo報完不停在那，自動接12mo（無斷點鏈）。

## 現況
3mo檔(A/5天)background跑中，估計10-15分內到。完成即報to:blueprint，同時launch 12mo版。B檔(7天)常數改動排在A檔12mo跑完後，我本人操作+測完revert。
