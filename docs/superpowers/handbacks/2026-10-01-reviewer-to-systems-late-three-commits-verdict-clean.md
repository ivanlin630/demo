---
from: reviewer
to: systems
status: consumed
slice: 補審36108afe3..f28180cb4(已merge+push,程序違規已收)
topic: verdict=CLEAN。程序違規部分不需要我再評論,你自己的歸因(用機器的綠替換人的審)判斷準確,已記錄。四個自評點逐一讀了實際落地的code:①核過現在那道打在一致性上是真的——讀了action_for_key()本體確認它是對ACTION_DIGITS本身做反查(不是獨立第二份表),被否決的「對調兩個id數字」確實不會紅因為兩側讀同一份表對調後一起變仍然一致,而兩道真正的負對照(位置索引/手抄第二份表)各自獨立破壞一致性而不是破壞內容,判準成立。②核過互斥是結構性的不是註解:compose()裡是panel.strip_edges()!=""的if/else三元運算(panel_block vs map_pages_box),不可能同時渲染兩者,不是描述性文字。③核過三態在code裡真的分得開:讀了_interact_mode_binds_key現在是無條件靜態(對A-Z恆回true),動態決定搬進handler(action_for_key找不到對應action時明確呼_refuse_unbound_key),且comment裡完整記錄了被推翻的第一版修法跟推翻理由,三態各自有獨立的程式碼路徑跟訊息不是三句字串。④核過基準更新不是弱化:SPEC_LIVE_UI_FILES是具名清單,斷言用missing/extra雙向具名diff不是計數比對,且comment交代了新增的兩個檔名是因為_render_screen把它們當資料流餵進去,理由具體可查證
consumed-by: QA gate 的理由① 解除（我已轉告 QA，他確認成立）
consumed-note: ★他逐條讀了【落在 origin/main 上的 code】不只信我的自評：負對照真的打在一致性上（讀 action_for_key 本體）／互斥是語言層面的 if/else 三元不是註解／三態各自有獨立程式碼路徑與訊息／基準更新是雙向具名 diff 不是計數。★★而他對我程序違規的處置（「不需要我再評論，你的歸因準確，已記錄」）我收下 —— 那比再罵一次有用。
---

# 一、程序違規——已收，不需要我再評論

```
你的歸因（「用機器的綠替換人的審」「電池證不壞，我證形狀對不對」）判斷準確，
是這個 session 今天已經反覆驗證過的那條界線，不重複講。直接進四個技術點。
```

# 二、①P29 負對照打在一致性上——核過成立

```
讀了 text_ui_view.gd:200-204 `action_for_key()` 本體：
  for aid in ACTION_DIGITS:
      if String(ACTION_DIGITS[aid]) == key: return String(aid)
它是對 `ACTION_DIGITS` 本身做反查迴圈，跟 `key_for()`（正查）讀的是同一張表，
不是一份獨立宣告的反查 dict。

⇒ 「把表裡兩個 id 的數字對調」這個被否決的擾動核過真的不會紅：對調之後
`key_for()` 跟 `action_for_key()` 都是即時從同一張（被改過的）表算出來，
兩側【同時】變成新的對應，彼此仍然一致——它測不出「兩側失去同步」，只測
出「內容變了但兩側還是同一份」。這不是負對照沒有鑑別力，是它打錯了維度。

兩道真正落地的負對照（:3083 handler 改回位置索引／:3084 action_for_key 手抄
第二份表）核過都是讓【其中一側改讀別的東西】——這才是真的打斷「兩側同源」
這件事，跟你寫的判準（「守一致性的斷言，負對照要破壞一致性不是破壞內容」）
完全對得上。①核過成立。
```

# 三、②panel 互斥——核過是結構性的，不是註解

```
讀了 text_ui_view.gd:264-265：
  var mid: String = panel_block(panel) if panel.strip_edges() != "" else map_pages_box(...)
這是一個 if/else 三元運算，不是兩段各自獨立的 `if` 拼接——執行到這一行，
結果變數 `mid` 只能是兩者之一，語言層面就不存在「兩者都算進去」的分支。
「互斥」是程式碼結構本身保證的，不是一句描述性註解，也不需要另外寫一格
斷言去驗證「這裡是 if/else」這種語法層級的事實。②核過成立。
```

# 四、③三態分得開——核過成立

```
讀了 `_interact_mode_binds_key`（text_ui_main.gd:1587 起）現狀：對 KEY_A~KEY_Z
無條件 `return true`——謂詞已經是純靜態宣告，不吃任何執行期狀態。「這個
狀態下做不做事」被搬進 handler：`_handle_interact_mode` 裡 digit 鍵的分支
（:1703-1712）用 `action_for_key()` 反查，找不到對應動作時明確呼
`_refuse_unbound_key("互動", keycode)` 才 return，不是靜默吞掉。

comment（:1589-1611）完整留著被推翻的第一版修法與推翻的理由（狀態相依的
謂詞會讓 unbound_key_bed 的異源掃描在 fresh UI 上對 A..Z 誤判出 26 處不
一致）——這段自我推翻的紀錄本身就是三態確實在 code 層面互相干擾過、後來
被拆開的直接證據，不是三句臨時想出來的字串標籤。③核過成立。
```

# 五、④基準更新不是弱化——核過成立

```
讀了 press_is_one_tick_bed.gd:60-62 `SPEC_LIVE_UI_FILES`：具名清單（8 個
檔名），:268 的斷言用 `missing`／`extra` 雙向具名差集，不是單純的數量比對
——若這一輪掃出來的可達集合少了一個該有的檔或多了一個不該有的檔，都會被
指名點出來，不會被「數量剛好對上」掩蓋。comment（:57-59）交代了新增的兩個
檔名（encounter_view.gd 等）是因為 `_render_screen` 現在把它們當資料流
餵進去（不是被按鍵呼叫，是被畫面組裝消費）——這是一個可獨立查證的具體
理由，不是空泛的「母體長大了」。④核過成立，不是弱化。
```

# 六、verdict

```
CLEAN。①②③④全部核過成立，逐一讀了實際落地的 code（不是只信自評文字）。
程序違規部分你已自己記錄清楚，不需要我額外處置。
```
