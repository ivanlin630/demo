# 多格移動走一格就靜默停（擋交玩缺陷，HOW）

```
藍圖真跑（91d6402b1，卷面 docs/measurements/2026-10-13-round5-blueprint-real-run.txt，兩輪重現）：
  01:01 在 (9,2) 下 M 到 (9,0)「預計 480 分鐘」→ 07:00 事件「抵達 (10,2)」→ 之後不動；13:01 L 回「沒有在移動」
讀碼（systems）：
  ①事件「抵達 (X)」印的是 _last_move_target（text_ui_main.gd:339-343：上一幀目標被清成 (-1,-1) 且人站在那格）
    ⇒ 印出 (10,2) ＝ 在清掉之前，玩家隊的 move_target 已經是 (10,2)，不是 (9,0)
  ②player_command_system.gd:2030 move_to 只寫 pt.move_target＝(9,0)
⇒ 有【另一個寫者】（R² 核：_last_move_target 唯一寫者 text_ui_main.gd:346 取自 team.move_target ⇒ 成立；只證有第二寫者、不證是誰）在 01:01 之後把玩家隊的 move_target 改成 (10,2)；到了之後 movement_system.gd:344/366 清掉 ⇒ UI 照規則印「抵達 (10,2)」
  候選（未驗）：faction_ai _evaluate_loop3_teams（:1526）對【每一隊含玩家】在 IDLE 時跑 gather／ambient（量測員 2026-10-07 已證它對玩家隊跑）；
  或其他對 state.teams 全掃、寫 move_target 而沒排除玩家隊的路徑
★若坐實：這是【AI 在替玩家走路】——比「停住」更重，玩家隊的移動只能由玩家指令寫（不變量：玩家隊零特殊物理，但決策只屬於玩家）
```

## 第一顆 commit：只查不改
```
在 play.py 同一個重現（seed 預設；printf 'x\nw\nw\nenter\nm\n'＋x×12＋'l'）下，對玩家隊 move_target 的每一次寫入記：tick、舊值→新值、寫入者（呼叫堆疊頂兩層）
做法：TeamData 加一個只在床開的寫入觀察（setter 或床裡逐 tick 比對＋同 tick 掃各系統呼叫點），不改世界、不耗 RNG
印出 01:01–13:01 之間所有寫入 ⇒ 找到把 (9,0) 換成 (10,2) 的那一個
```

## ★藍圖 WHAT（2026-10-13，採為本票前提）
```
附身中的隊：決策層不得寫它的 task／move_target／orders（「玩家＝可插拔控制器」的執法點）
允許改它狀態的只有物理與事件（被攻擊進遭遇、餓、強制事件到達），不含「AI 覺得該去哪」
⇒ 若是 (A)：修法＝把附身隊從 NPC 決策迴圈的【寫入】排除（讀可以、寫不行）；★不准在 UI 把目標改回來
```

## 修法（R² 第一輪 2026-10-13 改寫：(B) 根治＋#12 收在咽喉；(A) 降為量測）
```
根因候選（R² 讀碼，待寫入觀察定案）：move_to（player_command_system.gd:2039）只寫 move_target、task 留 IDLE＠0
  ⇒ 玩家的移動不是 arbiter 的一筆佔用；loop3 ambient（faction_ai_system.gd:1728 IDLE → :1737 try_set PRIO_AMBIENT=10 > 0）可無條件覆寫（task_arbiter.gd:244）
  ⇒ 其他玩家令（:790/:821/:1185）都走 try_set PRIO_PLAYER，只有 move_to 沒有
(B) 玩家移動成為一筆 arbiter 佔用：
   ①move_to 改走 TaskArbiter.try_set(…, TASK_TRAVEL, target, PRIO_PLAYER, "player_move")——★新 task 常數 TASK_TRAVEL（「行進」）；
     先 git grep `current_task ==`／`match .*current_task` 讀者，逐處報「新值走哪一支（預設／明列）」，有會誤判成別的 task 的就停手回我
   ②抵達要 release：movement_system._step_team 抵達兩處（:344/:366 之後的 _on_arrival）task＝TRAVEL ⇒ TaskArbiter.release
   ③cancel_move 同步 release
(#12 執法點) 附身隊的決策寫入在【咽喉】擋，不在 131 條迴圈逐條擋：
   ④task_arbiter：try_set／transition 對附身隊只接受 allowlist 來源（player_*、遭遇／戰鬥、強制事件）；其餘 deny＋Probe "arbiter.deny.possessed.by.<source>"
   ⑤抗命窗口（task_arbiter.gd:233 PRIO_PLAYER 被 PRIO_DISPATCH 挑戰 ⇒ leader 個性判定）對附身隊不適用（附身＝玩家就是那個 leader；#12：決策層不得寫）⇒ 附身隊跳過抗命判定（這一條會把「新的靜默停」堵掉）
   ⑥不經 arbiter 的 move_target 寫者（movement.process :60/:97/:100、set_strategic_move、事件驅動約 25 處）：
     不改造，用第一顆的寫入觀察當守衛——30 天、玩家附身、玩家下令之後的每一次 move_target 寫入，寫入者必須在 allowlist；違反逐筆印
   ★附身隊判定只用一個謂詞：person.team_id 取玩家隊那一支（R²：faction_ai 守衛用 leader_id==player_id，附身／繼承後會分叉）——新程式一律用同一支，舊守衛不在本票改
(C) 真的無路：下令時算路徑；不可達 ⇒ 結果行「無法抵達 (q,r)：原因」不下令；途中路斷 ⇒ 事件「停下：到 (q,r) 的路斷了」
UI（R²：不開第三欄位）：M 也設既有 _arrive_target；「抵達」只在 pos＝_arrive_target 時印；目標被清而人不在 _arrive_target ⇒ 事件「停下：<原因>（停在 (q,r)）」
(A) 降為量測：P5 改成「⑥ 的寫入觀察在 30 天內 allowlist 外寫入＝0」
```

## 驗收（界限第 24 條：走真路徑）
```
P1 play.py 同一重現：最終 tile＝(9,0)，事件流有「抵達 (9,0)」，沒有「抵達 (10,2)」
P2 下令到兩格外的可達格 ⇒ 走到；途中不印抵達
P3 下令到不可達格（佈置：四周山或地圖外緣隔絕）⇒ 結果行「無法抵達」，move_target 不被寫
P4 目標被別的原因清掉（佈置：途中 cancel）⇒ 事件流印「停下：…」
P5 30 天、玩家附身、真世界：附身隊 task／move_target 的 allowlist 外寫入＝0（逐筆印）｜反向：拿掉 ④ ⇒ >0 必紅
P5b 抗命：佈置 PRIO_DISPATCH 挑戰附身隊的 PRIO_PLAYER ⇒ 不換手、不加 stress｜非附身隊照舊會抗命（反向格）
P5c 抵達 release：走到後 task＝IDLE、priority 0
P7 （藍圖）玩家下令後閒置 24 小時：move_target 與 task 逐 tick 不變，除非事件流同 tick 有一筆解釋它為何變（遭遇／強制事件／抵達）｜反向：拿掉 (A) 的排除 ⇒ 出現無解釋的變化 ⇒ 必紅
P6 終端 E2E 已知紅排除 0；world-fp 若變（(A) 會改世界）先量、同 commit 換基準
```
序：最優先（擋第五輪邀請）
