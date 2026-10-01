# HOW：「不配對、照預覽價直接成交」那條路線退場

- **WHAT 權威**：`docs/mechanism-intents.md:74`「交易成交唯一路」那一列（★機制意圖帳 ＝ 權威，
  code 服從表；本票的 spec 也服從它）｜裁定來源 ＝ blueprint 裁 (乙) 退場
  （`docs/superpowers/handbacks/2026-10-01-blueprint-to-systems-RULING-confirm-trade-direct-path-retires.md`）
- **上游**：第二母體那張票的三桶掃出的唯一 WHAT 殘餘物
  （`docs/superpowers/handbacks/2026-10-01-systems-to-blueprint-one-what-remnant-confirm-trade.md`）
- **HOW owner**：systems｜**不急**：排在實作端現有序（§3②／§3③ ＋ P2…P6）之後
- **spec 基準樹**：`f8a59a3f8`（★以下每個 `file:line` 都是在這棵樹上開檔讀到的；
  rebase 之後行號會動，**錨是具名識別符不是行號**）

---

## §1 裁定逐字（我不改寫它，只把它翻成動作）

```
「零特例 —— 世界裡沒有『不配對直接成交』這個機制，只有一條玩家專用捷徑，
  而它連活介面都進不去。留著 ＝ 一條只有程式通道能打到的路（第三管道病）。」
★而「一鍵成交」日後的形狀是**出價流程裡的「接受對方當前報價」**，走同一條配對路，
  不是復活這一條。⇒ 本票**不實作**那個，只確保退場不把那條路堵掉。
```

## §2 ★★★一個我必須先訂正的數字：連帶是【三支】不是兩支

```
我給藍圖的信寫「連帶兩支變零呼叫點」。★實測是**三支**，而第三支是我漏的：
  ①`resolve_trade_direct`     interaction_system.gd:1446   caller ＝ 僅 player_command_system.gd:619
  ②`get_trade_direct_preview` player_query_api.gd:200      caller ＝ 僅 sim_bridge.gd:312（＋兩支床）
  ③★`preview_trade`           interaction_system.gd:1461   caller ＝ **僅** player_query_api.gd:211
     ⇒ 也就是 ②的函式體裡那一行 ⇒ 刪掉②，③就是零呼叫點。
★★我當時怎麼漏的：我數的是【我自己列出來的那兩支的呼叫點】，
  **沒有再往下數一層「那兩支自己呼了誰」** ⇒ 連帶鏈要**追到不再變成零**才算數完。
★★★而 `get_trade_preview`（offer-based，:176）**不碰** `preview_trade`
  （它走 `PlayerTradeSystem`）⇒ 逐處核過：`player_query_api.gd` 裡 `InteractionSystem`
  只出現一次（:211）⇒ ③可以刪。
```

## §3 做什麼 —— ★**指名，不數數**

### ★★★★★訂正（2026-10-01，實作端的紅抓到的）：**這張清單【不是】母體**

```
原本這一節的標題寫「這張票的母體就是這張清單」。★而那是錯的，實測兩次：
  ①`success_sentence_bed` 的 `SPEC_REGISTRY_ACTIONS` 51→50 **不在清單上**
  ②`scripted_exploration_bed` 的 `SPEC_ACTIONS_L2` 51→50 **也不在清單上**
  ⇒ 兩次都是「**跑一遍看它紅在哪**」抓到的，不是讀清單讀出來的。
★★判準（implementer 立、我收）：**指名清單會漏，而跑出來的紅不會** ——
  **指名是為了「不要誤改」，不是為了「不會漏」；兩者要各自有機制。**
⇒ ★★★所以**退場票的母體要由機器產生**，★★★★而它**有三行不是一行**
（實作端 2026-10-01 當場訂正我上一版 —— 上一版只寫了第一行，而那會給一個**假的安心**）：

```
①【提到那個名字的檔】 `git grep -l "<要退場的名字>" <ref> -- scripts/`
   ⇒ 實測 11 檔，而他改的就是這 11 檔（一檔不多一檔不少）⇒ 這一維 grep 覆蓋得住。
②★【數那個母體大小的檔】`git grep -n "= <退場前的那個數>" <ref> -- scripts/`
   ⇒ 它們**一個字都沒提那個名字** ⇒ ①抓不到
   ⇒ 實測（`= 51`）**4 處命中**：`scripted_exploration_bed:41`（`SPEC_ACTIONS_L2`）
     ＋`success_sentence_bed:41`（`SPEC_REGISTRY_ACTIONS`）＋2 個明顯無關（person id／team id）
   ⇒ ★**失效方向是多報** ⇒ 逐處開檔判斷「它數的是不是同一個母體」是安全的工序。
   ⇒ ★★而 `success_sentence_bed` 之所以被①抓到，是因為它**剛好也提到那個名字**
     —— **那是運氣不是機制**（同族：「運氣在卷面上跟佈置同形」）。
