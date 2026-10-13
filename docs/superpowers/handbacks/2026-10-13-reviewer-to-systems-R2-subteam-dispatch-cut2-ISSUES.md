---
from: reviewer
to: systems
status: open
slice: R² 第二刀重審＋用戶追加三條（b37fbae25）
topic: R② ＝ **第二刀 ISSUES（小,三處）；追加三條『一律回句』在 code 上有一類【沒被 P1c 抓到】的靜默**｜①＋／－ 在 PlayerRepl 打不出來且輸入 handler 不收 ⇒ 刪掉;②可達判斷要在【按 N 當下/開面板時】做,不是答完三題才拒;候選與任務清單塞進單列提示會再被 clip 靜默截 ⇒ 清單放面板;③追加:真正的病在 _input_mode_binds_key 與 handler 不同步（letters/digits 兩型共用一張『綁了』表）——numeric 按字母、string 按數字都【通過綁定檢查卻無分支】＝使用者回報的『按字母沒反應』;另有 Enter 空緩衝／緩衝滿／int==0 三個『綁了且收下卻靜默』;提示列與回句共用同一列要算寬度;輸入期間的鍵列現在回 main（:1368-1372）
---

# 0 審了哪棵樹
main b37fbae25。核對 text_ui_main.gd:410,615-700,1355-1372,3028-3125;player_repl.gd:51-61,156-178;player_command_system.gd:2046;
spec docs/superpowers/specs/2026-10-13-terminal-input-prompts-and-threat-clip-HOW.md(第二刀、改法 1 追加、P1b/P1c)。

# 1 第二刀:方向對（照 ③ 重寫）,三處要改
```
✓ 目標格＝主畫面先定游標再開面板;面板不放行 WASD;_cursor(text_ui_main.gd:33)在面板開著時不變——成立。
✓ 全走 _open_input、不新增字母鍵、不撞 U/N/A/B、新狀態登記 unbound_key_bed——成立。
✓ 『可達判斷重用多格移動』:code 在 player_command_system.gd:2046（"無法抵達 (%d,%d)：沒有路…"）。重用要【抽出共用判斷函式】,不是呼叫 move_to（它會寫 task）;spec 寫『同一句型』也要共用字串來源。

①＋／－:不可行。numeric handler（:664-695）只收 0-9／Backspace／Enter／Esc;_input_mode_binds_key（:618-623）不含 MINUS/EQUAL;
   player_repl.gd keycode_for 有 "-"→KEY_MINUS、"="→KEY_EQUAL,【沒有 "+"】(Shift+= 的 token 是 "+",回 -1『打不出這個鍵』)。
   ⇒ 終端玩家按＋什麼都沒有。刪掉＋／－(數字＋Enter 夠用),或三處(binds_key／handler／keycode_for＋play.py token)一起改並進 P2——不要只寫在 spec 裡。
②可達判斷的時機:spec ④『確認 ⇒ 出發;不可達 ⇒ 拒』=答完隊長、人數、任務三題才被拒,是『按即做』的反面。
   ⇒ 開面板(或按 N)當下就算:面板頂端印『目標＝(q,r)（可達）』或『（不可達：原因）』;不可達時 N 直接拒並說原因,不進三題。出發時再驗一次(游標沒變,但世界會變)。
   P6 拆兩格:N 當下拒；出發前路被斷(佈置)再拒。
③提示列塞清單:隊長『1 張三 2 李四 …』與任務選單(_subteam_task_menu_str)進單列提示,名字長／任務多時又會被 clip_to 靜默截——
   正是第一刀 §2 剛修威脅句的同一個病。清單放在【面板】(追加條『開它的面板留在畫面上』已保證面板可見),提示列只印『選隊長 (1~N): 2_』。
   P4 加一格:候選 N=最大值、名字取最長 ⇒ 面板列出全部、提示列不被截。
另:Esc 在第 2/3 題的語意寫明(建議整串取消回面板,與追加條『Esc 回面板』一致);set_player_input 已寫的 sub_leader_id／sub_pop_count 在取消時要清,免得被別的動作讀到殘值。
```

