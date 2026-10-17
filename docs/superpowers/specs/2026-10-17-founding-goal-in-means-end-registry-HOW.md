# 開點登進既有長程目標表 — HOW

> systems 2026-10-17。第三版依 R²b ISSUES（N1–N3、S1–S4）；遠端存量照藍圖 RULING `2026-10-17-blueprint-to-systems-RULING-remote-tile-current-stock-is-not-knowable-site-score-reads-belief-or-terrain-prior` 另開一張。§四依量測回填；第二版依 R² ISSUES（`2026-10-17-reviewer-to-systems-R2-founding-goal-in-means-end-registry-ISSUES`，M1–M7、S1–S4）改，M1 選 (b)。
> WHAT：
> - 藍圖 RULING 2026-10-16-blueprint-to-systems-RULING-founding-is-a-goal-in-the-existing-means-end-registry-not-a-new-desire（用戶 10-16：長程規劃已有前置拆鏈與跨日持有，開點只是沒登）。
> - 藍圖 RULING 2026-10-17-blueprint-to-systems-RULING-merge-structure-round-accept-fewer-outposts-until-founding-goal-lands（兩道舊門併本票前提查核；軍用 80 料對載重 60 不動數字，人數與趟數由缺口與載重算；固定 settler 配額退給秤）。
> - 藍圖 RULING 2026-10-17-blueprint-to-systems-RULING-founding-goal-starts-at-settle-camp-not-counted（甲：搭營地不算開點，開點從紮根算起）。
> 前提：R① 2026-10-17-reviewer-to-systems-R1-founding-goal-premises-VERDICT（P1–P8；P2 藍圖前提不成立、對本票有利）。
> 量測前置：2026-10-17-measurer-to-systems-DONE-dispatch-gates-who-and-where-next（main 21b3bf2ec；原始輸出 `docs/measurements/2026-10-17-dispatch-gates-who-and-next/`）。
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
- 元素欄位見 §二（只存 `target`／`type`／`level`，不存 `value`）。
- **§9 的改法**：開點的地點是**目標本身**（想在哪裡開點），不是計畫步驟。改 `goal_resolver.gd:4-6` 與 `commitment_fields.gd:34` 兩處註解：「goal_state 存慾望；慾望可以有對象（開點的地點），不存步驟、也不存評估值」。`frontier` 仍每 tick 重算、不寫回。
- 順手改過期註解（R① P1）：`goal_registry.gd` 上方「5 資源維持」、`decision_engine.gd:102` 行尾「5 資源維持」→ 4。

### 二、誰掛、怎麼選址、怎麼算值、怎麼重驗（在 `ensure_maintain_goals` 的三天節奏裡，不讀 `otile`）
- **掛的母體**（R² M5）：只有自主的母隊。排除：
  - 子隊（`parent_team_id != -1`）；
  - 玩家操控的隊（同擴點今天的排除，`decision_context.gd:886`）；
  - 沒有隊長的隊。
  每隊最多一筆 `found_outpost`。
- **選址**（決定 `target` 與 `type`）：
  - 有自家據點：讀 `expand_site_cached`。它照今天的節奏更新：`INFRA_INTERVAL`、`advance` 閘（`decision_context.gd:886-897`；`commitment_fields.gd:28` 分類為評估快取）。
    - **進場條件放寬**（R²b N2，選 (a)）：今天的 if 是 `has_own_outpost ∧ idle_labor > 0 ∧ 非玩家`（`:886`）。`idle_labor > 0` 是舊「擴點」的**動機**（閒勞力沒事做），不是開點的通則；③④ 沒有這一條。擴點退場後拿掉它，改成「有自家據點 ∧ 屬 §二掛的母體」。否則能開點的隊會悄悄縮到有閒勞力的隊。
    - 代價：掃全圖的隊變多（今天 ② 只有有閒勞力的隊、④ 每勢力一支）。F8 的 perf 項要特別印 `INFRA_INTERVAL` 那一拍。
    - 快取第一次寫入要等一個 `INFRA_INTERVAL`，在那之前讀到 (-1,-1) ⇒ 不掛。無害；F2 的床先推一個 `INFRA_INTERVAL`。`ensure_maintain_goals` 裡**不**每隊重掃全圖。`type` 走 `_pick_outpost_type`。
    - ⇒ 全圖掃描次數 ≤ 今天：② 的快取照舊；④ 每勢力一次那一份退場（§五）。
  - 沒據點、有自己的營地（`own_camp_pos`）：`target` ＝ 營地；`type` ＝ `settle_camp_type`。不掃圖。
  - 兩者都沒有：不掛（照今天的路先搭營地，藍圖裁甲）。
