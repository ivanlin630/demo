# 結構輪兩個探針：建點一支身體（含 L1 要材料、就地採）＋子隊到場一支身體 — HOW

> systems 2026-10-16。
> WHAT：
> - 藍圖 2026-10-14-blueprint-to-systems-RULING-structure-round-before-deep-batch-one-verb-one-body-events-carry-source（結構輪範圍五條、探針兩個、停損）。
> - 藍圖 2026-10-14-blueprint-to-systems-TICKET-L1-needs-material-gathered-on-site-and-three-entries-merge-into-one-verb（用戶裁「L1 要材料」、就地採不是備料、三入口一個動詞）。
> 狀態：R² ISSUES（2026-10-16-reviewer-to-systems-R2-structure-round-probes-build-and-subteam-arrival-ISSUES）M1–M6 已補；R²b（2026-10-16-reviewer-to-systems-R2b-…-ISSUES）M7＋三條備註已補，審查註明補完不需再審 ⇒ GO。平原新點採不夠料那個後果已轉藍圖（見 §給藍圖）。
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
- 材料採集量（`_collect_from_tile` :390 起算，material 乘工程在 :403-404）：
  `productivity × current × COLLECT_RATE × day_fraction × outpost_mult × labor_mult × labor_share × work_morale × (1 + 工程 × 0.3)`。
  - `labor_mult`：格的 `labor_alloc` 有這個工位才讀它，否則中性 `LaborSystem.LABOR_SCALE`＝1.0（:393-395）。L0 工地格 `labor_alloc` 是空的 ⇒ 中性。**人數不在這條式子裡**。
- 回生（`resource_system.gd:148-178 regenerate_tiles`）：material 每次呼叫加 `REGEN_RATE[terrain].material`，**不乘 day_fraction**（:151 註解、:174）；這一步每小時跑一次（`sim_runner.gd:263` grp "hour"）。
  - ⇒ 每日回生＝24 × 平原 0.5／森林 12／山地 2，遠大於各自的上限（`world_generator.gd:9-11`：平原 5-20、森林 80-220、山地 30-100）。
  - ⇒ **材料池實際上一直貼著上限**。採料速率 ≈ `productivity × cap × COLLECT_RATE` 每日，不會「池小採得慢、靠回生補」。
  - 量級（審查端用區間中點估）：森林約 6.8／日、山地約 2.3／日、平原約 0.7／日 ⇒ 缺 50 料：森林約 7 日、山地約 22 日、平原約 72 日。
- 逾時取消（`outpost_system.gd:66-86`）：窗＝3 × 預期工期，夾在 5～30 日；`start_pop` 還沒凍結時直接回上限 30 日（:81-84）。
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
- 移居判準：
  - 玩家：`PlayerCommandSystem.own_outpost_reason`（`player_command_system.gd:2529-2539`）＝格有據點（level>0）且主人是自己，或主人同勢力且勢力≠-1。出發前（:2521）與到場（`faction_ai:4377`）呼同一支。
  - NPC（:4176-4179）：主人存在且 `faction_id` 相同（兩邊都是 -1 也算）、不看 level、**沒有「到了」的判斷**——途中每一 tick 都判腳下那格；「未到不動」靠的是途中格剛好不是同勢力據點。
- 玩家派子隊建設出發前的材料門：`precheck_subteam_build`（`player_command_system.gd:2542-2563`，`afford_shortfall`）。

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
  - 抵不完的部分記進 `construction_target["gather_left"]`，並記 `construction_target["need"]`（成本表那一列的材料數，玩家面與持守讀它）。**只有 material 可以進 gather_left**；其他資源（只剩 L2+ 軍用的 tools）抵不完 ⇒ 開工回 false（升級才會遇到，本票不改）。
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
- **料的帳**：採到的料從 tile（`pool_set` reason `"site_gather"`）進 `site_stock`，不在任何 bank。完工時消耗、逾時時退一半。實作端確認有沒有材料守恆的稽核會把它看成憑空消失；有的話給「完工消耗」「逾時退料」各一個具名 reason，沒有就在交件信寫「沒有」。
- **其他材料門一起退**（M5）：
  - `player_command_system.gd:2542-2563 precheck_subteam_build`：只留格子三條（不在地圖、已有據點、正在施工），拿掉 `afford_shortfall` 那段。出發回句改走 §四 的「需材／帶料抵／可採約」。
  - `:1419`「無法建造（資源不足）」：`start_build` 不再因料回 false，改印真因（已有據點／正在施工；L2+ 軍用缺工具時才是資源）。
  - `outpost_system.gd:960-965` 的 tap 註解把 `start_build` 列為 `afford.short.<site>` 的呼叫點，同步改註解與對帳說明。

