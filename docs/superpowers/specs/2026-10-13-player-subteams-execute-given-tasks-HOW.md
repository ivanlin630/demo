# 玩家子隊真的做事（只做玩家給的任務）——HOW

狀態：收 R²（…-R2-player-subteams-ISSUES，兩擋已補；§2 §3 補完不需再審）
來源：QA 故事稽核判決 2026-10-13-qa-to-systems-subteam-dispatch-story-audit-VERDICT（trace `docs/measurements/2026-10-13-qa-subteam-dispatch-story-trace.txt`）；藍圖三裁 81a62871e（2026-10-13-blueprint-to-systems-RULING-player-subteams-execute-given-tasks-settle-split-build-chosen）
順位：玩家可見批，與派遣第二刀同批（fix/terminal-input-prompts 之後接著做；UI 修好了任務還不做事＝白修）。
意圖帳：「玩家子隊＝執行玩家給的任務」。

## 一、誰是「玩家子隊」（單一謂詞）
- **派生事實欄 `TeamData.player_controlled`**（R²：release／set_strategic_move 沒有 state，謂詞不能現算）：＝附身隊，或「parent 是附身隊 ∧ `dispatched_by_player`」。由同一支 `WorldState.sync_possession()` 順著 parent.subteam_ids 重算（多格移動票的單寫者），觸發點加：玩家派遣、子隊併回／死亡、`dispatched_by_player` 翻轉。P8 漂移校驗延伸到它。
- `dispatched_by_player`：玩家派遣路徑寫入的事實欄；NPC 派遣不寫。
- **一個跳過謂詞**：附身隊三件（丙）的 loop3 入口分類與本票共用「玩家控制的隊」＝`player_controlled`，不各寫一份。
- 換附身／繼承：新附身隊的既有子隊不自動變成玩家子隊（沒有 `dispatched_by_player`）。**藍圖補（2026-10-13）**：子隊面板對這種子隊標「自主（非你派出）」；玩家對它下**任一道令**（下令移動、召回、改任務）⇒ `dispatched_by_player` 翻成 true、成為玩家子隊（翻在玩家指令路徑的同一處，不在 UI）。不得出現「面板列著、我下了令、它還自己亂跑」。床 S12：換附身後舊子隊面板標「自主」；對它下令移動 ⇒ 之後 24 小時無任何決策層改派。**翻 flag 只在指令被接受後**（被拒的令不翻）。

## 二、決策層不碰（藍圖 ③）
- 同多格移動票的 arbiter 咽喉：`_possessed_blocks` 改讀 `player_controlled`；**玩家子隊與附身隊同一個允許集合**＝`PLAYER_SOURCES` ∪ `EVENT_SOURCES`。**不建「物理反應來源」集合**（R²：全專案沒有純物理的 source——自衛不經 arbiter（戰鬥靠 combat_target 鎖）、逃走 "unified"、求生 "survival" 與 AI 閒逛同名，放進去＝讓決策引擎重新替玩家子隊做事）。
- **抵達觸發的生命週期寫入要有具名 EVENT 來源**（R² 擋①）：`start_build`（outpost_system.gd:581 的 `TaskArbiter.transition(…"建設", PRIO_DISPATCH)` 目前用預設來源 "transition"）、`_convert_to_resident`、`establish_crude_camp` 各給具名來源（例 `construction_started`／`resident_converted`／`camp_established`）加進 `EVENT_SOURCES`；**不得把 "transition" 或空字串整類放行**（＝撤守衛）。實作端 grep 這三支以外還有沒有抵達觸發的 transition，一併列。
- 入口直接跳過（不只靠 arbiter 擋）：`_decide_subteam`（faction_ai_system.gd:4133-4134 → :4326）、loop3 野心層（:1732-1741）、`set_strategic_move`——對玩家子隊 return。外交提案生成同樣跳過。
- **待機＝原地待命**：task IDLE 且無 move_target；不被任何層改派。
- **物理與事件＝玩家事件**（藍圖 ③）：被攻擊（戰鬥鎖照舊 ⇒ 自衛自然發生）、糧將盡、紀律失效脫離（`_check_discipline`，randf 合法機率）、CONSTRUCT 10 天未開工強制併回、容量滿分團——每一件 emit 玩家相關事件（subjects 含玩家隊，wake=false），句子帶子隊名與位置，列 `ADVANCE_STOP_KINDS`。
- **逃與求生不自動做**（同附身隊已定規則：威脅／求生決策不放行，用事件通知、玩家決定召回或改令）。藍圖原文寫「被攻擊可自衛或逃」——自衛成立；**藍圖已確認（ce4041e3c）：不自己逃、不自己求生**，自衛照舊，只發事件並停推進。