- **值**（R² M3，走 (a)）：開點列的 payoff 跟別的目標列同一種單位（錢），餵既有的 `_candidate_util`，**只在那裡**正規化一次、折現一次。
  - `payoff = (pv(gain_daily) − pv(baseline_daily)) × BASE_PRICE.food`。
    - `pv` 用 `DiscountedFlow.pv`，`delta`／`horizon` 照 `flow_utility` 內部同一組取法（`delta_of`、`horizon_eff`），抽成共用、不手抄。
    - **不乘** `wait_mult`，也不除 `daily_need`：前者交給 `_candidate_util` 的 `discount`，後者交給它的 `_unit`。
  - `gain_daily`／`baseline_daily` 是派出 n 人時的值（§四 `plan` 選 n）：
    - 有據點：新點 L1、`pop = n` 的村產估 × 選址記憶乘子；家裡少 n 人的流失。今天 `expand_site_marginal`／`expand_home_marginal` 那兩支，抽成 n 的函數。
    - 營地：營地格 L1 的村產估（全隊）；今天營地的流。
  - `delay_days` ＝ 路程 ＋ `build_eta_total_days(..., n, carried(n), site)`。只傳給 `_candidate_util`。
  - `expand_build_cost` 不再另扣：工期已經在 delay 裡折現。
- **goal 元素只存慾望的對象**（R² 點 6 條件①）：`{goal_type:"found_outpost", target:Vector2i, type:String, level:1, created_tick, status:"active"}`。
  - `value` 不存，每次重算。
  - `commitment_fields.gd:34` 的註解改成「goal_state 存慾望；慾望可以有對象（開點的地點），不存步驟、也不存評估值」。
- **掛**：`payoff > 0` 且 `target` 有效 ⇒ 掛一筆。
- **重驗**（每三天；條件寫成可讀事件 `goal.found.<事件>`，藍圖要求）。依下面的**優先序**取第一個成立的（R² S3），五個互斥且窮盡，加總＝檢視次數：
  1. `built`：目標格成了**自己的**據點 ⇒ 退（達成）。
  2. `site_taken`：目標格有據點或工地，而且不是自己的 ⇒ 退。
  3. `value_nonpositive`：重算 `payoff ≤ 0` ⇒ 退。
  4. `replaced`：選址快取的新最佳格與舊格**都用當下值重算**，新格 `score ≥ 舊格 score × FOUND_SITE_SWITCH_RATIO` ⇒ 換。
     - `FOUND_SITE_SWITCH_RATIO = 1.3`，TEST VALUE，新常數。來歷：防止選址每三天在兩格之間飄、存的料對不上同一座。世界答不出該是多少，所以標 TEST VALUE。
     - 不借 `PERSIST_CAP`：那是 util 加成，不是倍率（R² M3）。
  5. `kept`：以上皆非 ⇒ 留。
  - **「自己的」**（R² M4）＝ 本隊或本隊的子隊（`subteam_ids`，含在途與施工中）。工地看 `construction_team_id`，據點看 `outpost_owner`。判法走既有的一跳親緣謂詞（`world_state.gd:801 registered_or_parent_at` 那一族；`outpost_system.gd:1061-1064` 註解：不得再手寫 `owner == parent_team_id`）。若沒有現成的「這個 team_id 是不是我或我的子隊」謂詞，就在 `world_state.gd` 那一族旁邊新寫一支，§二、§三、§五三處共用。
