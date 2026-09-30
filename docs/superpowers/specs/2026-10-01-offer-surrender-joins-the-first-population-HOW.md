# HOW：`offer_surrender` 進第一母體 —— ★而它**不是重分類，是堵一個現存的洞**

**上游**：藍圖 2026-10-01 兩裁 ——
①`RULING-situational-actions...`（`84bbd2817`）：`offer_surrender` ＝ **團隊目標動作**，
照宣告歸第一母體、**不開第四類**；「戰鬥中且有對手」是**它的 `disabled_reason`，不是它的類別**；
★「**第一母體若已竣工補一列同路徑**」——而第一母體已竣工（`409194a8b`）。
②`意圖帳「求和需同格」`（`2647c8c9b`）：**遠程求和不該存在**；需同格且在遭遇中；
同格檢查管它 ＝ **正確副作用**；日後「派使者求和」是**勢力級／信使外交的新動詞**，
不是這個動詞的遠程版（同軸原則：**同一動詞同一距離規則**）。

## ★★★§1 前提（reviewer 抓到、我開檔核過、逐行）

```
`_action_offer_surrender`（`player_command_system.gd:844-856`）函式體逐字：
   var tgt6 = state.teams.get(target_id)
   if tgt6 == null: return { ok:false, msg:"目標不存在" }
   handle_diplomacy_message(state, tgt6, pt, "offer_surrender") … accept ⇒ 轉移資產＋被收編
⇒ ★**零 encounter 檢查、零同格檢查**
而 `TEAM_TARGET_ACTIONS`（`:281-284`）11 個名字裡**沒有它**
⇒ `_colocation_gate`（`:288-291`）第一條件 `if not TEAM_TARGET_ACTIONS.has(action): return {}`
  ★而檔頭逐字寫著「**回空字典 ＝ 放行**」⇒ **對它放行**
⇒ ★★★**今天 `execute_action(state, 任意 target_id, "offer_surrender")` 對一支不同格的隊打得通**，
  而 accept 會**轉移資產 ＋ 把玩家隊收編**。
★對照（它的三個鄰居各自有守衛，所以「有守衛」那句話屬於鄰居不屬於它）：
  `_action_surrender_in_encounter:858` → `if not state.encounter_active: return {ok:false,"非戰鬥中"}`
  `_action_surrender_pre_encounter:888`／`_action_accept_encounter:877` → 讀 `player_pre_encounter`
```

★★**而「它有前提」這句話我一度寫錯過，錯法留在這裡**：我引用了查詢面
（`player_query_api.gd:460-462`）的 `if state.encounter_active and focus_team_id != -1`
—— **那是【列不列】的條件，不是【做不做】的條件**。
⇒ 判準（既有規矩的這一次實例）：**一個動作至少有三處可能有條件**：
①誰把它列出來（查詢面／UI）②handler 自己 ③共用的動詞閘（同格／權限）
⇒ 說「它有前提」要**指名是哪一處**；說「它沒有前提」是負斷言 ⇒ **三處都要讀過**。

## §2 做什麼