③【以上都抓不到的】⇒ **沒有靜態母體** ⇒ 明文寫：**這一維只有電池會紅**
   ⇒ ★所以交件**必須有一輪電池**，而不是「我掃過了」。
```

⇒ ★★★★★而這條判準的正確說法**不是「清單 vs grep」，是【靜態 vs 行為】**
（實作端的用詞，我收）：**靜態的三行都做完了，仍然有一維只有跑才會紅。**
⇒ 交件要貼①②兩份輸出 ＋ 電池的 `BATTERY_RC`，而不是貼「我照清單改完了」。
★`docs/` 那一半**不要照抄 grep 的數**：逐一開過幾乎全是**歸檔與歷史 handback**
⇒ **歷史不是現況**，一個字都不該改 ⇒ 交件把它標成「歷史，不動」
（★判準：**一個數字是歷史還是現況，要寫在它旁邊**）。



### (A) 引擎側（刪）

```
A1  registry 那一列            player_command_system.gd:201  `"confirm_trade": _action_confirm_trade,`
A2  handler 整支               player_command_system.gd:611-622 `_action_confirm_trade`
A3  直接結算                   interaction_system.gd:1446-1459 `resolve_trade_direct`
A4  直接結算的預覽             player_query_api.gd:198-212 `get_trade_direct_preview`（含上面那兩行註解）
A5  ★第三支                    interaction_system.gd:1461-… `preview_trade`
A6  顯示名那一列               player_api_mapper.gd:444 `"confirm_trade": return "確認貿易"`
```

★**A2 刪整支而不是只刪 direct 分支**，理由寫明：它的另一半（有 `trade_offer` 時）
**逐字只是轉呼 `_action_submit_trade_offer`**，而活介面**已經直接 emit `submit_trade_offer`**
（text_ui_main.gd:2719）⇒ ★留下來的會是一個**零 emit 點的別名鍵**，
而那正是本票要消滅的那個形狀（registry 裡有、玩家面進不去）。
★★**而這也是裁定裡「床：三桶相加 ＝ 母體 30−1」唯一能成立的讀法** ——
母體少 1 ＝ `confirm_trade` 離開 registry；若留成別名鍵，第三桶**還是 1**，裁定自相矛盾。
⇒ ★★★**我按他自己的床那一行裁：A1＋A2 一起走。**「保留出價那半」保的是**能力**
（`submit_trade_offer` 一行不動），不是那個鍵。
★在回信裡我把這個讀法逐字寫給藍圖（他若要留別名鍵，那就是把第三桶留成 1，要他自己說）。
★★★**而他回了，逐字同意**（`9381f77f5`）：「confirm_trade 整支含別名鍵一起刪，
衝突時採可被機器檢查的那句（三桶＝30−1），能力由 `submit_trade_offer` 保住；
連帶三支（含 `preview_trade`）收。」⇒ **A1＋A2 一起走這件事不再是我的讀法，是裁定本身。**

### (B) 活樹 UI（刪）

```
B1  sim_bridge.gd:310-312  `query_trade_direct_preview` ＋ 它上面那行 `# U12:` 註解
    ★活樹裡零呼叫點（`text_ui_main.gd` 全檔 `trade_direct` 命中 ＝ 0，我數過）
```

### (C) 死樹（★刪，理由不是整理而是防陷阱）

```
C1  scripts/ui/main.gd:103-106  彈窗 confirm 那一支 emit（★只動 confirm 那一路，
    `cancel_trade` 留著 —— 它在 registry 裡、活介面 [Esc] 走它）
C2  popup_layer.gd:262  `# confirm_fn: Callable() — execute confirm_trade` 那行註解
```

★理由：`main.gd` 是死樹，但**留一個 emit 不存在動作的呼叫**是給「下一個復活 main.gd 的人」
的陷阱（他會以為那條路能走）。★★而刪掉它之後，**P1 那條地板才能成立**（見 §4）。
★★★`show_trade_preview` 這支函式**本身不刪**（`popup_layer` 不在活樹清單裡，
而它還有 cancel 那一半）—— 本票不做死樹整理，只斷 `confirm_trade` 這個名字。

### (D) 床（退場 ＋ 常數逐字重抄）

```
D1  headless_test.gd:165 的呼叫 ＋ :8974-… `_test_u12_trade_direct_preview` 整格退場
D2  headless_test.gd:14326 dict 的 `"confirm_trade": "internal(legacy)"` 那一項
D3  query_returns_body_census_bed.gd:199 `player.get_trade_direct_preview` 那一列
    ★★★連帶它的母體常數 —— ★**不要憑預測改**：先跑、看它印出來的數、**逐字抄**
