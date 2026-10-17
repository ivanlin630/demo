---
from: implementer
to: systems
status: consumed
slice: 結構輪探針：建點一個身體＋子隊到場（spec 2026-10-16-structure-round-probes-build-and-subteam-arrival-HOW，含 GO-addendum §三之三）
topic: 交件；電池唯一紅＝world-fp（規格說會變）；V8 字面沒過（派出 0）停下回報；另 5 條請裁＋1 條既有觀測污染
---

# 一句話
分支 `feat/structure-round-probes` tip `d4ba72e99`（已推）。全量電池 run-id `3106-20261017-070633`：139 ✓、1 ✗＝world-fp no-verdict（final_fp `f8fb6b349bdc5fd23d9ee459c735d834`，舊 expect `815273e751115c3e73597dd4fe18ff50`）。
抽取那輪 `b29eefb89` run-id `22728-20261017-022608`：BATTERY_RC=0、fp 不變（`815273e…`）。
**我沒動 merge-gates.tsv 的 world-fp expect**（本票閘那一列 expect 33 是我的列）。

★要你裁的 6 條在最後「請裁」。

量測原始輸出全在 `A:/GDS/demo/docs/measurements/2026-10-16-structure-round-probes/`（本信同 commit）。

# 驗收床 `build_verb_one_body_bed.gd`（tip d4ba72e99）：33/33 PASS、errors 0
原文 `srp4-bed-tip.txt`。

## V1 五列實數（森林、池 150、帶 20 料）
| 入口 | action | type | level | gather_left | ticks_left | 扣料 | owner | 施工隊 |
|---|---|---|---|---|---|---|---|---|
| NPC紮根 | build | civilian | 1 | 30.0 | 720 | 20.0 | 1 | 1 |
| 玩家紮根 | build | civilian | 1 | 30.0 | 720 | 20.0 | 0 | 0 |
| 玩家建設 | build | civilian | 1 | 30.0 | 720 | 20.0 | -1（缺省） | 0 |
| NPC子隊抵達 | build | civilian | 1 | 30.0 | 720 | 20.0 | -1（缺省） | 6 |
| 玩家子隊腳下 | build | civilian | 1 | 30.0 | 720 | 20.0 | 0（母隊） | 6 |

## V6 估算 vs 實跑（森林、帶 20）
- 估算採段 **4.444** 天（總 6.752）｜實跑採段 **4.458** 天。差 0.014 日。

# V8 派子隊這條路（量測）——★字面沒過，停下回報
普查 `build_site_census.gd`，修前 `5c4f5581c`（＝`e9665a0ed^2`，本票 merge 前的樹）、修後 `d4ba72e99`。
原文：`srp4-census-{pre,post}.txt`（peaceful_economy／1337／30 天）、`srp7-census-<sha>-<cfg>-s<seed>-d<days>.txt`（另 5 個世界）。

## 六道閘並排
| 世界 | 樹 | attempt | busy_subteam | cost | site_barren | no_advisor | pop | food_bridge | 派出 |
|---|---|---|---|---|---|---|---|---|---|
| peaceful_economy 1337 30d | 修前 | 14 | 0 | 11 | 0 | 0 | 3 | 0 | 0 |
| | 修後 | 7 | 0 | （鍵不存在） | 0 | 0 | 7 | 0 | 0 |
| peaceful_economy 1337 60d | 修前 | 46 | 0 | 39 | 0 | 0 | 7 | 0 | 0 |
| | 修後 | 34 | 0 | （鍵不存在） | 0 | 2 | 32 | 0 | 0 |
| peaceful_economy 2 30d | 修前 | 9 | 0 | 6 | 0 | 0 | 3 | 0 | 0 |
| | 修後 | 4 | 0 | （鍵不存在） | 1 | 0 | 3 | 0 | 0 |
| peaceful_economy 3 30d | 修前 | 9 | 0 | 7 | 0 | 0 | 2 | 0 | 0 |
| | 修後 | 30 | 0 | （鍵不存在） | 2 | 0 | 28 | 0 | 0 |
| peaceful_economy_factioned 1337 30d | 修前 | 59 | 3 | 44 | 0 | 8 | 4 | 0 | 0 |
| | 修後 | 115 | 0 | （鍵不存在） | 14 | 74 | 27 | 0 | 0 |
| warring_states 1337 30d | 修前 | 359 | 0 | **352** | 0 | 0 | 7 | 0 | 0 |
| | 修後 | 573 | 6 | （鍵不存在） | 145 | 257 | 165 | 0 | 0 |

