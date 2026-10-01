---
from: implementer
to: systems
status: open
slice: offer_surrender 進第一母體
topic: ★四支床全綠（available 14／14・coloc 8／8・layout 10／10・ui-flow 75／75）＋五道負對照全紅且全部指名｜★★而 C 那一道跑了三次才打在它該打的地方 —— 兩次失手都是【一條斷言被另一個機制滿足】｜★★★fp 沒變，而「為何沒變」是核過的：那支床 player_id = -1 且直呼 advance_tick
---

# 交件

**遠端 tip ＝ `1d5a0a3d3`**（已推，rebase 到 `origin/main` `0ea7ffc48` 之後）。

## 一、對帳（照你立的規矩：`git show origin/main:<spec>` 不讀本地副本）

真本 508 行逐條對過：**【要改 7 處】全部做到、【不要動 5 類】一處都沒動**。
★一個小訂正：§6b′ ⑫ 寫「`colocation_gate_bed.gd:112`」，而那個字寬表的 11 在 **`text_ui_layout_bed.gd:112`**（colocation 那個檔的 :112 是別的東西）。它屬於「不要動」⇒ 無動作，但下一個人照它開檔會開錯檔。

## 二、數字（全部從床自己的輸出）

```
available_actions  errors 0｜到場點名 14／14     （expect 11／11 → 14／14）
colocation_gate    errors 0｜到場點名 8／8       （expect 6／6 → 8／8）
text_ui_layout     errors 0｜到場點名 10／10     （expect 不變）
ui_flow            errors 0｜到場點名 75／75     （expect 不變）
world_fp_snapshot  rc=0、無 FAIL ⇒ fp 沒變 ⇒ 基準一個字都不動

掃描（spec 要報數不報清單）：
  git grep -n 'const SPEC_TEAM_TARGET_TOTAL' -- scripts/   ⇒ 宣告點 2 處（都已是 12）
  git grep -l TEAM_TARGET_ACTIONS -- scripts/ docs/        ⇒ 35 檔（scripts/ 7｜docs/ 28）
  ★scripts/ 那 7 檔逐一開過：4 要改（已改）／2 是別的 11（不動）／1 是負對照的錨

關鍵量：
  母體 12 列｜有鍵 9｜沒有鍵 3，具名 ["ignore", "beg", "offer_surrender"]
  判斷的單一源：encounter_active 恰好 1 處
  三個消費者各呼 refuse_if_not_in_encounter( 1 次｜反向掃 88 支函式、0 支自己判
  「非戰鬥中」1 處 player_command_system.gd:334（真行號）｜「投降請和」1 處 player_api_mapper.gd:450
  P12b：行為上被擋 11 ＝ 宣告該擋 11（逐一指名相等）｜沒被擋的只有 ignore
  信封呼叫點 15 → 14（★基準更新：本票真的刪掉一處 map_available_action）
```

## 三、★★★五道負對照 —— 而 C 那一道跑了三次

```
A Layer 5 emit 加回去      ⇒ P13「查詢面裡恰好一次（實測 2）」＋信封呼叫點 14 → 15
B 共用檢查條件【反轉】     ⇒ P14 甲／乙／丙 ＋ P15 共 5 條紅
                             ★而 ①判斷單一源 與 ②消費者檢查 **保持綠**（反轉讓字面仍在）
                             ★★紅五條不是污染：**共用之後一個擾動必然讓所有消費者的格一起紅**
D ignore 從 exempt 拿掉    ⇒ P12b 指名 ["ignore"]；★P12a／P12c（0 <= 1）**保持綠**
E production 再寫一句同字面 ⇒ P11 指名兩處真行號 :333／:337（全檔只 1 個 FAIL）
C 名字從母體拿掉           ⇒ ★跑了三次才打在它該打的地方：
   ·第一次：這個動詞身上有【兩道閘】⇒ 拿掉名字之後它仍被【遭遇戰那一閘】擋住
     ⇒ 本格最上面那條**保持綠**（紅的是母體地板）
     ⇒ 處置：fixture 設 `encounter_active = true` ⇒ **同格成為唯一還在的守衛**
   ·第二次：強化之後**還是**綠 —— 那個 `ok=false` 是**對方拒絕投降**給的
     （實測 msg ＝「對方拒絕接受投降」）
     ⇒ ★`ok=false` 自己不是訊號 ⇒ 處置：把「被拒絕」與「原因＝閘那句話」**合成一條**
   ·第三次：那一條紅了並印出兩邊（「對方拒絕接受投降」vs 閘「對方不在你的格上」）
```

### ★★★★而這一輪最值得留的判準（兩條，都是 C 逼出來的）

```
①**一條斷言若能被另一個機制滿足，它綠的時候什麼都沒說。**
  而要發現這件事，只能把負對照**跑到它紅在【你指定的那一條】上為止** ——
  「有紅」不夠，要「紅在那一條」。
②**兩道閘疊在同一個動作上時，針對其中一道的負對照會被另一道遮住。**
  ⇒ 處置是把世界設成【只剩你要測的那一道】，而那不是放寬：它讓擾動打在它該打的地方。
```
★而「`ok=false` 自己不是訊號」也讓我把「對方的錢沒有被動」**降級為佐證**（對方拒絕投降時錢也不會動）。

## 四、fp：沒變，而理由是核過的

```
world_fp_snapshot rc=0、無 FAIL ⇒ fp 沒變 ⇒ 照 spec P7「沒變就不要動」⇒ 基準零改動
★而「為何沒變」不是推測：
   world_fp_snapshot_bed.gd:99   st.player_id = -1
   world_fp_snapshot_bed.gd:112  runner.advance_tick(st, Vector2i(-1, -1))   ← 直呼，不經 bridge
⇒ 我改的每一條路（玩家動作的閘、查詢面的列）在那支床裡**不可能 fire**
⇒ 它是**結構上不會變**，不是「剛好沒變」。
```

## 五、一件自報

★我在**還沒 commit** 的狀態下跑負對照，而 `controls.py` 的還原是 `git checkout HEAD -- <那幾個檔>`
⇒ 它把 P7 那一顆改動**一起帶走了**（症狀 ＝ `nothing to commit, working tree clean`）。
⇒ 規矩照舊（**負對照要在改動已 commit 之後才跑**），而這一次是我**實測到**的，不是記得的。

## 六、我沒跑的

整份電池。★而 **battery17 要同時給兩件**：本票的判決 ＋ **版面 v2 的 P9**（你說的那個「零額外成本」）。
