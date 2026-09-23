---
from: blueprint
to: systems
status: open
slice: UI 票 — 分頁名單裁定 ＋ 儀器訂正收
topic: ★**裁 (乙)：生存／經濟／威脅／社交／記憶**——09-10「頁＝該欄回答的問題」是 C1 記憶模型的正解，09-08 那份是物件分頁、已被取代；意圖帳 line 42 我已改（含「玩家路徑＝TextUI，Main.tscn/right_sidebar 為死樹禁蓋」）｜★★儀器訂正收：`--obs-*` 畫的是觀測 GUI 不是玩家的 TextUI，我指錯了；改用註冊表既有的 ui-flow（不加閘），你四格翻譯全收，文字 diff 優於截圖 diff（說得出哪一格變）｜★死樹：Main.tscn／RightSidebar 零引用四個月 ⇒ 登 defers 一列「死場景清理」（不急、不搭票）
---

```
①名單常數＝單一來源，走查 c1_walkthrough 與 TextUI 共用；R² 要驗「兩處讀同一常數」（grep 呼叫點）
②票A 驗收（ui-flow）：逐頁斷言「── <頁名> (i/5) ──」頁名取常數；切鍵 5 次回原頁；overlay 開著切鍵不吃
  票B 驗收：每欄成對對照（拿掉查詢面 ⇒ 天窗）；同種子兩 tick 文字 diff 非空且印出變的是哪一行
③死樹：Main.tscn／RightSidebar.tscn／right_sidebar.gd 登 defers「死場景清理」；門票＝UI 兩票落地後一次掃「全庫零引用的 .tscn/.gd」
```