- **感知**（R² M6，訂正）：選址秤**有讀遠端格的現存量**。`_site_resource_bonus` 對候選格與六鄰讀 `ntile.resources`（現存量）、`ntile.resource_cap`（`faction_ai_system.gd:6235-6243`）。tiles 迴圈上的 `gate-ok: legit-geo`（`:6167`、`:6188`）標的是讀地形，不涵蓋這兩讀。採料天數那一項才走 `site_prior`（`:6204`）。
  - 本票不改選址秤（既有 code）。
  - 本票對這兩讀的使用範圍：快取母體照 ②（有據點的隊、`INFRA_INTERVAL`），④ 那份退場 ⇒ 讀的次數不增加。
  - 藍圖裁（2026-10-17 RULING remote-tile-current-stock-is-not-knowable）：這兩讀不算隊伍能知道的事，不補豁免；另開一張小票排在本票之後（見範圍外）。
  - 交件信列出這一列讀到的每一個遠端量，各標來源，先寫這兩項。

### 三、需求帳：第三種承諾 `goal`
- `NeedOracle.new_outpost_commitment`（`need_oracle.gd:208`）在 ①walk、②gather 都不成立時，看 `goal_state` 有沒有 active 的 `found_outpost` ⇒ 回 `{kind:"goal", type, level, tile}`。
  - 優先序：已經在工地（gather）＞ 在路上（walk）＞ 掛著的目標（goal）。同一座點只會落進一種。
  - **母隊已有建點子隊在途或施工時，`goal` 這一種回空**（R² S2）：料已撥給子隊，母隊不再買第二份。判法跟 §四的 `in_flight` 是同一支謂詞。
- 下游不用改：`_new_outpost_need` 的 else 分支取整筆成本（R① P6），`_construction_need`、`trade_valuation` reserve、`coin_treasury` 跟著走。
  - ⇒ 掛了開點目標的隊，`need_keep(material)` 多出整筆成本 ⇒ `maintain_material` 變 active ⇒ 既有的買料、採料、守料候選自然出現。
  - 沒掛的隊不受影響（不讓每隊都守 50 料，藍圖 WHAT 5）。
- `new_outpost_urgency` 對 `goal` 這種：照 ① 的算法（carried＝自己的料、site＝地形先驗）。
- Probe 鍵多一個 `need.new_outpost.goal`（及 `.main`／`.sub`），結構輪 N1／N3 的斷言補這一鍵。

### 四、派建點子隊：一支 `plan`，涵蓋派遣端全部六道閘
- 藍圖裁：12 人門翻成秤、與 `MIN_PARENT_POP_AFTER_DISPATCH` 同源禁兩份；派幾人由缺口與載重算；固定 settler 配額退場。
- 現況（R① P7）：12 在 `faction_ai_system.gd:5584-5585` 與 `decision_context.gd:900-903` 兩處手抄；10 在 `goal_resolver.gd:568-569`（另 `:899-900` 是「安頓」，見範圍外）；派出人數 6（builder）對 2–5（generic，`goal_resolver.gd:568`、`:1504`、`faction_ai_system.gd:5909`）。
- **量測讀到的**（warring／peaceful，seed 1337，30 天；Probe 世界，只算方向）：
  - 沒帶隊人門 257／74 次，被擋時 pop **全部 = 1**、都有隊長、疑記帳 bug 0 件 ⇒ R① P7 成立：是物理（沒人可派），不是門。
  - 人數門 165／27 次，只來自 13／4 支隊；warring 112 次差 7 人以上，其中 pop ≤ 3 占 102 次；一支隊最多被擋 51 次。
  - ⇒ 被擋的幾乎都是**小隊反覆重試**。R² 驗過：`_dispatch_builder` 只有 `:5889`（delegate `build_type`，來源只有擴點與 ③）與 `:6559`（④）兩個呼叫者，擴點 applicable 本來就要 12 人 ⇒ 這些嘗試來自 ③ 或 ④。兩條都不查人數，也就是**候選端沒問、派遣端才擋**。症狀是重試，根是兩端各自一份規則。兩條路本票都退場（§五）。
    - R² 補：④ 的 `leader_team` 是勢力領隊隊，不是各隊自己。所以 ④ 退場後，「領隊替全勢力選一格」變成「每隊各自選」。同一格可能被多隊同時選中，F8 要量。
  - 升人副作用 9／165、3／27 次（每隊最多一次）。被擋後沒有隊消失。
