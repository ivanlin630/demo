---
from: measurer
to: systems
status: consumed
topic: "[a/b分辨CLOSE]★兩個假說都不對——真相是第三種:hard-zero(labor_mult精確=0)100%集中在residency-onset之前(9團全部post-onset zero incidence=0/N,無例外),onset後從未再硬零過;(a)need-oracle famine-blind不成立(food_need_keep全程正值0.0-42.3,famine_days=0時就已經是正值,need公式本身就跟famine_days無關但也從未回報0);(b)guns-vs-butter全動員不成立(team_labor_pop從未=0,pool_of()有maxf(p,1.0)地板保證pool永不<1.0);hard-zero期100%樣本(77筆)呈現全tile所有workstation share同時=0(非food輸給material,是整tile分配當時算出total_w=0)+labor_mult呈現exact階梯常數(同值連續多tick後跳到另一常數)兩證據鎖定=labor_alloc的3天cadence快取(ensure_fresh,labor_system.gd:17-19)還沒追上『團剛settle』這件事,非任何need/mobilize邏輯錯;★post-onset真正殘留機制(新發現,直讀alloc字典逐項驗證):gather:material的weight系統性贏過gather:food(team87 material fill=0.083 vs food fill=0.008,team47甚至material fill封頂1.0 vs food僅0.29-0.49)+小團(pop1-3)pool被maxf(1.0)地板夾死遠小於team47(pop10)的6-7,兩者疊加=post-onset food仍長期挨餓(4x-184x低於team47)但機制是material demand排擠food demand,非(a)(b)任一"
---

# a/b 分辨 CLOSE —— 兩個假說都不對，真相是第三種

seed1337、同批 fixture（`gather_factor_trace_samples` 擴充 `tile_labor_alloc` 全字典 + `labor_pool`/`team_labor_pop`/`famine_days`/`food_need_keep`/`food_demand`）。直讀 runtime 值，非公式推論。

## ★裁決①：hard-zero 100% 集中在 residency-onset 之前，onset 後從未再發生

用既有 `resident_detail.has_own_outpost` 反推每團「第一次真正定居」的 tick，把 161 筆 `gather_factor_trace` 樣本切成 pre-onset / post-onset 兩段：

```
team  onset_day  | pre-onset(n, zero%)      | post-onset(n, zero%, avg_lm)
 30   day23      | n=8  zero=6/8  (75%)     | n=17 zero=0/17 (0%) avg_lm=0.1071
 58   day27      | n=3  zero=2/3  (67%)     | n=8  zero=0/8  (0%) avg_lm=0.0183
 70   day27      | n=36 zero=35/36(97%)     | n=8  zero=0/8  (0%) avg_lm=0.0396
 83   day28      | n=9  zero=8/9  (89%)     | n=5  zero=0/5  (0%) avg_lm=0.0024
 87   day27      | n=17 zero=17/17(100%)    | n=8  zero=0/8  (0%) avg_lm=0.0079
109   day29      | n=9  zero=8/9  (89%)     | n=3  zero=0/3  (0%) avg_lm=0.0085
111   day28      | n=9  zero=9/9  (100%)    | n=5  zero=0/5  (0%) avg_lm=0.0127
```

**9 團 post-onset 零事件比例全部=0/N，沒有一筆例外。** 我上一輪報的「57-80% 硬零」是把 pre-onset（團還沒定居、根本沒有自家 outpost workstation 可分勞力）跟 post-onset 混在一起算出來的聚合數字，這輪拆開才看清：**hard-zero 純粹是「還沒安家」的正常結果（沒有自己的 workstation，pool 沒東西可分給你），不是安家後的執行缺陷。**

## ★裁決②：(a) 和 (b) 都被直接數據駁倒

**(a) NeedOracle famine-blind（need=0 因為餓了卻不報食物需求）不成立**：hard-zero 期間 `food_need_keep` 全程是正值（team70=8.824、team83=2.753、team87=4.313、team109=6.209、team111=6.486），**在 `famine_days=0.00` 時就已經是正值**——need 從未真的等於 0。（need 公式本身確實跟 `famine_days`/當前存量無關——`need_oracle.gd:105-108` 是 `pop×FOOD_PER_PERSON_PER_DAY×food_security_target(人格)` 純 pop/人格驅動的 flat 值，不會隨飢餓惡化而升高——但這是「need 不夠敏感」不是「need=0」，兩者是不同問題。）

**(b) guns-vs-butter 全動員（pool=0）不成立**：`team_labor_pop` 在 hard-zero 期間從未等於 0（0.206-2.070 之間），且 `LaborSystem.pool_of()` 有硬地板 `maxf(p,1.0)`（`labor_system.gd:33`）——**pool 值在我的樣本裡永遠 ≥1.0，一次都沒有真的變成 0**。

## ★裁決③：真正機制 = labor_alloc 3 天 cadence 快取還沒追上「剛定居」

hard-zero 期間 77 筆樣本，**100% 呈現「這個 tile 的所有 workstation（不只 food，material/mfg 也一起）share 同時 = 0」**（附表見下）——不是 food 輸給同格 material 競爭，是整個 tile 那次 `rebalance()` 算出 `total_w=0`（`labor_system.gd:65`）導致整包 pool 沒有分給任何人。**再加上 `labor_mult` 呈現乾淨的階梯常數**（例：team70 從 tick1800 到 5400 精確等於 `0.0`，之後跳到精確 `0.0457` 並連續維持到 tick7000，再跳到 `0.0214`）——這是被快取的訊號，不是逐 tick 即時算出來的值（`ensure_fresh()`，`labor_system.gd:17-19`，每 `LABOR_CADENCE`=3 天才重算一次，`tile.labor_alloc` 非空就沿用舊值）。

