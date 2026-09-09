# HOW spec：果事件帶因（ticker 一跳到因）

owner: systems ｜ 2026-09-10 ｜ **player_reachable: yes（觀眾可讀）** ｜ 用戶親測兩次揭出

上游：用戶看到**求和**而上游沒有任何宣戰/威脅事件；又看到**派工失敗**印一個沒有主詞的 `1.60x`。
blueprint 裁：**零新機制**、**事件文本帶因快照**、**同族一起掃不要逐隻**。

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

★**而 `combat_start` 印的就是「Team X 對 Team Y 宣戰」** —— **它自己也沒有因**
⇒ ★★所以「求和沒有上游宣戰」這件事，**即使有宣戰，觀眾也一樣看不到為什麼**。

## §2 修法：**一個約定，不是一個機制**

```
①`emit_message` 的 params 加一個【約定欄位】`cause`（★不是新事件族、不是新函式）
②在【產生端手上已經有因】的地方填它 —— ★★零新機制：只印它【當下已經讀到的東西】
   求和   ：`threat_id` / `threat_react`（decision_context:377-378）
            ⇒ 「Team X 向 Team Y 求和（懼其兵鋒，威脅 0.82）」
   派工失敗：`_short["margin"]` / `res` / `avail` ＋ ★★★【leader 在不在家】
            ⇒ 「安全緩衝 1.60x（慎重領袖）；material 5（公庫 0 ＋ 私 5）；★leader 不在自家據點」
   宣戰   ：`_should_attack` 的分數項（ambition/martial/greed/str_ratio/caution）
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
②★求和那則【一定要有】：它是用戶親自抓到的那一則 ⇒ 拿它當這張票的驗收樣本
③派工失敗那則要能【分開兩種世界】：真的沒料 vs 料在公庫而 leader 不在家
   ⇒ ★成對對照：構造兩種情形 ⇒ 兩行【文字不同】
④★★fingerprint 不變（只加印，不改判斷）
⑤★★★事件【總數】不增加 —— 對照跑前後的 `global_messages.size()`
   ⇒ 它證明我們沒有偷偷新增事件族
```

★誠實限：
1. 本票**不改**任何決策、門檻、事件的**發生條件** —— 它只改**那一行怎麼寫**。
2. ★**它不會讓「求和」變得合理** —— 求和的觸發條件（`threat_react` 過線、不要求敵對行為）
   **是另一回事**，已另記（`factcheck-peace-plea-needs-no-war`）。
   ★★**本票只保證觀眾【看得到它為什麼發生】**，不保證他【同意】那個為什麼。
