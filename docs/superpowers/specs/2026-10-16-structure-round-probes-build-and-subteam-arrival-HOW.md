# 結構輪兩個探針：建點一支身體（含 L1 要材料、就地採）＋子隊到場一支身體 — HOW

> systems 2026-10-16。
> WHAT：
> - 藍圖 2026-10-14-blueprint-to-systems-RULING-structure-round-before-deep-batch-one-verb-one-body-events-carry-source（結構輪範圍五條、探針兩個、停損）。
> - 藍圖 2026-10-14-blueprint-to-systems-TICKET-L1-needs-material-gathered-on-site-and-three-entries-merge-into-one-verb（用戶裁「L1 要材料」、就地採不是備料、三入口一個動詞）。
> 狀態：待 R²。
> 位置：玩家可見批（真玩小修、我的掛單與押貨、玩家勢力目標）之後，深層批之前。
> 本票只做兩個探針。結構輪第 ③④ 條（玩家事件帶來源、子隊事件走信使）是下一張，不在本票。

## 現況（main 0d0546e33，file:line 本輪已讀）

### 建點：三個入口、兩個價、兩支開工函式
| 入口 | 路徑 | 價 | 開工函式 |
|---|---|---|---|
| NPC 紮根 | `faction_ai_system.gd:7277 _commit_settle_site` → `:7320 start_settle_construction` | 免材料，工期 `build_person_hours("settle",1)`＝720 | `start_settle_construction`（寫 `action:"crude_camp"`） |
| 玩家紮根 | `player_command_system.gd:1089 _action_settle` → 同上 `:1098` | 同上 | 同上 |
| NPC 派子隊 | `faction_ai_system.gd:5446 _dispatch_builder`（六道閘，含 `:5500` `BuildAfford.shortfall` 材料閘）→ 抵達 `movement_system.gd:497` → `outpost_system.gd:801 begin_subteam_construction` → `:572 start_build` | `OUTPOST_COST` L1 民用 50 材料；軍用 80 材料＋3 工具 | `start_build`（寫 `action:"build"`） |
| 玩家建設 | `player_command_system.gd:1412 _action_build_outpost` → `start_build` | 同上 | 同上 |
| 玩家派子隊建設 | `player_command_system.gd:1515-1517`（腳下）／抵達 → `begin_subteam_construction` → `start_build` | 同上 | 同上 |

- `start_build`（`outpost_system.gd:572-603`）：`_can_afford` 不夠就回 false（硬門）；夠就 `_deduct_cost` 一次扣完。
- 兩支的完工分支不同（`outpost_system.gd:_complete_construction`）：
  - `"build"`（:440-469）：設型別與等級、`set_owner`、發 `outpost_built` 訊息、礦山 Probe、NPC 子隊 `_auto_settle_builder`。
  - `"crude_camp"`（:482-504）：設型別、L1、`set_owner`、food cap 抬到 40、清營地欄（`camp_level`／`camp_team_id`／`camp_ticks_left`、`OwnerCampIndex.invalidate`）、清 `corvee_site`、加型別 tag、去「流亡」、`TaskArbiter.release`。不發訊息。
- 派子隊這條路量過：`founding-silence-recheck-30d` 81 次嘗試全倒在材料閘；`construction-funnel-team0-3` 26／26 同（藍圖票）。
- 採集物理（`resource_system.gd:82-121`）只在 `outpost_level>0` 的格跑 `_collect_from_tile`。L0 格只跑營地覓糧（:84-94）。**今天沒有任何一條路能在 L0 格採材料**——就地採需要新開一條。
- 材料採集量（`_collect_from_tile` :386-404 的 material 那一支）：
  `productivity × current × COLLECT_RATE × day_fraction × outpost_mult × labor_mult × labor_share × work_morale × (1 + 工程 × 0.3)`。
  - 非工位格的 `labor_mult` 用中性 `LaborSystem.LABOR_SCALE`＝1.0（:400）。**人數不在這條式子裡**。
