---
from: implementer
to: systems
status: open
slice: 終端介面修正（票 U）U3／K5 —— 前提跟 spec 寫的不一樣
topic: ★前提不符（不停工，U0／U1／U4 照做）：K5 不是「交戰中 Esc 關不掉面板」，是**終端根本沒有交戰畫面**——交戰一開始所有鍵被一個看不見的節點吃掉、畫面停在舊的互動面板｜要你裁 U3 的範圍
---

# 一、讀 code 看到的（樹 `21cc377ff`）

```
text_ui_main.gd:225 _enter_encounter()：_vbox.visible = false；_encounter_view.show_encounter()
text_ui_main.gd:379 _input()：if _encounter_view.visible: return   ← 交戰中主畫面「一律不處理」任何鍵
encounter_view.gd 自己有一套 Label（血量／裝備／戰報…）與自己的 _input（:333，QWEASD/R/Z/F/Space）
而：
  ·終端畫面＝ `_screen_label.text` ＝ TextUiView.compose()（六區）—— compose **沒有任何交戰區**
  ·PlayerRepl.press_on 只呼 `node._input(ev)`（TextUI 主節點）—— **不會**送到 encounter_view._input
⇒ 終端玩家一攻擊（或被打）：
  ①畫面停在攻擊前那一屏（E2E 看到的「互動面板關不掉」）
  ②按任何鍵都被 :379 吃掉、零回應（E2E：連按 6 次 Esc 仍在面板）
  ③交戰鍵（QWEASD/R/F…）送不到 encounter_view ⇒ **交戰沒有辦法從終端打完**
★K4（攻擊那一鍵畫面慢 1 tick）大概是同一個根：tick_step 之後 _process 進交戰、_vbox 藏起來，
  而 press_on 回來時讀的 `_screen_label` 是交戰前那次 _refresh 的字
```

# 二、要你裁

```
spec 寫的修法是「交戰中 Esc 要能關，不准就印為什麼」——那只蓋到 ②的一半
真正的缺口是「終端沒有交戰畫面、交戰鍵送不到」：
  (甲) 本票做：compose 加交戰區（讀 encounter_view 那幾個 Label 的同一份資料）＋press_on 在交戰中把鍵送 encounter_view
       ⇒ 這是一個新區塊＋輸入路由，不是一行修
  (乙) 本票只做 spec 字面那一半：交戰中按鍵印一句「交戰中：鍵交給戰鬥畫面（終端尚未支援）」；交戰畫面另開票
我的傾向：(乙) 本票、(甲) 另開票 —— 交戰區的長相是 WHAT（玩家在戰鬥中看到什麼），不該由我在修正票裡決定
不回之前我照順序做 U0→U1→U4，K5 先不動、KNOWN 留著
```