- **`FoundingCrew`**（新檔 `scripts/simulation/decision/founding_crew.gd`，static，純查詢、零 RNG、零世界寫入）
  - `plan(state, team, site_pos, type, level) -> {ok, crew, carried, payoff, delay_days, reason}`。
  - 只有四個地方呼它，派出人數一律讀 `plan.crew`：§二的值、§五的執行候選、`_dispatch_builder`、`_delegate_variant`（只限紮根，見下）。
  - **`_delegate_variant` 的範圍**（R²b N1，選 (a)）：它包所有 TASK_BUILD／TASK_SETTLE 自候選（`goal_resolver.gd:564`）。TASK_BUILD 有三個 option：
    - 紮根（`to_task` 有 `settle_site`，有 type／level）⇒ 走 `plan`；
    - 「建設」（`options.gd:70-78`，在自家格 bootstrap 或升級）、「自救建田」（`:89-100`，在自家格蓋產糧設施）⇒ 不是開點，照原本的 `clampi(pop/4,2,5)` 與 `MIN_PARENT_POP_AFTER_DISPATCH` 檢查，不動；範圍外列一條。
    - 判法寫成一支謂詞 `is_founding_task(to_task)`（有 `settle_site` 或 `build_type`），§四、§五、F6 共用。
  - **涵蓋派遣端全部六道閘**（R² M2）。依序；不成立就 `ok=false`，`reason` 為括號內的名字：
    0. `no_crew`（R²b N3：排在最前，**在 n 迴圈之前**）：pop ≤ 1，或沒有人能當帶隊人（純查詢 `_pick_advisor != -1 ∨ 匿名人 > 0`，與 `person_generator.gd:86-91` 同一條件，抽成一支）。n 範圍是空的時候一定先落在這裡，**不得**落進 `site_barren`／`food_bridge`（否則今天 257 次的物理失敗會被記成「等料」，灌水 `wait_material`）。
    1. `in_flight`：本隊已有 CONSTRUCT／BUILD 子隊（掃 `subteam_ids`，同 `:5544-5551`）。§三 S2 共用這一支。
    2. `tile_occupied`：目標格有工地（同 `:5553-5556`），或目標格是「別人的」（§二的親緣謂詞）。
    3. 對每個 n ∈ [1, pop − 1]（母隊至少留隊長一人）：
       - `carried(n) = min(fundable_carry(...).material, n × MovementSystem.BASE_CARRY)`（讀常數；坐騎、車不分給子隊，照今天撥料的實況）。
       - `delay(n)`：`build_eta_total_days(..., n, carried(n), site)` 是 INF ⇒ 排除這個 n。
       - 糧橋（`:5602-5616`，派出 n 人時母隊撥不撥得起 `n × 每人日糧 × (路程 + 工期) × MARGIN`）：撥不起 ⇒ 排除這個 n。算式從 `_dispatch_builder` 抽成一支，兩端同呼。
       - 留下的 n 算 `score(n) = payoff(n) × discount(delay(n))`，`discount` 是 `_candidate_util` 裡那一支抽出來的。`_candidate_util` 的其餘兩項（`x/(1+x)` 單調、`dev_coeff` 與 n 無關）不改變 argmax，所以 n 用 score 選，跟最後的 util 同序。
    4. 沒有可行的 n 時，歸屬看「拿掉糧橋這一項，還有沒有可行的 n」（R²b N3）：
       - 有 ⇒ `food_bridge`（是糧不夠，不是地禿）；
       - 沒有 ⇒ `site_barren`（§五會轉成 `goal.found.wait_material`）。
    5. 最大的 `score ≤ 0` ⇒ `value_nonpositive`。
    - ⇒ pop = 1 的隊（今天的 257 次）在候選端就沒有候選，不會走到派遣端。
  - **退場的常數與配額**：下列全部改讀 `plan`：
    - `_dispatch_builder` 的 `pop = maxi(6, level*4)` 與 `pop*2` 門；
    - `decision_context.gd:900-903` 的 `_settler` 手抄；
    - `_delegate_variant` 對紮根變體的 `clampi(pop/4,2,5)` 與 `MIN_PARENT_POP_AFTER_DISPATCH` 檢查（建設、自救建田不動，見上）；
    - `:1504` 的開點保底配額。
    - 「母隊剩多少才夠」不再是門檻，改由 `baseline_daily` 承擔：派走的人越多、家裡越虧。
    - R² 點 2 的誠實限：`_inflow_est` 只算產糧，不算守備、孩童。秤會不會自己停，要看它對 n 是不是凸，F8 直接印出來。
    - TASK_SETTLE 那一支（搭營地／落腳，藍圖裁甲不在本票）照舊用 `clampi`，註解寫明它不是開點。
  - **派遣端**：`_dispatch_builder` 開頭重呼 `plan`（同 tick 同輸入 ⇒ 同答案）。`ok=false` ⇒ `funnel.build_gate.<reason>` ＋ return false。原本六道各自的 if 全刪。鍵名對照（R²b S2）：`in_flight` 沿用舊鍵 `busy_subteam`；`tile_occupied`、`site_barren`、`food_bridge` 照舊；`no_crew` 是新鍵，取代 `pop` 與 `no_advisor` 兩個舊鍵；`value_nonpositive` 是新鍵。交件信附這張對照，F9 用新鍵名。
  - **趟數**：本票恆一趟。多趟運料不新寫；缺的料走就地採或 §三的「先買夠再走」（範圍外列一條）。
