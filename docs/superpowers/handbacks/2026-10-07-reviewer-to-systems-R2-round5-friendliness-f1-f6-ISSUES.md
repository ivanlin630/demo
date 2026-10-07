---
from: reviewer
to: systems
status: consumed
slice: 第五輪友善度 F1-F6 一併判決
topic: R② ＝ **ISSUES,兩列**｜★你優先打的F2：核過安全——`ACTION_DIGITS`(text_ui_view.gd:88)是**靜態name→key字典**,不是位置索引,折疊不會動到它,而這專案已經有一次血證(action_for_key註解:212-221,舊版「畫面用id查、handler用位置索引」導致按鍵對不上動作,已修成單一權威)；★F3：引擎能給部分hint(demand_tribute→recruit,invite_settle→move_to自家據點),但有的disabled_reason確實無解除動作(propose_alliance/trade),"—"不硬湊的設計對；但找到第三種disabled-reason產生者(`precheck_*`系列用欄位名"reason"不是"disabled_reason")，F3的盤點範圍要把它們也算進去才不會漏｜F5兩題：NAMED_KEYS token逐字核對上(9個全對);Ctrl+C→離開要確認走既有QUIT_TOKEN(":quit")不是另開一條路;msvcrt在VS Code/Windows Terminal下是不是tty——這題讀code答不出來,是環境行為不是本專案程式碼問題，需要實測
---

# 0 審了哪棵樹

`origin/main` ＝ `18bbff2ff`。

# 1 ★F2——核過安全，而且這個專案已經為同一種病吃過一次虧

```
text_ui_view.gd:88 `const ACTION_DIGITS: Dictionary = {...}`——鍵是action_id→鍵號的靜態表,
  跟畫面上第幾行完全無關
text_ui_view.gd:197-205 `action_block()`的迴圈：`var key=ACTION_DIGITS.get(aid,"")`——
  逐個action_id各自查表,不是用迴圈的index算鍵號
⇒ F2要摺疊的是【哪些列會被印出來】,不是【action_id對應哪個鍵】——這兩件事完全獨立,
  摺疊不可能讓鍵號漂移
★而這專案已經踩過反例：text_ui_view.gd:212-221的註解逐字記著一次真實血證——舊版畫面
  用ACTION_DIGITS[action_id]印鍵,handler卻用位置索引actions[num]執行,「提議結盟」的
  鍵按下去會變成攻擊,「打聽」的鍵變成索貢。修法是訂出action_for_key()當唯一反查權威,
  handler一律呼它不准自己手抄對照表。F2沿用同一套靜態id機制,不會重蹈那個覆轍
```

# 2 ★F3——引擎確實能給部分hint，但盤點範圍漏了一種形狀

## 核過：引擎層(get_action_availability)對部分reason確實能指出解除動作

```
player_command_system.gd:107-111 "demand_tribute"的reason="人口不足"
  ⇒ 解除動作明顯是recruit/recruit_anon(讓人口變多)——引擎在這個match arm裡
  本來就有pt.population跟判斷context,加一個hint欄位是零成本的
player_command_system.gd:124-127 "invite_settle"的reason="你不在自家據點上"
  ⇒ 解除動作＝move_to自家據點——同樣在這個match arm裡context現成
player_command_system.gd:103-106 "propose_alliance"的reason="對方已經和你同一個勢力"
  跟:99-102 "trade"的reason="雙方都沒有可交易的錢"——這兩個【真的沒有】單一動作可以
  解除(已經同勢力這件事沒有「去做點什麼」能改；雙方都沒錢也不是按一個鍵就有錢)
⇒ 你spec自己寫的"指不出的寫—不硬湊"是對的設計,我核過至少有兩類reason真的指不出來,
  不是implementer偷懶
```

## 但有第三種disabled-reason產生者，用的欄位名不一樣，F3的盤點會漏到它

```
player_command_system.gd:515-615一整組`precheck_cancel_move`／`precheck_establish_faction`／
  `precheck_take_loot`／`precheck_camp`／`precheck_rest`...（12支）：這些回的dict用的欄位名
  是★"reason"★不是"disabled_reason"(跟get_action_availability的:142不同)
player_api_mapper.gd/player_query_api.gd另外還有：inquiry_system.gd:49 `DISABLED_REASON`
  字典(打聽題目的灰掉原因,我上週審過的那張票)——用的欄位名又是"disabled_reason"
  但來源完全獨立(另一個字典,不是get_action_availability)
⇒ F3寫「先盤點今天有幾個disabled_reason」——這句話字面上只會抓到用這個確切欄位名的
  地方,precheck_*那12支用"reason"命名,一個照欄位名搜的盤點會直接漏掉它們；
  而這12支產生的原因句(例如紮營離據點太近)正是用戶第四輪截圖裡最早被抱怨的那種句子,
  不盤點到它們,F3對用戶最在意的那組問題反而沒有覆蓋
⇒ 補一句：盤點範圍不要用欄位名字搜,要照「所有會印在玩家面上的『不可／為什麼不可』句子」
  這個語意去找producer,precheck_*系列跟inquiry_system的DISABLED_REASON都要算進去
```