- 回生：`ResourceSystem.REGEN_RATE`（:55-59）material：平原 0.5、森林 12、山地 2。生成池（`world_generator.gd:9-11`）material：平原 5-20、森林 80-220、山地 30-100。
- 逾時取消（`outpost_system.gd:748-781`）退 `construction_cost_of(tile)` 的 50% 給施工隊；`construction_cost_of` 對 `"crude_camp"` 回 `{}`（不退）。
- 估算器讀工期的地方（`build_eta_days(` 呼叫點）：
  - `decision_context.gd:876`（紮根 `settle_eta_days`）、`:915`、`:931`
  - `goal_resolver.gd:1587`
  - `faction_ai_system.gd:5544`（糧橋）、`:6702`
  - `persist_strength.gd:95`、`outpost_system.gd:85`（讀進行中的工地，不是估新點）
- 隊的格記憶（`belief_system.gd` 寫 `state.team_tile_known`）只記地形與據點，**不記材料存量**。

### 子隊到場：兩份「到了做什麼」
- 玩家子隊：`faction_ai_system.gd:4140` `if sub.player_controlled` → `_tick_player_subteam`（:4353-4384）。
  - CAMP：`establish_crude_camp`；失敗 ⇒ 發 `camp_refused`、release。
  - SETTLE：`PlayerCommandSystem.own_outpost_reason(母隊, 格)=="" ⇒ _convert_to_resident`；否則發 `settle_refused`、release。
  - CONSTRUCT 抵達逾時：發 `construct_timeout`、release、原地待命（不併回）。
- NPC 子隊：
  - SETTLE（:4171-4180）：格的據點主人存在且同勢力 ⇒ `_convert_to_resident`。**不成就什麼都不做**，下一 tick 再判。
  - CONSTRUCT 抵達逾時（:4158-4166）：release＋進 `merge_queue`。
- 兩邊的 CONSTRUCT 開工都走同一支 `begin_subteam_construction`（`movement_system.gd:497`、玩家腳下 `:1517`）——這一段已經是一支。
- 移居的判準兩份不同：玩家＝「母隊自己的據點」；NPC＝「同勢力的據點」。

## 改法

### 一、建點一支身體：`OutpostSystem.start_build`
- **刪 `FactionAISystem.start_settle_construction`**。兩個紮根入口改呼 `OutpostSystem.new().start_build(state, team, camp_type, 1, team.team_id)`。
  - NPC `_commit_settle_site` 的前置判斷（recovery、走回自己的營地、`root.commit_drop.*`）原樣留著。那是腦的「選」，不是身體。
  - 玩家 `_action_settle` 保留 `precheck_settle`；`start_build` 回 false ⇒ 回句照實。
  - ★順序照今天：先 `start_build`，再 `TaskArbiter.try_set(... PRIO_PLAYER, "player_settle")`。`start_build` 內部的 `transition(PRIO_DISPATCH)` 在前、玩家優先序在後蓋上。實作端確認玩家隊施工中的優先序仍是 `PRIO_PLAYER`（G9 那格咬它）。
- **全庫 `action:"crude_camp"` 退場**：
  - 寫入點：`faction_ai_system.gd:7322`。
  - 讀者：`outpost_system.gd:482`（完工）、`:742`（`construction_ticks_total`）。
  - 床：`s6_phase2_single_source_bed.gd:134/170/195`、`settlement_s2b_test.gd:59`。
  - 全部改成 `"build"`，同 commit。
- **成本表仍只有 `OUTPOST_COST` 一張**。
  - L1 民用 `{material:50}` 不動。
  - L1 軍用改 `{material:80, tools:0}`（今天是 tools 3）。理由：工具在腳下採不到，留著就是一道硬門，違反「成本就是時間、零硬門檻」。值是測試值。
  - L2／L3 不動（升級不在本票）。
