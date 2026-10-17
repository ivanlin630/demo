---
from: reviewer
to: systems
status: open
slice: 批尾小修二
topic: R²b VERDICT＝ISSUES（輕）：M1–M8、S1–S6 多數已收；新增 3 條 must-fix（N1–N3）＋ 4 條小項（T1–T4）。靜態讀 code，沒跑測試。
---

# 一、M1–M8、S1–S6 收沒收（spec 4ff9ed781 全文讀過，不只看 diff）
| 條 | 結果 | 依據 |
|---|---|---|
| M1 | ✓ | A0 把結算頁的鍵路徑講清楚（`_handle_key` 戰後分支，不經 `_global_advance_key`）；L＝留戰利品，用「頁上自己綁的鍵優先」；常數 `GLOBAL_KEY_IN_PANEL_MSG` 同一句。我確認 `TextUiMain` 有 `class_name`（`text_ui_main.gd:3`），encounter_view 可直接引用。驗收總則「不准直呼 `_global_advance_key`／`_handle_key`」成立 |
| M2 | ✓ | `_enter_post_combat()`＋`settled` signal 收三處；A1 格在頁還開著那一幀量。n1「`settled` 不接 drain」紅在對的位置 |
| M3 | **部分（見 N1）** | 母體、後備單列、被俘取 `held_by_enemy`、對帳改第二來源、對方不對帳，方向都對；但對帳式漏項 |
| M4 | ✓ 除 N3 | B0 改認 `possessed`（我確認 `sync_possession` 戰死窗口保持，`world_state.gd:1136-1137`、`:1158`）；發在 `player_id` 守衛之後；舊句改 `on_leader_death:32`；觀察者世界 0 則一格 |
| M5 | ✓ | 縮成只改句子；WHAT 缺口送藍圖。見 T3（句子的產生者要指名） |
| M6 | ✓ | 結算開頭清除（一處，`:1202` 之前，三條路徑共同經過——我確認 `:1199-1203` 是函式開頭）；敗者不在不列；`:1634-1635` 刪；獸戰格 |
| M7 | ✓ | 讀者表補了 `outpost_system.gd:1177`、`player_command_system.gd:1109/1434`、`text_ui_view.gd:202`；type×level 逐字相同格；miss 計數改斷言＝0 |
| M8 | **不收（見 N2）** | `last_firsthand_pos` 這個想法對，但它換掉的那個變數同時是 NPC 喚醒閘 |
| 重點 5 / C | ✓ | 一個 `ConfirmGate` 兩邊共用，三個舊旗刪、grep＝0。我確認三個旗都在：`_outpost_pending_abandon`（`:105`）、`_faction_extract_pending`（`:106`）、`_rest_confirm_armed`（`:1374`）；也有 `:3975-3976` 的重置點，請一起處理 |
| S1–S6 | ✓ | 遷移到鍵層、`press_on` 不卡、來歷、窄終端格、八個動作最終鍵、`key_reply` 一支 |

# 二、新增 must-fix

## N1 A3 對帳式漏項：正常戰鬥差額不會是 0
- spec `:84-89`：`人口差（before − after）` 對上 `死 ＋ 後備陣亡 ＋ 被俘`，並斷言「正常戰鬥差額＝0」。
- 但 `_aftermath_emit` 在 `_aftermath_captives_fate_pursuit`（`encounter_system.gd:1324`）**之後**才取 `pop1`（`:1404` 呼 emit、`:1571` 取值）。那一支在 NPC 為留場方時會當場減玩家隊人口：
  - `fate_kill`（傷兵被殺，`:1540`）→ `am.sides[vid].fate_killed`；
  - `fate_capture`（被俘走，`:1542`）→ `fate_captured`，**這與 2a 的 `held_by_enemy`（`:1488`）是兩個不同欄**；
  - 追擊 `kill_random(... "pursuit")`（`:1548-1553`）→ `pursuit_killed`。
  這三項今天句子裡都有（`world_events.gd:613-625`），但不在 spec 的等式裡。
  ⇒ 只要是 NPC 贏、有傷兵或追擊的一場，差額就非 0，「其他離隊」印出一個**其實有原因的數字**；而且「正常戰鬥差額＝0」這格在那種仗上會**紅**。
- 要求：等式右邊補 `fate_killed ＋ fate_captured ＋ pursuit_killed`（欄位在 `_aftermath_begin` `:1419-1420` 已存在），或明寫「這些場合不在對帳範圍」並讓床格涵蓋。床格要有一場「NPC 贏、有傷兵處置」的仗，不然這一格只在最簡單的仗上綠。
- 另：`resolve_negative_flags`／`resolve_anon_units`（`:1213-1214`）在 emit 之前跑；我讀了 `health_system.gd:120-190`，沒看到它們直接扣人口（`:181` 註解寫死亡由結算統一處理），但我只讀到 `:190`，**後半段沒讀**。請交件時用「人為製造差額＝0 的對照仗」證實，不要靠我這句。

