# M（移動到）＝設目標＋一顆 tick；「走到抵達」另給明確鍵（HOW）

```
票源 ＝ 藍圖真跑 round4c（`…TICKET-move-command-skips-to-arrival-breaks-press-is-do.md`）｜不擋交玩
現況：`text_ui_main.gd` KEY_M ⇒ command_player("move_to") 成功後 `request_advance(ADVANCE_UNTIL_EVENT)`＋「移動中 [Esc]停止」；
      `_process` 到點偵測後若仍「移動中」再請一次推到事件 ⇒ 一路推到抵達
來源：2026-06-01 headless-play 架構（`436a3fab7`），早於 10/1 press-is-do 裁定 ⇒ 沒有現行裁定允許它，是沒跟上
```

```
①M ＝ 設目標＋一顆 tick（同其他下令鍵：入列即 request_advance(1)，見 sim_bridge command_player）；結果行＝「開始走向 (q,r)，預計 N 分鐘」（預估讀既有移動成本）
②「走到抵達」＝一個新的明確推進鍵（與 X／Space 同族；鍵位放進全域鍵字表＝四缺陷 D4 那份，強制回應字母配發同步跳過它）
  ⇒ 推進到抵達或任何強制事件／遭遇（事件必停，同 ADVANCE_UNTIL_EVENT 既有的停點）；結果行＝「抵達 (q,r)」或「途中：<事件>，停在 (q,r)」
③移除 `_process` 裡「移動中 ⇒ 再推一次」的自動續推
④★R² 抓到：「到達」log（`text_ui_main.gd:343-348`）的閘是輸入列文字前綴「移動中」——③之後它在下一顆 tick 就被清掉、遠早於真正抵達
  ⇒ 裁 (A)：到點偵測改讀**狀態本身**——記住上一幀的玩家 move_target；它從某格變成 (-1,-1) **且** 玩家此刻就在那一格 ⇒ 印「抵達 (q,r)」
    （move_target 因取消／換任務被清掉而人不在那格 ⇒ 不印抵達）；不靠輸入列文字、不另加旗標
  E2E 加：按 M 後用 X 推到抵達 ⇒ 抵達句出現在抵達那一 tick｜Esc／換任務取消 ⇒ 不出現抵達句
E2E：M 一鍵後世界 tick ＋1（不是到抵達）｜新鍵一路到抵達，途中佈置一個強制事件 ⇒ 停在事件那一刻｜鍵位說明列出新鍵
已知問題清單那一列同 commit 標已修
```

## §2 藍圖 `fda4636f1`（用戶討論定案）：推進停點＝玩家相關事件＋休息玩家主導（併進本票）

```
①【推進停點】X（到整點）／Space（到隔日）／「走到抵達」鍵／休息這類長動作 ⇒ 碰到**玩家相關事件**就停在那個 tick、畫面當場更新
  停點清單＝從既有事件類型導出（`WorldEvents.all_kinds()` 與玩家事件匯流排），**禁手抄**：
    找上門／提案到達（強制事件）、被攻擊或遭遇開始、敵對隊進入同格或相鄰格、抵達目的地、成員死亡或離隊
  ⇒ 做法：推進迴圈每步後問一支「這一步有沒有玩家相關事件」（讀事件匯流排，條件＝事件涉及玩家隊或其相鄰格），有 ⇒ 停、結果行印「停下：<事件句>」
  ⇒ ★Team20 那件的真因＝M 自動推進跳過 00:00 的找上門 ⇒ 本票的 M 一顆 tick＋停點一起治
  ⇒ 「敵對隊進入相鄰」沒有既有事件類型時 ⇒ 先查；沒有就新增一個 kind 進 WorldEvents（單一真值），不在推進迴圈裡手算
  ★R² 核（第一輪）：
    ·既有 kind：找上門＝forced_event_arrived｜被攻擊／遭遇＝combat_engaged／combat_start（同格 pre_encounter 含在內）｜成員死亡離隊＝member_died／member_left
    ·沒有：敵對進相鄰（距離 1）⇒ **新增 kind**，寫入點放**模擬層**算位置之後（只算玩家隊的相鄰格、敵對＝既有 player_hostile_teams），不搬到 UI 逐 tick 重算
    ·抵達：設計上走 §1④ 的狀態邊緣偵測，不走 kind（不是漏）
    ·★結構矛盾：實作端已落地的共用停點 `_advance_stop_reason`（text_ui_main.gd，Space／X／G／L 共用）讀的是 `sim_bridge.gd:_diff_events` 的**手刻快照差分**，
      不讀 `WorldEvents.player_events` 的 kind ⇒ 與「禁手抄」矛盾（成員死亡離隊已有 kind 且事件流在顯示，停點卻沒讀）
  ⇒ 裁：停點判斷改讀 `WorldEvents.player_events` 的 kind（與事件流 UI 同源）——停點 kind 清單＝一個具名集合放 world_events.gd，`_advance_stop_reason` 只查它
    ⇒ 實作端已加的兩個停點（強制事件到達、pre_encounter）一併改成讀 kind，_diff_events 那兩段退場
    ⇒ 抵達仍走 §1④；休息也接同一支 `_advance_stop_reason`
②【休息＝玩家主導、兩段確認】旁邊（同格或相鄰）有敵對隊時按休息：第一次印「Team11 在 1 格外，確定要休息？再按一次休息」，第二次才執行
  ⇒ 引擎不得以「有更急的事」替玩家取消休息（玩家下的令，PRIO_PLAYER）；休息中敵對逼近 ⇒ 依①停下，結果句有主詞（哪一隊、幾格），不自動取消休息
E2E：每種停點各佈置一次 ⇒ X／Space／走到抵達都停在事件那一 tick｜無事件時照原長度｜休息兩段確認（第一次只有警告、tick 不動；第二次執行）｜休息中敵對逼近 ⇒ 停下帶主詞
```