- 每一列都對帳（閘＋派出＝attempt）。
- 修前：倒在材料閘的比例 peaceful 11/14、warring 352/359（規格寫的「81／81」是舊世界；這次照同一支普查重印）。
- 修後：材料閘退場，擋下的換成 `site_barren`／`no_advisor`／`pop`。**沒有一個世界派出 > 0。**

## 按目標地形（修後；★warring_states 是唯一有採段樣本的世界）
| 世界 | 地形 | attempt | 派出 | site_barren | 開工 | gather_ticks | gather_abort | 完工 | 選址選中 | gather_term 平均 |
|---|---|---|---|---|---|---|---|---|---|---|
| warring_states | 平原 | 145 | 0 | 145 | 6 | 51 | 0 | 1 | 0 | — |
| | 森林 | 291 | 0 | 0 | 1 | 230 | 0 | 0 | 0 | — |
| | 山地 | 137 | 0 | 0 | 4 | 610 | 0 | 1 | 126 | −65.85 |
| factioned | 平原 | 14 | 0 | 14 | 1 | 89 | 0 | 0 | 0 | — |
| | 森林 | 65 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | — |
| | 山地 | 36 | 0 | 0 | 0 | 0 | 0 | 0 | 36 | −66.11 |
| peaceful 1337/2/3 | 平原 | 7／4／30 | 0 | 0／1／2 | 0 | 0 | 0 | 0 | 0 | — |

- 修前每個世界每個地形都是 0：修前沒有採段，`gather_ticks` 與按地形的開工計數也是本票才加的。
- 「開工」＝`construct.start_build.terrain.*`（只數 `start_build`，按工地格地形）；不限派建造子隊那條入口。warring 修後 `start_build` 11 次，入口：紮根 4、子隊 7、主隊 0（見「紮根時帶料」那節）。`construct.start` 15 多出的 4 次是升級／設施／拆除（同一支 `_tap_build_start`）。
- ★「派出」＝`funnel.build_gate.dispatched`（`_dispatch_builder` 成功端）。六個世界全是 0 ⇒ 照規格「全部地形派出都是 0 ⇒ 不算過，停下回報」。
- 為什麼是 0：attempt 來源全是目標 delegate（`funnel.delegate.branch_build` = `delegate.build_fail`，修前修後都一樣）。過了選址的那些，被 `no_advisor`（warring 257、factioned 74）與 `pop`（warring 165）擋下。平原那 145 是 `site_barren`。
- 採段在跑，只是不走 `_dispatch_builder`：warring 山地 gather_ticks 610、完工 1，`construct.gather_done` 2、`gathered` 累計 156.7、`absorbed` 累計 62.9。
- 子隊入口那 7 次開工（`parent_team_id != -1` 呼 `start_build`）不是建造子隊：dispatched 是 0。我沒再拆它們從哪一個呼叫點來（候選 `faction_ai_system.gd:7436` 子隊紮根、`outpost_system.gd:1052` 子隊抵達）。要拆的話告訴我。
- `gather_term` 平均只有山地有值（「選中」那一欄只記到山地）。森林與平原的「選中」都是 0 ⇒ 看不出選址有沒有往林邊移。

## 選址候選並排
| 世界 | 樹 | candidates_scored | candidates_kept 累計 | filtered_barren | 3_loc_empty | 3_reached_dispatch_builder |
|---|---|---|---|---|---|---|
| warring_states | 修前 | 0 | 0 | 0 | 0 | 113 |
| | 修後 | 17208 | 15374 | 9698 | 0 | 126 |
| factioned | 修前 | 0 | 0 | 0 | 0 | 38 |
| | 修後 | 3611 | 3232 | 1959 | 0 | 36 |
| peaceful 1337/2/3、60d | 兩邊 | 0 | 0 | 0 | 0 | 0 |

- 修前 scored／kept／filtered_barren 0 是因為這幾支計數本票才加（`git grep` 修前樹 0 處），不是修前沒評分。`3_loc_empty` 修前就有。
- `3_loc_empty` 修前修後都是 0。

# 交件信要列（逐條）

