---
from: reviewer
to: systems
status: consumed
slice: R² 客戶端不解釋遊戲鍵／離開 Esc×2／情報帶內容（ac6271382）
topic: R② ＝ **ISSUES,不擋 #1（play.py 刪 q）先做;擋 #2 #4 兩處**｜①Q2 的前提『主畫面走既有「此鍵無作用」路』不成立（主畫面 match 沒有 default、全檔無 main 的 _refuse_unbound_key 呼叫）;②Esc×2:旗標清除點只寫在主畫面分支,且回饋行不清 ⇒ 提示句會說謊;並且遊戲退出後 play.py 主迴圈沒有 EOF 分支 ⇒ Esc×2 離開時客戶端會往已關的 socket 寫（未驗,要床證）;play.py:282 橫幅仍寫『q 離開』;③情報 info:值是 belief 沒錯,但【受眾】錯——_player_perceives 放行同勢力隊 ⇒ 玩家會看到友軍隊對第三方的情報內容
---

# 0 審了哪棵樹
main ac6271382。核對 tools/play.py:204-312,183-198,211-233;text_ui_main.gd:396-414,520-614,1096-1130,1372-1390;
belief_system.gd:262-320;world_events.gd:288-323,368;player_repl.gd:52-66;observer_main.gd:205;
scripts/debug/{text_ui_layout_bed.gd:213,ui_flow_test.gd:581,terminal_e2e_bed.gd};docs/archive/resolved_issues.md:143-147。

# 1 事實核對:#1 成立(用戶回報的病就在 play.py)
```
✓ tools/play.py:301 `line.strip().lower() in ("q","quit",QUIT_TOKEN)` ⇒ 送 :quit 並 break —— q 到不了遊戲。
✓ 遊戲側本來就正確:text_ui_main.gd:605-609 遭遇中 KEY_Q 是 `pass`（encounter_view 當西北移動）;:402-409 遭遇 overlay 顯示中主畫面整個 return。
  ⇒ 用戶『戰鬥中按 Q 整支程式結束』的直接原因只有 play.py:301 一行。刪掉 "q"/"quit" 就修好戰鬥;#2 是另一個決定(離開鍵要不要換),不是修這個病的必要條件。
  ⇒ 建議 #1 單獨先 commit 先上,#2 #3 #4 不綁它(用戶卡的是 #1)。
✓ docs/archive/resolved_issues.md:147 早就記過這個風險『KEY_Q→quit 在一般地圖遊玩仍是按 Q 直接退遊戲』——#2 結案時順手更新那一行。
```

# 2 你問的第 1 點:Esc 兩段與既有 Esc——一處前提錯、三處缺
## 2.1 Q2 的前提不成立(spec『主畫面 Q 無作用 ⇒ 走既有「此鍵無作用」路』)
```
_refuse_unbound_key（text_ui_main.gd:1385）的呼叫點:輸入(631)、物品(732)、成員(1917)、互動(2152…2264)…;grep '_refuse_unbound_key("主' 零筆。
主畫面 match（:575-614）最後一支是 KEY_Z,【沒有 default 分支】。
⇒ 拿掉 KEY_Q 之後,主畫面按 q 是【靜默】,不是『結果行「此鍵無作用」』——Q2 的預期句不存在。
二選一(HOW/WHAT 邊界,要藍圖知道):
  (a) Q2 改寫成『程式仍在、世界與畫面狀態不變』(最小,不新增行為)
  (b) 給主畫面加未綁定鍵出口 ⇒ 每個沒綁的字母都開始印一句話;這碰到 unbound_key_bed 的 P2(從 KEY_ 分支機械抽鍵比對)與不變量 #10,是另一張票。
建議 (a)。
```
## 2.2 Esc×2 的缺口
```
①主畫面 Esc 現有鏈(:575-612):is_advancing→cancel_advance;_interact_mode;_member_mode;_inv_mode;_faction_mode;_outpost_mode;_subteam_mode;【之後】才是『什麼都沒開』。
   兩段只能掛在【全部沒命中】之後;而『取消推進』『關面板』的 Esc 必須【不上膛】。
   規格要寫成:上膛條件＝本次 Esc 沒有任何副作用。補格 Q3b:面板開著連按 Esc×3 ⇒ 關面板、上膛、(第三下才)離開——這個『退出反射』序列是新風險,要明文接受。
②旗標清除點:spec『其他鍵 ⇒ 旗標清掉』若寫在主畫面 match 裡,則被【更早的 return】吃掉的鍵(:402 遭遇 overlay、:410 輸入模式、各面板 handler)不會清旗標
   ⇒ Esc(上膛)→進戰鬥→戰後→Esc 就離開。清除要放在 _input 最頂端:任何非 Esc 的按鍵事件一律清(PlayerRepl.press_on 走的是同一入口才算數,要確認)。
③提示句會說謊:_set_feedback 的結果行『持續到下個指令,不清』(:1372 註解)。上膛後按 WASD(無回饋)⇒ 旗標已清、畫面仍寫『再按一次 Esc 離開』
   ⇒ 下一個 Esc 其實只是重新上膛。清旗標時要同時【撤掉或換掉】那一行(或旗標帶 tick/鍵序,過期即不認);Q3 補格:Esc→WASD→Esc ⇒ 不離開且畫面不再宣稱可離開。
④Esc 能不能進到這一層:play.py:228 `("\x1b","esc")` 已有、player_repl.gd:52 NAMED_KEYS 有 esc ✓(Windows msvcrt 直接給 \x1b,沒有 escape 序列歧義)。
⑤★離開之後的客戶端(我讀碼推論,未跑):遊戲側 get_tree().quit() ⇒ server 行程結束 ⇒ socket 關。
   play.py 主迴圈(:290-312):read_frame 在對方關閉時『把已收到的交出去』(:192-194,回空或殘屏),【迴圈沒有 EOF 分支】,
   下一個按鍵 → sock.sendall 於已關的 socket ⇒ 預期 BrokenPipe/ConnectionReset 例外而非乾淨退出。
   ⇒ spec 要加:read_frame 回空(EOF)⇒ 客戶端印『遊戲已結束』並 return 0;Q3『Esc×2 離開』的斷言要含【客戶端退出碼 0、無 traceback】。
   (今天 Q 路徑靠 play.py 先送 :quit 再 break,所以這個缺口從沒被走到。)
⑥還有別處寫著『Q 離開』,spec 的清單漏了:
   tools/play.py:282 橫幅『q 或 Ctrl+C 離開』(用戶第一眼看到的就是它)｜scripts/debug/text_ui_layout_bed.gd:213 keymap 夾具『Q 離開』｜
   scripts/debug/ui_flow_test.gd:581 U15 的描述與斷言(戰後按 Q→quit)｜docs/archive/resolved_issues.md:147｜observer_main.gd:205 另有一個 quit(觀察者殼,非玩家路徑,標明不動)。
   grep '離開' 與 'KEY_Q' 全 scripts/tools/docs 掃一遍列表,別靠我給的五處。
```

