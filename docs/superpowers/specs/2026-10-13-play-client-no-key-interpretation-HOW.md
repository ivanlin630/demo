# 客戶端不解釋遊戲鍵＋離開不綁 Q＋情報帶內容——HOW

狀態：收 R²（2026-10-13-reviewer-to-systems-R2-play-client-no-key-interpretation-ISSUES；補完同版不需再審）
交付分兩刀：**第一刀＝改法 1 單獨 commit 先上**（用戶那個病的直接原因只有 play.py:301 一行）；第二刀＝改法 2–4。
來源：藍圖 2026-10-13-blueprint-to-systems-TICKET-play-py-hijacks-q-so-battle-move-quits-the-game（第五輪用戶真機回饋 #1）
順位：插到「附身隊後續三件」之前（實作端手上那張停在乾淨點，branch 上 commit，回頭續做）

## 事實（main b67eb8d11 之後）
- `tools/play.py:301`：`line.strip().lower() in ("q","quit",QUIT_TOKEN)` ⇒ 送 `:quit` 並 break ⇒ **q 永遠到不了遊戲**，戰鬥裡六向移動的 Q 一按就斷線。
- 遊戲側：`text_ui_main.gd:605-609` 主畫面 `KEY_Q` ⇒ `get_tree().quit()`（遭遇中 pass）；鍵列 `text_ui_main.gd:1104` 寫「[Q]離開」。
- `player_repl.gd:66` `QUIT_TOKEN=":quit"` 是 harness 層離開，與遊戲鍵分開。
- 情報：`belief_system.gd:317` `WorldEvents.emit(state,"intel_arrived",[obs_id],_wake)` 不帶 info；`world_events.gd:368` 只能印「X 收到了情報」。全 scripts 只有這一個產生者。

## 改法
1. **play.py 不解釋任何遊戲鍵**：刪掉 `"q"`、`"quit"` 兩個字面；只認 `QUIT_TOKEN`（`:quit`）與 Ctrl+C（`key_token` 已把 Ctrl+C 轉 `:quit`）。所有其他 token 原樣送。拿掉 :301-304 那段過期註解；橫幅（:282）改字；`--selfcheck` 加 Q5 那一格。獨立 commit。
2. **遊戲側離開不綁 Q**：`KEY_Q` 主畫面分支拿掉 quit。主畫面 match（:575-614）沒有 default、也沒有未綁定鍵出口 ⇒ 拿掉後按 q 是**靜默、狀態不變**（給主畫面加未綁定鍵出口會碰 unbound_key_bed 與不變量 #10，不在本票）。
   離開改 **Esc 兩段**：
   - **上膛條件**：這次 Esc 沒有任何副作用（沒關面板、沒取消推進、沒退出任何模式）才上膛，結果行印「再按一次 Esc 離開」。⇒ 面板開著時要連按 Esc×3 才離開，明文接受這個退出反射。
   - **清旗標放 `_input` 最頂端**：任何非 Esc 鍵都清（含之後被戰鬥 overlay、輸入模式提早 return 吃掉的鍵）；否則上膛後進戰鬥再按 Esc 就離開了。
   - **清旗標時撤掉提示**：結果行若仍是「再按一次 Esc 離開」就清掉，不讓提示說謊。
   - 下一鍵是 Esc 且旗標在 ⇒ 離開。
   - 先查：主畫面 Esc 目前有沒有綁別的意思（面板／模式內的 Esc 是關閉，照舊——只有「什麼都沒開」那一層才進兩段）。有衝突 ⇒ 交件信列出、不自行取捨。
   - 「Q 離開」全部改：鍵列 `text_ui_main.gd:1104`、play.py:282 橫幅、`text_ui_layout_bed.gd:213`、`ui_flow_test.gd:581` U15、`resolved_issues.md:147`——**用 grep 掃全**（q／Q＋離開／quit 各種寫法），交件信附命中清單與處置，不靠這五處。`KEYMAP_NEEDS` 同步。
   - **離開後客戶端**：play.py 主迴圈（:290-312）沒有 EOF 分支 ⇒ 遊戲 quit 後下一鍵 sendall 預期 BrokenPipe（讀碼推論，床證）。改：`read_frame` 回空 ⇒ 印「遊戲已結束」、return 0。
   - 終端路徑：`PlayerRepl` 對 Esc 已有命名鍵（F5 `NAMED_KEYS`）；確認 Esc 能經 `press_on` 進到這一層。