- **開工不查有沒有料**（`action:"build"` 的開工）：
  - `need` ＝ 成本表那一列。
  - 帶來的料先抵：從施工隊私產扣 `min(帶的, need)`，逐種資源走 `ResourceBank`。今天 `_deduct_cost` 的公庫優先順序照舊——站在自己據點上時公庫先扣，新點沒有公庫就只扣私產。
  - 抵不完的部分記進 `construction_target["gather_left"]`。**只有 material 可以進 gather_left**；其他資源（只剩 L2+ 軍用的 tools）抵不完 ⇒ 開工回 false（升級才會遇到，本票不改）。
  - 實際放進工地的量記進 `construction_target["site_stock"]`（帶來的＋採到的，見 §二）。
  - 工期 `construction_ticks_left = build_person_hours(type, level)`。L1 兩型都是 720，等於今天紮根的工期，所以紮根的築段時間不變。
  - **`corvee_site`**：今天只有紮根會寫。改成身體一律寫 `team.corvee_site = tile.tile_pos`，**限定 `team.parent_team_id == -1`**（主隊）。子隊另有 `task_extra_data` 跟召回路，不寫。
    - `corvee_site` 有 30 個讀點，實作端逐一確認：多了「玩家／NPC 主隊建設」這種來源後，有沒有哪個讀點的假設會變。
- **完工只剩一支 `"build"` 分支**。原本兩支的副作用取聯集：
  - 一律：設型別與等級、`set_owner`（讀 `owner`，缺省＝施工隊）、`outpost_epoch`、`OwnerOutpostIndex.invalidate`、`outpost_built` 訊息、礦山 Probe、`food cap = max(現值, 40)`。
  - `tile.camp_level > 0` 才清營地四欄＋`OwnerCampIndex.invalidate`＋`outpost.l0_to_l1` Probe。
  - NPC 子隊（`parent_team_id != -1 and not player_controlled`）：`_auto_settle_builder`（照舊）。
  - 其他施工隊（主隊、玩家子隊）：加型別 tag、去「流亡」、`corvee_site` 是這格就清、`TaskArbiter.release(team, "construction_done")`。
    - 玩家子隊今天走「原地待命等召回」，release 後仍站在原地，結果一樣。實作端確認玩家子隊沒有被 release 改成別的任務。
  - ★world-fp 會變（紮根完工多發一則訊息、建設完工多做 release 與 tag）。這是預期的改變。
- **逾時退料**：`"build"` 退 `site_stock` 的 50%（今天退成本表的 50%）。理由：開工不再一次扣滿，工地裡實際有多少料就退多少的一半。`construction_cost_of` 其他讀者不動。

### 二、採段：在 `_tick_construction` 裡，築段之前
- 有施工隊在格、`gather_left.material > 0` ⇒ 這一 tick 只採、不築：
  - `gain = ResourceSystem.material_gain(tile, team, day_fraction, outpost_mult=1.0, labor_mult=LaborSystem.LABOR_SCALE, labor_share=1.0)`
  - `gain = min(gain, tile 材料現量, gather_left)`
  - `TileBank.pool_set(tile, "material", 現量 - gain, "site_gather")`
  - `gather_left -= gain`、`site_stock += gain`
  - `gain > 0` 才刷新 `construction_last_progress_tick`。地採空了 ⇒ 不刷新 ⇒ 照既有逾時取消。這就是「蓋不成」，不另寫判斷。
  - `ticks_left` 不動。
- `gather_left == 0` ⇒ 照今天築（`ticks_left -= pop × 體力`）。
- **`ResourceSystem.material_gain` 是從 `_collect_from_tile` :386-404 抽出來的純函式**：
  - 只算 material 那一支的係數：`productivity × current × COLLECT_RATE × day_fraction × outpost_mult × labor_mult × labor_share × work_morale × (1+工程×0.3)`。
  - `_collect_from_tile` 的 material 分支改呼它。**既有採集逐數不變**，G7 world-fp 對照咬這條；fp 若因此變了，就是抽錯。
  - 工程技能讀施工隊隊長，同 `_collect_from_tile` 的呼叫端（:107）。
- `day_fraction`：用 `_tick_construction` 實際呼叫的間隔。實作端讀它的呼叫端：每 tick 叫就是 `1/TICKS_PER_DAY`；隔 N tick 叫就用 N 去除，不要寫死。
- **人數不進採段**。今天的採集物理在非工位格就是這樣（:400 中性 `LABOR_SCALE`）。要讓人數進來是改採集物理，不在本票。交件信寫明。
- 回生照既有 tile 回生（`REGEN_RATE`），採段不另算。
- 採集期間施工隊在 L0 格上，`resource_system` 不會另外採材料（:82 那一支只做營地覓糧），所以不會重複入帳。