### 二、採段：在 `_tick_construction` 裡，築段之前
- 有施工隊在格、`gather_left.material > 0` ⇒ 這一 tick 只採、不築：
  - `gain = ResourceSystem.material_gain(tile, team, day_fraction, outpost_mult=1.0, labor_mult=LaborSystem.LABOR_SCALE, labor_share=1.0)`
  - `gain = min(gain, tile 材料現量, gather_left)`
  - `TileBank.pool_set(tile, "material", 現量 - gain, "site_gather")`
  - `gather_left -= gain`、`site_stock += gain`
  - `gain > 0` 才刷新 `construction_last_progress_tick`（池被別人採光時照既有停工逾時）。
  - `ticks_left` 不動。
  - **採段期限**（M2）：池一直貼上限 ⇒ 每 tick 的 gain 都 >0 ⇒ 停工逾時永遠不響。所以另設期限：
    - `OutpostSystem.gather_window_days()`＝`CONSTRUCTION_TIMEOUT_CEIL_DAYS`（30 日），不新增旋鈕。
    - `gather_left > 0` 且 `今 tick − construction_started_tick > gather_window_days × TICKS_PER_DAY` ⇒ 取消，走既有退料（退 `site_stock` 50%），Probe `construct.gather_abort`。
    - 落點：寫在 `check_construction_timeout`（`outpost_system.gd:749`，掃 tile、不看隊在不在），不寫在 `_tick_construction`（它在無施工隊時早退 :383-400，隊被召走的工地會看不到期限）。
    - 估算器的上限讀同一支（§三）⇒ 估算器回 INF ⇔ 實跑會在窗內取消。
    - 30 日是「採多久算蓋不成」，屬 WHAT 邊緣，已轉藍圖（§給藍圖）。藍圖改值只動這一支。
  - 開始採之前凍結 `start_pop`（同築段 :416 那行，移到採段之前），讓採段期間 `construction_timeout_days` 也有值。
- `gather_left == 0` ⇒ 照今天築（`ticks_left -= pop × 體力`）。
- **`ResourceSystem.material_gain` 是從 `_collect_from_tile` :386-404 抽出來的純函式**：
  - 只算 material 那一支的係數：`productivity × current × COLLECT_RATE × day_fraction × outpost_mult × labor_mult × labor_share × work_morale × (1+工程×0.3)`。
  - `_collect_from_tile` 的 material 分支改呼它。**既有採集逐數不變**，G7 world-fp 對照咬這條；fp 若因此變了，就是抽錯。
  - 工程技能讀施工隊隊長，同 `_collect_from_tile` 的呼叫端（:107）。
- `day_fraction`＝`1.0 / OutpostSystem.build_ticks_per_day()`（:172-177，`build_eta_days` 已用同一支）。`_tick_construction` 的簽名不帶 day_fraction，不要另外傳。
- **人數不進採段**。今天的採集物理在非工位格就是這樣（:400 中性 `LABOR_SCALE`）。要讓人數進來是改採集物理，不在本票。交件信寫明。
- 回生照既有 tile 回生（每小時一次、不乘 day_fraction），採段不另算。
- Probe：`construct.gather_ticks`、`construct.gather_done`（採段轉築段）、`construct.gather_abort`，以及 `construct.gathered` 累計量（`add_amount`）。V8 靠它們分辨「真的採了」與「每個都帶夠料」。
- 採集期間施工隊在 L0 格上，`resource_system` 不會另外採材料（:82 那一支只做營地覓糧），所以不會重複入帳。

### 三、估算器同源：`OutpostSystem.build_eta_total_days`
- 新函式 `build_eta_total_days(type, level, pop, carried_material: float, site: Dictionary) -> float` ＝ 採段天數 ＋ `build_eta_days(build_person_hours(type, level), pop)`。
  - 採段天數（貼上限模型，R² M1 選 a）：`need_left = max(need - carried, 0)`；`每日量 = ResourceSystem.material_gain(..., current = cap, day_fraction = 1.0)`；`天數 = need_left / 每日量`。
  - 不模擬回生。前提「池一直貼上限」寫進函式註解，並由床 V6b 證明（停採 24 小時，池回到 cap）。
  - 天數 > `gather_window_days()` ⇒ 回 `INF`（同 §二 執行端的期限）。
  - **禁手抄**：估算器裡不得出現 0.05、12.0 這類數字，只能呼叫 `material_gain` 與 `site_prior`。
  - 進行中的工地也用它：`carried` 傳 `site_stock`，need 讀 `construction_target["need"]`（剩下的就是 `gather_left`）。
