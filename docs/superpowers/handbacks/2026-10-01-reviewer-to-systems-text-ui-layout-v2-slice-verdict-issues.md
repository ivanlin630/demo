---
from: reviewer
to: systems
status: consumed
slice: feat/text-ui-layout-v2 三顆(接電+ACTION_DIGITS+tick_clock)
topic: verdict=issues,②找到一個比你問的問題嚴重得多的真缺陷,建議擋merge。①核過P28真的補上了靜態半的牙齒(讀了真實instantiate node的_screen_label.text,不是grep子字串),沒有同一種盲——靜態半剩下的窄範圍(只驗call graph)已經被P28的行為證backstop,不是compose()結果被丟棄也能過關的形狀。②★★★不只beg/ignore按不到——我讀了_handle_interact_mode的實際按鍵處理(:1637-1644),它是純位置索引(num=keycode-KEY_1,actions[num]),完全不查ACTION_DIGITS;而action_block()的顯示是純名字查表(ACTION_DIGITS.get(aid));這兩套機制在本slice之前預設一致(舊_build_interact_str也是位置式ordinal),本slice只換了「顯示」沒有換「輸入」,造成9個有標籤的動作裡7個顯示的數字跟實際按下去選中的動作對不上(只有recruit_anon/invite_settle兩個因為剛好排在陣列尾端而巧合對上)。這不是「誠實的限制」或「兩個動作被靜默關掉」,是幾乎全部動作的按鍵提示都在說謊,嚴重度遠高於原本問的問題。③核過MINUTES_PER_HOUR的獨立性是真的成立,不是虛設的區分:讀了tick_clock()公式本體,它是用TICKS_PER_HOUR算「這個鐘頭過了幾成」的比例再用MINUTES_PER_HOUR縮放成0-59分鐘顯示,這個公式結構上對TICKS_PER_HOUR改變是健壯的(旋鈕變،比例計算自動跟著變,而分鐘顯示的60這個時鐘慣例不該跟著變),兩者只是今天數值剛好相等不是同一件事,不是抄了一份
consumed-by: 同上（BLOCKER 信 §五 逐字收錄他的兩件發現與我對他一處 off-by-one 的訂正）
consumed-note: ★他獨立抓到同一缺陷而方向相反（我：按下畫面印的鍵會執行什麼／他：要按哪個鍵才選到它）⇒ 兩個方向都寫進信裡。★★他多給兩件：9 個裡 7 個對不上且兩個是【巧合對上】／本 slice 之前兩套機制預設一致（舊 _build_interact_str 也是位置式）⇒ 落差是這次造成的。★★★我否決他的 (b)（顯示改回位置式）：那會讓「一個鍵永遠是同一個動作」作廢，而那是藍圖裁 (乙-1) 唯一在乎的性質 ⇒ 走 (a)。
---

# 一、①靜態半有沒有同一種盲——核過沒有，P28 真的補上牙齒

```
讀了 P28（ui_flow_test.gd:2994-3018）：`node = await _make_ui(); node._refresh()`
是真實 instantiate 的節點、真的呼叫 `_refresh()`，然後讀 `node._screen_label.text`
——這是讀【真實執行後的節點狀態】，不是掃原始碼文字。六個 REGION_ANCHORS 各剛好
一次、七個舊 carrier 的 `.visible` 全部 false、`_state_label.text` 非空（內容
還在）——三條斷言各自獨立，合起來能抓到「compose() 被呼叫但結果被丟掉／寫到
別的地方」這種深一層的盲：若有人把 `_screen_label.text = TextUiView.compose(...)`
改成 `var _unused = TextUiView.compose(...)`，靜態半（只數 `TextUiView.compose`
這個子字串在函式體出現幾次）一樣會通過，但 P28 的錨計數會全部變成 0——真的會紅。
⇒ 靜態半現在剩下的窄範圍（只驗 call graph：_refresh 呼 _render_screen、
_render_screen 呼 compose）已經被 P28 的行為證頂住，不是同一種「分不出定義與
呼叫」的病复發。①核過成立。
```

# 二、★★★②不只 beg／ignore 按不到——我讀了實際按鍵處理，找到更嚴重的真缺陷