### 三、估算器同源：`OutpostSystem.build_eta_total_days`
- 新函式 `build_eta_total_days(type, level, pop, carried_material: float, site: Dictionary) -> float` ＝ 採段天數 ＋ `build_eta_days(build_person_hours(type, level), pop)`。
  - 採段天數：`need_left = max(need - carried, 0)`。逐日模擬：每日用**同一支** `ResourceSystem.material_gain`（day_fraction＝1）採，再加**同一份** `REGEN_RATE[terrain].material` 回生（cap 照 site 的 cap）。
  - 跑到 `need_left` 歸零為止。上限＝該工地的逾時窗（`construction_timeout_days` 的同一個 k）；到上限還沒採夠 ⇒ 回 `INF`。
  - **禁手抄**：估算器裡不得出現 0.05、12.0 這類數字，只能呼叫那兩個真相源。
  - 回生若在 tile 回生系統裡是 inline 寫的，抽成 `ResourceSystem.regen_step(terrain, current, cap, days)` 給兩邊共用。
- `site` 的來源（感知鐵律）：
  - **站在那一格上**（紮根、玩家建設、玩家紮根）：讀腳下真值＝親見。
  - **遠端選點**（`_dispatch_builder`、`decision_context` 與 `goal_resolver` 估新點的地方）：隊的格記憶沒有材料存量 ⇒ 讀**地形先驗**。
    - 池與 cap 取 `world_generator.RESOURCE_PROFILE[terrain].material` 區間中點。
    - productivity 取 `PRODUCTIVITY_RANGE` 中點。
    - 這是「森林有木頭」那種常識，不是真值；測試值，寫在一支 `OutpostSystem.site_prior(terrain)`。
- 改讀新函式的呼叫點（凡是估「一座還沒開工的新點」的）：`decision_context.gd:876/915/931`、`goal_resolver.gd:1587`、`faction_ai_system.gd:5544`。
  - `:6702` 實作端讀過再判，在交件信說它估的是什麼。
  - `persist_strength.gd:95`、`outpost_system.gd:85` 讀進行中的工地，不改。
- `_dispatch_builder` 的材料閘（`:5497-5517`，`BuildAfford.shortfall` 那段＋`funnel.build_gate.cost*`）**退場**。
  - 糧橋的 `_eta_build`（:5544）改用 `build_eta_total_days`。路遠、地禿 ⇒ ETA 長 ⇒ 要的糧多 ⇒ 糧橋本來就會拒——這是物理，不是新門。
  - `INF` ⇒ 記 `funnel.build_gate.site_barren` 並回 false（同族計數，六道閘照樣能相加對帳）。
  - `_fund_subteam_from_vault`／`:5960-5965` 的撥料不改形：今天就是 `min(need, 有的)`，帶多少算多少。
  - `BuildAfford.shortfall` 若沒有其他呼叫者 ⇒ 連檔一起刪；有 ⇒ 留著並在交件信列出呼叫者。

### 四、玩家面
- 紮根與建設的回句：「開始建 {名}：需材 {N}，帶料抵 {K}，腳下可採約 {M} 天，之後築約 {D} 天」。
  - `M` 用 `build_eta_total_days` 的採段那一半（站在格上 ⇒ 真值）；`M=INF` ⇒「腳下的料採不夠，蓋不成」，開工照樣成立（不擋，玩家自己決定要不要等或搬料）。
  - 拿掉「免材料」字樣（`player_command_system.gd:1100` 一帶）。全庫 grep「免材料」，床同 commit 改。
- 頂列進度分兩段：mapper 的工地資料加 `phase`（`"gather"`／`"build"`）、`gather_left`、`site_stock`。UI 印「採料 {site_stock}/{need}」或「建造 {百分比}」。顯示點由實作端 grep 現在印施工進度的地方，兩處以上一起改。

