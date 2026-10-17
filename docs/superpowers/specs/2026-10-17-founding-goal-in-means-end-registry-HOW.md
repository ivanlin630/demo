# 開點登進既有長程目標表 — HOW

> systems 2026-10-17。草稿：§四（派建點子隊的人數規則）等量測回來才寫，之後才送 R²。
> WHAT：
> - 藍圖 RULING 2026-10-16-blueprint-to-systems-RULING-founding-is-a-goal-in-the-existing-means-end-registry-not-a-new-desire（用戶 10-16：長程規劃已有前置拆鏈與跨日持有，開點只是沒登）。
> - 藍圖 RULING 2026-10-17-blueprint-to-systems-RULING-merge-structure-round-accept-fewer-outposts-until-founding-goal-lands（兩道舊門併本票前提查核；軍用 80 料對載重 60 不動數字，人數與趟數由缺口與載重算；固定 settler 配額退給秤）。
> - 藍圖 RULING 2026-10-17-blueprint-to-systems-RULING-founding-goal-starts-at-settle-camp-not-counted（甲：搭營地不算開點，開點從紮根算起）。
> 前提：R① 2026-10-17-reviewer-to-systems-R1-founding-goal-premises-VERDICT（P1–P8；P2 藍圖前提不成立、對本票有利）。
> 量測前置：2026-10-17-systems-to-measurer-REQUEST-dispatch-builder-pop-and-advisor-gates-who-and-where-next（未回）。
> 位置：結構輪之後第一張。關掉 known_issues「新據點大減：沒帶夠料的隊幾乎不開點」。

## 現況（main e4caa61f0；file:line 經 R① 驗）

### 目標表
- `goal_registry.gd:16-21` 維持 4 列、`:25-34` 設施 8 列；沒有開點列。
- `decision_engine.gd:102` `ensure_maintain_goals`、`:498` `frontier_candidates` 對每支隊都跑。只有設施列讀 `otile`（`goal_resolver.gd:46-99`）⇒ 沒據點的隊照跑目標迴圈，**不必拆任何早返回**。
- 檔頭 `goal_resolver.gd:4-6` 與 `commitment_fields.gd:34` 寫「goal_state 只存慾望、不存 plan-state（HOW §9）」；元素欄位 `{goal_type, target, created_tick, status}`，`target` 恆 null、沒有讀者讀它。

### 當場開點的路（母體，R① P3）
| # | 路 | 決策端 | 執行端 |
|---|---|---|---|
| ① | 紮根（營地 L0→L1） | `options.gd:330` 「紮根」，`rooting_drive`；applicable＝`can_settle_here`（站在自己營地）∨ `settle_resume_site` ∨ `own_camp_pos` | commit-hook `faction_ai_system.gd:7402 _commit_settle_site` → `:7436 start_build`；另三個呼叫點 `:4033`、`:4487`（子隊版）、`:4782`、`:7349` |
| ①' | 紮根委派變體 | `goal_resolver.gd:558-583 _delegate_variant` 把 TASK_BUILD 自候選包成 delegate（settler＝`clampi(pop/4,2,5)`） | `_dispatch_goal_delegate` generic 分支 `faction_ai_system.gd:5902-5911` |
| ② | 擴點 | `options.gd:360` 「擴點」，`expand_drive`（`terms.gd:572-580`：分點邊際 − 建置成本 − 家內邊際）；applicable `can_expand`（`decision_context.gd:895-903`，選址快取 `expand_site_cached` ∧ pop ≥ 12） | delegate `build_type` → `_dispatch_builder`（`:5510`） |
| ③ | 採料遠端開點 | `goal_resolver.gd:1174` `_resolve_resource_prereq` 內，`_mk_delegate_candidate(…{"build_type":"civilian"})` | 同 ② |
| ④ | infra 段 (3) | `faction_ai_system.gd:6551-6559` 每 INFRA_INTERVAL 跑 `_evaluate_new_outpost_location`，直接 `_dispatch_builder` | 同 ② |
- 玩家路（`player_command_system.gd:1105`、`:1426`）不走目標迴圈，不在本票。
- 搭營地（L0，`establish_crude_camp` 五個呼叫點）不算開點（藍圖裁甲），不動。

