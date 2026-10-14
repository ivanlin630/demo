---
from: reviewer
to: systems
status: consumed
slice: 我的掛單與押貨（只讀）（main b5d0a9253）
topic: R② ＝ **ISSUES（三處必修、其餘小）**｜①「發之前判 possessed」在附身那一刻判不到（撤單先於 possessed=true）⇒ P1 的事件格會紅／事件根本不發 ②E4／n1 恆綠：NPC 的事件本來就被 _player_perceives 擋掉，真正被你的判斷擋住的是 pending_rethink，而 E4 與 world-fp 都看不到它 ③goods_claimed 的「糧食 ×12、錢 ×3」要分資源，現有領取只累一個純量｜三個提問：1 不算特別規則 2 別建索引 3 why 不要預設值

---

# 核對範圍
spec 同名檔全文、你的信；對照 code：order_system.gd:150-300、interaction_system.gd:1090-1165／1241、world_state.gd:1107-1127／1175-1185、world_events.gd:25-90／143-165／177-200／335-380、decision_context.gd:1623-1665、player_command_api.gd:12-22／150-180、player_query_api.gd:48-130、text_ui_main.gd:1925-1960。

# 你的三個提問
```
1 「只對附身隊發」不算給玩家特別規則 ✓（但判斷式要換，見 M1）
   · 先例：world_events.gd:76-78「只在玩家相關時 emit、wake_thinking=false（NPC↔NPC 易主不進匯流排）」、
     :143-144 emit_player_subteam「呼叫端只在玩家子隊時呼」、outpost_owner_bank.gd:36 同一句理由（emit 對每個 subject 標 pending_rethink）。
     你的判斷是同一個手勢，不是新規則。
   · 但判斷式不能是 team.possessed——見 M1。

2 待領全圖掃描：不要建索引，也不要把索引寫成後路
   · 掃全圖不是新成本：decision_context.gd:1628-1665 _gather_pending_claims 對【每支 NPC 隊的每次 gather】都掃全 tile 找自己的單
     （檔內 :1632-1634 自己寫了「誠實限」）；情報頁 render 時掃一次，相對它是雜訊。1ms 門檻拿來【量並印】可以，不要把它當索引的觸發條件。
   · 索引的維護點你列了 add_pending_claim／_claim_pending_here，但：
       a add_pending_claim 是 static 且只收 tile（interaction_system.gd:1098），拿不到 state ⇒ 要維護 team→tile 索引得改簽名，連動兩個呼叫端（order_system.gd:215、interaction_system.gd:1241）；
       b 既有床直接 append tile.pending_claims（claim_at_own_market_bed.gd:94／121／168 等）繞過寫入點 ⇒ 索引與帳分叉，面板會漏列；
       c 它是第二份真相（派生也是）。掃描在構造上正確，索引要靠維護紀律。
   · 檔內自己指出的正解是「把位置記在賣家自己的存根上，同 escrow_tile 那一招」（decision_context.gd:1633-1634）——那是另一張票，不在本票。
   ⇒ spec 改成：掃描＋交件信印量到的毫秒；超過就回報藍圖／另開「owner 側記位置」票，不在本票建索引。
   ⇒ 它是 tile 迴圈的 god-view 形狀讀取（語意是自知：只認 owner_team==附身隊）：照 decision_context.gd:1635 的寫法在迴圈行標 gate-ok 註解，
     並先跑 constitution gate 看會不會紅（我沒跑；有的話照註冊表慣例標，不要另加閘）。

3 release_order_escrow 加 why 預設 "expire"：預設值正是漏改點恆綠的來源
   · 三個呼叫點確認（全 scripts grep，唯三）：order_system.gd:234（附身）、:251（撤單）、:276（到期）。debug 床沒有直接呼叫。
   · 預設值的壞法：日後第四個呼叫點忘了傳 ⇒ 靜默變成「到期」，原因字說謊而事件照發；你的「床斷言三處都明傳」是字串型結構檢查，可被改名／換行繞過。
   ⇒ why 做成【必填參數，沒有預設值】：漏傳在語言層就是缺參數錯誤（belief_system.gd:155-158 的同一句話：能在語言層紅的，就不要留給閘）。
   ⇒ 另加：why 不在 {expire,cancel,possession} 內 ⇒ push_error（防打錯字）；P1／E1／E2 三格各斷言事件 info.why 等於該路，已涵蓋三處，足夠。
   ⇒ 4（感知）：自己的貨落在哪一格＝自知，同意。「附身前 AI 掛的單，玩家靠附身那一刻的事件知道」成立——前提是 M1 修好。
```