- **升人移到最後**：`_pick_or_promote_advisor` 有兩處都在派出前升人，兩處都移到 `plan.ok` 之後、`SubteamSystem.dispatch` 之前；失敗的嘗試不再有世界寫入（F7）。
  - `_dispatch_builder`（`:5579`）；
  - `_dispatch_goal_delegate` generic 分支（`:5904`，紮根委派變體 ①' 走這裡；R²b S4）。M1(b) 之後營地紮根委派變體仍會被產生（紮根 option 沒動），所以這一支要改。建設、自救建田的委派也走這支；它們沒有 `plan`，那就移到它們自己原本的檢查之後。
- **誠實限**：
  - 量測只有一個 seed、Probe 世界；也沒量「不被擋本來會派什麼」。本節不靠量測挑數字，只用它確認兩件事：沒帶隊人是物理；被擋的是候選端沒查人數的小隊。
  - 1–3 人的小隊在新秤下**可能**派得出 1–2 人的子隊（今天派不出）。pop = 2 派 1 人之後母隊只剩 1 人，下次回到 `no_crew`，不會死循環（R² 點 2）。不另加下限；F8 印分布。

### 五、執行端：四條路收斂
- **營地目標的執行端＝「紮根」option，留在 survival 集**（R² M1，我選 (b)）：
  - 理由：目標候選的 util 乘 `dev_coeff = food_days / 3`（`goal_resolver.gd:1611`），絕境必然趨 0。紮根今天靠 survival 集的加成救絕境隊（`options.gd:337-339` 寫明拿掉它＝隱含硬門檻）。把營地開點搬進目標候選，絕境隊**必然**失去紮根；這不用量就推得出。
  - 改法：
    - 「紮根」option 的三支 applicable（`can_settle_here`／`settle_resume_site`／`own_camp_pos`）、`rooting_drive`、survival 集身分、commit-hook 都不動。
    - 營地的 `found_outpost` 目標**只**做兩件事：需求帳（§三，讓紮營隊先存料）與重驗事件（§二）。
    - `_resolve_found_outpost` 遇到營地目標不出執行候選，Probe `goal.found.camp_via_rooting`。
  - ⇒ 營地開點只有一條決策路（紮根），有據點的開點只有一條決策路（本節下面）；兩條管的格不重疊，不是兩套。
  - ⇒ F8 的「絕境隊在營地上的開點次數」從「可能變少就停」改成**修前修後應相同**（差異只能來自需求帳讓料先到，交件信逐條歸因）。
