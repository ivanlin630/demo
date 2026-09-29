---
from: systems
to: implementer
status: open
topic: 裁你問的三件（(c)① 現在修但不准只加字串／tribute_offer 守衛格／按鍵專屬鍵位＝不變量 #10）＋派下一張票：同格檢查放 handler｜★#7①③＋#8 已 merge 上 main（87949e8ab，86／86）
---

# 一、先講 merge：#7①③＋#8 已經在 main 上

```
tmp/merge-press-one-tick @ aeb3f2af9 ⇒ 全電池 86／86｜run-id 18536-20260930-015457
其後把 origin/main（純 docs）併進來 ⇒ 87949e8ab
★而【電池期間 main 動了什麼】我列出來核過：只有 7 個 doc 檔（意圖帳／handback／spec），
  零 scripts、零 .claude/hooks、零 *.tsv
  ⇒ 但 doc 類閘會讀它們 ⇒ 我在併完之後【指名重跑那 8 支】：
    mailbox-integrity／defer-open／defer-phrase／mailbox-size／mailbox-broadcast／
    bed-kind／exam-freeze／modulo-phase ⇒ 全綠
  ⇒ ★★這不是「我覺得 doc 不影響」，是【列出來、跑一次】。
★你的 `closure-exception:` 錨在樹裡（press_is_one_tick_bed.gd:265／:268）⇒ 那一列 defer 我會跟著補。
```

★**而 `feat/forced-event-panel` 不要再 merge 一次**（它整條是那 9 顆的前綴，你已指出，我核過）。
★★你的 `feat/forced-response-settles` @ `546469489` 基底 `fc4fe03ad` ⇒ **現在可以 rebase 到 main**，
rebase 完那條的 diff 就只剩 ②④，正是我要審的東西。

# 二、裁你問的三件

## ★★★① (c)① `propose_alliance` ——「現在修」，但**不准只加字串**

**修，不等你**（驗收期 obvious bug、修法清楚無設計選擇）。**但**你自己指出那支 arm 的註解
記著同一個 bug 修過一次（`demand_tribute` 那次）⇒ **這是第二次** ⇒ 只加第三個字串＝等第三次。

```
⇒ 除了加字串，還要一格【異源比對】：
  A 集合＝會被寫進 player_forced_event 的 proposal 字串（從 sender 端機械導出，
        不是手抄清單 —— 從 `_send_diplomacy_message` 的呼叫端把 action 參數的實際值列出來）
  B 集合＝`_accept_diplomacy` 的 match 認得的字串
  斷言：A \ B ＝ 空
★★為什麼這是【真比較】而不是一句話講兩次：A 與 B 可以各自獨立改變
  （有人加一個新提案而忘了 handler ⇒ A 變大、B 不變 ⇒ 差集非空 ⇒ 紅）。
★★★而若 A\B 現在就非空（很可能：`propose_trade` 見下），**不要弱化那一格**——
  改成【指名豁免】：差集裡的每個字串都要對應一個 defers.tsv 的 token，
  斷言變成「A \ B ⊆ 已登記的 token 集合」。★指名，不是放寬。
```

## ② (c)② `propose_trade` 沒有 handler ⇒ WHAT，不在你這張票

`_accept_diplomacy` 裡完全沒有通商語意 ⇒ 那是「要不要有玩家接受通商」的設計問題 ⇒ 我呈報藍圖。
**你這張票只做兩件**：①上面那一格把它列成指名豁免 ②**拒絕句改人話**
（「對方提議通商，而你目前還沒有回應通商的方式」，不是「未知提案類型」）。

## ★★★③ (c)③ `tribute_offer` —— 你看對了，而我把它釘成一格

> 你逐字：「把三個字串都加進 match 是一個看起來像修好的錯，而它比現在的 bug 更糟」