- `site` 的來源（感知鐵律）：
  - **站在那一格上**（紮根、玩家建設、玩家紮根）：讀腳下真值＝親見。
  - **遠端選點**（`_dispatch_builder`、`decision_context` 與 `goal_resolver` 估新點的地方）：隊的格記憶沒有材料存量 ⇒ 讀**地形先驗**。
    - `OutpostSystem.site_prior(terrain)` 只回 `{cap, productivity}`：cap 取 `world_generator.RESOURCE_PROFILE[terrain].material` 區間中點，productivity 取 `PRODUCTIVITY_RANGE` 中點。估算器不得自己再讀那兩張表。
    - 先例：`decision_context.gd:908/925` 以地形當公共地理估新點。這是「森林有木頭」那種常識，不是真值。
    - 誠實限：被採光的格、老林（`world_generator` 覆寫）的格，先驗會錯；錯了 ⇒ 隊到場後被採段期限取消。交件信印 `construct.gather_abort` 次數。
- 改讀新函式的呼叫點（凡是估「一座還沒開工的新點」的）：`decision_context.gd:876/915/931`、`goal_resolver.gd:1587`、`faction_ai_system.gd:5544`。
  - `:6702` 實作端讀過再判，在交件信說它估的是什麼。
  - **`persist_strength.gd:95`（糧門）改讀 `build_eta_total_days`**（M3）：採段期間 `ticks_left` 還是整張 720，只讀它就看不到 7～22 日的採段 ⇒ 隊以為糧夠、不放手。
    - `site` 參數：隊站在工地上 ⇒ 腳下真值；隊離開（`corvee_site` 那條路）⇒ `site_prior`。
  - **`persist_strength.gd:111-113`（`_progress`）**：分子分母都含採段。總量＝採段天數＋築段天數，已完成＝`site_stock` 對應天數＋已築天數；實作端寫成一支 `OutpostSystem.construction_progress(tile)`，不在 persist 裡另算。
  - `outpost_system.gd:85`（停工逾時的預期工期）不改；採段由 §二 的期限另管。
- `_dispatch_builder` 的材料閘（`:5497-5517`，`BuildAfford.shortfall` 那段＋`funnel.build_gate.cost*`）**退場**。
  - 糧橋的 `_eta_build`（:5544）改用 `build_eta_total_days`。路遠、地禿 ⇒ ETA 長 ⇒ 要的糧多 ⇒ 糧橋本來就會拒——這是物理，不是新門。
  - `INF` ⇒ 記 `funnel.build_gate.site_barren` 並回 false（同族計數，六道閘照樣能相加對帳）。
  - **撥料量抽成一支純函式**（R²b M7）：`FactionAISystem.fundable_carry(vault, owner_res, sub_res, cost) -> {res: 量}`。`_fund_subteam_from_vault`（:5973-5985）與 `:5960-5965` 的撥料改呼它；糧橋前的估算（:5544）也呼它，`carried_material` ＝它回的 material。
    - 理由：估算在撥料（:5564）之前。傳 0 ⇒ 母隊庫存夠的平原派遣也被判 `site_barren`；實際撥料後 `gather_left` 是 0。
    - 禁止估算端另寫一份 `min()`。
  - 刪 **`BuildAfford.shortfall` 這個函式**（非 debug 碼只有 :5500 呼叫）。`BuildAfford` 這個檔留著：`can_afford` 還有 `faction_ai_system.gd:5662/5998/6503/6598` 四處、`:3218` 讀 `MARGIN_MAX`、`build_afford_persona_test.gd`。

### 四、玩家面
- 紮根與建設的回句：「開始建 {名}：需材 {N}，帶料抵 {K}，腳下可採約 {M} 天，之後築約 {D} 天」。
  - `M` 用 `build_eta_total_days` 的採段那一半（站在格上 ⇒ 真值）；`M=INF` ⇒「腳下的料 {窗} 天內採不夠，不帶料會被取消」，開工照樣成立（不擋）。要蓋得成就開工前帶料；開工後再搬料進工地的動作不在本票。
  - 拿掉「免材料」字樣（`player_command_system.gd:1100` 一帶）。全庫 grep「免材料」，床同 commit 改。
  - 玩家派子隊建設（`precheck_subteam_build`）的出發回句同一套，`M` 讀遠端先驗（子隊還沒站上去）。