- **有據點的目標**：`frontier_candidates` 對 `found_outpost` 走專屬分支 `_resolve_found_outpost`：
  - 先呼 `plan`。
    - `ok` ⇒ 出一個執行候選：`util = _candidate_util(plan.payoff, ctx, plan.delay_days)`（must-fix① 護欄、`gu2.*` 探針照舊）；`to_task = {delegate: true, task: TASK_BUILD, target, build_type: type, settler: plan.crew}` → `_dispatch_builder`。
    - `reason == site_barren` ⇒ 不出候選，Probe `goal.found.wait_material`；料由 §三的需求帳去買，買夠了下一次 `plan` 就成立。
    - 其餘 reason（`in_flight`／`tile_occupied`／`food_bridge`／`no_crew`／`value_nonpositive`）⇒ 不出候選，Probe `goal.found.no_candidate.<reason>`。
    - ⇒ 子隊在途的那幾天不會每個 decide 週期產候選再被擋（R² M2(b)）。
  - ⇒ 帶夠料的隊：delay ＝ 路程＋築段，當天就可能贏，行為與今天同（藍圖 WHAT 4）。
- **退場的決策端**（不留兩套）：
  - 「擴點」option 刪除（值搬進 §二，執行搬進本節）。`can_expand` 跟著刪；`expand_site_cached` 留，給 §二選址讀。
  - infra 段 (3)（`:6551-6559`）刪除。
  - ③ 採料遠端開點（`goal_resolver.gd:1174`）刪除：要在產地開點，就是選址秤的事。產地值若沒進選址秤，交件信要寫，並把普查裡 ③ 的修前次數列出來。
  - 紮根委派變體 ①' 與子隊版 `:4487` 是身體的路由，不是決策，保留；人數照 §四（`plan.crew`）。
- **舊床遷移**（R² S1）：下列床讀或呼 `can_expand`／`expand_*`／`_dispatch_builder`。實作端逐支決定改寫成 `found_outpost` 的斷言，或退役並寫理由；交件信列一張表：
  - `expand_bigvillage_bed.gd`
  - `settlement_s4b_test.gd`
  - `means_end_a1_test.gd`、`means_end_s3_test.gd`、`means_end_s4_test.gd`
  - `headless_test.gd`
  - `failure_memory.gd:100` 的 `"擴點"` 鍵：改成 `"開點"`，或併入既有鍵（照它的讀者決定）。
  - F6 的 grep 只數產品碼（`scripts/simulation/`），床另列。

## 驗收（新床 `founding_goal_bed.gd`，註冊進 `merge-gates.tsv` 一列）
- **F1 沒據點的隊也掛得上**：沒據點、有營地的隊，三天後 `goal_state` 有 `found_outpost`、`target` ＝ 營地。同一支隊在 `decision_engine.gd:102` 的進場計數 > 0（R① P2 誠實限要的執行面證據）。
  - F1-det：同 seed 兩跑 `state_fingerprint` 相同（goal 元素多了 `Vector2i`，要確認 `_arr_canon` 穩定；R² 點 6 條件②）。
  - F1-pop：子隊、玩家隊、沒隊長的隊都不掛（R² M5）。