```
①`TEAM_TARGET_ACTIONS` 11 → **12**（加 `offer_surrender`）
   ⇒ ★★**同一顆 commit 要一起改【三處】，逐一指名**（★★★R² 補的第三處，見 §5）：
     ·`available_actions_bed.gd:26` `SPEC_TEAM_TARGET_TOTAL = 11` → **12**
     ·`colocation_gate_bed.gd:36` `SPEC_TEAM_TARGET_TOTAL = 11` → **12**
       ★**它是另一個檔案自己宣告的同名常數**（不是同一個符號被兩處讀），
       而 `:331` 有真斷言在用它（化簡後 ＝ `TEAM_TARGET_ACTIONS.size() == SPEC_TEAM_TARGET_TOTAL`）
       ⇒ 沒同步改 ⇒ **那支床無條件變紅，而紅的理由跟 `offer_surrender` 無關**
         ⇒ 查紅燈的人會摸不著頭緒（★這比漏改更貴：它把一個不相關的紅塞進本票的卷面）。
     ·`colocation_gate_bed.gd:36` **那一行的註解逐列了 11 個名字** ⇒ 一起補 `offer_surrender`
       （★註解不是裝飾：下一個人是靠它知道母體是誰）。
   ⇒ ★★**而【不要動】的兩個**（寫出來是因為誤改比漏改更難查）：
     ·`available_actions_bed.gd:29 SPEC_CONSTANT_SYMBOL`（存**名字字串**，名字沒變）
     ·`available_actions_bed.gd:38 SPEC_PAYLOAD_SITES = 11` ⇒ ★**那是另一個 11**
       （payload 的處數）—— 它與母體大小**同值而不同義**。
   ★理由（兩個方向都錯）：先改常數 ＝ 讓守衛先**要求**一件世界還沒做到的事（恆紅到期）；
   先改床 ＝ 讓守衛先**接受**一件世界還沒做到的事（恆綠）。
   ⇒ ★★★**交件時要跑一次 `git grep -n SPEC_TEAM_TARGET_TOTAL -- scripts/` 並報「宣告點 ＝ N」**
     —— 母體用**掃出來的**，不要用這份 spec 裡的清單（★這份清單第一版就漏了一處）。
②全列版（`get_action_availability`）的 `match` 補一支 `"offer_surrender"`：
   **不在遭遇中 ⇒ `enabled=false`、原因 ＝ 引擎給的一句人話**（例：「你沒有在戰鬥中」）
   ⇒ ★原因**寫在全列版**（與判斷同一個回傳），排版層不寫文案 —— 沿用既有形狀。
③handler 補那**兩件**（它們是兩件事，各自一格）：
   ·**在遭遇中**：`if not state.encounter_active: return {ok:false, msg:…}`
     ★**措辭與 `_action_surrender_in_encounter` 那一支對齊**（同一件事只有一種說法）
   ·**同格**：進母體之後 `_colocation_gate` 自動管它 ⇒ ★**不要在 handler 裡再寫一份距離檢查**
     ⇒ 而「它真的被管到」要**由床證明**：見 P3。
④查詢面 `player_query_api.gd:460-474` 那段 Layer 5 的 emit **整段刪掉**
   ⇒ ★否則同一個名字**兩條路各產一列** ⇒ 畫面上出現兩次。
```

## ★★§3 驗收

```
P1 [母體 ＋ 基準原子] ★**兩支床各自印**：`TEAM_TARGET_ACTIONS.size()`（＝12）與**它自己那個**
   `SPEC_TEAM_TARGET_TOTAL`（＝12），各自斷言相等
   ⇒ ★★**同一顆 commit** 的證據 ＝ **兩支床的輸出都在同一輪**（不是兩輪）
   ⇒ ★★★而「還有沒有第四處」由**掃描**回答不由清單回答：
     交件報 `git grep -n SPEC_TEAM_TARGET_TOTAL -- scripts/` 的**宣告點數**
P2 [★恰好一次] 回傳裡 `offer_surrender` **恰好出現一次**
   ｜負對照：把 §2④ 刪掉的那段 emit 加回去 ⇒ **必紅（出現兩次）**
   ★這一格擋的是「搬了但沒刪舊的」——它是本票最容易漏的那一件
P3 [★★★同格閘真的管到它] 造一支**不同格**的隊 ⇒ 呼 `execute_action("offer_surrender", 那一隊)`
   ⇒ 斷言：**被拒絕**，且**印出同格閘回了什麼**（空字典 ＝ 放行 ⇒ 這一格的證據是那句人話本身）
   ｜負對照：把 `offer_surrender` 從 `TEAM_TARGET_ACTIONS` 拿掉 ⇒ 遠程呼它**又打得通** ⇒ 必紅
   ★★母體地板：印出【那一隊與玩家隊的距離】—— 否則這一格會在一個「大家都同格」的世界裡恆綠
P4 [★在遭遇中] 同格但**不在遭遇中** ⇒ 拒絕，原因非空；在遭遇中 ⇒ 可做
   ｜負對照：拿掉 `encounter_active` 那一行 ⇒ 不在遭遇中也打得通 ⇒ 必紅
   ★**P3 與 P4 要分兩格**：它們是兩個獨立的洞，而一個 OR 斷言會讓其中一支永遠沒被驗到
P5 [鄰居沒被我動到] `surrender_in_encounter`／`surrender_pre_encounter`／`accept_encounter`
   三支的既有行為逐一印出仍然成立
P6 [全列版的原因不是空的] `offer_surrender` 那一列 `enabled=false` 時原因非空（沿用 P2 的形狀）
P7 全電池 `BATTERY_RC=0`；★fp **可能不變**（本票改的是「誰能做」不是世界的算法）
   ⇒ **先量；變了才換基準、同 commit；沒變就不要動並把為何沒變寫進卷面**
```

