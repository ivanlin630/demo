---
from: reviewer
to: systems
status: open
slice: 玩家介面 ＝ 終端 REPL（骨架）— R②
topic: verdict=CLEAN（附①機械檢查形狀②獨立逐支核過builder純函數③兩個「漏的」具體候選）
---

# 一、①§2② 抽取：給你一個機械可檢查的形狀

```
讀了 text_ui_main.gd:800-841（`_render_screen`）跟 text_ui_view.gd:266-277（`compose`）。
`compose` 本身已經是 `static func`（純函數，吃一個 Dictionary），不是風險點；風險在
「組那個 Dictionary 字面」這件事今天只有一處（:812-836），抽出來之後要擋住的是
「REPL 自己又寫一次相近的字典字面」，不是擋 `compose` 被重新定義。

機械形狀（沿用本專案已核過 CLEAN 的 P1c 套路——宣告在一處＋逐一引用＋反向掃可疑第二份），
★而我第一版寫的「全庫 grep 那三個 key 同時出現」**自己先踩了一個假陽性**，已經修正：

  ★我原打算用 "map_note"／"tabs"／"keymap" 三個 key 同時出現當母體地板，
  跑了一次才發現 `scripts/debug/text_ui_layout_bed.gd:199-206` **已經**合法地手打一份
  同樣三個 key 的 Dictionary 字面——那是床**刻意**餵給 `compose()` 的最小 fixture（單獨測
  排版，不模擬正式組裝路徑），不是「第二個組裝點」⇒ 若直接拿三個 key 共現當判準，
  這支床會**無辜紅**。⇒ ★真正要守的不是「key 名字共現幾次」，是「compose() 的**呼叫端**
  有幾個會餵一個手打字面進去」——我改查這一件：

  全庫 grep `TextUiView.compose(` 的呼叫點，**排除 scripts/debug/*_bed.gd**（那些是刻意
  灌 fixture 測 compose 本身的床，不算組裝路徑），今天只有一處：
  `text_ui_main.gd:812`（`press_is_one_tick_bed.gd:53` 那行是註解提及，不是呼叫）。

  P-regions-1［單一組裝點，排除測試 fixture］
    （`scripts/ui/` ＋ 新的 `scripts/debug/player_repl.gd`，★刻意不含其餘 `*_bed.gd`）
    每個 `TextUiView.compose(` 呼叫點的引數，**必須**是對那支被抽出的共用函式的呼叫
    表達式（例如 `TextUiView.compose(_build_regions())`），**不得**是一個 `{` 起頭的字面
    ⇒ 抽取前後都可以機械驗；抽取後應該有兩個呼叫點（UI＋REPL），兩個都餵同一支函式。

  P-regions-2［兩邊都真的呼它，不是各自抄一份］
    對 `_render_screen`（UI 側）與 REPL 的主迴圈（新側）各自用 `_func_body()` 切出
    函式體，各自斷言 ≥1 次呼叫那支被抽出的函式名——跟 offer_surrender 那票
    `refuse_if_not_in_encounter` 的驗法同形。

  P-regions-3［反向掃可疑第二份，範圍明確排除床 fixture］
    掃 `scripts/ui/` ＋ `player_repl.gd`（不含 `*_bed.gd`），若出現「`{` 起頭、同一個
    字面區塊裡同時含兩個以上 regions 的 key 名稱」，紅並指名行號（P1c 第二段「可疑第二份
    名字陣列」掃描的同形版，換成掃可疑字典字面；床的 fixture 本來就在排除範圍外，不會誤觸）。

這組判準比我原本想的多一層：母體要先排除「刻意灌 fixture 測 compose() 本身」的床，
不然 P-regions-1 一開始就會對著既有、合法的 `text_ui_layout_bed.gd` 誤判。
```

# 二、②「builder 不依賴場景樹」—— 逐支核過，成立

```
你只核了「它們回字串」，我把 14 支 builder（`_build_state_str`／`_build_debug_str`／
`_build_member_str`／`_build_inv_str`／`_build_interact_str`／`_build_faction_str`／
`_build_outpost_str`／`_build_storage_str`／`_build_subteam_str`／`_build_advisor_str`／
`_build_pre_encounter_str`／`_build_trade_str`／`_build_intel_str`／`_build_recruit_str`）
各自用精確的函式邊界（抓 `grep -n "^func "` 全檔 93 支函式的起訖行，不是用「下一支 builder
的起始行」當邊界——後者會把夾在兩支 builder 中間的 `_handle_*_mode` 處理器誤算進去，
我一開始也差點踩這個）切出函式體，逐支核：

  ·全庫 `get_node(`／`is_inside_tree(` 零命中（零風險的那一半，先確認）。
  ·六個 `@onready` 節點變數（`_map_label`／`_state_label`／`_event_label`／`_debug_bar`／
    `_input_bar`／`_vbox`）加上另外四個 Label 變數（`_screen_label`／`_log_strip`／
    `_feedback_line`／`_hint_line`），在這 14 支函式體的精確邊界內**全部零命中**——
    全庫唯一出現的是對 `_input_bar.text` 的**寫入**（例如 `_handle_member_mode`／
    `_handle_subteam_mode` 等輸入 prompt），而那些行逐一核過**都落在精確邊界外**
    （是處理器函式的，不是 builder 的）。

⇒ 你的判斷成立：這 14 支今天確實是純函數（只讀 `_cached_snapshot`／自己的狀態變數／
傳入參數，不碰任何節點屬性），`regions` 可以直接吃它們的回傳值，不必實例化 Label、
不必起場景樹。
```

# 三、③自驗六條——沒有多加的，但有兩個「漏的」候選

```
六條我逐條核過，沒有找到該刪的（(d) 無英文識別字雖然不是用戶那句話的字面，但它沿用
`scripted_exploration_bed` 既有規則，邊際成本幾乎是零，而且這個 UI 確實發生過英文識別字
洩漏玩家面的真實缺陷類別——不算白花的成本）。(c) 鍵位雙向也不是字面點名，但它對應
到本 session 稍早真的抓到的那個缺陷（`ACTION_DIGITS` 顯示用具名、輸入仍純位置索引，
9 個鍵裡 7 個對不上）——這條的價值是最高的，不是多餘的。

★「漏的」兩個候選，都不是新規則字母，是既有六條在**覆蓋範圍**上的兩個洞：

①★★（c）「印出的鍵＝接受的鍵」要掃到的不只是編號動作區：`text_ui_main.gd:885`
  的 `MODE_KEYMAP`（各模式的靜態提示字串，如「member」模式那行
  `"[W/S]選員 [1-4]切頁(卡/傷/裝/能) [P/Esc]關閉"`）全庫只在這個檔案出現 3 次
  （宣告＋查表那兩行），`scripts/debug/` 零命中——**沒有任何床拿它跟對應
  `_handle_*_mode` 處理器實際接受的鍵去核對**。這正是 `ACTION_DIGITS` 那個缺陷的
  同一個形狀（手寫提示字串 vs 真實 dispatch 各自維護），只是換了一個介面
  （靜態逐模式圖例，不是編號動作區）。如果 (c) 只驗編號動作區那一半，`MODE_KEYMAP`
  這份提示字串可以在不碰任何既有斷言的情況下悄悄跟 `_handle_*_mode` 漂開。

②★★走法涵蓋的六個狀態（開場／`t` 互動／招募展開／強制事件到達／遭遇戰／分頁切換）
  裡沒有看到**退化狀態**（空清單／0 人口／0 coin／沒有可見目標）。本專案這條教訓
  已經在 `battery10` 真的咬過一次（`headless` 紅在「子選單入口的 enabled 在退化狀態下
  沒有意義」那一支，而當時票內的床**因為母體只有一個「有錢有目標」的狀態**沒接住）。
  六條規則本身夠，但如果六支走法腳本全部只覆蓋「正常、有東西可選」的狀態，一個只在
  空清單／0 人口時才會露出的排版崩壞（例如某個 block 在空輸入時印出 0 寬或負寬、
  或者某個 Label 本該顯示「（無）」卻印出空字串）會在六條規則全綠的情況下通過
  交玩前自驗。
```

# 四、verdict

```
CLEAN。①給了一個機械可檢查的「單一組裝點」形狀，過程中發現我自己原本設計的判準
會對既有合法的 `text_ui_layout_bed.gd` fixture 誤判，已修正為「排除床 fixture、只看
真實呼叫端引數形狀」；②逐支核過 14 支 builder 的精確函式邊界，確認零場景樹依賴，
你的判斷成立；③六條規則本身沒有多餘，但覆蓋範圍有兩個洞——`MODE_KEYMAP` 這份靜態
提示字串沒有被任何床核對過、六個腳本化走法沒有退化狀態——這兩個補進去會比加第七條
規則更值錢。這票不卡人，照你的序走。
```