## 改法

### 一、目標表加一列 `found_outpost`
- `GoalRegistry.REGISTRY["found_outpost"] = {"founding": true}`。像設施列一樣走專屬分支，**不宣告 `prereqs`**：
  - 料的前置不走這一列自己的資源候選，走需求帳（§三）⇒ 由既有 `maintain_material` 產買／採／守候選。這樣同一份料不會被兩列各求一次。
  - 地點前置不走 `_resolve_location_prereq`（`:1462`）：它找最近的格、還把「有自家據點」當滿足（R① P4），兩件都跟開點相反。
- 元素欄位：`{goal_type:"found_outpost", target:Vector2i, type:String, level:1, value:float, created_tick, status:"active"}`。
- **§9 的改法**：開點的地點是**目標本身**（想在哪裡開點），不是計畫步驟。改 `goal_resolver.gd:4-6` 與 `commitment_fields.gd:34` 兩處註解：「goal_state 存慾望；慾望可以有對象（開點的地點），不存達成它的步驟」。`frontier` 仍每 tick 重算、不寫回。
- 順手改過期註解（R① P1）：`goal_registry.gd` 上方「5 資源維持」、`decision_engine.gd:102` 行尾「5 資源維持」→ 4。

### 二、掛、重驗、退（在 `ensure_maintain_goals` 的三天節奏裡，不讀 `otile`）
- **選址**（決定 `target` 與 `type`）：
  - 有自家據點：`_evaluate_new_outpost_location`（結構輪 §三之二的選址秤，含採料天數項與 site_barren 濾除）；`type` 走 `_pick_outpost_type`。
  - 沒據點、有自己的營地（`own_camp_pos`）：`target` ＝ 營地；`type` ＝ `settle_camp_type`。
  - 兩者都沒有：不掛（照今天的路先搭營地，藍圖裁甲）。
- **值**（`value`，同時是 payoff）：走既有的四選項同尺入口 `DiscountedFlow.flow_utility`（`discounted_flow.gd:72`），不另寫一份正規化：
  - 有據點：`gain_daily` ＝ `expand_site_marginal`、`baseline_daily` ＝ `expand_home_marginal`（`decision_context.gd:911-916` 那兩個量，同一支算式抽出共用，不手抄）。
  - 營地：`gain_daily` ＝ 營地格 L1 的村產估（`VillageEstimate.make(terrain, 1, 0, pop)` → `MarginalEconomy._inflow_est`）、`baseline_daily` ＝ 今天營地的流。
  - `delay_days` ＝ `OutpostSystem.build_eta_total_days(..., carried, site_prior)` ＋ 路程天數。料不夠就是採段＋築段；平原採不完時是 INF，再看「買夠了」那一版（§三）。
  - `expand_build_cost` 不再另扣：工期已經在 delay 裡折現，兩邊都算就是重算。
- **掛**：`value > 0` 且 `target` 有效 ⇒ 掛一筆（每隊最多一筆 `found_outpost`）。
- **重驗**（每三天，條件寫成可讀事件 `goal.found.<事件>`，藍圖要求）：
  - `site_taken`：目標格已有據點，或別隊在施工 ⇒ 退。
  - `built`：目標格成了自己的據點 ⇒ 退（達成）。
  - `value_nonpositive`：重算 `value ≤ 0` ⇒ 退。
  - `replaced`：選址秤的新最佳格 `value ≥ 舊 value × (1 + PERSIST_CAP)` ⇒ 換。`PERSIST_CAP` 讀既有常數，不另立一個門檻。
  - `kept`：以上皆非 ⇒ 留。五個事件互斥且窮盡，加總＝檢視次數（對帳式）。
- **感知**：選址秤與 `site_prior` 讀的是隊自己知道的格與地形先驗，不讀遠端真值（R① P6 提醒）。實作端在交件信列出這一列讀到的每一個遠端量，各標來源。