## corvee_site 讀點（grep 為準，一行一個）
- `commitment_fields.gd:56` build_tile：要求 `ticks_left > 0`；採段中 ticks_left 是滿的 ⇒ 照常成立。不改。
- `decision_context.gd:832-835` recovery → `settle_resume_site`：**現在也會吃主隊建設那一類**（`start_build` 對每個主隊都寫 corvee_site，`outpost_system.gd:824`）。判斷：可接受——只走回自己的工地、不重設工期；但這條路的名字叫「紮根」。→ 請裁 ⑤。
- `need_oracle.gd:212`：②採段需求那一支（本票新加）。
- `persist_strength`：經 `CommitmentFields` 讀。
- `outpost_system.gd:501` `is_site_worker` 第二條、`:690` 完工清掉。
- `faction_ai_system.gd:7415` 復工時寫、`:7628` 自家營地釋放時清。
- `task_arbiter.gd:438`：tap。
- `state_fingerprint.gd:393`：fp。

## `:6702`（現在在 `faction_ai_system.gd:6820`）
估的是**自救設施升級**的 ETA：`_can_afford(upgrade_cost)` 之後呼 `build_eta_days(person_hours, pop)`。不是新點、沒有採段 ⇒ 沒改。

## `BuildAfford.shortfall`
刪了，0 呼叫者。留下 `margin_of`、`can_afford`、`MARGIN_*`。

## 材料守恆稽核
**沒有**。`InvariantAudit` 沒有材料守恆那一條 ⇒ 完工消耗、逾時退料沒有加具名 reason。採段進出走 `pool_set` reason `"site_gather"`。N4／N4b 規格寫「守恆走 InvariantAudit」，因為沒有那一條，床改成逐欄比對（隊上 −20、site_stock +20、gather_left −20）。

## 人數不進採段
照規格：非工位格採集是中性 `LABOR_SCALE`，6 人與 60 人同速。

## `subteam.arrival.*` 次數
- 修後只有 warring_states 有鍵：`settle.done.npc` = 3，**`settle.refused.npc` = 5**。camp 那一族 0。玩家側 0。
- 其餘 5 個世界：沒有任何 `subteam.arrival.*` 鍵。修前樹沒有這支計數（本票才加）。

## 三種地形缺 50／80 料的採段天數（真函式、真先驗）
原文 `srp6-numbers.txt`（6 人真成員隊，`AnonCohort.add` 平民 healthy 6）。`gather_window_days` = 30。
| 型 | 缺料 | 平原（cap 12.5、prod 1.1） | 森林（cap 150、prod 0.9） | 山地（cap 65、prod 0.7） |
|---|---|---|---|---|
| 民用 L1 | 50 | INF（採不完） | 7.407 天 | 21.978 天 |
| 軍用 L1 | 80 | INF | 11.852 天 | INF |
- 帶滿料時三種地形都是總天數 5.000 ＝ 築段，採段 0。
- 規格寫平原「約 72 日」；真函式回 INF——平原池上限 12.5 < 50，回生之外採不到 50。

## 運量
- 6 人子隊載重 **60**（pop × BASE_CARRY 10）。
- 帶 50 料總重 50 ≤ 60；**帶 80 料總重 80 > 60** ⇒ 6 人子隊帶不動軍用 L1 的全料。撥料照規格不看載重，超重走既有移動物理。→ 給藍圖。

## 紮根時帶料 >0 的比例
| 世界 | settle 帶料>0／=0 | subteam 帶料>0／=0 | main 帶料>0／=0 |
|---|---|---|---|
| warring_states | 2／2 | 4／3 | 0／0 |
| factioned | 1／0 | 0／0 | 0／0 |
| peaceful 四個 | 0／0 | 0／0 | 0／0 |
- peaceful 系列沒有任何經 `start_build` 的開工；`construct.start` 那 8–13 筆是升級／設施／拆除。

## world-fp
- 抽取那輪 `b29eefb89`：run-id `22728-20261017-022608`，fp 不變 `815273e751115c3e73597dd4fe18ff50`、BATTERY_RC=0（`battery-b29eefb89-extraction-green.txt`）。
- 全量那輪 `d4ba72e99`：run-id `3106-20261017-070633`，新 `f8fb6b349bdc5fd23d9ee459c735d834`／舊 `815273e751115c3e73597dd4fe18ff50`（`battery-d4ba72e99-worldfp-only.txt`、`worldfp-no-verdict-d4ba72e99.txt`）。
- tree-after 同 commit。電池改了 artifact `docs/measurements/2026-09-30-scripted-exploration.txt`，已用 checkout 還原。
- 逐條歸因：見下節。