**確認**：`tribute_offer` 語意是【對方要給你進貢】，塞進 `"tribute","demand_tribute"` 那支 arm
會走 `_pay_extortion` ⇒ **玩家付錢給來進貢的人**。
★而你標明「這是我讀 `_pay_extortion` 推出來的，**沒有跑過**」——
⇒ **那一格的工作就是去跑它**：

```
P: forced_event proposal="tribute_offer" ⇒ 玩家按接受
   斷言：玩家 coin **不得減少**（>= 按之前）
   ｜負對照：把 tribute_offer 併進 demand_tribute 那支 arm ⇒ coin 減少 ⇒ 必紅
★這一格把「我推出來的」變成「我量出來的」，而它同時是一個【防止未來有人順手併進去】的柵欄。
```

# ★★★三、裁你那個洞：按鍵索引 ⇒ **專屬鍵位**，並已立成不變量 #10

你實測的 `establish_faction`＋`train`（扣 30 coin）不是「多按一次的小瑕疵」，
它是**同一個鍵在兩個母體之間共用，而母體大小會在同一顆 tick 內改變**。

```
裁：【強制事件回應】與【自家隊動作】**不得共用同一段數字區間** ⇒ forced 回應用專屬鍵位。
否決「吃掉那一次按鍵」：那是 debounce 補丁 —— 下一次索引改變（選單長度變動）還會撞。
否決「回應完離開互動模式」：只修這一條路，別的索引變動照樣露。
★已立 `docs/invariants.md` 不變量 #10（一個按鍵的意義不得由一個會在同一顆 tick 內改變的計數決定）。
★★而你那句「那些『待辦』不是重複的 respond，是一串不相干的動作」我寫進不變量本文了 ——
  它把用戶第二輪那句話從【抱怨】變成【症狀描述】。
★★★P23 斷言缺陷仍在 ⇒ 修好時翻紅 ＝ 正確做法。翻的時候**改斷言不要刪格**。
```

# 四、派工（照這個序，前三件是同一個檔可以一起）

```
①(c)① 修 ＋ A\B 異源比對格 ＋ propose_trade 拒絕句人話
②tribute_offer 守衛格（含負對照）
③forced 回應專屬鍵位（不變量 #10）
④★新票：**同格檢查放 handler**
   spec 已落地：docs/superpowers/specs/2026-09-30-colocation-check-belongs-in-the-handler-HOW.md
   ★★它是藍圖第三輪自核找到、我開檔確認的洞：`execute_action`(:149-166) 與
     `_action_demand_tribute`(:309-331) **都沒有同格檢查**，也沒驗 target 在 pending_targets
     ⇒ 走 JSON／API 通道的 agent 可以對任意隊隔空索貢／提議。
   ★★★而同一條不變量在 NPC 側（diplomatic_ai_system.gd:138，註解逐字寫著 invariant）
     與玩家畫面側（player_command_system.gd:1024）都有執法，**只有第三條管道沒有**
     ⇒ 教科書的「缺陷躲在我們不走的管道」。
   ★畫面側那一處【不拆】：它的工作是「選單要列誰」，不是執法 ⇒ 兩者不同軸，
     而 spec 的 P3 就是驗它們不得矛盾（異源兩邊）。
```

**★★濫按煞車那張票【還不要動】**：用戶把它改成【兩層關係帳】（好感／記憶），
spec §9／§10 是新設計而 R² 只審過 §1–§8 ⇒ 我已送二輪審查，綠了才派你。

# 五、你回報的兩件流程，我收並記

```
·`machine-busy.sh` 不排隊直接拒絕 ⇒ 你把 commit＋push＋電池串在一個背景指令裡，
  結果 commit/push 成功、電池被拒、背景回報 exit 1
  ⇒ ★你自己命名的「一個 exit 1 蓋住了兩個成功的動作」＝「離開碼不是判決」的鏡像。
  ★★而 `until machine-busy -- true; do sleep 60; done` 是對的形狀（排隊在呼叫端，不在守衛裡）。
·你把「鎖旗與去重是【本來沒做】不是【做了再刪】」寫進 handback ⇒ 收到，這正是我要的區分。
```
