# HOW：自家隊／無目標動作的全列＋原因 —— ★而它的母體【不是】一份新清單

**上游**：藍圖 2026-09-30 裁定②「動作全列拆成**三個具名母體**分開點名」。
第一個母體（團隊目標，`TEAM_TARGET_ACTIONS`）已竣工並 merge（`409194a8b`）。
**本票 ＝ 第二個母體**，而它被 `defers.tsv:305`（`own-team-actions-no-source-constant`）擋了一輪。

---

## ★★★§1 訂正上游前提：defer 305 那句「**沒有任何來源常數**」**過強，而我是寫下它的人**

```
我機械數過（65bf795e2）：`player_command_system.gd` 的 `_action_registry` 有 **51 個 key**，
而 defer 305 點名的那 11 個裡 **10 個在裡面**：
  ✓ establish_faction／take_loot／leave_loot／subjugate_enemy／confirm_gather_intel
  ✓ hunt／hunt_beast／camp／train／promote_anon
  ✗ cancel_move  ← 唯一不在（它不是 `execute_action` 的一個 action_id，
                    是 dispatch 動詞自己一格，同 `move_to`）
⇒ ★★所以正確的句子不是「沒有來源」，是【**沒有一個剛好等於這一類的常數**】：
  registry 是一個 51 的**超集**，而「哪些屬於自家隊／無目標」這條邊界在 registry 裡沒有被宣告。
```

★★★**而這個錯正是我 memory 裡那條的第 N 次**（下【X 沒被收錄】的斷言前先數這類收錄有幾套機制）：
我查了「有沒有一個叫做 OWN_TEAM_ACTIONS 的常數」（沒有），
**就寫成「沒有任何來源常數」** —— 而真正的收錄機制叫 `_action_registry`，它一直都在。
⇒ ★**下游後果如果沒被攔下來**：本票會照 defer 的字面「先立一個 const」
  ⇒ 手抄一份 11 個名字 ⇒ **那是第 52 份真相**，而它與 registry 會各自漂移。
  ★★而那個漂移的長相是「動作全列做完了」。

### ★★★§1b 母體的判準要**逐字寫出**：「第一參數是**字面量且不含插值**」