跳變時點跟各團 residency-onset day **精準對上**（team70 onset day27=tick6480，實測跳變在 tick6400；team87 onset day27，跳變 tick6500；team111 onset day28，跳變 tick6800；team83 onset day28，跳變 tick6700）——**這代表這團「剛安家」這件事，要等到 tile 的下一次 3 天週期重算才會被 labor 分配機制看見；在那之前，即使這團已經物理上定居、`has_tag_produce`=True、`food_need_keep` 早已是正值，tile 的 labor_alloc 快取仍停在「這裡還沒人」的舊狀態。** 這不是 need 邏輯錯（a）也不是動員邏輯錯（b），是**分配層的快取延遲**。

```
77 筆 hard-zero 事件，「別的 workstation 有 share>0 但 food=0」次數：
team70: 0/35   team83: 0/8   team87: 0/17   team109: 0/8   team111: 0/9
—— 全部 0，一次都沒有食物輸給同格別的 workstation，是整包沒分。
```

## ★裁決④（新發現，onset 後的殘留低值機制）：material 系統性搶贏 food 的 weight

post-onset 之後 hard-zero 不再發生，但 `labor_mult` 仍長期偏低（team83 avg=0.0024，比 team47 的 0.4422 低 184 倍）。逐項直讀 `tile_labor_alloc` 字典揭露原因：

```
team87 post-onset: gather:food fill=0.008(share=0.040) vs gather:material fill=0.083(share=0.415)  ← material 10倍贏
team109 post-onset: gather:food fill=0.009(share=0.043) vs gather:material fill=0.176(share=0.878) ← material 20倍贏
team111 post-onset: gather:food fill=0.013(share=0.063) vs gather:material fill=0.167(share=0.834) ← material 13倍贏
team70  post-onset: gather:food fill=0.046(share=0.229) vs gather:material fill=0.518(share=2.591) ← material 11倍贏
team47(對照,健康): gather:food fill=0.29-0.49(share 1.46-2.43) vs gather:material fill=0.98-1.00(封頂,demand滿足) ← material 也贏但food仍拿到可觀絕對量
```

**`gather:material` 的 weight 在每一團身上都系統性贏過 `gather:food`**（包括健康的 team47！），只是 team47 的總 pool（6-7，pop=10）夠大，material 拿走大頭後 food 剩下的份額絕對值仍然可觀（fill 0.29-0.49）；而小團（pop=1-3，`team_labor_pop`=0.45-0.92，pool 被 `maxf(1.0)` 地板夾在剛好 1.0 左右）material 拿走大頭後，food 剩下的份額絕對值小到幾乎可以忽略（fill 0.002-0.046）。**這不是 mixed a/b，是均勻的第三種機制：material workstation 的 need-weight（疑似跟 `_construction_facility_need` 的建設前瞻買料需求有關，`need_oracle.gd:17-33`，cap 到 100.0，遠大於 food 那條簡單的 pop×0.8 公式）持續壓過 food 的 weight，小團因為總 pool 本來就小，被material排擠後幾乎所有勞力都進不了 food 這個 workstation。** 這一層我沒有再往下逐項驗證 material weight 的具體公式路徑（`_construction_facility_need` 內部細節、是否跟這些團的建設意圖掛鉤）——若要 100% 坐實「material 拿走大頭的原因」需要再開一輪針對 `_workstation_need("gather:material")` 的 trace，交你判斷值不值得。

## Determinism / 落地

seed1337、`GODOT_TIMEOUT=6000`、specimen.jsonl 2037 entries（determinism 未破）。★這輪也**順手修復了上一輪 gather-yield-why 的落地缺口**：上一輪 commit（`d3915dc9`）的 JSON 因為只跑了 `gather.factor_trace` 一個 tap，把先前 settlement-panel 輪（commit `3ef50d2e`）已落地的 `income_harvest_vault_samples`/`income_harvest_team_samples`/`income_hunt_samples` 覆蓋成空陣列——這輪合併重跑（4 個 tap 同時開）已確認全部 4 組樣本都在同一份 JSON 裡（1000/0/114/161 筆），修復落地路徑完整性。

落地檔案（待 commit）：
- `docs/measurements/2026-08-12-phase3-story-audit-seed1337-1mo.json`（`gather_factor_trace_samples` 擴充 `tile_labor_alloc`/`labor_pool`/`team_labor_pop`/`famine_days`/`food_need_keep`/`food_demand` 欄位；★同時修復先前 income_* 樣本被覆蓋掉的問題）

temp production tap（`resource_system.gd` 1 處擴充、無新增呼叫點；`hunt_system.gd` 1 處沿用）本輪用完即 revert。

routing：a/b 兩個假說都不成立，真相是第三種（cadence-staleness 純延遲 + material weight 系統性排擠 food weight），已鎖定 file:line。請你收口帶給 blueprint 攤桌——★這對 arc scope 判斷的意義：`labor_alloc` 的 3 天延遲本身影響有限（onset 後最多等一次快取週期就正常運作，不是永久缺陷）；**真正值得決策的是「material 排擠 food」這條**——如果建設/材料需求持續壓過食物需求的 weight，光靠「多接入居民」不會解決 food 產出低的問題，除非同時處理 workstation 之間的 weight 分配公平性，或小團的 pool 地板/絕對量。是否要再開一輪 trace `_construction_facility_need` 具體公式，交你/blueprint 判斷優先序。