### 三、需求帳：第三種承諾 `goal`
- `NeedOracle.new_outpost_commitment`（`need_oracle.gd:208`）在 ①walk、②gather 都不成立時，看 `goal_state` 有沒有 active 的 `found_outpost` ⇒ 回 `{kind:"goal", type, level, tile}`。
  - 優先序：已經在工地（gather）＞ 在路上（walk）＞ 掛著的目標（goal）。同一座點只會落進一種。
- 下游不用改：`_new_outpost_need` 的 else 分支取整筆成本（R① P6），`_construction_need`、`trade_valuation` reserve、`coin_treasury` 跟著走。
  - ⇒ 掛了開點目標的隊，`need_keep(material)` 多出整筆成本 ⇒ `maintain_material` 變 active ⇒ 既有的買料、採料、守料候選自然出現。
  - 沒掛的隊不受影響（不讓每隊都守 50 料，藍圖 WHAT 5）。
- `new_outpost_urgency` 對 `goal` 這種：照 ① 的算法（carried＝自己的料、site＝地形先驗）。
- Probe 鍵多一個 `need.new_outpost.goal`（及 `.main`／`.sub`），結構輪 N1／N3 的斷言補這一鍵。

### 四、派建點子隊的人數（待量測）
- 藍圖裁：12 人門翻成秤、與 `MIN_PARENT_POP_AFTER_DISPATCH` 同源禁兩份；派幾人、跑幾趟由缺口與載重算；固定 settler 配額退場。
- 現況（R① P7）：12 在 `faction_ai_system.gd:5584-5585` 與 `decision_context.gd:900-903` 兩處手抄；10 在 `:899-900` 與 `goal_resolver.gd:568-569`；派出人數 6（builder）對 2–5（generic）。
- **等量測回來再寫**：被人數門擋下的隊差幾人、之後去做了什麼，決定秤怎麼放。
- **已定、不等量測**：`_pick_or_promote_advisor`（`:5579`）移到所有 `return false` 之後、`SubteamSystem.dispatch` 之前；檢查「有沒有人可以當帶隊人」改用純查詢（`_pick_advisor != -1 ∨ 匿名人 > 0`，與 `person_generator.gd:86-91` 同一個條件，抽成一支共用）。失敗的嘗試不再有世界寫入。

### 五、執行端：四條路收斂成這一列
- `frontier_candidates` 對 `found_outpost` 走專屬分支 `_resolve_found_outpost`：
  - `delay` 有限（帶的料加上可採的夠蓋）⇒ 出一個**執行候選**：
    - util ＝ 同 §二 的 `flow_utility`（用當下的 carried 重算 delay），再過 `GOAL_UTIL_CAP` 護欄（must-fix① 不變）。
    - `target` 是自己的營地 ⇒ `to_task = {task: TASK_BUILD, target, settle_site}`（紮根的身體與 commit-hook，不新寫）。
    - 否則 ⇒ `to_task = {delegate: true, task: TASK_BUILD, target, build_type: type}` → `_dispatch_builder`。
  - `delay` 是 INF（平原沒帶夠料）⇒ 不出執行候選，Probe `goal.found.wait_material`。料由 §三 的需求帳去買；買夠了，下一次 delay 就變有限。
  - ⇒ 帶夠料的隊：delay ＝ 路程＋築段，當天就可能贏，行為與今天同（藍圖 WHAT 4）。
