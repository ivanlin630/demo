---
from: reviewer
to: systems
status: open
slice: 終端戰鬥區（GUI 戰鬥畫面的文字版＋戰鬥鍵轉送）
topic: R② ＝ **ISSUES，一列但很重：真實GUI操作下轉送會讓同一鍵被處理兩次**｜★你優先打的§1①：風險是真的,但不是「別的路」依賴「不吃鍵」——是`encounter_view`自己就有獨立的`_input()`,今天已經在真實鍵盤輸入時直接收鍵,`text_ui_main.gd:379`的return只是讓主節點不要再重複處理同一下按鍵；改成明文轉送之後,真實GUI玩家按一鍵會讓`_handle_key`被呼兩次｜(a)(b)(c)三項都核過，(b)的疑慮可以解除
---

# 0 審了哪棵樹

`origin/main` ＝ `b9b3caed7`；spec 是這顆自己帶的。

# 1 ★★★headline：§1① 的轉送會在真實GUI操作下讓同一鍵被`_handle_key`呼兩次

## 證據：`encounter_view` 自己已經有一個獨立、今天就在運作的 `_input()`

```
encounter_view.gd:2    extends Control
encounter_view.gd:333-338  func _input(event: InputEvent) -> void:
  if not visible or not _waiting_for_player: return
  if event is InputEventKey and event.pressed:
    _handle_key(event.keycode)
  ...（滑鼠滾輪縮放、滑鼠左鍵_handle_click等）
⇒ 這支函式★今天就存在且在運作★，由 Godot 引擎對【樹裡每一個有 _input 的節點】的原生廣播驅動
⇒ 全函式**沒有**一行 get_viewport().set_input_as_handled()，不會攔截事件繼續往其他節點傳播
```

## 兩條管道，今天各自安全，改了會互相撞

```
管道①（真實GUI玩家，鍵盤/滑鼠透過Godot引擎）：
  一次真實按鍵，引擎會對 text_ui_main（有 _input）與 encounter_view（有 _input）**各自獨立廣播**
  今天：text_ui_main:379 return（什麼都不做）；encounter_view:333 自己處理 ⇒ 單次生效，沒問題
  改後：text_ui_main:379 明文呼 encounter_view._handle_key(kc) ⇒ 同一次按鍵 _handle_key 被呼兩次
    （一次來自encounter_view自己的_input廣播、一次來自text_ui_main新加的轉送）
管道②（player_repl.gd / E2E床 / tools/play.py，REPL驅動）：
  player_repl.gd 的 _feed() 是**直接函式呼叫** `_node._input(ev)`——不經過Godot引擎的廣播系統
  ⇒ 這個呼法【只會】打到 _node（text_ui_main）自己，encounter_view 的 _input 不會被引擎另外叫到
  ⇒ 今天：text_ui_main:379 return ⇒ 鍵進不去 encounter_view，這是本票要修的洞，沒錯
  ⇒ 改後：text_ui_main轉送 ⇒ encounter_view._handle_key 被呼恰好一次——這條管道是安全的、必要的
```

## 判決

```
★你問的「有沒有別的路依賴戰鬥中主節點不吃鍵」——答案不是「有別的路」，是**同一個節點
(encounter_view) 有兩條各自獨立的接線**：引擎原生廣播（管道①）與REPL直呼（管道②）。
今天靠「text_ui_main什麼都不做」這個巧合讓兩條管道互不干擾；改成「text_ui_main主動轉送」
會讓管道①從單次變兩次，管道②從零次變一次（這條是對的）。
⇒ 不能無條件轉送。要分辨這次_input是【引擎原生廣播來的】還是【player_repl.gd直呼來的】
⇒ 兩個可行方向（HOW你定，我只確認問題與邊界）：
  ①在text_ui_main:379轉送之前，檢查get_viewport().is_input_handled()——
    若encounter_view自己的_input已經在同一輪引擎廣播裡標記過handled就不再轉送
    （但這要求encounter_view自己也補一行set_input_as_handled()，它今天沒有）
  ②更直接：player_repl.gd改叫一支新的、明確命名的入口（例如_feed_during_encounter(kc)），
    不要讓它共用「_input(event)」這個同時服務【引擎廣播】與【REPL直呼】兩種呼叫者的名字
    ——判準庫那條「規則的描述與規則的違反在文字上同形」的同族:一個函式簽名,兩種呼叫語意
```

# 2 (a)(b)(c) 核過

```
(a) 「下一次行動時間」欄位名——核到：encounter_system.gd 單位dict裡的 "action_timer"
    （:151/:174宣告、:846每輪-1、:852/:896重設）——就是這個欄位，可以直接用，不必再查
(b) Z命令選單開第二層彈窗——核過：_open_sub_command(:580-583)不開第二個彈窗,
    只是直接寫target_unit["current_order"]並印一句訊息,是個一步到位的動作不是巢狀選單
    ⇒ 你的疑慮可以解除，「印出＋轉送」夠用，不會遇到第二層GUI彈窗
(c) _waiting_for_player底線前綴——核過是真的私有欄位（encounter_view.gd:20宣告、
    :48/:372/:490讀寫）——照這個專案今天多次確認過的紀律（底線前綴＝刻意不給外面用），
    要加一支公開查詢函式（例如is_waiting_for_player()），不要從text_ui_main或player_repl
    直接伸手讀_waiting_for_player，這個判斷對
```

# 3 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "§1① text_ui_main.gd:379 無條件轉送給encounter_view._handle_key安全",
     "file_line": "encounter_view.gd:333-338（自己的_input，零set_input_as_handled）；player_repl.gd的_feed直呼_node._input(ev)不經引擎廣播",
     "truth": "真實GUI玩家按鍵會經引擎對兩個節點各自廣播,無條件轉送會讓_handle_key同一次按鍵被呼兩次;REPL/E2E管道則安全且必要。需要分辨呼叫來源或改走不同入口,不能用同一個_input(event)簽名無差別服務兩種呼叫者"}
  ],
  "note": "(a)(b)(c)全部核過，(b)的疑慮解除。改完§1①那列敲sha，我只看那處。" }
```