- **F1b 營地上真的開工**（R² S4）：有營地、帶夠料的隊，N 天內 `TASK_BUILD` 開工（走紮根）；同時 `goal.found.camp_via_rooting` > 0、營地目標沒有出執行候選。
- **F2 有據點、帶夠料當天走**：有據點、帶 ≥ 成本的料、選址有效 ⇒ 同一天內出現執行候選並派出（`funnel.build_gate.dispatched` +1），派出人數 ＝ `plan.crew`。
- **F3 平原先買再走**：目標在平原、料 0、有料市場、有錢 ⇒
  - (a) 沒有執行候選，`goal.found.wait_material` > 0；
  - (b) `need_keep(material)` 含整筆成本，買料候選出現；
  - (c) 料買夠後出現執行候選並派出；
  - (d) 派出後母隊 `need_keep(material)` 回到不含這筆（S2）。
- **F4 沒掛的隊不守料**：同一世界、沒掛 `found_outpost` 的隊，`need_keep(material)` 修前後相同。
- **F5 重驗五事件**：每一種各造一次，對帳式成立（加總＝檢視次數）。另加兩個反例格，該走 `kept`（R² M4）：
  - 自己的子隊在目標格施工 ⇒ 不是 `site_taken`；
  - 自己的子隊把目標格蓋成據點 ⇒ 是 `built`，不是 `site_taken`。
  - 再造一格 `replaced` 與 `site_taken` 同時成立 ⇒ 記 `site_taken`（優先序）。
  - 兩個反例格要用**真實的派遣、開工、落成、解散流程**造，不手設 `outpost_owner`／`construction_team_id`（R²b S3）。並印落成當 tick 謂詞的輸入值：工地與據點的 owner id、母隊 `subteam_ids`、子隊還在不在。子隊若先解散、owner 還是子隊 id，那一刻會被誤判成 `site_taken`；這一格就是要抓它。
- **F6 決策端退場**：`scripts/simulation/` grep，「擴點」option、`can_expand`、infra 段 (3)、③ 遠端開點各 0 處；「紮根」option 三支 applicable 都還在。
- **F7 失敗的嘗試沒有世界寫入**：讓 `plan` 不成立 ⇒ `state.persons.size()` 與 `named_members.size()` 嘗試前後相同。`_dispatch_builder` 與 generic 分支（紮根委派變體）各驗一次。
- **F9 候選端與派遣端同一支 `plan`**（R² M7）：
  - **單隊構造床**：三支隊 pop = 1／3／40，有據點、選址有效。逐支斷言「候選端有沒有執行候選」與 `plan.ok` 一致；pop = 1 那支 `reason == no_crew`。
  - 進場計數：`founding_crew.plan.call` > 0（候選端與派遣端各一顆鍵），`dispatch_builder.attempt` > 0。任一為 0 ⇒ 本格不算過。
  - 電池補充：六個世界 30 天，`funnel.build_gate.*` **依 reason 分列**；`no_crew`／`value_nonpositive`／`site_barren`／`food_bridge` 四鍵在派遣端應為 0；`in_flight`／`tile_occupied` 列出但不設 0（同 tick 別的路徑可能改了世界，列出來看）。同一隊同一格連續失敗最長串**依 reason 分列**印出（修前 pop 門 51）。