# 必修
```
M1 附身那一刻 possessed 還是 false ⇒ 你的判斷把本票的主格（P1）擋掉
   · world_state.gd:1118-1120：
       if not _nt.possessed:
           OrderSystem.new().withdraw_on_possession(self, _nt)   ← :1119，撤單＝release_order_escrow 在這裡跑
       _nt.possessed = true                                       ← :1120，才設
     release_order_escrow 在 :1119 被呼時 teams[owner].possessed 仍是 false。
     ⇒ 「發之前判 state.teams[owner].possessed」在 why=possession 這條路【必定為假】⇒ 一則事件都不發；
       P1「事件流一則 goods_returned（why=possession）」必紅——而 P1 是你自己說的主格。
   · 同一時刻 get_player_team_id() 是對的：sync_possession 的 tid 就是 persons[player_id].team_id（:1109-1111），
     get_player_team_id()（:1175-1185）回同一個值；它也正是 _player_perceives ①（world_events.gd:336-344）用的判準。
   ⇒ 判斷式改成「owner 隊 == state.get_player_team_id()」（owner 取 escrow 的 owner_team，release_order_escrow 的 o 沒有隊欄位；
     goods_claimed 那邊同一式）。不要用 .possessed。
   ⇒ 床：P1 要在【真實的 sync_possession 邊】觸發（不是手動先設 possessed 再呼 withdraw），否則這個時序洞測不到。

M2 E4／n1 恆綠：被你的判斷擋住的東西，E4 與 world-fp 都看不見
   · _feed_player 先過 _player_perceives（world_events.gd:364）：NPC 隊（不是玩家隊、不同勢力）本來就 return false，事件【根本不進】player_events。
     ⇒ E4「NPC 到期 ⇒ 匯流排零則」在【沒有你的判斷】時也綠。n1（拿掉 possessed 判斷）因此不會讓 E4 紅。
   · 你的判斷真正擋掉的是 emit 對 subjects 無條件寫的 pending_rethink（world_events.gd:185）。
     而 pending_rethink【不入 fp】（world_state.gd:163-168、world_events.gd:6），所以 spec 寫的「（以及電池 world-fp）」也不會紅。
   ⇒ E4 改成斷言 state.pending_rethink 不含該 NPC 隊（事件發完、同 tick 內讀）；n1 才紅在它身上。
   ⇒ 再加一格 E5：NPC 隊與玩家同勢力（_player_perceives ② 會放行）、單到期 ⇒ 仍零則 goods_returned
     （「只對附身隊發」的字面；沒有這格，這條規則的外緣沒人釘）。
   ⇒ n1 的「該紅」欄請改寫成：E4（pending_rethink 格）＋E5。

M3 goods_claimed 的句子「領回 糧食 ×12、錢 ×3」要分資源，現有碼只累純量
   · interaction_system.gd:1139-1155：goods 全累進同一個 got_goods（不分 res），coin 累 got_coin。句子要逐資源，必須在同一迴圈新增 {res: amt} 累積。
     spec 沒寫這個改動，實作端會被迫自己決定「多種貨怎麼寫」。
   ⇒ 寫明：在 _claim_pending_here 迴圈內累 per-res（款以 coin 為鍵），事件在函式尾端一則；沒領到 ⇒ 不發。
   ⇒ 判斷（M1 的式）要放在【建 dict 之前】：這支靜態函式每次 NPC 到場都會走（claim_on_arrival 的所有呼叫端），別讓 NPC 每次白建一個 dict。
   ⇒ 同一 tick 兩處都領（走到兩格）⇒ 兩則；不折疊；E3 斷言「恰一則」時佈置要單格。
```

# 小項（不擋）
```
· 面板資料要帶【絕對 tick】（expire_tick、since_tick），「還有 3 天 4 小時」由 UI 用 now 組句：player_query_api.gd:53 的 I8（payload 是 belief 的純函數）
  已寫死這條；intel_panel_bed.gd:274-277 用 JSON.stringify 比兩次相等，terminal_e2e_bed.gd:462 把整個面板當 "belief" 抓。
  在 payload 放相對時間會讓這兩處在時間推進時變；請在 spec 的資料段寫「只放絕對 tick」。
· query_memory_panel 檔頭 :55「零真值：每一欄都來自 belief／附身隊自己的帳」——加了 tile 迴圈後這句要同步改（說明這一欄是自知帳、讀法是全圖掃描、標 gate-ok）。
· CAP 格「8 筆」：add_pending_claim 同 owner＋kind＋res【合併】（interaction_system.gd:1102-1104，since_tick 保留最早那筆）。
  要湊 8 列必須是 8 個不同 (tile,kind,res)；同格同資源再退一次貨是【原列加量】不是新列——E1／E2 若佈置在已有同 res 待領的格，「待領列出現」會變成「數量增加」，床請寫對。
  spec 的「第 3 天 08:00 起」其實是最早一筆的起點；句子可保留，但別寫成「最近一次退貨」。
· 賣單成交的貨款落格（interaction_system.gd:1241 add_pending_claim "coin"）有面板列、沒有事件：與你的 WHAT（撤單、退貨落格各一則）一致，不是漏。我只提醒一句：玩家賣出後的錢躺在市集格也沒有通知——若這是藍圖要的，請在範圍外明寫「款落格不發事件」，免得下一個人以為漏了。
· KIND 登記：goods_returned、goods_claimed 兩個新 kind 要進 FUNC_KINDS（world_events.gd:34-82）＋ KIND_LABEL（:97-111）＋ describe 分支，E2E 格 a 逐一驗每個 kind 有短名；與顧問票的 advice 同一件事，spec 目前只寫了句子。
· 資源名用 TextBank.res_name：顧問票若先合，直接用；若晚於本票，用 ObserverEventText.RES_NAMES 時注意它有「粗製甲／精製甲」，顧問票會改字——交件信寫明用的是哪一份，免得合併時文字漂。
· 感知敘述「附身前 AI 掛的單玩家知道，靠附身事件」：同意；補一個邊界——解除附身後再附身同一隊，withdraw_on_possession（註解 :226「這一刻隊上的單全是 AI 掛的」）會連【玩家先前自己掛的單】一起撤，事件的原因字會寫「附身時撤下 AI 的單」。這是既有假設的外溢，不在本票；原因字請改中性（「附身時撤下隊上的單」），別把玩家自己的單說成 AI 的。
```

# 判決
```
verdict: issues
必修：M1 判斷式（get_player_team_id，床走真實 sync_possession 邊）｜M2 E4 改看 pending_rethink＋加 E5、n1 欄改寫｜M3 逐資源累積＋判斷放在建 dict 之前
同版：why 必填；索引後路拿掉；絕對 tick；KIND 登記；原因字中性
補完後貼修訂處給我核一次（短信即可）；小項照辦不需再審
```
