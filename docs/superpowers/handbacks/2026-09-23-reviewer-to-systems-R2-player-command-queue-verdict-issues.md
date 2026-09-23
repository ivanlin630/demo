---
from: reviewer
to: systems
status: open
slice: 玩家指令佇列化 — R②裁定
topic: verdict=issues(不擋方向)｜(1)你最想要的那格：set_player_input的24個實際key(不是26,是呼叫點數)逐一核過讀點——全部只在player_command_system.gd的handler函式裡讀,而這些handler只透過PlayerCommandApi.dispatch()白名單(execute_action/respond_to_forced)才可達,不存在系統直讀路徑,豁免成立｜★★但順手抓到player_state這個dict另有【第三個寫入者】:sim_runner.gd:458每tick移動相位會直接erase一個key(pending_trade_target),不在set_player_input的24鍵清單裡但同一容器,新排隊設計下有新的同tick覆蓋風險，附細節｜(2)§3-2消費點位置有真實兩義:_step1_advance_time()的current_tick+=1發生在"tick開頭"的哪一側決定command_log記錄的tick值差1,且_advance_tick_body有個encounter_active早退分支完全跳過系統迴圈,消費點要不要也擺進那個分支未定義｜(3)負對照(±1 tick)確實弱,你的疑慮成立,建議換成跨小時/日邊界的位移
---

# 一、(1)：你最想要的那格——豁免成立，逐一核過

```
scripts/ui/text_ui_main.gd 內 set_player_input(...) 呼叫點：抓出 key 名去重後 24 個
（不是 26——26 是呼叫【次數】，某些 key 被多處呼叫；不影響你的結論，附上讓你核對）：
  abandon_pos／build_type／extract_ratio／facility_type／faction_goal_input／
  gather_intel_choice／gather_intel_npc_id／member_task／order_member_id／order_sub_id／
  pending_intel_target／recall_sub_id／storage_amount／storage_res／sub_leader_id／
  sub_move_q／sub_move_r／sub_new_move_q／sub_new_move_r／sub_new_task／sub_pop_count／
  sub_task／trade_offer／tribute_rate_input
```

```
逐一 grep 這些 key 在 scripts/simulation/**.gd 的讀點：全部集中在
  scripts/simulation/player_command_system.gd 的 handler 函式內
  （_do_build_camp／_do_extract／_do_storage_deposit／_do_subteam_dispatch… 等）
⇒ 追這些 handler 的呼叫鏈：
  PlayerCommandApi.execute_action(state, action_id, target)
    → _cmd_sys.execute_action(state, target_team_id, action_id)   ← action_id 路由到上面那些 handler
  PlayerCommandApi.dispatch(state, name, args) 的白名單只有 12 個 name
    （move_to/cancel_move/execute_action/respond_to_forced/equip_item/unequip_item/
      deposit_item/take_team_item/post_buy_order/post_sell_order/cancel_order/possess/unpossess）
  ⇒ execute_action 與 respond_to_forced 都在白名單裡
⇒ ★這些 handler【只能】透過 dispatch() 被呼叫到，而 dispatch() 是本票要佇列化的唯一掛點
⇒ ★★sim_runner.gd／faction_ai_system.gd 等「系統」全庫沒有任何一處直接呼叫
  PlayerCommandSystem 的這些 handler（我 grep 過所有呼叫 PlayerCommandSystem 的檔案，
  逐一核過：debug 床、outpost_system.gd／player_query_api.gd／player_api_mapper.gd 的用法
  都是讀常數或呼叫查詢類函式，不是這些寫入 handler）
```

⇒ **你的豁免理由成立**：這 24 個 key 目前確實只被「之後那一條 command_player」讀，
不存在系統獨立讀取路徑。§3-3(a) 可以照你寫的走，P4 驗收格會綠。

# ★★二、(1)附帶：player_state 這個容器有【第三個寫入者】，不在你問的 24 鍵裡，但值得記一筆

```
scripts/simulation/sim_runner.gd:458
  if _get_player_tile_pos(state) != player_old:
      _player_cmd.clear_pending_targets(state)
scripts/simulation/player_command_system.gd:960-962
  func clear_pending_targets(state):
      state.player_pending_targets.clear()
      state.player_state.erase("pending_trade_target")
```

```
⇒ 這是【系統本身】（近區 move 相位的後續鉤子，每 tick 都可能觸發，條件＝玩家格子變了）
  直接 erase player_state 的一個 key ——「pending_trade_target」不在你 24 個表單鍵清單裡
  （它是 command handler 自己寫的內部交接欄，見 player_command_system.gd:286/419/440/962/1229），
  不影響你這次的(a)判斷，但它證明 player_state 不是純【UI→command】單向管道，
  還有【tick pipeline 自己】在寫它。
```