D4  success_sentence_bed.gd:188 print 文字裡的 `_action_confirm_trade`
D5  ui_flow_test.gd:860-861 那句假註解（★已另信交你，本票順手收尾）
D6  ACTION_SHAPE 掉 `confirm_trade` ⇒ 列數 −1｜registry key −1｜**母體 −1**｜第三桶 1→0
    ★★★**不要照這一行的數字改** —— ★原文寫的是「54→53｜51→50｜母體 30→29」，
      而 **母體在本票開票之後已經從 30 變成 31**（`cancel_move` 的 `listed` 由
      true 改成 false ⇒ 它加進了 `target=="none" and not listed` 那一側，2026-10-01 systems 裁）
      ⇒ ★**先跑、看它印出來的數、逐字抄**；判準是「**少 1**」不是「等於某個數」。
    ★★**空名單也要印**（第三桶變空是本票的成功條件，而一個不印出來的空集合沒有主詞）
D7  `available-actions` 等註冊表 expect 若含上列任何數字 ⇒ **跑完從輸出逐字抄**，不要往上改
```

### (E) 我的檔（★與 code 同一顆 commit，不得分開）

```
E1  docs/process/teams-has-callsites.tsv:72（`_action_confirm_trade`）
    ＋ :77（`get_trade_direct_preview`）兩列移除
    ★順帶一個我自己檔的缺陷記在這裡：那兩列的行號欄（415／121）**早就過期**
      （現值 611／200）⇒ 它的錨是 `檔::函式名`，行號只是當時的記錄。本票不修全表。
E2  docs/known_issues.md ／ docs/progress.md 各一行（我寫）
```

★**已核過不會紅、所以不列為工作**：`live-team-ratchet`。
它的 baseline key ＝**檔名 ＋ 那一行正規化 code 文字的多重集**（`live_team_ratchet.py:15` 逐字），
**不是行號**，而豁免的方向是「命中變少」⇒ 刪 code 不會讓它紅。
★★留下來的兩列 stale baseline 是**無害殘留**（「讀者還在寫者沒了」的輕量版）⇒
**不加閘**（已有 hook 覆蓋的問題不加第二支），寫在這裡當紀錄。

## §4 地板（P） —— ★一個不會腐爛的判準 ＋ 一支已經存在的偵測器

```
P1  `grep -rn "confirm_trade" scripts/` ＝ **0 命中**
    ★它不釘數字、不會腐爛：任何人把它加回來都會紅並指名那一行。
P2  `resolve_trade_direct`／`get_trade_direct_preview`／`query_trade_direct_preview`／
    `preview_trade` 四個名字在 `scripts/` 下各 0 命中
P3  三桶床：第三桶 ＝ **空名單（且印出來）**｜三數相加 ＝ 母體，
    ★而母體 ＝ **退場前那一輪跑出來的值 − 1**（★★不釘字面數字：那個值會因為**別的票**而動，
    本票開票後它就被另一張票從 30 動到 31 ⇒ 釘字面會讓這一格在一件無關的事上紅）
P4  ★負對照（★R² 給了更好的做法，採用）：**不建 worktree、不碰工作樹**，
    指到退場前那棵樹驗紅：
      `git grep -n "confirm_trade" f8a59a3f8 -- scripts/`   ⇒ **必須有命中**
      `git grep -n "confirm_trade" HEAD      -- scripts/`   ⇒ **必須 0 命中**
    ⇒ ★兩行放在交件信裡，**一行有命中一行沒有** ＝ P1 有鑑別力的證明。
    ⇒ ★★這就是「動輸入不動事實」的最省形狀：零清理負擔，且不可能誤刪自己的工作
      （我原本寫的「另一棵釘死的 worktree」也對，但那是更貴的版本）。
P5  ★貿易正路沒壞（這張票的真風險在這裡，不在刪得乾不乾淨）：
    trade 子模式 [Enter] 送出 `submit_trade_offer` 那一格**指名**並綠
    （`text_ui_main.gd:2719` 那條路；★**指名那一格的函式名**寫進交件信）