## world-fp 歸因（同一趟：warring_states、seed 20260922、player_id=-1、20000 tick；探針 `wfp_attr_probe.gd.txt`／`wfp_rank_probe.gd.txt`）
- 重現：探針不開 Probe 的 final_fp，修前 `b7beaa095` ＝ `815273e…`、修後 `d4ba72e99` ＝ `f8fb6b34…`，跟電池兩個值逐字相同（`srp8-wfpattr-<sha>-probe0.txt`）。
- **首分歧 tick 60、域＝teams**（每 tick 一次逐域 fp，`srp9-wfpfirst-<sha>.txt`）。
- tick 60 原文行 diff（`srp10-dump60-<sha>.txt`）：只差 Team2 那一列（T 行＋TD 行）。TD 欄位數兩邊都是 159 ⇒ **不是欄位形狀變了，是行為變了**。差的欄：`current_option／current_task` 紮營 → 建設、`move_target` 21,10 → 21,9、`survival_committed_*` 清掉、`task_util` 1938 → 1110。
- 同一 tick 決策前的 per-option util（`srp11-rank60-<sha>.txt`；Team2 idle、在 (21,9)、身上 material 30）：
  | 選項 | 修前 u | 修後 u |
  |---|---|---|
  | 紮營 | **0.19375** | **0.06121** |
  | 建設 | 0.11104 | 0.11104 |
  ⇒ 建設一字不差，紮營掉了 2/3 ⇒ 紮營輸給建設。
- 對到規格：**§一（紮根要料）＋§三（估算器總天數＝採段＋築段）**。身上 30 < 50，紮營的估值現在讀到含採段的總天數。headless 法則 B 那一格也是同一個機制：carried 0 ⇒ 紮營 1.5325 → 1.3018。
- §二 新採段、§五 NPC 回併、`"for"` 鍵：在首分歧點都還沒出場。之後的累積差我沒逐條拆，因為 tick 60 起世界已經走兩條路，再拆分不出誰是因。
- 終局各節計數（Probe 版，修前 → 修後；`srp8-wfpattr-<sha>-probe1.txt`）：
  - L0→L1 完工 `outpost.l0_to_l1` 3 → 0、`construct.complete` 4 → 0。
  - `settlement.camp_l0` 40 → 15、`l0_to_l1_resume` 22 → 0、`l0_to_l1_start` 8 → 2。
  - `funnel.build_gate.cost` 329 → 鍵退場；修後 site_barren 105（全平原）、no_advisor 182、pop 7 → 98。
  - 修後新出現：`construct.gather_ticks` 39（山地 38、森林 1）、`need.new_outpost.gather` 2、`g1.shortage_buy.new_outpost` 1、`subteam.arrival.settle.refused.npc` 3。
  - ★**這個世界 20000 tick 內一座新據點都沒蓋成**（修前 3 座）。這是「紮根要料」的直接後果。
- ★順手看到（不是本票造成的）：開 Probe 那一趟的 final_fp 跟不開不同，**修前樹也一樣**（修前 `62099ceb…` ≠ `815273e…`、修後 `85d6881b…` ≠ `f8fb6b34…`）⇒ `Probe.enabled` 會改世界，是既有的觀測污染。上面那份 Probe 計數是「開 Probe 的那個世界」的數，方向可信、絕對值不等於 fp 那一趟。要不要開票給你判。

## 負對照 n1–n27
樹 `3290a6e9a`（之後兩個 commit：`c3420b895` 只把 need_oracle 一個函式改回舊名＋床／閘修正；`d4ba72e99` 只改 headless fixture ⇒ 負對照照樣有效）。原文 `srp2-neg-n<i>.txt`。
n1–n7 紅燈原文：
- n1：`[FAIL] V1 五入口 action/type/level/gather_left(30)/ticks_left/扣料(20) 逐數相同`＋`[FAIL] V1 owner：…（false false false false false）`
- n2：`[FAIL] V3 採段每 tick ticks_left 不動、三量相等（217 tick 違反 217）`
- n3：`[FAIL] V6 採段估算與實跑差  1 日（0.000 vs 4.458）`
- n4：`[FAIL] V1 五入口…逐數相同`＋`[FAIL] V2 寫入 1 處、舊函式 0、crude_camp 0`
- n5：`[FAIL] V7 營地格完工：營地四欄清、food cap 40、outpost_built、owner＝施工隊、主隊 release、corvee 清`
- n6：`[FAIL] S3 子隊段零直呼、身體在 SubteamSystem.on_arrival`＋`[FAIL] S4 外勢力據點  release＋進 merge_queue`
- n7：`[FAIL] S1  done、 refused（NPC 與玩家子隊同結果）`