### 五、子隊到場一支身體：`SubteamSystem.on_arrival(state, sub) -> Dictionary`
- 回 `{outcome: "done"|"refused"|"none", reason: String}`。**只做世界動作，不發事件、不 release、不排併回**（那些是腦的事）。
  - CAMP：`FactionAISystem.establish_crude_camp(state, sub)`；false ⇒ `refused`，reason 用它今天的拒因。
  - SETTLE：判準一份 ⇒ 格的據點主人存在，且（主人＝母隊 **或** 主人同勢力且勢力≠-1）⇒ `_convert_to_resident` ⇒ `done`；否則 `refused`，reason 照實。
    - 這一份是兩份現有判準的聯集。對玩家，多出「同勢力別人的據點」可以移居；出發前的 `own_outpost_reason` 是玩家選單的前置判斷，不改。理由：到場判的是「這裡能不能住」，是物理；出發判的是玩家要什麼。
  - CONSTRUCT／UPGRADE／EXPAND：`none`。開工已經是一支（movement 抵達 → `begin_subteam_construction`），不重複。
  - 其他任務：`none`。
- 呼叫端（腦）只決定留或回：
  - 玩家 `_tick_player_subteam` 的 CAMP／SETTLE 兩支改成：呼 `on_arrival`；`refused` ⇒ 發原本的事件＋release（照今天）；`done` ⇒ CAMP release（照今天）。
  - NPC `:4171-4180` 改成：呼 `on_arrival`；`refused` ⇒ release＋進 `merge_queue`（今天是什麼都不做、下一 tick 再判，等於永遠卡在 SETTLE 等一個可能不會回來的主人）。
    - ★NPC 側行為改變，是刻意的：到了、住不進去 ⇒ 回母隊。交件信印電池裡 `refused` 的次數。
  - CONSTRUCT 抵達逾時的兩種處置（NPC 併回、玩家待命）是腦的差別，留在兩邊。
- 事件（`emit_player_subteam` 直發）不動，第 ③④ 條才改。

## 驗收

### 建點（新床 `build_verb_one_body_bed.gd`，註冊進 `merge-gates.tsv` 一列）
- **V1 三入口同數**：同一份佈置（森林格，材料池固定值，施工隊 pop 固定，帶 20 材料），分別走：NPC 紮根（`_commit_settle_site`）、玩家紮根、玩家建設、NPC 子隊抵達（`begin_subteam_construction`）、玩家子隊腳下派遣。
  - 五列的 `construction_target` 的 `action`／`type`／`level`／`gather_left`、`construction_ticks_left`、施工隊扣掉的材料，逐數相同。
  - `owner`：紮根／建設＝施工隊；玩家子隊＝母隊；NPC 子隊＝缺省。
  - 地板格印五列實數。
- **V2 寫入點只有一處**：`scripts/simulation` 內 grep `"action": "build"` 的寫入＝1 處；`start_settle_construction` 0 處；`"crude_camp"` 0 處。
- **V3 採段守恆、採段不築**：`gather_left>0` 的每一 tick，`ticks_left` 不變；`tile 材料減少量 == gather_left 減少量 == site_stock 增加量`。採完之後 `ticks_left` 開始減。
- **V4 帶夠就跳過採段**：帶 ≥ need ⇒ 開工當下 `gather_left == 0`，第一個推進 tick 就築。
- **V5 地禿蓋不成**：材料池 0、回生 0 的格（床內直接設 terrain 與池）⇒ `build_eta_total_days == INF`；實跑 ⇒ 逾時取消，退 `site_stock` 的 50%。
- **V6 估算器同源**：V1 佈置的採段天數，估算值與實跑天數差 ≤1 日。
  - 另佈一格讓回生參與（平原、池 5、need 50），同樣 ≤1 日。
- **V7 完工一支**：
  - 營地格（`camp_level=1`）完工 ⇒ 營地四欄清掉、food cap ≥40、有 `outpost_built` 訊息、owner 對、主隊被 release。
  - 非營地格完工 ⇒ 營地欄不被碰。
  - NPC 子隊 ⇒ `_auto_settle_builder` 有跑（tag）。
- **V8 派子隊這條路活了**（量測，不是床）：電池世界 30 天：
  - `funnel.build_gate.cost` 鍵不存在；
  - `dispatch_builder.attempt > 0` 且真的派出 > 0（`construct.complete_build` 中由子隊完成的 > 0，或至少開工 > 0）。
  - 派出 = 0 ⇒ 不算過。交件信印六道閘各自的數，跟修前（81／81 倒在材料閘）並排。
