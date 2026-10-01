# HOW：「不配對、照預覽價直接成交」那條路線退場

- **WHAT 權威**：blueprint 裁 (乙) 退場
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

## §3 做什麼 —— ★**指名，不數數**（這張票的母體就是這張清單）

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
★在回信裡我會把這個讀法逐字寫給藍圖（他若要留別名鍵，那就是把第三桶留成 1，要他自己說）。

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
D6  ACTION_SHAPE 掉 `confirm_trade` ⇒ 54→53｜registry 51→50｜母體 30→29｜第三桶 1→0
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
P3  三桶床：第三桶 ＝ **空名單（且印出來）**｜三數相加 ＝ 母體 29
P4  ★負對照：把 A1 那一列加回去 ⇒ P1 必紅**並指名** `player_command_system.gd` 那一行
    ⇒ ★**動輸入不動事實**：用 `git stash` 以外的方式 —— 在**另一棵釘死的 worktree** 或
      對一個 fixture 做，**不要在共用 main dir 改活檔**（共用目錄的破壞式負對照已出事兩次）
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
·三桶：27／2／**0**，相加 ＝ 29（★空名單那一行的**原文**貼上來）
·registry key 數｜ACTION_SHAPE 列數（跑出來的數，不是預測的數）
·P5 那一格的**格名**
·★★哪幾支床的 expect 被改、各改成什麼（從輸出逐字抄的那個值）
```

## §6 ★不在本票範圍（寫下來，免得被吞掉）

```
·「接受對方當前報價」那個一鍵 —— 藍圖明寫是**日後**、且形狀走配對路 ⇒ 不在本票。
·`popup_layer` ／ `main.gd` 的其餘死樹整理 ⇒ 不在本票。
·`teams-has-callsites.tsv` 全表行號過期 ⇒ 不在本票（E1 只動那兩列）。
·這條裁定要不要進 `docs/mechanism-intents.md`（我查過：那份表目前**沒有**貿易那一格的
  「不配對直接成交」條目）⇒ ★**WHAT 權威是藍圖**，我在回信裡問他一句，不自己加。
```