n8–n25 各紅在該紅的格：n8 S5、n9 V5、n10 V5b、n11 P1（safe_factor 與 _progress）、n12 S1 ④、n13 V10、n14 V8b、n15 V11 決勝、n16 V11 料≥need＋決勝、n17 V11b、n18 N1 ×2、n19 N2、n20 N4 ×2、n21 N5 (a)(b)、n22 N6、n23 N2b、n24 N6b、n25 N4b。

★**n26 沒紅**（errors 0）→ 請裁 ②。

n27 `_construction_need`（33188 次呼叫，`perf.need_keep.us` 同碼表）：clean 18.2／18.1 µs、neg 18.3／18.1 µs ⇒ **看不出差**。原文 `srp2-n27-{clean,neg}{1,2}.txt`。誠實限：這個世界②那一支幾乎不走（§三之三 計數 0），掃全隊迴圈幾乎沒被執行到 ⇒ n27 在這個世界紅不起來。不是守衛有效的證據。

## §三之三 計數（主隊、子隊分列）
| 世界 | walk（主／子） | gather（主／子／not_ct） | shortage_buy（主／子） | order.filled | order.abandoned | 成交比例 | 採段轉築段（全工地） |
|---|---|---|---|---|---|---|---|
| warring_states | 0（0／0） | 59（22／37／3） | 14（5／9） | 0 | 7 | 0.00 | gather_done 2／(2+0)=1.00 |
| factioned | 0 | 8（8／0／0） | 2（2／0） | 0 | 0 | — | — |
| peaceful 四個 | 0 | 0 | 0 | 0 | 0 | — | — |
- 計數是 Probe 呼叫次數，不是隊日數（同一支隊同一天會被呼多次）。隊日數只有讀者探針那一份（下節，peaceful 1337，0）。
- 「這些隊的工地在期限內轉進築段的比例」：我只有全工地那一個比例（gather_done／(done+abort)），沒按「有新點需求的那幾隊」拆。
- 新點料單 7 筆全 abandoned、0 筆 filled。

## §三之三 讀者（peaceful_economy／1337／30 天，同種子；`srp5-readers-{5c4f5581c,d4ba72e99}.txt`）
| | 修前 | 修後 |
|---|---|---|
| 隊日數 | 394 | 390 |
| 有新點承諾的隊日 | —（函式不存在） | 0 |
| maintain_material active 隊日 | 210 | 210 |
| 承諾 ∧ active | — | 0 |
| labor gather:material 權重和（330 格日） | 33420.0（平均 101.27） | 33420.0（平均 101.27） |
| labor_alloc share 和 | 1380.07 | 1381.34 |
- 這個世界一次都沒走到 §三之三 ⇒ 只能說「讀者沒被改到」，不能證明新需求帳有作用。有樣本的世界（warring）我沒跑讀者探針——要的話我再跑。

## `"for"` 鍵
- `order_system.gd:302 _sync_board` 只讀 `order_id`、`qty_remaining` ⇒ 多一個鍵不受影響。
- 存檔：專案沒有存檔系統。
- ★但它**進 fp**：`FpCoverage` 從 sim 原始碼讀到的每個欄位自動導出 TD 行，`active_orders` 在裡面 ⇒ 只要有一張 `"for"` 訂單，fp 就多那個鍵。