```
implementer 用【三個獨立軸】重數（不同工具、不是我的方法）：
  軸1 `map_available_action(` ⇒ 15｜軸2 `"allowed_kinds"` ⇒ 15｜軸3 `"command_name"` ⇒ 15
  軸4 awk 抽下一行第一參數 ⇒ 13 個 id 與我的清單**逐字相同**
★★而兩種方法在【一個成員】上分歧：awk 把 `:276` 的 `"forced_%s" % resp["response_id"]`
  歸進字面那一堆（因為那一行以 `"` 開頭）⇒ 它得 **14 ＋ 1**，我得 **13 ＋ 2**。
⇒ ★★★兩邊都不是算錯，是**判準的粒度不同**：
  「以引號開頭」 vs 「是一個**完整的**字面量（不含 `%` 插值）」。
  而 13 是對的：`forced_%s` 是**格式字串**，它不產生一個固定的 id。
```

★★★而 implementer 用不同工具（`sed` 切範圍 ＋ `sort|uniq`）異源重數 registry，
**數字與我逐字相符，並多驗到一件我沒查的**：
```
軸A `_setup_registry` 函式體內 `"key":` 的行數 ⇒ 51
軸B ★【去重之後】的 key 數                     ⇒ 51   ← 兩者相等
軸C `uniq -d`（重複的 key）                     ⇒ 空
```
⇒ ★**GDScript 的 dict 字面重複 key 會靜默覆蓋** ⇒ 若 51 行裡有重複，
`51` 這個數會**比實際 dict 大**而**沒有任何東西會紅**。實測 51 ＝ 51、無重複
⇒ 那個 51 引用起來是安全的。
⇒ ★★判準：**引用一個「數行數得到的」集合大小之前，先確認那個集合不會靜默去重。**

⇒ **所以本票的母體判準在 spec 裡逐字寫成**：
**「`map_available_action(` 的第一參數是字面量【且不含插值】」** ——
★不寫下來的話，下一個人用 awk 重數會得到 14，然後**兩邊各自都覺得自己對**。
★★這一族今天第三次（我的 11 呼叫點 vs 他的 11 動作名／`ui-stack-pending` 13 vs 11／這次 13 vs 14）
⇒ 共同形狀是**判準的粒度，不是算術**；
★★★而它是「分桶總數等於母體總數時最危險」的下一層版本：
**15 三軸一致，而分歧藏在下一層的分桶裡** ⇒ 對帳對上了不代表分桶對了。

## ★★§2 真正的病：**邊界沒有被宣告，所以它只能被手抄**

```
`player_query_api.gd:379-536`（Layer 5／6）：11 個動作各一段 `if`，每段就地手寫
  ①名字字面 ②中文標籤 ③`allowed_kinds` ④`enabled` 恆 `true` ⑤`disabled_reason` 恆 `""`
★而條件在這裡是【第二份】—— 血證兩處，註解自己承認：
  ·`:496` 「N-3: 補 `_action_camp` 的 `_check_distance` 真 gate（否則距離太近恆列→選後才拒）」
    ⇒ 查詢面 `OutpostSystem.new()._check_distance(...)`，而 `player_command_system.gd:391`
      `_action_camp` 裡有同一個呼叫 ⇒ **同一條規則兩處**
  ·`:510` 「N-3: 補 `_action_train` 的 coin 真 gate」
    ⇒ 查詢面 `coin >= TRAIN_COST_COIN`，而 `_action_train:341-342` 有
      `if coin < TRAIN_COST_COIN: return {ok:false, msg:"coin 不足訓練（需 %.0f）"}`
      ⇒ ★★★**那句人話就是我們要的 `disabled_reason`，它早就存在**，
        只是住在【執行路徑】裡，玩家**只有按下去之後**才看得到。
★而 `allowed_kinds` 的宣告與行為不一致已經登記過（`defers.tsv:306`
  `tile-actions-unreadable-boundary`：hunt／hunt_beast／camp 註解寫「依腳下 tile」卻宣告 `kind=none`；
  `offer_surrender` 宣告 `kind=team` 卻放在無目標區塊）。
```

⇒ **一句話**：這一類的三個東西（**母體**／**目標形狀**／**不能做的原因**）
現在都只存在於「emit 的那一行」裡，而那一行是**查詢面**手寫的。

### ★★★§2b 病要拆成**兩件疊在一起**，而**主病是 (乙)**（implementer 訂正，我核過）

```
(甲)【條件的第二份】查詢面與 handler 各有一份 —— 指紋：`TRAIN_COST_COIN` 在
    `player_query_api.gd` 出現 **2 次**（我實測）；`_check_distance` 在查詢面與
    `player_command_system.gd:391` 各一處。★這正是第一張票在團隊目標那一類治掉的 P7 病。
(乙)★★★【不可做的**整列消失**】條件沒過 ⇒ 那一段 `if` 不 append ⇒ 玩家看到的**不是**
    「不可做 ＋ 原因」，是**什麼都沒有**：他不知道有這個動作、也不知道為什麼沒有。
⇒ ★★**(乙) 才是本票要治的東西**；(甲) 是全列版成為唯一持有者之後**順手**被治掉的副產物。
```

★★★**而我原本給實作端的那句話方向是反的**（他攔下來的）：
我把 `:496`／`:511` 那兩行註解（「N-3: **補** `_action_camp` 的 `_check_distance` 真 gate」）
寫成「要補一個 gate」—— ★**那兩個 gate 已經在那裡了**（`:499-501`／`:513-514`，我開檔逐行核過），
**那兩行註解是過去式的紀錄，不是待辦**。
⇒ ★**實害很具體**：實作端會去「補一個已經存在的 gate」，做完**卷面會綠**（因為 gate 真的在），
  而 (乙) 一個字都沒被處理 —— **一句方向相反的血證，比沒有血證更貴。**
⇒ ★★判準（他立的，我收）：**過去式的紀錄與待辦在文字上同形**
  （「補 X」既可讀成「要補 X」也可讀成「已補 X」）
  ⇒ **引用一行註解當血證之前，先讀它下面那幾行。**
  ★★★而這與我同一小時的另一個錯是同一族（§1：我讀了「有沒有叫 `OWN_TEAM_ACTIONS` 的常數」
  就寫「沒有任何來源常數」）—— **兩次都是讀了一個說明性的字串，沒讀它下面的 code。**

## §3 做什麼 —— ★**宣告在一處 ＋ 反向掃**（形狀沿用已核過 CLEAN 的 `SUBMENU_OPENERS`，不重新發明）

```
①在 `player_command_system.gd`（＝ registry 與 handler 的同一個檔）加一張
   **宣告表**，key ⊆ registry 的 key：
     const ACTION_SHAPE: Dictionary = {
       "camp":  {"target": "none"}, "train": {"target": "none"}, …
       "trade": {"target": "team"}, "move_to": {"target": "tile"}, …
     }
   ★★**母體 ＝ `ACTION_SHAPE` 裡 `target == "none"` 的那些**（機械導出，不是手抄的第二份）
   ★★★而它的完整性靠**反向掃**，不靠紀律：
     床斷言 `_action_registry` 的每一個 key 都在 `ACTION_SHAPE` 裡有一列，
     **漏一個就紅並指名** ⇒ 新增 handler 的人會被擋下來。
   ★誠實限要寫進 code：`cancel_move`／`move_to` **不在 registry**（自己一格 dispatch 動詞）
     ⇒ 它們要嘛也進 `ACTION_SHAPE` 並在反向掃裡具名豁免「不在 registry」，
     要嘛明文不在本母體 —— ★**二選一要就地寫理由，不准沉默**。
②每一個 `target=="none"` 的動作各有一支**純查詢前置檢查**，回
   `{"ok": bool, "reason": String}`，而：
   ·`_action_<x>` 的既有前置檢查**改呼它**（★不是複製：handler 那句人話搬進去，原地只留呼叫）
   ·全列版**也呼它** ⇒ ★★一份真相兩個消費者，而「同一份」是結構性的
   ★★★**禁止**在查詢面重寫任何條件字面（`0.7`／`TRAIN_COST_COIN`／`_check_distance`…）
     —— 這一條與第一張票的 P7 同形，而 P7 已經有血證會紅。
③查詢面 Layer 5／6 那 11 段 `if` 收成**一個迴圈**（同第一票把 4 處收成 1 個迴圈的形狀）：
   母體來自 ①、`enabled`／`disabled_reason` 來自 ②、`allowed_kinds` **從 `ACTION_SHAPE` 導出**
   ⇒ ★這一步順手把 `defers.tsv:306` 的一半變成結構性的（宣告與使用同源）
     —— ★★但**不要宣稱 306 解除**：它的解除條件是「宣告與**行為**對齊」，
       而 hunt／camp 到底讀不讀腳下那格**是行為問題**，本票不動行為。
⑤★★★**`ACTION_SHAPE` 與既有的 `TEAM_TARGET_ACTIONS` 不准變成兩份真相**，
   而本票的處置是**先比較、後收斂**（★分兩票，理由寫在這裡）：
   ·`ACTION_SHAPE` 宣告**全部 51 個** registry key 的 `target`；
   ·床斷言 **`ACTION_SHAPE` 裡 `target=="team"` 的集合 ＝ `TEAM_TARGET_ACTIONS`**
     ⇒ ★這是**異源比較**（兩邊各自獨立可改）⇒ 不是「同一句話講兩次」的恆真格。
   ·★★**本票不把 `TEAM_TARGET_ACTIONS` 收成衍生檢視**，理由是母體風險：
     它有**兩支床＋同格閘**在逐字引用那個**符號名**（`available_actions_bed.gd:29`
     `SPEC_CONSTANT_SYMBOL = "TEAM_TARGET_ACTIONS"`、`:26` `SPEC_TEAM_TARGET_TOTAL = 11`、
     `colocation_gate_bed.gd:315`、`player_command_system.gd:289` 同格閘第一條件）
     ⇒ 一起改會讓**三支守衛同時失去主詞**，而失去主詞的長相是一片綠。
   ·⇒ ★★★**登一列 defer**：`team-target-actions-not-yet-derived`
     （解除條件 ＝ `ACTION_SHAPE` 已落地且那個交叉斷言綠過一輪電池；
     ★met_check 錨到 `ACTION_SHAPE` 這個符號在 `player_command_system.gd` 出現）。
④`cancel_move` 的 `disabled_reason`：`pt.move_target == (-1,-1)` ⇒「目前沒有移動目標」。
   ★它是本票裡唯一**不在 registry** 的成員 ⇒ 它會是反向掃那一格的第一個客人。
```

## ★★§4 驗收（★每一格都要能【各自】紅）

```
P1 [母體機械導出] 印出 ①`_action_registry` 的 key 數 ②`ACTION_SHAPE` 的列數
   ③`target=="none"` 的那些（**逐名印出**）
   ★斷言：registry ∖ ACTION_SHAPE ＝ ∅（反向掃）；ACTION_SHAPE ∖ registry ⊆ 具名豁免
   ★★斷言用【指名】不用【數數】（血證：merge 判準「行數≥兩邊」被 77 滿足而少一支閘）
   ｜負對照 a：從 `ACTION_SHAPE` 刪掉一列 ⇒ 反向掃必紅**並指名那個字**
   ｜★負對照 b：在 registry 加一個假 handler 而不宣告 ⇒ 必紅（守的是「下一個人」）
P2 [原因不是恆空] 本輪逐列印 `action_id｜enabled｜disabled_reason`
   ★斷言：`enabled==false` 的每一列 `disabled_reason` 非空；★★而 **false 的列數 ≥ 1**
     —— 否則這一格會在一個「什麼都可做」的世界裡恆綠（母體地板）
   ｜負對照：某一支的 reason 清空 ⇒ 必紅並指名
P1c [★異源交叉：兩個母體不准漂開] 印出 `ACTION_SHAPE` 裡 `target=="team"` 的集合
   與 `TEAM_TARGET_ACTIONS` 的集合，**逐名**印兩邊的差集
   ★斷言：兩個差集都空；★★而這一格**合法**的理由是兩邊**各自可獨立改變**
     （不是同一個常數讀兩次 ⇒ 不是恆真格）
   ｜負對照：把某一支的 `target` 從 `"team"` 改成 `"none"` ⇒ 差集非空 ⇒ 必紅並指名
P2b [★★★(乙) 的本體：不可做的那一列【仍然在】] 造一個「camp 條件不過」的世界
   （腳下已有據點）⇒ 斷言 `camp` **仍然出現在回傳裡**，`enabled==false`、原因非空
   ｜★負對照：把那一支改回「條件沒過就不 append」⇒ 那一列消失 ⇒ **必紅**
   ★★這一格與 P2 不是同一件事：P2 守的是「原因不空」，本格守的是「**列不消失**」——
     而舊行為在 P2 之下是**恆綠**的（不存在的列沒有空原因）。
   ★★★母體地板：印出【這一輪有幾支條件沒過】，若為 0 ⇒ 本格不可判（不是綠）。
P3 [★★★一份真相：handler 與全列版同源] 對 `camp`／`train` 兩支（＝有血證的那兩支）：
   P3a [行為證] 擾動 `TRAIN_COST_COIN`（★動輸入不動事實：改完改回）
       ⇒ 斷言**不是**「reason 變了」，是 **reason 裡的數字 ＝ 擾動後的精確值**
   P3b [靜態證] 印出查詢面那個迴圈的函式體原文
       ⇒ 斷言：`TRAIN_COST_COIN`／`0.7`／`_check_distance` 這些字面在它裡面 **0 次**
   ★★兩證缺一不可（行為證擋「複製了常數」，靜態證擋「行為上剛好同值」）——
     形狀與 npc-tribute 那票 §9 的異源雙證同一個判準
P4 [查詢面沒有殘留字面動詞名] 印出那個迴圈的函式體
   ⇒ 斷言：11 個名字的字面在裡面 **0 次**（★同 `colocation_gate_bed` P2 翻面之後的形狀：
     驗的是【第二份不存在】，不是【兩邊集合相等】）
P5 [既有呼叫端零改動] `get_available_actions` 那條路的 5 個既有呼叫端逐一印出仍然可用
   ★而舊版回傳 ＝「全列版裡 enabled 的那些」⇒ 衍生檢視，不是第二支實作
P6 [★誠實限就地登記] `defers.tsv:305` 的那一列**劃掉留理由**（不是刪除）：
   理由 ＝「前提過強：registry 是超集且含其中 10 個；真病是邊界沒被宣告」
   ⇒ ★★新的解除條件錨到 `ACTION_SHAPE`；★★★而 `:306` 那一列**不動**（見 §3③）
P7 全電池 `BATTERY_RC=0`；★fp **可能不變**（本票不改行為，只改「誰在回答」）
   ⇒ **先量；變了才換基準、同 commit；沒變就不要動並把為何沒變寫進卷面**
   （血證：上一次我 spec 寫「fp 會變」而它逐字不變，照 spec 預先換 hash 就會親手弄壞那支閘）
```

## ★★§4b 誠實限（寫進 spec，★而它是我預期 R² 會問的那一句）

```
`ACTION_SHAPE` 要宣告 **51 個** key 的 `target`，而本票**不保證每一個宣告都對**。
★它保證的是兩件可機械驗的事：
  ①**每一個 registry key 都有人宣告過**（反向掃，漏一個紅並指名）
  ②**`target=="team"` 那一類與既有的 `TEAM_TARGET_ACTIONS` 一致**（P1c 異源交叉）
★★而**行為上被真的驗到的只有 11 個**（本票消費的那一類：P2／P2b／P3）——
  其餘 40 個的 `target` 是**宣告**，它的正確性要靠各自的消費者出現時咬出來。
⇒ ★★★**這一段要寫進 code 的檔頭**，不是只寫在 spec 裡：
  下一個人看到一張 51 列的表，會以為那 51 列都被驗過。
  ★而「以為被驗過的宣告」比「沒有宣告」更貴：它會被下游當前提。
```

## §5 不在本票

```
·`defers.tsv:306`（`allowed_kinds` 宣告 vs 實際讀不讀腳下那格）—— 那是**行為**，本票只動宣告來源
·第三個母體（格動作）—— 藍圖②的三分之三，等 306 有定義才做
·`move_to`／`cancel_move` 該不該變成 registry 的一員（dispatch 動詞的統一是另一條縫）
·那 11 支動作各自的平衡值（`TRAIN_COST_COIN` 等 TEST VALUE）
```

## ★§6 要上游裁的（★我不自己定，而它們都是「玩家看到什麼」）

```
①`take_loot`／`leave_loot`／`subjugate_enemy`／`confirm_gather_intel` 這四支是
  **情境動作**（打完一場才存在）⇒ 沒有戰後狀態時，它們該
   (a) 列出來 ＋ 原因「你沒有剛結束的戰鬥」  ⇒ 玩家永遠看得到完整的動詞表
   (b) 不列                                  ⇒ 清單短，但玩家不知道有這個動作存在
  ★我傾向 (a)：本票的整個理由就是「不可做也要說得出為什麼」；
   ★★而 (b) 會讓這四個名字回到「只有懂的人才知道」那個狀態。
   ⇒ 但「畫面上要不要永遠有 11 列」是版面與體驗 ⇒ **呈藍圖**（且它直接影響 #10 的區塊高度）。
②`offer_surrender`（宣告 `kind=team` 卻在無目標區塊）算第二母體還是第三母體？
  ★我傾向：**照宣告走**（`target=="team"` ⇒ 不在本票），而把「它放錯區塊」就地具名登記。
```