3. **戰鬥結束那一拍不吃下一鍵**：戰後畫面到主畫面的切換那一刻，同一次按鍵不得同時被兩個模式解讀（例：戰後「按任意鍵離開」吃掉一鍵後，同一鍵又落到主畫面）。實作端先用床重現，**兩條路都試、各寫結果**：(i) 終端 `PlayerRepl.press_on`（本來就一鍵一派，P10b；重現不到不能證沒 bug）；(ii) 引擎層 `Input.parse_input_event` 注入（GUI 廣播下 encounter_view 先 hide，主畫面 `_input` 再看到 visible==false）。重現得到才修，修在模式切換入口（一鍵只派一個模式）；都重現不到 ⇒ 交件信寫明試了哪些序列。
4. **情報帶內容**：`intel_arrived` emit 帶 info `{tgt, pos, src, age}`（觀察者這次寫進 belief 的值，不是真值——感知鐵律就值而言成立）。
   - **受眾**：`_player_perceives` 放行同勢力隊 ⇒ 若照帶，玩家會看到「Team7 得知 Team3 在 (q,r)」＝友軍對第三方的情報內容，玩家沒被告知（:304-310 註解自己警告的「有 belief 撐著所以看起來合法」）。⇒ **info 只在 subjects 含玩家自家隊時才帶**；友軍那則照舊句、不帶對象與座標。
   - 句子：自家「你得知 Team<tgt> 在 (q,r)」；**親見與轉述分開**——親見「你看到…」，轉述「你得知…（N 分鐘前的消息）」，來源與時間讀 claim 的 source／tick。info 缺欄 ⇒ 舊句（不印空對象）。保留「得知」的轉述語氣（claim 可能失真）。
   - **折疊（藍圖 #6 ①，b3b873b49）**：同一 tick、同一來源的多則 intel_arrived 折成一條：「從 Team8 得知：Team6 在 (4,7)、Team11 在 (9,0)」。折疊在玩家事件流的寫入端（`_feed_player` 或其上一層）做，不在 UI 合併；只折自家隊那幾則（受眾規則同上）。
   - **「記下 N 筆」只數改變所知的（藍圖 #6 ②）**：`message_system.gd:247-322` 的 `written` 現在每寫一則 claim 就 +1，不管內容有沒有變。改：寫 claim 前後各取接收方對該目標的 `best_estimate`，**值欄位（位置、實力估等，不含時間戳與可信度）有變才算 written**；只換時間戳 ⇒ 計入 `refreshed`。結果句：written>0 照舊；written==0 且 refreshed>0 ⇒「他說的你早就知道了（更新了時間）」。訊息複製那段（:260-277）已經跳過已知 id，照舊。
     - R²（2de9898a9 審）補：(a) value 字典內含 `last_tick`（belief_system.gd:99、195）⇒ **明列比較鍵集合**、排除時間與可信度欄，不比整個字典；(b) `best_estimate` 只看勝出那一筆 ⇒ 結果**三態**：採信而改變（written）／一致只更新時間（refreshed）／衝突未採信（`conflicted`，低可信度 claim 寫入但沒贏）。結果句各一：「記下 N 筆」／「他說的你早就知道了（更新了時間）」／「他說的跟你知道的不一樣，你沒採信（N 筆）」。written 與訊息複製段合看（兩段都進總數）。
     - 折疊做法：只在 `_feed_player` 內改**最後一筆**（同 tick、同 kind、同 source_id ⇒ 合併、重組 text、不新增 seq）；info 帶 `source_id`。
   - 「糧源情報同型」：目前沒有糧源情報這種事件（糧源 belief 種類在深層批）⇒ 本票不做，在交件信註明。

## 驗收（床，管道餵鍵走 play.py 同一條路或 PlayerRepl）
- Q1（修前紅）：進遭遇戰後送 `q` ⇒ 連線不斷，結果行是移動句或邊界句。
- Q2（修前紅）：主畫面送 `q` ⇒ 程式仍在、狀態不變。
- Q3（修前紅）：主畫面 Esc 一次 ⇒ 仍在＋提示；Esc 兩次 ⇒ 離開，play.py 退出碼 0、無 traceback、印「遊戲已結束」。
- Q3b：Esc→WASD→Esc ⇒ 不離開，且 WASD 之後結果行不再有「再按一次 Esc 離開」。
- Q3c：Esc 上膛→進遭遇戰→Esc ⇒ 不離開。
- Q4：面板開著時 Esc ⇒ 只關面板（不上膛）；面板開著連按 Esc×3 ⇒ 離開。
- Q5：play.py `--selfcheck` 加一格：`key_token` 後的 `q` 照原樣送出（不轉 `:quit`）。
- Q6（若 3 重現得到）：戰後切換那一鍵只被派一次。
- Q7（修前紅）：自家隊的 intel_arrived 句子含對象與座標，親見／轉述兩種句子各一格。
- Q7b：友軍隊的 intel_arrived 不含 tgt 與座標（放寬受眾謂詞 ⇒ 必紅）。
- Q8（修前紅）：同一 tick 同來源 4 則情報 ⇒ 事件區 1 條、含 4 個對象。
- Q9（修前紅）：同一人一分鐘內問兩次 ⇒ 第二次結果句是「他說的你早就知道了（更新了時間）」，不是「記下 5 筆」。
- Q9b：佈置一筆低可信度的衝突 claim ⇒ 結果句是「沒採信」那一態，不是「早就知道了」。
- 負對照：play.py 放回 `"q"` ⇒ Q1 紅；`describe` 放回舊句 ⇒ Q7 紅。
- terminal E2E 照綠；有既有步驟用 Q 離開的 ⇒ 改成 Esc×2，交件信列出。
- world-fp 不變（info 多帶欄位不進世界狀態）。