# 2 追加三條(用戶):P1c 抓不到的那一類靜默【在 code 上有】
## 2.1 病根:binds_key 與 handler 兩型共用一張表,不同步
```
text_ui_main.gd:618-623 _input_mode_binds_key:任何 A-Z、任何 0-9、Esc/Enter/Backspace ⇒ 回真（不分 numeric／string）。
  ⇒ numeric 模式按字母:通過綁定檢查（不走 _refuse_unbound_key）→ numeric 分支只認 0-9／Backspace／Enter／Esc ⇒ 【落空、什麼都不做、沒有一句話】
     ＝使用者回報的『N 之後按字母像沒反應』的確切機制;
  ⇒ string 模式按數字:同理（:633-659 string 分支只收 A-Z）。
這兩格不是『未綁定的鍵』,P1c『送一個該模式不收的鍵』若挑的是 binds_key 回假的鍵（如 F1、符號）,【測不到它】——它會綠,病還在。
⇒ 修法:binds_key 依 _input_mode_type 分型（numeric:0-9＋Esc/Enter/Backspace;string:A-Z＋同三個）,不收的鍵走既有 _refuse_unbound_key 出口（一句話）;
   P1c 的送鍵必須【每型至少送一個『另一型的合法鍵』】(numeric 送字母、string 送數字)+【一個 binds_key 以外的鍵】,兩類都要。
```
## 2.2 『一律回句,不得例外』——收下卻靜默的三格
```
a. 數字緩衝滿:`if _input_buffer.length() < 6` 不滿足時,數字被收下又丟掉（:664-667）,無回句;string 模式 30 字同（:634-638）。
b. Enter 空緩衝:numeric（:672-696）與 string（:645-652）皆為『什麼都不做』（string 有 allow_empty 才通過）。玩家按 Enter 沒反應。
c. numeric 無 callback 的舊分支:`elif int(_input_buffer) > 0` 不成立（例:輸入 0）⇒ 靜默。
⇒ 『一律回句』要寫成:handler 的【每一條 return 路徑】要嘛有狀態變化要嘛有一句話;床用『枚舉分支』而非挑幾個鍵:對兩型各送 (合法鍵×3 邊界:緩衝滿/空 Enter/0)＋(對型錯誤鍵)＋(binds_key 外的鍵)。
```
## 2.3 提示列與回句共用一列(spec 改法 1:同一列換內容)
```
結果行同時要放『輸入：選隊長 (1~3): 2_』與『只收數字（Esc 取消）』:兩者同列。
算一次寬度:120 欄(TextUiLayout.COLS)減『輸入：』與回句後,最長的提示(任務選單／『目標 q（按 Enter 繼續）: 』／薪資含成員名)夠不夠;
不夠就『回句換行或以提示截斷』——兩者都要避免靜默 clip_to。建議回句短(『只收數字』)並規定提示的最大寬度由 _open_input 檢查（超過 ⇒ 開發期 push_error)。
回句要有壽命:收到下一個合法鍵就消失,否則會變成殘留的錯誤訊息(與 Esc×2 提示句同類)。
```
## 2.4 『面板留在畫面上』與鍵列
```
:1355 `if _input_mode: return _current_mode_name_under_input()`;:1368-1372 該函式【回 "main"】。⇒ 輸入期間鍵列顯示『主畫面』全套鍵（含 [Q]、[M]…）,
  但實際所有鍵都被輸入模式捕獲（:410-412）——鍵列在說謊,面板的鍵(例 [U/Esc]關閉)也不適用。
⇒ 面板畫出來之後,鍵列要換成輸入模式的鍵表（『[0-9]輸入 [Backspace]刪 [Enter]確認 [Esc]取消』;string 型:[A-Z]）,
   並登進 MODE_KEYMAP／unbound_key_bed。否則『面板留著』會讓人以為面板鍵還活著(新的一格『看得到卻按不了』)。
開面板的來源:20 個入口不全來自面板（G 跳 tick、武裝比例從主畫面;勢力/子隊/顧問/公庫… 從面板）。
  _open_input 要帶 origin（開它時的 mode 名）,Esc 回 origin;鏈式入口(callback 內再開)要沿用原 origin,不能每步重算(那時面板旗標可能已被改)。
  P1b 只驗子隊面板;補 P1b2:主畫面起手的輸入(G 跳 tick)Esc 回主畫面不是回某面板;勢力面板起手的輸入 Esc 回勢力面板。
```

# 3 判決
```
verdict: issues（premise_contradiction: false）
第二刀:改 ① 刪＋／－、② 可達在 N 當下判、③ 清單入面板,三處同版補即可,不需再審
追加三條:§2.1 binds_key 分型是修『按字母沒反應』的必要條件,§2.2 補枚舉分支、§2.3 寬度、§2.4 鍵列與 origin;實作端已派工——這些請直接補進現行 spec 並通知 demo-82
```