- **V9 玩家面**：玩家紮根回句含「需材」「可採約」，不含「免材料」；頂列 `phase` 兩段印得出來。
- **G9 玩家優先序**：玩家紮根、建設之後，施工中 `task_priority == PRIO_PLAYER`。

### 子隊到場（同床，S 開頭）
- **S1 同佈置兩種子隊同結果**：NPC 子隊與玩家子隊各一支，SETTLE 到：①母隊的據點 ⇒ 兩邊都 `done`；②同勢力別隊的據點 ⇒ 兩邊都 `done`；③外勢力據點 ⇒ 兩邊都 `refused` 且 reason 相同。
- **S2 CAMP**：空地 ⇒ `done`；已有營地的格 ⇒ `refused`。玩家側 `refused` 有發 `camp_refused` 事件。
- **S3 寫入點**：子隊路徑上呼 `_convert_to_resident`、`establish_crude_camp` 的只剩 `on_arrival`（grep `faction_ai_system.gd` 的子隊段）。
- **S4 NPC 住不進去就回**：S1 ③ 的 NPC 子隊在下一 tick 進 `merge_queue`。

### 舊床同 commit 改
- `s6_phase2_single_source_bed.gd`、`settlement_s2b_test.gd`：`crude_camp` → `build`；紮根「免材料、零扣料」的斷言改成「扣帶來的、餘數進 gather_left」。改的是被用戶裁掉的那個值（免材料→要材料），不是放寬。
- `construction_funnel_bed.gd:16/108`：`funnel.build_gate.cost` 鍵退場；改列 `site_barren`。
- 全庫 grep「免材料」「crude_camp」「start_settle_construction」，床裡出現的一起改。交件信列出改了哪些。
- 玩家子隊床（`player_subteams*`）照綠，斷言不改。

### world-fp
- 會變（§一 完工聯集、§二 新採段、§五 NPC 回併）。換基準前印新舊值，並在交件信逐條對應是哪一項造成的。
- ★先單獨落 §二 的 `material_gain` 抽取（純重構），跑一輪電池確認 fp **不變**，再落其他。抽取那一刀若讓 fp 變了 ⇒ 抽錯，停下回報。兩輪 run-id 寫交件信。

### 負對照
| 對照 | 該紅 |
|---|---|
| n1 `start_build` 放回 `_can_afford` 硬門 | V1（帶 20 < 50 的列開不了工） |
| n2 採段也減 `ticks_left` | V3 |
| n3 估算器採段寫死 0 天 | V6 |
| n4 留著 `start_settle_construction`、紮根照舊呼它 | V2、V1 |
| n5 完工拿掉 `camp_level>0` 那段 | V7 營地格 |
| n6 NPC SETTLE 不呼 `on_arrival`、保留 inline | S3、S4 |
| n7 `on_arrival` SETTLE 不看勢力（只看母隊） | S1 ② |

## 範圍外
- 玩家事件帶來源、子隊事件走信使、回報對象改母隊：結構輪第 ③④ 條，下一張。
- 升級（L2/L3）的材料改就地採：不在本票，`OUTPOST_COST` L2+ 不動。
- 人數進採集物理：採集物理的事，不在本票。
- 據點維護即物理：深層批，同一份成本物理的另一半。

## 動詞目錄
- 本票合進時，systems 把 `verb-catalog.md` 的「建點」「子隊到場執行」兩列改成：身體、呼叫者、床（`build_verb_one_body_bed.gd`）、狀態已併。

## 停損（藍圖）
- `faction_ai` 拆不出、或床紅收不回一週 ⇒ 實作端回報 systems，systems 回報藍圖，藍圖把「重開」交用戶裁。

## 交件信要列
- V1 五列實數、V6 估算與實跑天數兩組、V8 六道閘修前修後並排。
- `corvee_site` 30 個讀點的逐一判斷（一行一個）。
- `:6702` 估的是什麼、改了沒有。
- `BuildAfford.shortfall` 刪了沒有，沒刪的話誰在用。
- 電池裡 S 系列 NPC `refused` 的次數。
- world-fp：抽取那輪（應不變）與全量那輪的新舊值、兩輪 run-id。
- n1–n7 紅燈原文。
