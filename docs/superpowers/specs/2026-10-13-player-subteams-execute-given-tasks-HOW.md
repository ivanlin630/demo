# 玩家子隊真的做事（只做玩家給的任務）——HOW

狀態：草稿，待 R²
來源：QA 故事稽核判決 2026-10-13-qa-to-systems-subteam-dispatch-story-audit-VERDICT（trace `docs/measurements/2026-10-13-qa-subteam-dispatch-story-trace.txt`）；藍圖三裁 81a62871e（2026-10-13-blueprint-to-systems-RULING-player-subteams-execute-given-tasks-settle-split-build-chosen）
順位：玩家可見批，與派遣第二刀同批（fix/terminal-input-prompts 之後接著做；UI 修好了任務還不做事＝白修）。
意圖帳：「玩家子隊＝執行玩家給的任務」。

## 一、誰是「玩家子隊」（單一謂詞）
- `is_player_subteam(state, team)`：`team.parent_team_id == state.get_player_team_id()`，且該子隊由玩家指令派出（`dispatch` 的玩家路徑寫入一個事實欄 `TeamData.dispatched_by_player: bool`，NPC 派遣不寫）。兩條都要，避免換附身後把 NPC 的舊子隊也算進來。
- 換附身／繼承：新附身隊的既有子隊不自動變成玩家子隊（沒有 `dispatched_by_player`）；交件信寫明這個選擇。

## 二、決策層不碰（藍圖 ③）
- 同多格移動票的 arbiter 咽喉：`_possessed_blocks` 擴成「附身隊**或**玩家子隊」共用的謂詞；玩家子隊的任務只接受 `PLAYER_SOURCES` ∪ `EVENT_SOURCES` ∪ **物理反應來源**（自衛、逃、求生——列成具名集合 `PHYSICAL_REACTION_SOURCES`，實作端從現有 source 字串查出精確成員，交件信列表）。
- 入口直接跳過（不只靠 arbiter 擋）：`_decide_subteam`（faction_ai_system.gd:4133-4134 → :4326）、loop3 野心層（:1732-1741）、`set_strategic_move`——對玩家子隊 return。外交提案生成同樣跳過。
- **待機＝原地待命**：task IDLE 且無 move_target；不被任何層改派。
- **物理反應＝玩家事件**：自衛／逃／求生每一件 emit 玩家相關事件（subjects 含玩家隊，wake=false），句子帶子隊名與位置（「你的子隊 Team20 在 (3,6) 被 Team6 攻擊」「子隊 Team20 糧只剩 1 天」），列 `ADVANCE_STOP_KINDS`。

## 三、各任務真的執行（缺陷修＋藍圖 ①②）
### 一律歸建閘（缺陷）
- `faction_ai_system.gd:4126-4131`「move_target==-1 且 task≠IDLE ⇒ 抵達即歸建」是補丁閘（2026-09-22 measurer tap 已量到）。**對玩家子隊不適用**：玩家子隊抵達後執行任務，直到玩家召回（召回指令已存在）。
- 對 NPC 子隊：這道閘照舊（改它會動 NPC 世界，另開票）；交件信量它在 30 天世界對 NPC 子隊 fire 幾次、各 task 分佈，記 known_issues。
### 覓食／巡邏／偵查
- 實作端先查三者的**執行端**是否存在（隊在格上、task＝覓食時有沒有產出；巡邏、偵查有沒有每 tick 的行為）。有 ⇒ 抵達後就讓它跑；沒有 ⇒ 停手列出，由我定。
- 子隊路過母隊格不得被 `try_merge_back` 吞（interaction_system.gd:176）：玩家子隊只在玩家召回時併回。
### 落腳（安頓拆一，藍圖 ①）
- 到目標格後呼 `establish_crude_camp`（F8，玩家紮營同一支，當場 L0）；前提用同一支 `precheck_camp`（目標格已有據點／營地 ⇒ 不可帶原因）。未知格：前提讀那一格 ⇒ 拒（同 44d310612）。
### 移居自家據點（安頓拆二）
- 目標必須是地主＝玩家或同勢力的據點，否則不可、原因「(q,r) 不是你的據點」；抵達後走既有 `_convert_to_resident`（fai:4109-4118）。
- 選單不再出現「安頓」。
### 建設（藍圖 ②）
- 子隊建設＝去目標格開工**玩家選定的**工程：選單與玩家自己「建設前哨／蓋設施」同一份（實作端找出那份清單的單一來源），開工走 NPC 的「抵達才開工」路：`TASK_CONSTRUCT` ＋ `task_extra_data.build_type/level`，抵達時 `begin_subteam_construction`（outpost_system.gd:788-804）。**不再派 `TASK_BUILD`**（那是開工之後的狀態）。
- 缺料／缺人：前提用開工函式同一支判，不可帶原因（「需材料 N，子隊帶 M」）。

## 四、威脅掃描排除母隊與同勢力（缺陷，先量）
- `decision_context.gd:652-661` 只排除自己；`threat_assessment.gd:31-70` 不排除同勢力。
- 先量（修前，3 seed × 30 天）：NPC 子隊把母隊或同勢力隊選為最大威脅的次數、因此發起的外交（求和／進貢）次數。
- 修：掃描排除母隊與同勢力隊。會動 NPC 世界 ⇒ world-fp 先二分（只動這一處）再換基準；量測數字寫交件信。

## 五、腳下派遣也要等 6 小時才「抵達」（查）
- QA：腳下派出 `move_target` 在 t=360 才清（movement_system.gd:340-344 同格清，但要等移動計時）。查呼叫端計時；若是「同格也要走完一格的時間」⇒ 同格派遣直接視為抵達（不走計時），交件信寫原因。

## 驗收（各格修前紅，除註明）
- S1：玩家子隊覓食到一格外 ⇒ 抵達後 1 天內有覓食產出、未被併回；路過母隊格不被吞。
- S2：巡邏、偵查各一格（依執行端查到的行為寫斷言）。
- S3：待機 ⇒ 24 小時內 task、位置不變、零外交。
- S4：玩家子隊不發起任何外交（對母隊尤其）——整天零「找上門」來自自己的子隊。
- S5：落腳 ⇒ 目標格出現 L0 營地；已有據點的格 ⇒ 不可帶原因。
- S6：移居自家據點 ⇒ 成為居民；非自家據點 ⇒ 不可帶原因。
- S7：建設 ⇒ 抵達後工程開工（`construction_team_id` 有值、進度推進）；缺料 ⇒ 不可帶原因。
- S8：子隊被攻擊 ⇒ 事件流有「你的子隊…被…攻擊」、推進停下；子隊照常自衛。
- S9：召回 ⇒ 併回。
- S10：腳下派遣的抵達時間（依五的結論）。
- S11：NPC 子隊行為——一律歸建閘照舊（量測數字）；威脅掃描修後 world-fp 二分報告。
- 負對照：拿掉玩家子隊謂詞 ⇒ S3／S4 紅；放回一律歸建 ⇒ S1 紅；建設改回 TASK_BUILD ⇒ S7 紅。