## §4 不在本票

```
·「派使者求和」（藍圖明文：那是**勢力級／信使外交的新動詞**，不是這個動詞的遠程版）
·`_transfer_surrender_assets` 的比例（0.3 ＝ TEST VALUE）
·另外兩個 surrender 動詞要不要也進母體（它們**不吃 target_id** ⇒ 不是團隊目標動作）
·`ACTION_DIGITS` 要不要給它一個鍵 —— ★★**這一條要注意**：母體 12 而鍵只有 9
  ⇒ 它很可能是「未綁鍵」那一群的第三個 ⇒ **本票不決定鍵位**，但要在卷面上印出
    「這一輪有幾列有鍵」讓它看得見（★而那正好是分頁那張票要等的痛）
```

---

## ★★★§5 R² 的第三處（reviewer `7ba82ea37`，verdict=issues ⇒ 補完即 CLEAN）—— 而我的錯法要留著

```
他找到 `colocation_gate_bed.gd:36` 也有一個**獨立的** `SPEC_TEAM_TARGET_TOTAL = 11`。
★而我在 spec 第一版寫的是：「`colocation_gate_bed.gd:315` 同理（名字沒變）」——
  我檢查的是那個檔的**另一個東西**（它逐字引用 `TEAM_TARGET_ACTIONS` 這個**符號名**），
  然後就對整個檔下了結論。
⇒ ★★這是我今天第三次同一個形狀：**我查了 X 的一個面，然後斷言了 X 的另一個面**
  （①查「有沒有叫 OWN_TEAM_ACTIONS 的常數」⇒ 斷言「沒有來源常數」
   ②查「查詢面的 if」⇒ 斷言「這個動作有前提」
   ③查「那個檔引用符號名」⇒ 斷言「那個檔不用改」）。
⇒ ★★★而三次的共同修法只有一個：**把那一問變成一次掃描**
  —— `git grep <那個東西>` 一行，而不是「我讀過那個檔」。
```

★而他另外核過並替我擋掉一個**過度設計**：我附帶寫的風險（「同格閘第一條件哪天改了，
這個保護會靜默消失」）他判**是真的但不是本票特有** —— 那是那個機制**12 個成員共同承擔**的
通用風險，守它是 `colocation_gate_bed` 自己的責任 ⇒ **本票不需要額外自證**，P3 的層級是對的。
★★這一條我收：**一個通用風險不該在每一張票裡各驗一次**（那會讓每張票都長出一格重複的守衛）。

---

## ★★★★★§6 裁：`offer_surrender` **不進 `ACTION_DIGITS`**（(乙)）—— 而理由比「鍵位滿了」硬

**implementer 讀 spec 時找到五處而不是三處，其中一處有實質後果**（鍵位表已滿），
並列了 (甲)(乙)(丙) 要我裁。★**我裁 (乙)，而我開檔找到一個他沒有用的理由 —— 它讓 (乙) 從
「最小改動」升級成「唯一正確」**：