## N2 D5：`_known_pos` 同時是 NPC 的喚醒閘，換了就改世界
- spec D5 把 `_known_pos`（`belief_system.gd:305-309`）的比對基準換成 `last_firsthand_pos`，理由是玩家面「你看到」重報。但同一個 `if _known_pos == null or _known_pos != fields["tile_pos"]`（`:310`）包住的是整段：
  - `_wake = ThreatAssessment.score(...) >= THREAT_BASE_THRESHOLD`（`:324-327`）；
  - `WorldEvents.emit(state, "intel_arrived", [obs_id], _wake, _iinfo)`（`:340`）——第四個參數 `_wake` 是**喚醒觀察者重新思考**（注釋 `:302-303`「觀察者當 tick 可重新思考」）；
  - 之後的 DIAG Probe 計數。
  這段對**每一支隊**（含全部 NPC）執行，不只玩家。把基準換成「最近親見」，NPC 隊「喚醒」的次數與時機會變 ⇒ NPC 決策時序變 ⇒ world-fp 變。
- spec 的 world-fp 一條寫「D1 的清除點與 B1／B2 新欄只在玩家世界作用」，**沒有把 D5 列進去**，開頭範圍也寫「世界行為只動一處」。與這個事實不符。
- 要求（擇一，不裁）：
  - (a) 把新基準**只放在玩家文字路徑**：`obs_id == state.get_player_team_id()` 那一支（`:334` 已有此分流）決定「要不要進玩家事件」，`_wake` 與 emit 的喚醒語意維持舊基準不動；或
  - (b) 接受 NPC 喚醒改變，把它寫成範圍內的世界行為、F 格加 NPC 世界 fp 前後與第一個分歧 tick 歸因，並經藍圖確認這是 WHAT 已裁。
- 順手：`last_firsthand_pos` 的「親見」判準請用同檔 `:336` 的 `source_type == "親見" and source_id == obs_id`（或情報頁的 `is_firsthand`，`player_query_api.gd:563` 註解），不要再寫第三種。
- 順手：轉述（source ≠ 觀察者）抵達時用什麼基準，spec 只寫「親見事件」。轉述位置與最近親見不同就會發，行為與舊版差不多；請寫一句免得實作端各猜一次。

## N3 `player_death_announced` 沒有生命週期
- spec B2：WorldState 新欄 `player_death_announced`，鍵＝`team_id`、值＝死亡 tick，「同一支隊同一次死亡只發一次」。
- 沒寫「同一次」怎麼認、何時清。鍵只用 `team_id` 的話：繼承人接手之後**同一支隊**再有玩家死亡，鍵還在 ⇒ 第二次死亡永遠不發，也就不停。`_action_choose_heir`（`player_command_system.gd:2252-2280`）清 `player_forced_event` 的地方是自然的清除點。
- 要求：寫清楚清除時機（繼承完成、或鍵改用死亡 tick 並比對），床格加「死→選繼承人→再死，兩次都停」。另寫這欄進不進 fp／存檔（B1 的 `critical_announced` 有寫「進存檔」，這欄沒寫）。

# 三、小項（不擋，併同輪）
- T1 C：`ACTION_SHAPE` 的列加 `confirm: "conditional"`，「條件函式掛在列上」——若 `ACTION_SHAPE` 是 `const`（`player_command_system.gd:456` 一帶），常數字典放不進 Callable。請寫成條件函式的**名字**（字串）由一支分派，或條件留在 UI 側。我沒開檔確認它是 const，請實作端先看。
- T2 D1：結算開頭清除，會連「上一場尚未結清的待處置」一起清。我推論前一場的結清在下一個 tick 開頭必定先跑（`settle_pending_aftermath` 在 SimRunner 推進那顆 tick 裡、世界系統之前，`player_command_system.gd:841-843`），所以玩家遭遇戰不會夾在中間；但這是從註解推的，請床裡加一格「結算頁開著時又觸發第二場」（若這種情形可達）證實不丟居民處置（`_abandon_occupation`）。獸戰後 `_post_combat_summary(res)` 在 `res` 為空時的畫面（`encounter_view.gd:151-153`）也請看一眼不會印空白殼。
- T3 B3：句子的產生者要指名。「玩家絕後」的字串現在有兩處：`event_system.gd:88` 與 `player_command_system.gd:2100`（後者是另一句「玩家絕後（隊已滅,無繼承人）」）。spec 只說「句子」，沒說改哪處、是不是收成一支。
- T4 B2：`on_leader_death` 的玩家分支以「這支隊是玩家隊」判斷（`event_system.gd:34`），不是「玩家本人死了」。玩家若不是該隊領袖而領袖死了，會不會進 `handle_player_succession` 並發「你倒下了」？我沒追到玩家是否恆為領袖（`set_leader` 與附身的關係），請實作端確認；若玩家可以是非領袖成員，句子主詞「你」會錯。

# 四、結論與下一站
- 判定：**ISSUES（輕）**。N1–N3 都是 HOW 內的補寫；N2 若選 (b) 才需要經藍圖。
- 修完回 R²c，只審 N1–N3 對應段落＋T1–T4 有沒有被收。CLEAN 後即可派實作。
- 沒重審但這輪重讀過、沒新問題：A4、A5、C 的鍵位規則、D2、D3、D4、D6、E1–E7（同上輪，沒有展開成負斷言）。
