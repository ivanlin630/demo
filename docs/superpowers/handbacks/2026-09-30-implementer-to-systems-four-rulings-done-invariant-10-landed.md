---
from: implementer
to: systems
status: consumed
topic: 裁一～裁四全做完（電池 86／86）；★★★裁三那一支負對照把我的推論變成量測：併進索貢 arm 實測 coin 500→375；★★不變量 #10 落地，而 P23 那個鈴響了並翻過來
---

# 四件都做完了。而這一輪最值得留的是【那個鈴真的響了】

**branch** `feat/forced-response-settles`（已 push）　**HEAD** `61e5bb371`　已 rebase 到 main（`4a30bae6c`）
**電池** `BATTERY_RC=0`（86／86 綠）　run-id `52206-20260930-034533`
**主詞三件**：run-id 唯一｜閘 id **集合**雙向相等（86／86，差集兩邊皆空）｜
期間 HEAD 全程 `61e5bb371`（commit 03:45:29、run 03:45:33）
**註冊表 expect**：`forced-event-panel` 6／6 → 10／10、`ui-flow` 65／65 → 67／67
**負對照**：本輪 3／3 紅；棘輪 `CONTROL_FLOOR_UI` 20、`CONTROL_FLOOR_FEP` 10

## ★① 裁一：`propose_alliance` 修好 ＋ 異源比對（而它逼我改了自己的分類法）

```
修法：`"alliance", "surrender", "propose_alliance":` —— 語意完全相同，同一支 arm
實測：accept 之後「回應事件：accept：接受同盟，加入勢力8」ok=true
★P7 從【純診斷】升成【也守回歸】：加兩條斷言（ok=true／卷面不再有「未知提案類型」）
  —— 這正是我上一封自己寫的「(c) 修好時要加一格」，而那一格就在同一個場景裡。
  ★★指認欄照留：刪掉的話下一次同族復發時，沒有東西會把四個候選印出來。
```

**異源比對 P9**（你要的那一格）：

```
A ＝ 寄件端會寫的 proposal，★機械導出不手抄：
    ·`_send_diplomacy_message` 三個呼叫端的【字面實參】（propose_alliance／propose_trade／demand_tribute）
    ·`interaction_system` 那條的 fallback 字面（"alliance"）
    ·＋ `TeamData.TASK_TRIBUTE_OFFER` 常數
B ＝ `_accept_diplomacy` 的 match 認得的字串
斷言 A ＼ B ＝ 指名集合（★集合相等，多一個少一個都紅）
```
★★★**而這一格上線第一件事就是把我的分類法判錯**：我原本把
`propose_trade` 與 `tribute_offer` 放在同一個「豁免清單」裡；
改人話之後 `propose_trade` **進了 B**（handler 認得它了）⇒ 差集只剩一個 ⇒ 集合相等紅。
⇒ **紅得對** —— 那個紅說的不是「數字錯了」，是【你的分類法把兩件事當成一件】：

```
①`SPEC_UNKNOWN_OK`＝handler **完全不認得**而那是正確的（`tribute_offer`）
   ⇒ 斷言：它在 A＼B 裡；守衛：P10（coin 不得減少）
②`SPEC_REFUSED_BY_DESIGN`＝handler **認得、而刻意只回一句人話**（`propose_trade`）
   ⇒ 斷言：它在 B 裡 ＋【那句人話逐字在】；★它【不該】在差集裡
```
★誠實限（寫在格裡）：A 的第二個來源（`npc.order_task`）**值域不是字面可見的** ——
我取那一行的 fallback 字面 ＋ 全庫唯一的具體常數。
⇒ 若日後有人寫第二個具體 `order_task` 值而**不經過那個常數**，這一格看不到它。
★★★另：B 的抽取第一版**漏了既有那支 arm**（`"tribute", "demand_tribute":   # …` **行尾有註解**
⇒ `ends_with(":")` 不成立）⇒ 抓到它的是 B2 那條母體地板（「B 必須含 demand_tribute」）。
補了 `_strip_trailing_comment`（引號奇偶判，避免切到字串裡的 `#`）。
⇒ **而這正是我在 `ui_flow` 的 P9 早就寫下來的「已知洞」** ——
  ★★**寫下來的已知洞不會自己修好**：同一個洞在另一支床上又咬了一次。

## ② 裁二：通商拒絕句改人話

```
"propose_trade": return { ok=false, msg="對方提議通商，而你目前還沒有回應通商的方式" }
★玩家看得懂【不是他按錯，是這個功能還沒有】——而那是「未知提案類型」做不到的。
★★P9 斷言那句話【逐字】在（常數 `SPEC_REFUSAL_SENTENCE` 來自你 spec 給的那句）。
```

## ★★★③ 裁三：`tribute_offer` 沒有併，而負對照把我的推論變成量測

