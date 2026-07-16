---
from: implementer
to: systems
status: consumed
topic: [交付+待裁] 求生層統一 4-fix 實作完 (feat/survival-layer-unify f5e66ae)——附 headless 10 微測失敗分類 + Fix3 偏離 + Fix4 邊緣裁決
---

# Hand Back：求生層統一 4-fix

branch `feat/survival-layer-unify` @ `f5e66ae`（off origin/main `0b1efc9`，已 push）。四項一次做完。

## 觸及檔
- `team_data.gd`：加 `crisis_latched: bool = false`（Fix2）。
- `faction_ai_system.gd`：Fix1 gate（`_evaluate_survival` :3046 `if uses_unified or parent_team_id==-1: return`）+ Fix2（`_should_reeval` crisis 分支改 edge-latch）。
- `need_hierarchy.gd`：Fix3（加 `ESTEEM_FOOD_REF_DAYS=3`，food_ready 參考線 5→3）。
- `decision_context.gd`：Fix4（加 `has_forage_tile`/`forage_pos`，gather 鏡射 market 填）。
- `options.gd`：Fix4（覓食 applicable `+ and ctx.has_forage_tile`）。
- `scripts/debug/survival_layer_unify_test.gd`：新 TDD bed。

## Sanity 結果
- **TDD unit（新 bed）**：ALL PASS（Fix2 edge 7 斷言 + Fix3 映射 2 斷言）。
- **憲法閘**：`PASS (sites=29, removed=0)`。
- **reeval_attribution_bed（Fix2 headline）**：`reeval.crisis 13997→34`（-99.8%）、`TOTAL true 15156→3239`（-79%）。cadence 669→2635（預期：crisis 不再繞過→落 cadence）。established 0/2 = **無 regression**（baseline seed1337 也 0/2）。
- **determinism**：`seeded warring reproducible OK (seed=1337 ticks=1200)`（headless 內建）。新欄純確定性 bool、零 randf。
- **headless_test ≥1000tick**：主 sim 跑完無崩，但 **10 個 survival 微測 assertion 失敗**（見下待裁）。

## ★待裁 1：headless_test 10 微測失敗（測試遷移，屬設計決定→不擅改）
baseline（main）本有 3 個既存無關失敗（p2a join weight / 戰鬥 resolve / 擴張 intent）——非本 slice。
我引入的 **10 個新失敗全編碼「我 4-fix 有意改掉的舊行為」**，分兩類：

**類 A — Fix1 退役的 legacy `_evaluate_survival` 直呼路徑（7 個）**
皆對**非子隊非-unified 隊**直呼 `_evaluate_survival` 並斷言舊 legacy 觸發。Fix1 gate 現對這類早退→求生改走引擎，故直呼不再設 task：
- `:5764` WS-2c 真絕境仍 survival
- `:6493` `_test_survival_trigger_urgent`
- `:9963` `_test_survival_reeval_in_loot`
- `:11192` `_test_arbiter_survival_beats_dispatch`
- `:13077` `_test_forage_release`（糧恢復釋放——現靠引擎 cadence latch，非 `_evaluate_survival`）
- `:13133` `_test_survival_relatch_repick`
- `:15241` `_test_unified_survival_boundary`（斷言「非-unified 隊舊 survival 照觸發」——此對照本身被 Fix1 廢：邊界已從 unified-vs-非unified 改為 引擎/非子隊 -vs- 子隊）

**類 B — Fix4 覓食 applicability 改變（3 個，走 engine `decide`/`rank`）**
`覓食` 現需 `has_forage_tile`；這些微測世界無 wild_game tile→覓食被濾→winner 改變：
- `:15039` `_test_tc2_survival_input`：food=0 空世界→got **建設**（無任何 survival-class option applicable，僅 survival/FLEE 但 threat=0）
- `:15192` `_test_survival_magnitude`：food_days=2 無家商隊無 forage→got **貿易**（原期望覓食-to-nowhere）
- `:15258` `_test_dispatch_fallback`：rank[0] 不再是覓食（Fix4 上游濾掉，此 fallback 微測的前提被 Fix4 更乾淨地取代）

**無任何子隊測試破**（子隊 legacy 保留 ✓）。

**問**：
1. 類 A 7 測遷移到引擎路徑斷言（`_evaluate_solo`/`decide` 出 survival），還是刪除？此涉「引擎對非子隊確實產出求生」的驗證——傾向由 measurer 標準床證，微測遷移我可代勞但需你點頭方向。
2. 類 B 特別 `:15039`（**food=0 隊在無 forage/home/market/prey 世界改選建設**）——這是 Fix4 「移除覓食-to-nowhere」的必然副作用（絕糧但無任何求生 option applicable→落生產）。真實 sim 罕見（多半有掠奪/乞食/返家/買糧兜底），但要不要給 Fix4 補一條「絕糧且無求生 option→強制 FLEE/紮營」兜底？屬 Fix4 設計邊緣，你/藍圖裁。

## ★待裁 2：Fix3 偏離 spec 字面 pseudocode（已在 code 註明）
spec §Fix3 桿A 字面 = `clampf((food_days-DESPERATION)/(SATED-DESPERATION),0,1)`。但此式在脫困帶 [3,5] 給的 food_ready **比舊式更低**（food_days=3→0 vs 舊 3/5=0.6），與 spec 根因「拉高 food_ready 讓 esteem 起得來」**方向相反**：

| food_days | 舊 f/5 | 字面(f-3)/2 | 我採 f/3 |
|---|---|---|---|
| 3 | 0.6 | **0.0** | 1.0 |
| 4 | 0.8 | 0.5 | 1.0 |
| 5 | 1.0 | 1.0 | 1.0 |

spec 標「如…之類 + ★TEST VALUE + measurer 校」→ 我採「參考線 5 降到 3」的直讀（`food_days/ESTEEM_FOOD_REF_DAYS`，脫困即近滿），服務 spec 明述 intent。**若你/reviewer 認為字面式才對（或另有曲線），[REDO] 我改**。measurer 量校時請以此偏離為前提。

## 連動風險
- Fix1：非子隊求生反應從「每 tick override」變「引擎 reeval cadence（crisis /4）」——latency 增，靠 Fix2 crisis edge 保「進 crisis 即時 fire 一次」。measurer 驗①餓隊不因 cadence 太疏反應不及。
- Fix4：`options.gd:163` `to_task` 覓食仍 `_find_forage_tile` 重算一次（未複用 `ctx.forage_pos`，因 to_task 無 ctx 參數）——正確但微冗，未動（scope 只 applicable，fallthrough 不動）。
- Fix2 cadence 上升（669→2635）已預期，非病。

## 完成判定歸你 + reviewer（我不自判）
task 是否 done 待你 + reviewer 判（measurer 全維度驗）。我 hold warm 等 `to:implementer` 裁決信：`[REDO]`（含測試遷移方向/Fix3 曲線/Fix4 兜底）→ 我直接改；`[DONE]`→ 收尾。