- 頂列進度分兩段：mapper 的工地資料加 `phase`（`"gather"`／`"build"`）、`gather_left`、`site_stock`。UI 印「採料 {site_stock}/{need}」或「建造 {百分比}」。顯示點由實作端 grep 現在印施工進度的地方，兩處以上一起改。

### 五、子隊到場一支身體：`SubteamSystem.on_arrival(state, sub) -> Dictionary`
- 回 `{outcome: "done"|"refused"|"none", reason: String}`。**只做世界動作，不發事件、不 release、不排併回**（那些是腦的事）。
  - CAMP：`FactionAISystem.establish_crude_camp(state, sub)`；false ⇒ `refused`，reason 用它今天的拒因。
  - SETTLE（M6）：**直接用既有那一支** `own_outpost_reason`，不寫第三份。
    - 把它從 `PlayerCommandSystem` 搬到 `SubteamSystem.settle_refuse_reason(state, team, pos)`（不依賴玩家層）；`PlayerCommandSystem.own_outpost_reason` 刪掉，出發前（:2521）與 `on_arrival` 都呼新位置。
    - 母隊不存在時，用子隊自己的 `faction_id` 比（不要一律 refused）；母隊在就照今天用母隊。
    - `""` ⇒ `_convert_to_resident` ⇒ `done`；否則 `refused`，reason 就是它回的字串。
    - 玩家側沒有行為改變（今天就收同勢力）。
    - **NPC 側的行為改變**（列進交件信，新舊結果並排）：獨立隊（faction -1）的子隊不再能移居到別的獨立隊據點；要求 `outpost_level > 0`；母隊已亡時照子隊勢力判。
  - CONSTRUCT／UPGRADE／EXPAND：`none`。開工已經是一支（movement 抵達 → `begin_subteam_construction`），不重複。
  - 其他任務：`none`。
- 呼叫端（腦）只決定留或回：
  - 玩家 `_tick_player_subteam` 的 CAMP／SETTLE 兩支改成：呼 `on_arrival`；`refused` ⇒ 發原本的事件＋release（照今天）；`done` ⇒ CAMP release（照今天）。
  - NPC `:4171-4180` 改成：**先加「到了」的門**（M4）——`sub.move_target != Vector2i(-1, -1)` ⇒ return，同玩家側 :4365-4366。到了才呼 `on_arrival`；`refused` ⇒ release＋進 `merge_queue`（今天是什麼都不做、下一 tick 再判，等於永遠卡在 SETTLE 等一個可能不會回來的主人）。
    - ★NPC 側兩個行為改變，都是刻意的：
      - 到了、住不進去 ⇒ 回母隊。
      - 今天 NPC 移居子隊**途經**自家勢力據點也會當場轉居民；加門之後只在目的地轉。
- Probe 進場計數：`subteam.arrival.{camp,settle}.{done,refused,none}`，NPC／玩家分鍵或分 sample 欄位。交件信從這裡讀 `refused` 次數。
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
- **V5 池被採光**：池 0 且停回生（床內直接設）⇒ 不刷新 `last_progress` ⇒ 停工逾時取消，退 `site_stock` 的 50%。
- **V5b 平原蓋不成**（M2）：真平原格（生成的 cap 與 productivity）、need 50、帶 0 ⇒ `build_eta_total_days == INF`；實跑 ⇒ 在 `gather_window_days` 內被取消（`construct.gather_abort` +1），退 `site_stock` 的 50%。
- **V6 估算器同源**：V1 佈置（森林）的採段天數，估算值與實跑天數差 ≤1 日。地板格印兩個數。
- **V6b 池貼上限**：採走一半後停採 24 小時 ⇒ 池回到 cap；回補量＝回生呼叫次數 × `REGEN_RATE`（鎖單位）。這格守住估算器「不模擬回生」的前提。
- **V7 完工一支**：
  - 營地格（`camp_level=1`）完工 ⇒ 營地四欄清掉、food cap ≥40、有 `outpost_built` 訊息、owner 對、主隊被 release。
  - 非營地格完工 ⇒ 營地欄不被碰。
  - NPC 子隊 ⇒ `_auto_settle_builder` 有跑（tag）。
- **V8 派子隊這條路活了**（量測，不是床）：電池世界 30 天：
  - `funnel.build_gate.cost` 鍵不存在；
  - **按目標地形拆**：平原／森林／山地各一列，印 attempt、派出、`site_barren`、開工、`construct.gather_ticks`、`gather_abort`、完工。
  - 過關＝森林或山地至少一列「派出 > 0 且 `gather_ticks > 0`」（後者排除「每個都帶夠料、採段從沒跑」）。
  - 平原若 100% `site_barren`：不算 bug，是 §給藍圖 那個後果；照實印出。
  - 全部地形派出都是 0 ⇒ 不算過，停下回報（NPC 選址若幾乎只挑平原，就會這樣——那也是藍圖要看的）。
  - 修前（81／81 倒在材料閘）並排。