- **F8 量測（電池世界 30 天；修前＝本票 merge 前的 main）**：
  - 新據點蓋成數按地形分列，修前修後並排；**戰國世界 20000 tick 新據點 > 0**（結構輪後是 0）。
  - 掛 `found_outpost` 的隊佔幾成；這些隊平均持有的料，對比沒掛的隊。
  - `goal.found.*` 各事件次數。
  - 絕境隊（food_days < 3）在營地上的開點次數，修前修後（§五：應相同）。
  - 派出子隊的 `crew` 分布、派完母隊人數分布；1–3 人小隊派出的次數單獨列。
  - R² 點 2：構造三支有據點的隊，pop 20／40／80，印 `score(n)` 全曲線與 argmax n。
  - **payoff 量級**（R²b S1）：開點列的 `x = payoff / _unit` 值分布，與維持列、設施列並排，並印 `gu2.payoff_val`。
    - 理由：開點列的 payoff 是整段視野的現值，別的列是一次性缺口×價。兩者都是「一筆量 × 價」，單位相同；但開點列的 `x` 可能長期 ≫ 1、貼在 `GOAL_UTIL_CAP` 附近，失去可比性（`goal_resolver.gd:1622-1623` 的舊病）。
    - 若貼頂（開點列 `x` 中位數 > 其他列的最大值），交件信照實寫、不自己調；那是 `_candidate_util` 共用壓縮的問題，回系統另判。
  - **能開點的隊的母體**（R²b N2）：「掛得上 `found_outpost` 的隊 ÷ 有據點且自主的隊」比例；對照修前「③④ 產出建點嘗試的隊」佔同一母體的比例。
  - 同一目標格同時有幾支在途子隊（R² M5，④ 退場後各隊各選）。
  - **perf**：HOB 量測協議，修前修後同一 checkout 比 per-tick（`reference_hob_perf_protocol`），特別看 `INFRA_INTERVAL` 那一拍。
- world-fp 會變（開點的決策端換了）。換基準前印新舊值，首分歧點逐條對到本票哪一節。

## 負對照（各紅在該紅的格）
| 注射 | 該紅 |
|---|---|
| m1 掛的條件改成讀 `otile`（沒據點不掛） | F1 |
| m2 執行候選的 delay 固定加 1 天 | F2 |
| m3 `new_outpost_commitment` 不看 goal | F3(b) |
| m4 goal 那一種對所有隊都回整筆（不看有沒有掛） | F4 |
| m5 重驗少一個事件（`replaced` 併進 `kept`） | F5 對帳式 |
| m5b「自己的」只認本隊、不認子隊 | F5 反例格 |
| m6 「擴點」option 留著 | F6 |
| m7 升人移回 `plan` 之前 | F7 |
| m8 候選端不呼 `plan`（只派遣端呼） | F9 單隊床：pop = 1 那支候選端有候選、派遣端 `no_crew` |
| m9 營地目標也出執行候選（走目標迴圈） | F1b（`camp_via_rooting` = 0） |

## 範圍外
- 玩家開點路（不走目標迴圈）。
- 搭營地（L0）；TASK_SETTLE 委派的 `clampi` 配額。
- 「安頓」派子隊（`faction_ai_system.gd:899-900`，把人送進既有據點當居民，不是開點）：它仍讀 `MIN_PARENT_POP_AFTER_DISPATCH`，本票不動；常數註解改寫成只服務這一處。
- 多趟運料。
- 選址秤讀遠端現存量（§二感知）：藍圖裁「不算隊伍能知道的事」，另開一張小票，排在本票之後（選址評分只讀這支隊記得的或地形先驗，與估算器同源；腳下格照舊親見）。known_issues 已登。
- 「建設」「自救建田」的委派變體：不是開點，仍讀 `clampi(pop/4,2,5)` 與 `MIN_PARENT_POP_AFTER_DISPATCH`。交件信列 `MIN_PARENT_POP_AFTER_DISPATCH` 剩幾處讀它、各屬哪一類。
- 成交與市場深度（貿易深層批）。
- 「走回營地途中被勢力目標換走」（known_issues，回訪＝持守統一）。

## 交件信要列
- F8 全部數字；world-fp 新舊值與首分歧歸因。
- §二「感知」那一條：這一列讀到的遠端量，各標來源（先列 `resources`、`resource_cap` 兩讀）。
- ③ 遠端開點修前次數；產地值有沒有進選址秤。
- `expand_site_cached` 剩下的讀者。
- 舊床遷移表（§五）。
- 負對照 m1–m9 紅燈原文。