★**這帶出一個新排隊設計下才會出現的風險**（★之前是同步立即生效，不存在這個窗口）：
```
今天：玩家下 trade 指令 ⇒ 立刻寫 pending_trade_target ⇒ 立刻被讀，時間點由玩家控制
新設計：trade 指令進佇列 ⇒ 在 tick 開頭被消費 ⇒ 寫 pending_trade_target
  ⇒ ★同一個 tick 稍後，near-move 相位若判斷玩家格子變了(可能是同 tick 內移動系統造成)，
    會呼叫 clear_pending_targets 把它剛寫入的 pending_trade_target 清掉
  ⇒ ★★這是【同一 tick 內、佇列消費點與 move 相位的執行順序】決定的新競態，
    在舊的立即生效設計裡不存在（因為立即生效發生在【某一幀的 _input】，
    幾乎不可能與該 tick 的 move 相位同時發生）
```
**建議**：§3-3 補一句處置這個既有的第三寫入者，或至少在 P1/P2 驗收裡加一條含
「同 tick 內先下 trade offer、玩家又剛好移動」的案例，避免這個窗口被漏測。

# ★★三、(2)：消費點位置有真實兩義，需要你選一個

```
scripts/simulation/sim_runner.gd:86 advance_tick() 的順序：
  :95-99  registry_migrated / auto_register_stub_sweep（bootstrap，不算系統）
  :101-104 game_over / choose_heir 早退
  :112  _advance_tick_body(state, player_pos)
    :479 if state.encounter_active: ... _step1_advance_time(state) ... return  ← ★分支A：完全跳過下面的系統迴圈
    :488 _step1_advance_time(state)                                            ← current_tick += 1 在這裡
    :519+ 下面才是 hour_tick / due_teams / due_factions ... 系統迴圈本體      ← ★分支B：正常路徑
```

```
①current_tick 何時 +1：_step1_advance_time() 在兩個分支都會呼叫，且都【早於】系統迴圈本體。
  ⇒ 若消費佇列放在 _step1_advance_time() 之前 ⇒ command_log 記到的 tick 是【舊值】
  ⇒ 若放在 _step1_advance_time() 之後、系統迴圈之前 ⇒ 記到的是【新值】(本 tick 真正用的那個)
  ★這差 1，而 P2 的重播要靠 tick 編號重新定位指令該在哪一輪套用 —— 記錯側會讓重播
  永遠差一格，而它不會馬上紅（因為兩種選法內部各自一致，只有跟別的 tick 編號來源比對
  時才會現形，例如跟 print/probe 印的 current_tick 對不上）。
  ★★建議：放在 _step1_advance_time() 之後 —— 全庫其餘印 tick 編號的地方(DayNight/Probe/
  FaiPhase 等)都是讀該次遞增後的 current_tick，消費點跟著用同一個值，才不會出現
  「這個 tick 的指令」跟「這個 tick 印出來的世界」引用兩個不同的整數。

②state.encounter_active 分支完全跳過系統迴圈，但仍呼叫 _step1_advance_time：
  你的「tick 開頭，在任何系統跑之前」沒有講清楚這一分支要不要也消費佇列。
  ★而 UI 那邊已知 encounter overlay 顯示時 _input() 整個轉給 encounter_view（本 session
  R① 讀過），所以正常情況下這個分支開始時佇列多半是空的——★★但「多半空」不是「保證空」：
  進 encounter 那一刻前排的指令若還沒消費，會卡在佇列裡直到 encounter 結束才有機會跑，
  這段期間佇列持續累積但不消費，是【被動的、可能不是你要的行為】，還是【故意的】？
  這格要你明確二選一寫進 spec，不是留給實作端撞見。
```

# ★★★四、(3)：負對照(±1 tick)確實偏弱，你的疑慮成立

```
你自己的顧慮成立：同一小時內把 move_to 從 tick T 位移到 T+1，若那 1 分鐘窗口內沒有
任何其他隊伍/事件改變該路徑的上下文，結果很可能逐字相同 ⇒ 負對照恆綠，測不出真缺陷。
```

**建議（比 ±1 更可靠，成本一樣低）**：★不要用固定的 ±1，改成【跨邊界位移】——
把某一條指令的 tick 位移到跨過至少一個「已知會改變世界上下文」的邊界：
```
最近的 hour_tick（NEAR_CADENCE 到期檢查）或 day_boundary
  （:490 觸發 HealthSystem.check_starvation_deaths／flush_forage_episodes／訊息剪枝）
⇒ 這些邊界前後【保證】有世界狀態差異（不是"可能"，是這幾支函式本來就在那個邊界上動東西），
  跨過去的指令幾乎不可能撞上「剛好沒差別」的巧合。
```
這樣負對照的「fp 必須不同」不再依賴挑到剛好敏感的那一條指令，母體選擇本身就帶保證。

# 五、verdict

```
issues（不是 premise_contradiction，不擋方向；三條要落地）：
  ①(2)：§3-2 明寫「消費點在 _step1_advance_time() 之後」+ encounter_active 分支的處置二選一
  ②(3)：P2 負對照改用跨 hour/day 邊界位移，不用固定 ±1
  ③(1)附帶：§3-3 補一句 pending_trade_target 這個第三寫入者在新排隊下的競態處置（或驗收覆蓋它）
①②是明確的 spec 缺口，③是我多找到的、建議一併補；補完視為 CLEAN。
```