# 3 ★F5——兩題核對，一題答不出來（環境行為非本專案code）

## token名稱核對：逐字跟NAMED_KEYS對上

```
player_repl.gd:51-59 NAMED_KEYS＝{esc,enter,space,tab,backspace,up,down,left,right}
  （9個）——spec列的9個token(esc/enter/tab/space/backspace/up/down/left/right)
  逐字跟這份對上,沒有另外發明名字,核對通過
```

## 一個小缺口：Ctrl+C→離開，要確認是不是走既有QUIT_TOKEN

```
player_repl.gd:66 `const QUIT_TOKEN: String = ":quit"`——這是★既有★的、專門用來跳出
  harness的token(跟遊戲內的Q鍵刻意分開,:61-63的註解逐字講這個理由：一個鍵兩個意思
  是本專案最常見的病)
⇒ spec只寫「Ctrl+C(\x03)⇒離開」,沒寫清楚它產生的token字串是不是":quit"
  (讓它走:215那段既有的QUIT_TOKEN判斷),還是play.py自己另開一條"if ctrl+c: sys.exit()"
  的捷徑——兩種讀法都說得通,補一句消歧義：Ctrl+C應該產生":quit"這個token,
  走同一條既有退出路徑,不要另開第二條
```

## msvcrt在VS Code整合終端／Windows Terminal下算不算tty——讀code答不出來

```
這題問的是★第三方終端模擬器的行為★,不是這個repo自己的程式碼——靠讀code/git grep
  沒有辦法驗證msvcrt.getwch()或sys.stdin.isatty()在那兩個具體終端環境下回什麼值,
  這超出靜態讀碼能回答的範圍(跟判準庫那條「讀得出存在讀不出次數」是同一種邊界,
  這裡更進一步是讀不出【別人家軟體的行為】)
⇒ P5a(--selfcheck不起Godot)測的是key_token()這支純函式的對照表,P5b測的是管道
  (非tty)退回逐行模式——★兩個都沒有測「在真的VS Code整合終端或Windows Terminal
  裡跑起來是什麼樣子」,這件事目前沒有任何P項目覆蓋,因為它天生不能寫進自動化腳本
  (需要人坐在那兩個終端裡實際按鍵)
⇒ 處置：加一個人工驗證步驟(不是床,是一行操作說明)：交件前請在VS Code整合終端跟
  Windows Terminal各跑一次play.py單鍵模式,確認按鍵真的即時生效,這件事沒有自動化
  替代品，只能承認它、排進交付清單，不是我能在這裡幫你確認的
```

# 4 F6——拆刀方向沒有矛盾，F1/F4沒有深入查

```
F6的「資料→區塊資料→字串」兩步拆分跟我這學期已經讀過的TextUiView既有函式形狀一致——
  action_block/feed_block/compose這些今天就是吃Array/Dictionary(rows/regions),不是吃
  raw world state,F6基本上是把這個既有事實正式化、明文化,不是發明新架構,沒有找到矛盾
F1(開場三行)／F4(鍵列只印有效鍵)這輪沒有深入查file:line,只核過你指名的F2/F3以及
  額外問到的F5；F1/F4若要我核可以下一輪指名優先項
```

# 5 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "F3先盤點今天有幾個disabled_reason",
     "file_line": "player_command_system.gd:515-615(precheck_*系列12支,欄位名是\"reason\"不是\"disabled_reason\")；inquiry_system.gd:49(另一個獨立的DISABLED_REASON字典)",
     "truth": "盤點若照欄位名字搜會漏掉precheck_*那12支,而它們產生的原因句(例如紮營離據點太近)正是用戶最早抱怨的那種句子;盤點範圍要照語意(所有印在玩家面上的不可/為什麼不可句子)找,不要照欄位名"},
    {"claim": "F5：Ctrl+C(\\x03)⇒離開；msvcrt在VS Code/Windows Terminal下都算tty",
     "file_line": "player_repl.gd:66(QUIT_TOKEN既有退出機制)",
     "truth": "Ctrl+C產生的token字串有沒有是\":quit\"(走既有退出路徑)沒寫清楚,補一句消歧義；msvcrt在那兩個具體終端下的tty行為是第三方軟體行為,讀code驗證不到,P5a/P5b都沒覆蓋這個情境,需要排進交付前的人工驗證步驟,不是能用審查擋下來或放行的事"}
  ],
  "note": "F2核過安全且有歷史血證佐證。F5的token對照跟F6的拆刀方向都核過沒矛盾。F1/F4沒有深入查這輪,下輪可指名。" }
```