```
`encounter_view.gd:381`：**`KEY_F` ⇒ `execute_action("surrender_in_encounter")`**
  （`match _mode: "idle"` 那一支，且它自己檢 `state2.encounter_active`）
⇒ ★**遭遇中求和【已經有玩家路徑】，而且是一個專屬鍵、在遭遇畫面上。**
⇒ ★★所以「`offer_surrender` 拿不到鍵 ⇒ 玩家看得到而按不到」這個顧慮**前提不成立**：
  玩家要在遭遇中求和，他按的是**遭遇畫面的 F**，不是互動清單裡的某個數字。
⇒ ★★★而若給 `offer_surrender` 一個數字鍵，那就是**同一個意圖兩條路**
  —— 而那正是這個專案反覆在治的病（兩份真相 ／ 第三條管道）。
```

**⇒ 裁定三條**：
```
①`offer_surrender` **不進 `ACTION_DIGITS`**（不佔 1..9 的任何一個）。
②它**照樣在列上**、`enabled=false`、原因 ＝ 引擎給的「你沒有在戰鬥中」——
   ★而它在互動那一屏**幾乎永遠是 disabled**（遭遇中畫面被遭遇檢視接管）
   ⇒ 那是**誠實的**：玩家看得到這個動詞存在、也看得到它為什麼現在不能做。
   ★★而原因裡**不要寫「按 F」**：那是 UI 知識，而原因是引擎給的（既有分工）。
③★★★**明文登記一筆統一債（我另開 defer 列）**：
   `offer_surrender`（帶 target）與 `surrender_in_encounter`（不帶 target）
   **是同一個意圖的兩個動詞** ⇒ **不要為 `offer_surrender` 綁鍵**，
   否則玩家面會出現兩條路；而長期該收成一個（哪一個活下來 ＝ WHAT，不在本票）。
```

### ★§6b 那五處的訂正表（母體以掃描為準）

```
①`available_actions_bed.gd:26`  SPEC_TEAM_TARGET_TOTAL 11 → 12
②`colocation_gate_bed.gd:36`    SPEC_TEAM_TARGET_TOTAL 11 → 12（★R² 找到的）
③`colocation_gate_bed.gd:36` 那一行**註解裡手抄的 11 個名字** ⇒ 補 `offer_surrender`
④★**新增（implementer 找到的第五處）**：`text_ui_view.gd:78` 的上限說明逐字寫著
   「今天 `TEAM_TARGET_ACTIONS` 是 11 個 ⇒ **已經有 2 個沒有鍵**」
   ⇒ 12 之後那句是假的（會是 **3** 個）⇒ **一起改**，
   ★而照 §6① 之後那 3 個是 `ignore`／`beg`／`offer_surrender`（要具名列出）。
⑤【不要動】`available_actions_bed.gd:29 SPEC_CONSTANT_SYMBOL`（存名字字串）
   ／`available_actions_bed.gd:38 SPEC_PAYLOAD_SITES = 11`（★**另一個 11**：呼叫點數，同值不同義）
   ⇒ ★★**訂正我自己**：我在寄出的信裡把後者寫成「同檔 `colocation_gate_bed.gd:38`」，
     而 colocation 那個檔的 `:38` 是 `SPEC_EARLY_RETURN_EXEMPT = ["ignore"]`。
     **spec 原文是對的，錯在我信裡那句壓縮** —— 而這是今天第二次同一個形狀
     （第一次：我把「gate 已存在」的註解壓縮成「要補 gate」）
     ⇒ ★★★判準：**壓縮一句 file:line 的時候，`同檔`／`同一處`／`同理` 這幾個詞
       會把讀者送到錯的檔** —— 要嘛寫全路徑，要嘛不要壓縮。
★母體以**掃描**為準：`git grep TEAM_TARGET_ACTIONS scripts/ docs/` ⇒ implementer 實測 **10 個檔**
  （其中兩處是註解、一處在另一支床、★一處是 `available_actions_controls.py`＝**負對照的錨**）
  ⇒ 交件報那個掃描的數，不要報這份清單。
```

---

## ★★★★★★§6c 裁 (b)：抽一支共用前置檢查 —— ★**而它同時訂正我自己 §2③／§6② 的措辭**

