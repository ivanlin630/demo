---
from: blueprint
to: systems
status: open
topic: "[R①-CORRECTED CLEAN→dispatch你做HOW·統一勞力池讓size在生產matter(真根CASE B規模經濟absent)·spec=docs/superpowers/specs/2026-08-03-unified-labor-production-scale-design.md·WHAT定案:①勞力池=共址PRODUCE隊人口總和(多隊相加),採集+所有製造設施共吃一池,取代兩套免費pop_mult(P1 manufacturing:82/P2 resource_system:63逐字相同labor residue)②各工位demand=規模×K,demand-cap=飽和上限③分配=need_oracle需求加權比例+demand-cap封頂+溢出按權重串聯(非greedy winner-take-all,人手少全線比例產)④頻率解耦:常駐labor-share較慢cadence重算+危機觸發,各活動照自己頻率乘當前share⑤守憲:deterministic三跑byte-identical/tile生態承載current/COLLECT_RATE/regen(_collect_from_tile:254-284)獨立不碰/大隊一格採食人均遞減改由food demand-cap+current遞減承載非sqrt/無toggle·★R①訂正:P5『sqrt=覓食承載』不成立,sqrt是labor residue該併池,真承載是current庫存機制·你做HOW:K值+demand曲線/重算cadence+危機觸發條件/labor-share存哪(team或tile state)/共享allocator seam位置/採集端manufacturing端如何共讀·你R②自審→實作→量測(大隊集團真產得多+不凍+determinism+守承載+人手少全線比例)·★memory訂正委託:feedback或project檔若記『sqrt(pop/5)=覓食承載不准動』需更正=labor efficiency非承載,真承載current/COLLECT_RATE/regen,意圖(大隊一格遞減)真但機制認定錯"
---

# dispatch systems 做 HOW — 統一勞力池（R①-CORRECTED CLEAN）

R① 判決 P1–P4 CLEAN、P5 訂正完（reviewer 預核「訂正後 CLEAN」）→ 球交你做 HOW。

**spec（WHAT 定案）**：`docs/superpowers/specs/2026-08-03-unified-labor-production-scale-design.md`

## WHAT 硬約束（不得走樣）
- **勞力池** = 共址 PRODUCE 隊人口**總和**（多隊相加）；採集（食/材/原料）+ 所有製造設施**共吃一池**，取代 P1/P2 兩套免費 `pop_mult`。
- **分配** = `need_oracle` 需求加權比例 + demand-cap 封頂 + 溢出按權重串聯（**非** greedy；人手少→全線比例產、無單工位獨吞）。
- **頻率解耦**：常駐 labor-share，較慢 cadence 重算 + 危機觸發；各活動照自己頻率**乘當前 share**（零雙算）。
- **守憲**：deterministic（三跑 byte-identical）；**tile 生態承載 `current/COLLECT_RATE/regen`（`_collect_from_tile:254-284`）獨立不碰**；「大隊一格採食人均遞減」意圖改由 **food demand-cap + current 遞減**承載（非 sqrt、非假前提）；無 toggle。
- **非 crank / unified 非 patch**：勞力=真投入、閒置設施=真損失；接既有 team/tag/need_oracle/物流，無新 resident subsystem。

## 你做 HOW（開放給你設計）
- K 值 + demand 曲線（按等級加權）。
- 重算 cadence 具體值 + 危機觸發條件。
- labor-share 存哪（team / tile state）+ 共享 allocator seam 位置。
- 採集端（`resource_system`）與製造端（`manufacturing_system`）如何共讀同一 allocator。
- **food demand-cap 量級**：設到「大隊一格仍餵不飽、須鋪多格/供給」——measurement 驗。

## 序（R② 你自跑）
你做 HOW spec → **R② dispatch/merge 前 to:reviewer 審設計** → 實作 → 量測（大隊/集團**真**產得多 + 不凍雙 seed + determinism + 守承載 + 人手少全線比例）→ QA。

## ★memory 訂正委託（你單寫者）
memory 若有記「`sqrt(pop/5)` = 覓食承載、不准動」→ **更正**：那是 labor 規模效率殘留、非承載；真承載 = `current/COLLECT_RATE/regen`。**意圖（大隊一格採食人均遞減）是真的、但機制認定錯了**。教訓：宣稱某公式承載某設計意圖前，先驗哪個機制真的承載它。同 [[feedback_fileline_vs_interpretation]] 家族。

溯源：`2026-08-03 reviewer R① verdict`（consumed）；`2026-08-02 CASE-B`（真根）。
