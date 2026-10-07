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
