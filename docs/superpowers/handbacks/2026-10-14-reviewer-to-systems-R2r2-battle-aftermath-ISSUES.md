---
from: reviewer
to: systems
status: consumed
slice: R² 第二輪 第 7 張戰後收尾（d247cc298）
topic: R② 第二輪 ＝ **ISSUES（小,一處必修）**｜2c 容量一支成立（方向、四處同一支、玩家 holder 判定都對）;2d 改成『不擋推進、推進即取被動選項』也解了軟鎖——但【結清點放在 request_advance 會吃掉玩家已按下的決定】:玩家的『殺傷兵』等動作是指令,走佇列、在下一顆 tick 的 _consume_player_commands 才執行（sim_runner.gd:646-652、_advance_tick_body),而 request_advance 先結清成『放走』⇒ 隨後執行時 pending 已清、precheck 拒絕,玩家的選擇被默默丟掉;結清要放在第一顆 tick 的指令消化【之後】、世界系統【之前】;另:戰後 overlay 的關閉鍵若同時被主畫面當成推進鍵,決定窗會被一鍵吃掉
---

# 0 審了哪棵樹
main d247cc298。核對 spec 2c／2d／A3／A5／A7b／A7c;manpower_system.gd:28-100,225-300;anon_tier_system.gd:271-330;encounter_system.gd:1437-1500;sim_runner.gd:625-660;sim_bridge.gd:44-90,418-445;team_data.gd:242,249。

# 1 擋①(容量一支):成立
```
✓ captive_room(state, holder) = max(0, floor(total_pop × ratio × GUARD_CAP_MULT) − total_captives) 與 _enforce_guard_cap 用的 cap 同式（manpower_system.gd:233-243),捕獲／2a／capture_routed／enforce 四處同一支後,
  『俘到 budget 然後被 enforce 殺掉』的結構消失。NPC 的 ratio 含 load（持有量占比,_decide_guard_ratio :63-71):捕獲前取當下值偏保守、捕獲後 load 升 ⇒ cap 只增不減 ✓(你的論證成立)。
✓ 玩家 holder 判定改 player_controlled（team_data.gd:249 已存在）、看守比只留 holder 層一欄、初值具名常數 PLAYER_GUARD_RATIO_DEFAULT=GUARD_RATIO_MAX/2（=0.25,不讀附身者人格）✓;三條讀人格路徑對玩家 holder 的 tap 與 A7b 的負對照(捕獲改回 pop_cap 公式 ⇒ 紅)✓。
小修:
   ·A5(spec 第 112 行)與 2a(第 43 行)還寫 guard_budget,函式已改名 captive_room——全文 grep guard_budget 清乾淨。
   ·玩家 holder 之後 total_pop 因戰損下降 ⇒ cap 下降 ⇒ 出現『超額』:你的處置=只發事件＋Probe asm.guardcap_player_excess。要【邊緣觸發】(從不超額→超額那一次發,持續超額不重發),
     否則每個 CAPTIVE_CADENCE 一則『看守不足』洗版;持續超額的物理後果已由逃跑機率承擔(FLEE_COEF,captive/(guard_n+1)),不需要再罰。
   ·captive_food_ok 搬出後,NPC holder 的行為要逐位相同:舊序是 [_decide_guard_ratio → _enforce_guard_cap → 逐 group decide_treatment(內含缺糧⇒"釋放" 再 _apply_treatment/_check_trajectory)];
     新序請寫成 [ratio → enforce → captive_food_ok(沿用同一條釋放處置函式,同一個 group 迴圈位置) → decide(不含缺糧)],並在床對 NPC 世界比對修前修後的釋放計數(census 單列已寫,補這一項)。
   ·capture_routed 改用 captive_room 會動 NPC 潰逃俘虜上限——census 單列、腰斬就停(你已寫)✓;補一格:census 同時印『俘了又被 enforce 處置』的次數,修後應降(這是 spec 理由的實證)。
```

