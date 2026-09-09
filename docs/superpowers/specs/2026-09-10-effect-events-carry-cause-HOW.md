# HOW spec：果事件帶因（ticker 一跳到因）

owner: systems ｜ 2026-09-10 ｜ **player_reachable: yes（觀眾可讀）** ｜ 用戶親測兩次揭出

上游：用戶看到**求和**而上游沒有任何宣戰/威脅事件；又看到**派工失敗**印一個沒有主詞的 `1.60x`。
blueprint 裁：**零新機制**、**事件文本帶因快照**、**同族一起掃不要逐隻**。

## §0 ★★★【R² 2026-09-10 大幅訂正】三個代表案例裡，只有一個真的走這條管道

```
宣戰    ★走 emit_message（npc_combat_system.gd:124）⇒ ★本票修得到
求和    ★★【查無實據】：全庫 grep「求和」只出現在 decision_context／options／terms／failure_memory
        ＝【決策層的 option 名稱】,★★★【沒有任何 emit_message 與它關聯,一個都沒有】
        ⇒ 用戶看到的「求和」八成是 observer/text UI 直接顯示 `team.current_task` 之類的【狀態標籤】
        ⇒ ★而我把它定成本票的【頭號驗收樣本】—— 那是在修一個【不存在的呼叫點】
派工失敗 ★★走【裸 print()】（faction_ai_system.gd:4538 `_log_dispatch_fail`）
        —— 與 emit_message／TextBank／global_messages 【完全不同管道】
        ⇒ ★它不受本票 §4④⑤（fingerprint／事件總數）約束,因為它根本不碰 global_messages
```

⇒ ★**本票拆成三件，而只有第一件是「加 cause 欄位」**：
```
①本票      emit_message ＋ cause 欄（代表案例：宣戰、★replace —— 見 §1b，因現成且更便宜）
②求和      ★【先查它到底在哪個畫面顯示】—— 一句話的查點,不是本票
③派工失敗  ★★直接改 `_log_dispatch_fail:4624-4626` 那行 `%` 格式化字串
           （加 leader 在不在家）—— ★★★不套 cause／TextBank 機制,套錯會查半天找不到掛勾點
```
★★★**而我犯的錯是【把三個不同管道的東西打包成一個機制】** ——
**症狀相同（觀眾看不到因）不代表管道相同**，而**打包會讓兩件事卡在一個掛不上的鉤子上**。

## §1 列舉（★母體，我 grep 過的）

```
`emit_message(state, …)` 的產線呼叫點：★20 處（message_system.gd:40 是定義本身）
   faction_establish／famine_warning／extortion／diplomacy／tribute×2／order_delivered／
   aid_refused×4／aid_given×2／combat_start／combat_end／subjugate／order_<kind>／
   outpost_built／trade_done
★★而它們的 params 幾乎【全部只有「誰對誰」】：`origin` / `target` / `loser` / `faction` …
⇒ ★★★【誰做了什麼】有，【為什麼】沒有。
（★唯一帶一點因的是 `famine_warning`（帶 harvest 相關欄），而它正好是用戶【沒有抱怨】的那個。）
```

## §1b ★★而我的母體漏了【整個目錄】（R² 查出，今天第 N 次同病）

```
grep -rn "emit_message(" scripts/simulation/events/*.gd   ← ★我完全沒掃這個目錄
   event_faction_defect.gd:51   "faction_defect"   params 只有 origin
   event_unrest_replace.gd:17   "replace"          params 只有 origin
   event_unrest_split.gd:26     "split"            params 只有 origin+x+y
⇒ ★母體是 23 不是 20。★★而這次排除的不是一種寫法,是【一整個目錄】。
```
★★★**而 `replace`（領袖替換）的因【現成且比我原本的三個例子都便宜】**：
```
event_unrest_replace.gd:7-14   team.unrest_turns（已跨 UNREST_REPLACE_THRESHOLD=20）
                               dissenters（_get_dissenters 已算出,非空才會走到這行）
⇒ ★用它當本票的代表案例,比「求和」（查無實據）與「派工失敗」（不同管道）都合適。
```

## §1c ★TextBank 是【兩條路徑】不是一條（R² 查實）

```
TextBank.TEMPLATES 有模板的 9 個：subjugate／battle／betrayal／faction_establish／
   diplomacy／tribute／outpost_built／order_delivered／famine_warning
★而 combat_start 是【直接 % 格式化字面】,TEMPLATES 裡【根本沒有這個 key】
  （只有 "battle"，那是另一個 type＝結果訊息）
faction_defect／replace／split 同樣是 call-site 字面
⇒ ★★加 cause 有【兩條路】：有模板的要編輯模板字串（加 {cause} 佔位）,
  其餘要改 call site 那行 % 字串
⇒ ★★★§4① 的對帳表要多一欄：【這個 type 走 TextBank 還是 call-site 字面】
  —— 否則實作者會遇到「加了 cause 進 params,而 TEMPLATES 裡沒有這個 type 可以改」
  ⇒ ★而那正是我怕的「加了但沒接電」,只是漏電點在【模板缺席】不是【模板沒讀那個欄位】。
```