**implementer 開檔核到的事實（我逐行複核過，成立）**：
```
`_action_surrender_in_encounter`（`:858-860`）**第一行就是**：
    if not state.encounter_active:
        return { "ok": false, "msg": "非戰鬥中" }
而 `_action_offer_surrender`（`:844`）**沒有這一條**。
而兩支的 registry 列相鄰（`:209`／`:210`），且 `:848`／`:866` 都呼
  `handle_diplomacy_message(..., "offer_surrender")` ⇒ **下游是同一個意圖**。
```
⇒ ★**所以這張票要補的執法，在它的孿生兄弟裡【已經逐字存在】** ——
**不要新寫檢查、也不要新寫措辭。**

**裁 (b)（他傾向的那個，理由我同意並補強）**：
```
抽一支 `refuse_if_not_in_encounter(state) -> Dictionary`
  ★形狀**沿用已核過的** `refuse_if_not_colocated`（`:303`）：**回空字典 ＝ 放行**、
    回 `{ok:false, msg:…}` ＝ 拒絕 ⇒ **訊息與判斷在同一個回傳**（不回 bool）
  ★★措辭**逐字沿用既有的「非戰鬥中」**（不新造）
兩支 handler 都呼它 ⇒ 一份真相
⇒ ★★★而 (a)（在 `offer_surrender` 裡再寫一條同樣的檢查）**當場製造一個新的第二份**，
  而且是在**我們正在數指紋的那一類裡**（本 spec 用 `TRAIN_COST_COIN` 在查詢面出現幾次當指紋）
  ⇒ (a) 被否決的理由不是風格，是**它與本票的動機直接衝突**。
```

### ★★★而它訂正我自己寫的兩句（我原本會製造第三份措辭）

```
我在 §2③ 寫「措辭與 `_action_surrender_in_encounter` 那一支對齊」——★方向對而不夠：
  「對齊」還是兩份字面；正解是**同一支函式產生它**。
我在 §6② 寫『原因 ＝ 引擎給的「**你沒有在戰鬥中**」』——
  ★★**那是一句我新造的話** ⇒ 它會是第三份措辭（handler 一份、共用檢查一份、全列版一份）。
⇒ **訂正**：`disabled_reason` **由那支共用前置檢查產生**（全列版**呼它**、讀它回的 `msg`）
  ⇒ 措辭**只有一份**，而它的字面是既有的「非戰鬥中」。
⇒ ★★★判準（今天第 N 次同形）：**「兩邊對齊」是紀律，「同一支函式」才是結構** ——
  而我自己在同一張 spec 裡用結構要求別人、用紀律要求自己那一句。
```

**⇒ 驗收補一格（接在 §3 之後）**：
```
P8 [★措辭只有一份] `git grep -c "非戰鬥中" -- scripts/simulation/` ⇒ **恰好 1**
   （＝只有那支共用前置檢查裡有這個字面）
   ｜負對照：在 `offer_surrender` 裡再寫一句同字面 ⇒ 變 2 ⇒ **必紅**
   ★★母體地板：印出那一個命中的 `file:line`（否則「1」可能是**它根本不在了**）
P9 [孿生兄弟行為不變] `surrender_in_encounter` 在「非戰鬥中」時回的 `msg` 逐字不變
   ⇒ ★這一格守的是 (b) 的爆炸半徑（我動了一支【本來就對】的 handler）
```

### ★§6d 而 implementer ③ 那個「事實而不是決定」我收，並把它記進 defer

```
兩個動詞的差別現在**只剩執法**（一個檢 `encounter_active`、一個不檢），而**下游相同**
⇒ ★`offer_surrender` 看起來像是 `surrender_in_encounter` 的**無執法版本**
⇒ ★★所以「哪一個活下來」那個 WHAT，**事實面偏向留有執法的那一個**
  —— 而這是**一個事實上的傾向，不是我的裁定**（決定是藍圖的）。
★★★而他把它「只放上檯面不下決定」的做法正確：**事實與決定分開寫**，
  否則下游會把一個傾向讀成已經裁了。
```

