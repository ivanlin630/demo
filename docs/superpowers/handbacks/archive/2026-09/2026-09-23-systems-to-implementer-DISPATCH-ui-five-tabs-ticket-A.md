---
from: systems
to: implementer
status: consumed
slice: UI 五分頁 — 票A（框）
topic: ★DISPATCH 票A（R② issues 兩條已補，reviewer 的條件性 CLEAN 已達成）｜★★**先讀 spec §0**：`right_sidebar.gd` 在一棵**死樹**（`Main.tscn`，全庫零引用）底下——**蓋在那裡會通過每一支閘而玩家什麼都看不到**；玩家路徑是 `project.godot:14` 的 `TextUI.tscn`｜★★★**P2 那支新 cell 只准抄 `ui_flow_test.gd:408-424` 的 `InputEventKey`＋`node._input(ev)` 形狀**——26 支既有 cell 有 25 支繞過鍵盤路徑，抄錯的話 P2 會綠而綠的是「函式被呼叫」｜★不急：你先把改名驗證那輪跑完、放開機器
---

# 〇、spec

```
docs/superpowers/specs/2026-09-23-ui-five-tabs-HOW.md
R②：issues（兩條），已補 ⇒ reviewer 逐字：「補完即可視為 CLEAN → 可派票A」
★但 §2-3b 我採的是【第四種】（不在 reviewer 的三選一裡）⇒ 我已回他請他打；
  ★★他若反對我會立刻攔你 —— 在那之前你照 spec 做
```

# ★★一、動手前必讀的三件（★全部是 file:line，別靠印象）

```
①玩家路徑 ＝ project.godot:14 run/main_scene="res://scenes/TextUI.tscn"（text_ui_main.gd，2018 行）
②scenes/Main.tscn ＋ main.gd ＋ right_sidebar.gd ＋ 六個子場景 ＝【死樹】（全庫零引用，最後動 2026-05-31）
   ★★★不要碰、不要刪、不要蓋在上面（刪除另有 defers 列 dead-scene-tree-cleanup）
③scripts/ui/world_map_view.gd ＝【雙用途】（observer 分支 ＋ dormant player 分支，:27/:58/:84/:157/:173/:178/:182/:268）
   ⇒ ★本票不碰它；非碰不可 ⇒ 停、回我（碰它＝同時改到 ObserverMain，那是截圖冒煙格的家）
```

# 二、票A 做什麼（★框，不是內容）

```
①新檔 scripts/ui/ui_pages.gd（class_name UiPages）
     const PAGE_ORDER := ["生存", "經濟", "威脅", "社交", "記憶"]   ← blueprint 已裁
   ★★scripts/debug/c1_walkthrough.gd:17 改成讀它（刪掉它自己那份）
   ★★★禁止在 text_ui_main.gd 裡另寫一份頁名，或把頁名寫成字串字面值
②var _page_idx: int —— ★不進 _current_mode_name()（:640-654），★★不加 MODE_KEYMAP 第 13 列
   （分頁與 overlay 是兩個軸；R② 已證：11 個 overlay 全寫 _event_label，分頁寫 _state_label，不搶）
③切鍵進 MODE_KEYMAP["main"] 的提示字串
   ★[<][>] 或 [Tab] 是我【看鍵表挑的】，沒驗過撞不撞 —— 你第一次跑起來時確認，撞了就換並回我
④§2-3b：狀態列（頁外）＝ :675-679 三行 ＋ :740-749 Tick·Day；
   第 1 頁 ＝ 頁首 ＋「── 未分類（票B 將搬走：N 行）──」＋ :680-738 【逐字原樣】
   ★★★不要順手分類、不要順手美化 —— 那是票B，混進來紅燈就分不開了
⑤第 2–5 頁 ＝ 頁首 ＋ 具名天窗「<欄位名>：未接出（票B）」★不得靜默空白
```

# ★★★三、驗收（★P2 的形狀是硬的）

```
P1 框＋【零損失】：前後同種子同 tick，舊 _build_state_str() 的行集合 ⊆（狀態列 ∪ 第1頁），少一行＝紅
P2 鍵：切鍵循環 5 次回原頁；overlay 開著時切鍵不吃
   ★★★新 cell 必須是 InputEventKey.new() ＋ node._input(ev)（抄 ui_flow_test.gd:408-424）
   ★明文禁止 node._process(...) / node._bridge.set_player_input(...)
P3 單一來源：text_ui_main.gd 無頁名字面值；c1_walkthrough.gd 不再自帶 PAGE_ORDER
P4 天窗：未接欄位印「未接出（票B）」；★任一頁【全空白】＝紅
P5 ObserverMain 截圖冒煙照舊綠（證明沒弄壞另一棵樹）
P6 world-fp 不變 —— ★本票只讀不寫；fp 若動了那不是 UI 票
P7 merge 前全部 merge-gates（bash .claude/hooks/merge-gates.sh）
```

# 四、節奏

```
★你先把改名驗證那輪跑完、回報、放開機器 —— 本票【不急】，世代 8 已開、用戶手上已有啟動指令
★★而用戶【現在可能正在玩】⇒ 起 Godot 前照既有規矩看機器（電池那支煞車會自己擋，別繞過它）
★★★P1 的「前後行集合」要在【動手之前】先跑一次舊版存下來 —— 動完才想起來就沒有「前」了
```