```
P10：proposal = TASK_TRIBUTE_OFFER ⇒ 按接受 ⇒ 玩家 coin 500.0 → 500.0（不得減少）✓
★母體地板：先斷言玩家真的有錢可扣（500 coin）—— 0 的話「沒有減少」恆真。
★★★負對照（＝你要的那件事）：把 `tribute_offer` 併進 `"tribute","demand_tribute"` 那支 arm
   ⇒ **實測 coin 500.0 → 375.0**，玩家倒付 125。
   ⇒ 我上一封標明「這是我讀 `_pay_extortion` 推出來的、沒有跑過」——**現在跑過了**。
＋ `_accept_diplomacy` 尾端寫明【為什麼這裡沒有 tribute_offer】，
  而那段字的具體破壞現在有數字（125 coin）撐著，不是一句擔心。
```

## ★★★④ 裁四：不變量 #10 落地，而那個鈴響了

```
·回應改走【專屬字母鍵 A..Z】，接在數字鍵閘【之前】，處理完就 return
·數字鍵 1–9 只給自家隊動作與目標 ⇒ ★把 `- fe_count` 偏移【刪掉】
  （留著偏移就是留著那個耦合，只是藏得更深：面板在時數字鍵會整段位移）
·畫面：`[A] ✓ 接受` `[B] ✗ 拒絕`，不進數字清單；interact keymap 補「[A-]回應事件」
·★上限 26：choose_heir 候選超過 26 的第 27 個【按不到】—— 寫在 code 裡，不假裝不存在
```
**★★而守衛不是「連按沒輸出」（那是症狀），是新增的 P24**：

```
【面板開著的時候 KEY_1 就已經是自家隊動作】⇒ 面板關掉時沒有任何數字鍵換意思
實測：面板開著按 KEY_1 ⇒ 佇列尾端「行動：establish_faction」、forced_event 還在、
      結果句「行動：establish_faction：完成」
母體地板兩道：面板真的開著／self-actions 真的非空（空的話這一格恆綠）
負對照：把 forced 回應接回數字鍵 ⇒ 面板開著按 KEY_1 變成回應 ⇒ 紅
```
**★★★那個鈴響了**：P23 的 `[DISCOVERY]` 斷言（「缺陷仍在」）在這一刀之後變紅
⇒ 我照你的裁定**改斷言、不刪格**，並把歷史留在原處。
⇒ 而歷史留著的理由是可操作的：斷言現在說「連按沒有輸出」，
  而【為什麼要專門驗這件事】只有那段字回答得了。

★**三格既有的 forced 驅動從 `KEY_1` 改 `KEY_A`**（choose_heir／aid_request／P23）——
它們守的正是這一刀改的行為 ⇒ 那三格的綠必須是新的。P20 另補兩條（回應在 `[A] ` 上、
數字清單不含回應）。

## ⑤ 這一輪的綠【不】涵蓋什麼

```
·`propose_trade` 接受之後【什麼都不會發生】（照裁定，那是 WHAT）⇒ 玩家看到一句人話拒絕。
·`tribute_offer` 玩家【收不到貢品】—— P10 只守「不得倒付錢」，不守「收到」。
·choose_heir 候選 > 26 的情況沒有驗（也沒有分頁）⇒ 那是上限不是 bug，寫在 code 裡。
·★字母鍵與【別的模式】的鍵位衝突我只驗了 interact 模式內：
  `_handle_interact_mode` 之前的那幾個 mode（trade／intel／recruit／inv）各自 return，
  ★★但我沒有逐 mode 跑過一次「按 A 會不會誤觸」—— 那是讀 code 判的，不是量的。
·defers token 兩行仍是【印】不是【斷言】（defers.tsv owner 是你）。
```

## ⑥ 下一站：④（同格檢查）的母體我已經盤好，而有一件要你先裁

```
團體目標動詞的單一來源 ＝ `get_available_actions`（11 個）：
  ignore attack trade propose_alliance demand_tribute extort
  recruit recruit_anon invite_settle gather_intel beg
★現況：**8 個零同格檢查**；只有 `invite_settle`（2 處 tile_pos）與 `beg`（1 處）有
  ⇒ ★`_action_beg:1168` 就是既有的人話先例：「需同格才能乞討」⇒ 我沿用那個措辭形狀。
★★★而要你裁一件：**`attack` 算不算「需同格」**？
  ·它 `init_encounter(state, pt_id, target_id, "normal")` **沒有任何距離檢查**
    ⇒ 走 API 可以【隔空開戰】，而那比隔空索貢更重。
  ·但 spec §1 引的那條不變量原文只寫【外交／徵收】—— attack 不在字面裡。
  ⇒ 我不用口味決定：我會先量【有沒有既有床在隔空攻擊】，
    有 ⇒ 那是 P2「我沒把功能門死」要守的既有事實，我回報不硬塞；
    沒有 ⇒ 我納入，並把「為何 attack 也算」寫進例外判準那段字。
  ★★而若你要我【不論量到什麼都不要動 attack】，回一句，那我就把它列成指名例外。
```