- **V9 玩家面**：玩家紮根回句含「需材」「可採約」，不含「免材料」；頂列 `phase` 兩段印得出來。
- **G9 玩家優先序**：玩家紮根、建設之後，施工中 `task_priority == PRIO_PLAYER`。
- **V8b 撥料與估算同源**（M7）：同一個平原目標，母隊庫存 0 ⇒ `site_barren`；庫存 ≥ need ⇒ 過這道閘、子隊開工時 `gather_left == 0`。
- **V10 玩家子隊建設不擋料**（M5）：玩家子隊帶 0 料派往森林格 ⇒ `precheck_subteam_build` ok，回句含「需材」「可採約」。
- **P1 持守看得到採段**（M3）：同一支隊、`food_runway` 固定，兩個進行中工地：`gather_left=0` 與 `gather_left=need` ⇒ 後者 `safe_factor` 較小、`_progress` 較小。

### 子隊到場（同床，S 開頭）
- **S1 同佈置兩種子隊同結果**：NPC 子隊與玩家子隊各一支，SETTLE 到：①母隊的據點 ⇒ 兩邊都 `done`；②同勢力別隊的據點 ⇒ 兩邊都 `done`；③外勢力據點 ⇒ 兩邊都 `refused` 且 reason 相同；④獨立（faction -1）NPC 子隊到另一獨立隊的據點 ⇒ `refused`（今天會轉，新舊並排印）；⑤母隊已亡、同勢力據點 ⇒ `done`。
- **S2 CAMP**：空地 ⇒ `done`；已有營地的格 ⇒ `refused`。玩家側 `refused` 有發 `camp_refused` 事件。
- **S3 寫入點**：子隊路徑上呼 `_convert_to_resident`、`establish_crude_camp` 的只剩 `on_arrival`（grep `faction_ai_system.gd` 的子隊段）。
- **S4 NPC 住不進去就回**：S1 ③ 的 NPC 子隊在下一 tick 進 `merge_queue`。
- **S5 途中不判**（M4）：NPC SETTLE 子隊 `move_target ≠ (-1,-1)`，連續 N tick 站在外勢力格與自家勢力據點格 ⇒ 仍是 TASK_SETTLE、不在 `merge_queue`、沒有轉居民。

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
| n8 NPC SETTLE 不加「到了」的門 | S5 |
| n9 採段每 tick 都刷新 `last_progress`（不看 gain>0） | V5 |
| n10 執行端不加採段期限 | V5b |
| n11 `persist_strength` 只讀 `ticks_left` | P1 |
| n12 `on_arrival` SETTLE 改回舊 NPC 判準（`faction_id` 相等，含 -1 == -1） | S1 ④ |
| n14 糧橋估算 `carried` 傳 0（不呼 `fundable_carry`） | V8b 後者 |
| n13 `precheck_subteam_build` 留著料門 | V10 |

## 給藍圖（已另寄）
- L1 要材料＋就地採＋現在的生成上限 ⇒ 新點只有森林（約 7 日）、山地（約 22 日）採得夠；平原約 72 日，超過 30 日採段期限 ⇒ 不帶料就蓋不成。
- 這是 WHAT 後果，不是 bug：農地開不出新點，除非先備料。NPC 選址偏農地（`decision_context.gd:868`）⇒ V8 可能大半倒在 `site_barren`。
- 規格照現值寫（期限 30 日、不連動選址）；藍圖若要改，只動 `gather_window_days` 或選址的估值，身體不變。

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
- `corvee_site` 讀點的逐一判斷（以實際 grep 為準，一行一個）。`decision_context.gd:831-835` 的 recovery（有 corvee_site 就 `settle_resume_site`）會多吃「主隊建設」這一類來源，那一格要寫判斷。
- `:6702` 估的是什麼、改了沒有。
- `BuildAfford.shortfall` 刪了沒有，沒刪的話誰在用。
- 電池裡 `subteam.arrival.*` 各鍵次數（NPC `refused` 單獨列）。
- 三種地形缺 50 料的採段天數（用真函式、真先驗算），給藍圖。
- world-fp：抽取那輪（應不變）與全量那輪的新舊值、兩輪 run-id。
- n1–n7 紅燈原文。