★★**而 `cause` 只進 `honest` 層**（R² 指出的語意衝突）：
有模板的型別分 `honest／unintentional／malicious／vague` 四層＝**傳播失真**用的
⇒ ★**一則被扭曲成「附近有政治動作」的模糊傳聞，不該同時附一句精確的「威脅 0.82」**
⇒ ★★★**寫死在這裡**，否則實作者會照抄 honest 的做法塞進所有層，
   產生【假傳聞卻帶精確數字】的不一致。

★**而 `combat_start` 印的就是「Team X 對 Team Y 宣戰」** —— **它自己也沒有因**
⇒ ★★所以「求和沒有上游宣戰」這件事，**即使有宣戰，觀眾也一樣看不到為什麼**。

## §2 修法：**一個約定，不是一個機制**

```
①`emit_message` 的 params 加一個【約定欄位】`cause`（★不是新事件族、不是新函式）
②在【產生端手上已經有因】的地方填它 —— ★★零新機制：只印它【當下已經讀到的東西】
   宣戰   ：`_should_attack` 的分數項（ambition/martial/greed/str_ratio/caution）
   replace ：`unrest_turns` / `dissenters`（★★本票的代表案例，見 §0 訂正）
   ★★★以下兩則【已於 §0 移出本票，保留在此只為對照】：
   ~~求和~~   ：走 `faction_ai_system.gd:3929` 的裸 print ⇒ **不碰 `global_messages`**
   ~~派工失敗~~：同上，裸 print ⇒ **不碰 `global_messages`**
   ⇒ ★這兩則的家在【裸 print 帶因】那一格：
     `docs/superpowers/specs/2026-09-10-bare-print-carry-cause-CELL.md`
     （blueprint 裁：低優先、不單獨開工、拆動詞票或 inspect 票誰先動誰帶走）
   ⇒ ★★留著劃掉的版本而不是刪掉，是因為**本票曾經拿它們當驗收樣本**——
     ★★★而那是一個真的錯誤：拿兩個【本機制完全影響不到】的樣本當驗收，
     等於這張票就算完全沒做，那兩格也會長一樣。
③★★★而【產生端手上沒有因】的地方 —— **不要發明**：
   ⇒ 那是一個【發現】：它表示「這個決定不是在這裡做的」
   ⇒ **列進 handback 的『無因清單』**，由我逐條判要不要往上游追。
```

## §3 ★★這一刀的紀律（免得它變成 spam）

```
★只印【產生端已經讀到】的量 ⇒ 零新讀取、零新機制、零新事件
★★一個事件【一行】 —— 因附在同一行的括號裡,★★★不另發一則「因事件」
   （另發＝事件族長大＝ticker 變成刷屏,而那會讓用戶更看不到戲）
★不改任何判斷、不改任何門檻 ⇒ determinism fingerprint【不變】（本票的安全網）
```

## §4 驗收

```
①【逐事件對帳表】20 個 emit 點 × 有沒有因 × 因從哪個欄位來 ⇒ ★落地成檔案
   ★★「無因」那一欄要有【理由】：是「產生端沒有」還是「有但沒印」——★★★兩者處置不同
②★★★【訂正】求和那則【不在本票範圍】（§0：查無 emit_message 關聯）
   ⇒ 代表案例改用【`replace`】（因現成：unrest_turns ＋ dissenters）
③★★★【訂正】派工失敗那則【不在本票範圍】（§0：走裸 print，不碰 global_messages）
   ⇒ 它是【另一張一句話的票】：直接改 `_log_dispatch_fail:4624-4626` 的 `%` 字串
④★★fingerprint 不變（只加印，不改判斷）
⑤★★★【逐 type 的計數】都不變（R² 加固：總數不變擋不住「刪一則、在別處加一則」的淨零）
   ⇒ 而 by-type 幾乎零額外成本（本來就在讀 `global_messages`）
```

★誠實限：
1. 本票**不改**任何決策、門檻、事件的**發生條件** —— 它只改**那一行怎麼寫**。
2. ★**它不會讓「求和」變得合理** —— 求和的觸發條件（`threat_react` 過線、不要求敵對行為）
   **是另一回事**，已另記（`factcheck-peace-plea-needs-no-war`）。
   ★★**本票只保證觀眾【看得到它為什麼發生】**，不保證他【同意】那個為什麼。

---

★**附掛【順手改】格**：裸 print 帶因（`[SoloAI]` 行 ＋ 派工失敗行）
⇒ `docs/superpowers/specs/2026-09-10-bare-print-carry-cause-CELL.md`
（本票**曾經**把「求和」錯當自己的驗收樣本 ⇒ 這行指標是為了讓以後回頭查的人
**省一次重新推導**。blueprint 2026-09-10 裁：低優先、不單獨開工、
本票或 inspect 票**誰先動誰帶走並刪該檔**。）