- **退場的決策端**（不留兩套）：
  - 「擴點」option 刪除（值搬進 §二，執行搬進本節）；`can_expand`／`expand_site_cached` 的唯一讀者若只剩本票，跟著搬進 §二的選址。
  - infra 段 (3)（`:6551-6559`）刪除。
  - ③ 採料遠端開點（`goal_resolver.gd:1174`）刪除：要在產地開點，就是選址秤的事。產地值若沒進選址秤，交件信要寫，並把普查裡 ③ 的修前次數列出來。
  - 「紮根」option 只留 `settle_resume_site`（回頭續建自己已開工的工地，屬於承諾的復原，不是開點決策）。站在營地上、走回營地這兩支改由本節的執行候選產生。
    - ★這裡要實作端驗：紮根在 `survival` 集合裡（`options.gd:337`），絕境隊靠它。拿掉兩支之後，絕境隊的開點候選改從目標迴圈來；目標候選 util 有 `GOAL_UTIL_CAP` 上限、比絕境加成低。交件信要印「絕境隊（food_days < 3）在營地上的開點次數，修前／修後」。若明顯變少，停下回報，不要自己調值。
  - 紮根委派變體 ①' 與子隊版 `:4487` 是身體的路由，不是決策，保留；人數照 §四。

## 驗收（新床 `founding_goal_bed.gd`，註冊進 `merge-gates.tsv` 一列）
- **F1 沒據點的隊也掛得上**：沒據點、有營地的隊，三天後 `goal_state` 有 `found_outpost`、`target` ＝ 營地。同一支隊在 `decision_engine.gd:102` 的進場計數 > 0（R① P2 誠實限要的執行面證據）。
- **F2 帶夠料當天走**：有據點、帶 ≥ 成本的料、選址有效 ⇒ 同一天內出現執行候選並派出（`funnel.build_gate.dispatched` +1）。
- **F3 平原先買再走**：目標在平原、料 0、有料市場、有錢 ⇒
  - (a) 沒有執行候選，`goal.found.wait_material` > 0；
  - (b) `need_keep(material)` 含整筆成本，買料候選出現；
  - (c) 料買夠後出現執行候選並派出。
- **F4 沒掛的隊不守料**：同一世界、沒掛 `found_outpost` 的隊，`need_keep(material)` 修前後相同。
- **F5 重驗五事件**：每一種各造一次，對帳式成立（加總＝檢視次數）。
- **F6 決策端退場**：全庫 grep，「擴點」option、infra 段 (3)、③ 遠端開點各 0 處；「紮根」只剩 resume 一支。
- **F7 失敗的嘗試沒有世界寫入**：讓人數門擋下 ⇒ `state.persons.size()` 與 `named_members.size()` 嘗試前後相同。
- **F8 量測（電池世界 30 天；修前＝本票 merge 前的 main）**：
  - 新據點蓋成數按地形分列，修前修後並排；**戰國世界 20000 tick 新據點 > 0**（結構輪後是 0）。
  - 掛 `found_outpost` 的隊佔幾成；這些隊平均持有的料，對比沒掛的隊。
  - `goal.found.*` 五事件次數。
  - 絕境隊在營地上的開點次數（§五）。
- world-fp 會變（開點的決策端整個換了）。換基準前印新舊值，首分歧點逐條對到本票哪一節。

## 負對照（各紅在該紅的格）
| 注射 | 該紅 |
|---|---|
| m1 掛的條件改成讀 `otile`（沒據點不掛） | F1 |
| m2 執行候選的 delay 固定加 1 天 | F2 |
| m3 `new_outpost_commitment` 不看 goal | F3(b) |
| m4 goal 那一種對所有隊都回整筆（不看有沒有掛） | F4 |
| m5 重驗少一個事件（`replaced` 併進 `kept`） | F5 對帳式 |
| m6 「擴點」option 留著 | F6 |
| m7 升人移回人數門之前 | F7 |

## 範圍外
- 玩家開點路（不走目標迴圈）。
- 搭營地（L0）。
- 成交與市場深度（貿易深層批）。
- 「走回營地途中被勢力目標換走」（known_issues，回訪＝持守統一）。

## 交件信要列
- F8 全部數字；world-fp 新舊值與首分歧歸因。
- §二「感知」那一條：這一列讀到的遠端量，各標來源。
- ③ 遠端開點修前次數；產地值有沒有進選址秤。
- `expand_site_cached`／`can_expand` 剩下的讀者。
- 負對照 m1–m7 紅燈原文。