## 三、各任務真的執行（缺陷修＋藍圖 ①②）
### 一律歸建閘（缺陷）
- `faction_ai_system.gd:4126-4131`「move_target==-1 且 task≠IDLE ⇒ 抵達即歸建」是補丁閘（2026-09-22 measurer tap 已量到）。**對玩家子隊不適用**：玩家子隊抵達後執行任務，直到玩家召回（召回指令已存在）。
- 對 NPC 子隊：這道閘照舊（改它會動 NPC 世界，另開票）；交件信量它在 30 天世界對 NPC 子隊 fire 幾次、各 task 分佈，記 known_issues。
### 覓食／巡邏／偵查（R²：執行端實況）
- **覓食**：沒有主動執行端；採集是被動的、依所在格（營地／據點／野味），與 task 無關。⇒ 子隊抵達後停留在該格，產出由所在格決定；結果句與子隊面板誠實寫「在 (q,r) 採集（此格產出：…／此格沒有糧源）」。S1 選有糧源的格。
- **巡邏**：全 simulation 沒有執行端（只剩 faction_ai_system.gd:1765 的標籤親和表）⇒ **從玩家子隊選單移除**（不定義新行為；要巡邏是新功能，另提）。
- **偵查**：玩家手上＝走到該格停留、提供視野；結果句「到 (q,r) 停留觀察」。
- 子隊路過母隊格不得被 `try_merge_back` 吞（interaction_system.gd:176）：玩家子隊只在玩家召回時併回。
### 落腳（安頓拆一，藍圖 ①）
- 到目標格後呼 `establish_crude_camp`（F8，玩家紮營同一支，當場 L0）；前提用同一支 `precheck_camp`（目標格已有據點／營地 ⇒ 不可帶原因）。未知格：前提讀那一格 ⇒ 拒（同 44d310612）。
### 移居自家據點（安頓拆二）
- 目標必須是地主＝玩家或同勢力的據點，否則不可、原因「(q,r) 不是你的據點」；抵達後走既有 `_convert_to_resident`（fai:4109-4118）。
- 選單不再出現「安頓」。
### 建設（藍圖 ②）
- 子隊建設＝去目標格開工**玩家選定的**工程。**「同一份來源」現況不存在**（R²：子隊用 text_ui_main.gd:10 的 SUBTEAM_TASK_CHOICES，玩家建設用 `_prompt_build_facility`／build_type）⇒ 新建 `OutpostSystem` 層具名常數（可建類型／設施清單），玩家自己的建設與子隊建設都讀它。開工走 NPC 的「抵達才開工」路：`TASK_CONSTRUCT` ＋ `task_extra_data.build_type/level`，抵達時 `begin_subteam_construction`（outpost_system.gd:788-804）。**不再派 `TASK_BUILD`**。
- **據點歸屬（R² 擋①）**：完工 `set_owner(tile, construction_team_id)` 的 owner 會是子隊 id；召回時 `_merge_into` 沒有據點歸屬轉移、子隊被 erase ⇒ 據點可能變無主。⇒ `construction_target` 帶 `owner`＝母隊（玩家隊），完工 set_owner 讀它；實作端核 `erase_team` 是否走死亡釋放並列出。
- 缺料／缺人：前提用開工函式同一支判，不可帶原因（「需材料 N，子隊帶 M」）。

## 四、子隊對自家人外交（缺陷，先量）
- 根因（R²）：`try_proactive_diplomacy` 排除自家人的條件是「同勢力且勢力≠-1」⇒ 獨立隊（含獨立玩家隊）的子隊勢力也是 -1、條件為假 ⇒ 對同格母隊送通商或索貢（QA 看到的「找上門」）。威脅掃描 `decision_context.gd:652-661` 只排除自己。
- 修在**譜系**不是勢力：新增一支 `is_kin(a, b)`（母隊／子隊／同母兄弟），外交提案與威脅掃描都用它（一把，不各寫一份）；同勢力排除照舊另算。
- 先量（修前，3 seed × 30 天）：NPC 子隊對 kin 發起外交與把 kin 選為最大威脅的次數。行為改變 ⇒ world-fp 先二分再換基準。

## 五、腳下派遣也要等 6 小時才「抵達」（查）
- QA：腳下派出 `move_target` 在 t=360 才清（movement_system.gd:340-344 同格清，但要等移動計時）。查呼叫端計時；若是「同格也要走完一格的時間」⇒ 同格派遣直接視為抵達（不走計時），交件信寫原因。

## 驗收（各格修前紅，除註明）
- S1：玩家子隊覓食到一格外**有糧源的格** ⇒ 抵達後停留、1 天內所在格產出入帳、未被併回；路過母隊格不被吞；結果句寫此格產出。
- S2：偵查 ⇒ 停留在目標格、視野含該格周圍；選單無「巡邏」。
- S3：待機 ⇒ 24 小時內 task、位置不變、零外交。
- S4：玩家子隊不發起任何外交（對母隊尤其）——整天零「找上門」來自自己的子隊。
- S5：落腳 ⇒ 目標格出現 L0 營地；已有據點的格 ⇒ 不可帶原因。
- S6：移居自家據點 ⇒ 成為居民；非自家據點 ⇒ 不可帶原因。
- S7：建設 ⇒ 抵達後 task 變「建設」且進度推進（`construction_team_id` 有值）；缺料 ⇒ 不可帶原因。S7b：完工後召回 ⇒ 據點 owner 仍是玩家隊。S7c：start_build 的 transition 在玩家子隊上不被 deny（具名來源）。
- S8：子隊被攻擊 ⇒ 事件流有「你的子隊…被…攻擊」、推進停下；子隊照常自衛（戰鬥鎖）；不自動逃（藍圖已確認）。S8b：紀律失效脫離 ⇒ 玩家事件。
- S9：召回 ⇒ 併回。
- S10：腳下派遣的抵達時間（依五的結論）。
- S11：NPC 子隊行為——一律歸建閘照舊（量測數字）；威脅掃描修後 world-fp 二分報告。
- 負對照：拿掉玩家子隊謂詞 ⇒ S3／S4 紅；放回一律歸建 ⇒ S1 紅；建設改回 TASK_BUILD ⇒ S7 紅。