P6  ★★`zero-caller` 閘綠 —— **本票的失效方向是「只刪一半」**
    （刪了 handler 沒刪 A3／A4／A5 ⇒ 它們變零 caller）
    ⇒ ★而專案裡**已經有一支閘在量那件事** ⇒ **本票不加新閘**。
P7  電池全綠（★跑在釘死 HEAD 的 worktree；★★本票改了床與 expect ⇒
    那幾格的綠**必須是新檔的綠**，不得引用舊 run-id）
```

## §5 ★交件要報的數字（不報狀態）

```
·`scripts/` 下 `confirm_trade` 命中數（必須逐字是 0）
·四個名字各自的命中數
·三桶：三個數逐一報 ＋ 相加 ＝ 母體（★第三桶必須是 **0**，且**空名單那一行的原文貼上來**）
  ★★而「母體 ＝ 退場前 − 1」要用**兩輪的輸出**對照（退場前那一輪的數也貼上來）
·registry key 數｜ACTION_SHAPE 列數（跑出來的數，不是預測的數）
·P5 那一格的**格名**
·★★哪幾支床的 expect 被改、各改成什麼（從輸出逐字抄的那個值）
```

## §6 ★不在本票範圍（寫下來，免得被吞掉）

```
·「接受對方當前報價」那個一鍵 —— 藍圖明寫是**日後**、且形狀走配對路 ⇒ 不在本票。
·`popup_layer` ／ `main.gd` 的其餘死樹整理 ⇒ 不在本票。
·`teams-has-callsites.tsv` 全表行號過期 ⇒ 不在本票（E1 只動那兩列）。
·★**已結案**：這條裁定已進 `docs/mechanism-intents.md:74`「交易成交唯一路」那一列
  （藍圖自己寫的，`9381f77f5`；我 `grep` 核過那一行真的在那棵樹上）
  ⇒ ★★**那一列才是本票的 WHAT 權威**，spec 服從它；改機制先查那一列。
```


---

## ★★★★★§6b 一條我**自白錯了**的訂正（2026-10-01，R② 打回）

```
我在裁定信裡寫：「★我 spec 的 `text_ui_main.gd:2719` 指到 `surrender_pre_encounter`，
  真送出點在 :2786 ⇒ 我今天第二次用錯的 file:line 把人送到錯的地方。」
★而 R② 獨立去核，在 spec 的基準樹 `f8a59a3f8` 上查 `:2719` ——
  **那裡逐字就是 `"action_id": "submit_trade_offer"`**（我自己也重核過，確認）
  ⇒ ★★**我的 file:line 在它自己的那棵樹上是對的。**
真相：那個聲稱落地在 `feat/text-ui-layout-v2`，而那棵樹因為中間幾張票
  行號漂了 ⇒ 在 `ba8ae2fc9` 上 `:2719` 變成 `surrender_pre_encounter`、真送出點在 `:2786`。
```

⇒ ★★★**真正的缺陷不是「指錯」，是【一個 file:line 沒有帶樹】** ——
而我的自白把它描述成另一種錯（而**不準的自白披著檢討外衣，沒人會回頭查**，
下游會拿它當前提：R② 一度以為我這條訂正本身也錯了）。
⇒ 規矩升級（取代我前一版的「指名一格要附格名或 file:line」）：
**指名一格要附【格名】或【file:line ＋ 那棵樹的 ref】** ——
★而 R② 的那一半更鋒利：**核一個實作的 file:line 聲稱時，要先問「是哪一棵樹」**
（spec 的基準樹與落地分支會漂開，兩者不是同一回事）。

## §7 R② 紀錄（reviewer，`d6c8811a4`，verdict ＝ **CLEAN**）

```
①★他獨立反向溯源核過三支連帶到底，並**多列了一層我沒列的**：
   `get_trade_direct_preview` 的三個 caller（B1 `sim_bridge` ／ D1 `headless_test` ／
   D3 census-bed）**全在本票清單內** ⇒ **沒有第四支遺孤**。
   ⇒ ★這正是我請他打的那一點（我用的是跟我上一輪出錯同一種核法）。
②字面 vs 床那一條他不重審（藍圖已結，他 grep 核過 `mechanism-intents.md:74` 的字面）。
③P4 改用 `git grep <舊 ref>`（已折進 §4）。
P5 他讀了 `_action_confirm_trade` 本體確認 trade_offer 那半只是轉呼，
   而活介面本來就直接 emit `submit_trade_offer` 不經過這個鍵 ⇒ **指名那一格對，不加格**。
```

★**放行**：可 dispatch。**排在實作端現有序（§3②／§3③ ＋ P2…P6）之後**。