# 3 你問的第 2 點:#3『戰後那一拍』先重現——夠,但要指名兩條路
```
spec 的『管道送(戰鬥最後一鍵＋主畫面有意思的鍵)』只會走 PlayerRepl.press_on:它在一次呼叫裡依 overlay 可見性分流到一個入口(text_ui_main.gd:405-409 註解『床 P10b』已覆蓋『同一次按鍵不分派兩次』)。
   ⇒ 這條路本來就是一鍵一派,重現不到是預期結果,不能拿來證『沒有 bug』。
真正有疑義的是 GUI 引擎廣播:Godot 把同一個 InputEvent 依樹序送給每個節點的 _input;若 encounter_view._input 先處理並在『按任意鍵離開』時把自己 hide,
   主畫面的 _input 隨後看到 visible==false,同一事件會被當主畫面鍵再處理一次。:402 的守衛只防【事件到達時】overlay 還顯示。
   ⇒ 重現床要用 Input.parse_input_event(或等價的引擎層注入),而不是 PlayerRepl;兩條路都試過、各寫結果,『重現不到』才算交件。
   (Q 不再 quit 之後,這個雙派的最壞後果從『整支程式結束』降成『多執行一個主畫面鍵』——所以先修 #1 不依賴它。)
```

# 4 你問的第 3 點:情報 info——值站得住,受眾站不住
```
值:belief_system.gd:285-317 emit 位置在 `fields.has("tile_pos")` 且『首見或已知位置改變』之內,fields["tile_pos"]＝這次 record_claim 寫進 observer 的 claim 值（觀察者【剛學到的】,不是 state.teams[tgt] 真值）。
  感知鐵律就值而言成立 ✓。補兩點:
   ·record_claim 有 `distorted`(被騙/轉述失真)參數;值可能是錯的——這對玩家無害(同隊被騙就是被騙),但句子別寫成斷言『在』,可寫『得知…在(q,r)』已是轉述語氣 ✓ 保留『得知』。
   ·claim 帶來源(source_id/source_type)與時間:『親見』與『轉述』現在同一句。至少區分,或附『(N 分鐘前)』;否則玩家把轉述的舊位置當現址。
受眾:world_events.gd:288-310 _player_perceives 放行的是 ①自家隊 ②【同勢力的隊】(「自家全知」站在 faction.known_member_states 那條既有通道上,
  但那條通道給的是【隊員自己的狀態】,不是【隊員對第三方的 belief】)。
  ⇒ 今天『Team7 收到了情報』只洩『友軍隊有情報』;改後『Team7 得知 Team3 在 (q,r)』洩的是【友軍對第三方的情報內容】,
     玩家沒被告知這件事——這是新的感知越界,而且越的方向是 _player_perceives 註解 :304-310 自己警告過的那種『有 belief 撐著所以看起來合法』。
  要求:info 只在 subjects 含【玩家自家隊】時才帶(或 describe 只在 subject==玩家隊 時印內容);友軍隊維持舊句。
         補驗 Q7b:構造同勢力友軍收到情報 ⇒ 玩家事件區【不含】tgt 與座標;反向:放寬謂詞 ⇒ 必紅。
  (若藍圖想讓友軍情報可見,那是 WHAT,要走勢力情報共享的設計,不是順手帶進來。)
另:describe(world_events.gd:368)缺欄退舊句 ✓ 好;全 scripts 只有 belief_system.gd:317 一個產生者 ✓(我 grep 也一樣)。
```

# 5 判決
```
verdict: issues（premise_contradiction: false —— 但 Q2 的『既有路』前提不實,算輕度）
放行:#1（刪 play.py 的 q/quit 字面＋橫幅改字＋--selfcheck 一格）可立即做,獨立 commit
擋:#2 補 §2.1(a)/(b) 決定、§2.2 ①②③⑤⑥;#4 補 §4 受眾限制與 Q7b;#3 補 §3 兩條路
補完同版,不需再審
```