```
你問的是「beg/ignore 沒有 ACTION_DIGITS 項，是不是玩家按不到」。
我去讀了【實際處理按鍵的那段 code】（text_ui_main.gd:1637-1644，本 slice
完全沒有碰這一段——diff 裡零命中）：

  var num: int = (keycode - KEY_1) + _interact_page * 9
  var actions: Array = _interact_action_split()["team"]
  if num < actions.size():
      var act: Dictionary = actions[num]

⇒ 實際選中哪個動作，是【純位置索引】——按下的數字鍵對應陣列裡第幾個，
完全不查 `ACTION_DIGITS`。而 `action_block()`（text_ui_view.gd:161-178，
本 slice 新增的顯示函式）是【純名字查表】——`ACTION_DIGITS.get(aid)` 決定
畫面上印哪個數字。這兩套機制是各自獨立的系統，彼此不知道對方存在。

`_interact_action_split()["team"]` 的陣列順序＝ `TEAM_TARGET_ACTIONS` 的宣告
順序：ignore(0)、attack(1)、trade(2)、propose_alliance(3)、demand_tribute(4)、
extort(5)、recruit(6)、recruit_anon(7)、invite_settle(8)、gather_intel(9)、
beg(10)。我逐一核對「實際按哪個鍵會選中它」vs「畫面印的是哪個鍵」：

  動作            實際鍵(位置)  畫面印的鍵(ACTION_DIGITS)  對不對
  ignore          1            （未綁鍵）                 ✗（其實按得到，卻說沒鍵）
  attack          2            6                          ✗
  trade           3            1                          ✗
  propose_alliance 4           2                          ✗
  demand_tribute  5            3                          ✗
  extort          6            7                          ✗
  recruit         7            4                          ✗
  recruit_anon    8            8                          ✓（巧合：剛好排在陣列尾端）
  invite_settle   9            9                          ✓（巧合：同上）
  gather_intel   （需第2頁）    5                          ✗（顯示的鍵在第1頁按了會選中別的動作）
  beg            （需第2頁）   （未綁鍵）                  ✗（同上，而且根本沒顯示鍵）

⇒ 9 個「有顯示鍵」的動作裡，**7 個顯示的數字跟實際按下去選中的動作完全對不上**
（只有 recruit_anon／invite_settle 兩個因為剛好落在陣列尾端而數字巧合吻合）。
玩家看畫面上寫「[3] 要求納貢」去按 3，實際選中的是 trade（貿易）。

⇒ 這不是你問的「誠實的限制」或「兩個動作被靜默關掉」——是幾乎整張動作表的
按鍵提示都在說謊，嚴重度比「2 個動作沒有顯示鍵」高得多：那 2 個沒顯示鍵的
（ignore／beg）裡，ignore 其實還真的按得到（位置 1），只是畫面沒告訴玩家是
哪個鍵；而另外 7 個「有顯示鍵」的反而是主動在誤導玩家按錯動作。

★為什麼這是本 slice 造成的、不是既有問題：diff 裡 `_handle_interact_mode`／
`num`／`ACTION_DIGITS` 在 `text_ui_main.gd` 完全沒有被碰（git diff 零命中）
——本 slice 只新增了【顯示】（`ACTION_DIGITS`＋`action_block`），沒有同步改
【輸入處理】。而本 slice 之前，舊的 `_build_interact_str()`（:1786-1792,
現在仍在、只是寫進已隱藏的 `_event_label.text`）用的也是位置式編號
（`a_shown` 迴圈計數，不是名字查表）——舊顯示與輸入處理彼此一致（都是位置），
是本 slice 換了顯示卻沒有同步換輸入，造成兩者第一次出現落差。

⇒ 建議：這一格要在 merge 前修，不是下一輪再說。修法兩選一：
  (a) 把 `_handle_interact_mode` 的選取邏輯從位置索引改成用
      `ACTION_DIGITS`／`key_for()` 反查該按鍵對應哪個 action_id（讓輸入跟
      顯示共用同一份真相），或
  (b) 把 `action_block()` 的顯示改回位置式編號（不查 ACTION_DIGITS，跟輸入
      處理保持一致），但這樣 `ACTION_DIGITS` 那個「母體 11、鍵 9、2 個沒鍵」
      的整個設計就要重新想過（它原本假設的是「固定名字對應固定鍵」）。
  ★我沒有找到第三個選項能讓兩邊都不動——它們現在就是互相矛盾的兩套真相。
```

# 三、③MINUTES_PER_HOUR 的獨立性——核過是真的，不是虛設的區分

```
讀了 `tick_clock()`（player_api_mapper.gd:530-537）的公式本體：
  var minute: int = int(float(rem % per_hour) / float(per_hour) * float(MINUTES_PER_HOUR))
這是「這個鐘頭已經過了幾成」（`rem % per_hour` 除以 `per_hour`，一個 0~1 的
比例）乘上 `MINUTES_PER_HOUR` 縮放成一個 0~59 的分鐘顯示。★這個公式結構上
對 `TICKS_PER_HOUR`（世界唯一自由參數）改變是健壯的：改了 `TICKS_PER_HOUR`，
比例計算的分子分母會一起變、算出來還是同一個比例；而 `MINUTES_PER_HOUR`
（時鐘慣例，永遠 0~59）不該跟著變，也確實不會。

我一開始的直覺是「`TICKS_PER_HOUR` 本身的註解就寫『1 tick ＝ 1 分鐘』，
那不就等於 `MINUTES_PER_HOUR` 嗎」——但讀完公式發現那是【今天的巧合值】，
不是【結構性相等】：`TICKS_PER_HOUR` 是遊戲時鐘的粒度（旋鈕），
`MINUTES_PER_HOUR` 是顯示時鐘的換算慣例（世界事實），公式把兩者用在不同
角色上，只是剛好數值相同。這條分界在 code 的公式結構裡看得見，不是一句
沒有支撐的註解。③核過成立，不是抄了一份。
```

# 四、verdict

```
issues——不是文字層的小補丁。①③核過成立，無異議。②找到一個比你原本問題
更嚴重的真缺陷：本 slice 新增的顯示層（ACTION_DIGITS／action_block）與既有
的輸入處理層（位置式索引）互相矛盾，9 個有顯示鍵的動作裡 7 個按鍵提示是
錯的（玩家照畫面按會選到別的動作）。建議擋這次 merge，直接在本 slice 裡
修好（見二節的兩個選項），不要留到下一輪——這個形狀（顯示與輸入各自一套
真相）比「有 2 個動作沒有鍵」危險得多，而且今天已經出貨會被玩家立刻撞到。
```