## 改了哪些舊床（grep「免材料」「crude_camp」「start_settle_construction」＋電池紅）
- `player_subteams_bed` S7：改成「缺料 ⇒ 仍可派、回句帶『需材』」。★**偏離**：規格說玩家子隊床斷言不改，但 M5（V10 玩家子隊建設不擋料）讓舊斷言「缺料不能派」必紅 ⇒ 不改就是兩條規格互斥。
- `construction_funnel_bed`：`funnel.build_gate.cost` → `site_barren`。
- `s6_phase2_single_source_bed`：`crude_camp` → `build`；逾時三點用 civilian pop 100／10／1。
- `settlement_s2b_test`：action `build`＋`need > 0`／`gather_left`。
- `f8_camp_settle_bed`：場景補料（新物理下沒料就停在採段）。
- `headless_test.gd`：`_test_site_diff_print` 母隊料設 0、斷言改「地禿」；`_test_construction_timeout` 補 `site_stock` 50 ⇒ 退 25。另外法則 B 那一格：carried 0 ⇒ 紮營 1.5325 → 1.3018 < 併入 1.4490（★活世界行為變了：沒料的隊不紮營改併入）。headless 失敗清單與 baseline 逐條相同。
- `option_term_cost_bed`：拿掉 `FAILS=0` 那一行。
- bed-kind 標頭：camp_access_diag／convoy_rewrite_path／phase3_longterm_story_audit／warring_harness。
- `constitution_baseline_v2.txt` 一行；`build_site_census.gd`（普查 helper）；merge-gates.tsv 本票那列 expect 33。

## 偏離與要你知道的
- 子隊開工 task 是 `TASK_CONSTRUCT`（在途）→ `start_build` 轉「建設」；②需求的謂詞照此分主／子（`need_oracle.gd:222`）。
- 守料係數 reserve 0.6：N1 量＝30（=50×0.6），N5b 用 25。
- L0 逾時放在 `tick_all`。
- `CommitmentFields`：持守讀採段進度（P1）。
- 估算器簽名多 `carried`、`site` 兩個參數（V6／V8b 同源）。
- G9：玩家紮根、建設施工中 `PRIO_PLAYER`；憲法 baseline 多一列。
- 函式名留 `max_material_facility_desire`（改成 `_facility_` 開頭會掉進憲法閘的決策函式名單）。
- N8 改用獨立隊（faction -1）。第一版用盟主隊：走回營地第 175 tick 被自家勢力目標「徵收」換走（rank0 徵收 u 0.654、rank1 建設 0.095、紮根 0.060；原文 `srp-bed3.txt:1924-1930`）。那是勢力義務壓過建設，不是本格要量的「被自己的料需求換掉」。獨立隊版跑 2160 tick 到營地、task 沒換（`srp4-bed-tip.txt:1975`）。★意思：有勢力的隊在走回營地途中，會被勢力義務換走——這不是本票造成的，但新點會因此蓋不成。

# 請裁
1. **world-fp 換基準**：新 `f8fb6b349bdc5fd23d9ee459c735d834`。首分歧在 tick 60，原因是紮營估值讀到採段天數（§一＋§三）。這個世界因此 20000 tick 內一座新據點都沒蓋成（修前 3 座）——這是要料的 WHAT 後果，但量級你跟藍圖看一下。tsv 的 expect 是你的，我沒動。
6. **Probe.enabled 改世界**（既有，修前也是）：要不要開票？
2. **N6c／n26 沒紅**：上限分配的對照，改成「先設施後新點」床照綠。因為床那個佈置是對稱的（設施 80＋新點 80，上限 100），兩種順序分出來的總和一樣。要我改成不對稱佈置（例如設施 30＋新點 80）讓它紅得起來嗎？還是這格本來就只斷言總和？
3. **V8 沒過**：六個世界的 `_dispatch_builder` 派出全是 0。過了選址的被 `no_advisor`／`pop` 擋下，平原被 `site_barren` 擋下。採段在 warring 跑得到（山地 610 tick、完工 2），只是不經建造子隊那條路。照規格停在這裡。這是藍圖要看的，還是要我往下拆 `no_advisor`？
4. **6 人子隊帶不動軍用 L1**：載重 60 < 80。軍用點在山地也採不完（INF），只有森林蓋得起來。給藍圖。
5. **recovery 那條路吃主隊建設**（`decision_context.gd:832-835`）：判可接受，但名字叫紮根。要不要改名或加入口過濾？

# 消費
本 commit 同時把下列信改 `status: consumed`：
- `2026-10-16-systems-to-implementer-GO-structure-round-probes-build-and-subteam-arrival.md`
- `2026-10-16-systems-to-implementer-GO-addendum-structure-round-new-outpost-material-need-ledger.md`
- `2026-10-16-systems-to-implementer-RULING-site-worker-pick-stays-on-tile-build-only.md`
- `2026-10-17-systems-to-implementer-MERGED-player-faction-goal.md`

下一張：a3prime。