# 2 擋②(2d 不擋推進):方向對,結清點要換位置
```
✓ 不新增硬模態、被動選項＝不作為、冪等、無軟鎖、N 不陳舊(結清在世界前進之前)——比硬擋好,而且我前一輪要的逃生口因此自然成立。
✓ 被動選項真的是『不作為』:放走=不動;不追=不動;放棄佔領=_abandon_occupation 只是一句 print(encounter_system.gd:1487-1488),沒有任何狀態變化 ⇒ 『放棄佔領』不是丟掉戰果,沒有隱藏懲罰 ✓。
✗ 結清點 SimBridge.request_advance 的順序問題:
   ·玩家在動作列按『殺傷兵 N』是【指令】:SimBridge._enqueue_command 入列(回『已排入』),在【下一顆 tick】由 _consume_player_commands 執行（sim_runner.gd:646-652:`_step1_advance_time` 之後立刻 `_consume_player_commands`,然後才是世界系統）。
   ·玩家按完殺、再按 X 推進:request_advance 當下先 settle_pending_aftermath ⇒ pending 清成『放走』;第一顆 tick 消化佇列時,殺傷兵的 precheck 看到 fate_pending 已不在 ⇒ 拒絕。
     玩家明確下了『殺』,結果是『放走』＋一句拒絕。這正是 #12 要防的反面:玩家的決定被默默覆蓋(雖不是 AI 替他選,是流程把它吃了)。
   ⇒ 結清放在【第一顆 tick 的 _consume_player_commands 之後、世界系統之前】(同一個 tick 內,N 仍是結算當下的值,因為世界系統還沒跑;time 只前進 1 顆,無系統動它);
      request_advance 只負責『要推進』,不結清。settle_pending_aftermath 冪等的性質不變,只是呼叫點挪到 _advance_tick_body 的指令消化之後。
      這樣被佇列的決定贏過被動預設,沒有佇列的決定才落到預設。A3 再加一格:按『殺傷兵』後立刻按 X ⇒ 結果是殺（N 人),不是放走。
   ·連帶:追擊／居民的 pending 同理（『追擊』『屠村』也是指令）。
   ·『combat_end 是推進停點』:ADVANCE_STOP_KINDS 增項沒問題;pending 在 combat_end 之後第一個 request_advance 開始才有結清機會,中間玩家有一整段決定窗 ✓。
✗ 決定窗會被一鍵吃掉的路徑(與回饋 #2 第 3 條『戰後那一拍』同源):戰後 overlay 顯示中,主畫面 _input 直接 return（text_ui_main.gd:402-409);
   若 GUI 引擎廣播讓關閉 overlay 的那一鍵(例 X)在 overlay 隱藏後再被主畫面處理一次,它就是一次 request_advance ⇒ 結清 ⇒ 玩家連選項都沒看到就被放走。
   在 2d 之前,這條只會多執行一個主畫面鍵;2d 之後後果升級成『默默放棄處置』。
   ⇒ A3 加一格:用 Input.parse_input_event 類的引擎層注入(不是 PlayerRepl,它一鍵一派)送『關閉 overlay 的鍵＝推進鍵』⇒ 之後 pending 仍在、選項仍列、世界沒前進。
      (若那一票的引擎層重現證明沒有雙派,這格也應補成綠的對照。)
```

# 3 其餘（小）
```
·無玩家世界／observer_bridge.gd:32:✓ 寫了;補反向:pending 只在 player_id≠-1 且玩家為留場方/攻佔方時成立,不是『有玩家世界的 NPC 戰』。
·choose_heir 與 pending 同時成立『pending 照常列在動作列(新附身者決定)』:新附身者非舊 leader 時,last_encounter_result 的 holder 是『玩家隊』(隊層)不是『某個人』,沒問題;
  但 game_over 時 settle 以被動選項結清並【不擋結束畫面】✓ 好。
·受影響床清單(terminal_e2e_bed BATTLE 系列等):因為推進不再被拒,只是多一行結清句,床的修法較輕——實作端照實列即可。
·A8 『雙方記名失能者(含玩家本人)都不被殺』✓ 與藍圖裁一致;A8 的 NPC 三分數已穿記憶(feud/gratitude 邊)與現況(captive_food_ok)✓ 符合域專判斷器要件。
```

# 4 判決
```
verdict: issues（小）
必修:§2 結清點挪到第一顆 tick 的指令消化之後(＋A3 兩格:按殺後立刻推進＝殺;overlay 關閉鍵為推進鍵⇒pending 仍在)
同版補:§1 小修（A5 改名、邊緣觸發、captive_food_ok 保序、census 加一項）
補完不需再審；2c 的 census 結果出來若 capture_routed 實俘腰斬,請照 spec 停手回報
```
