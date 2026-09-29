# HOW spec：死輸入探索床（把每個動詞×每種目標各按一遍，每步核四條）

owner: systems ｜ 2026-09-29 ｜ **player_reachable: yes（它驗的就是玩家面）**
上游：blueprint 票 `2026-09-29-blueprint-to-systems-TICKET-scripted-exploration-bed-all-verbs-four-rules.md`
（用戶裁「先跑死輸入」；LLM 自玩不做）
序：**#8 → #7 → 本票** → 圖形介面方向票（等用戶）。

---

## ★★★§1 前提與【母體的三個數】（★而上游的 37 不等於我量到的任何一個）

```
①`agent_repl.gd` 是一支 **stdin／TCP 的互動 REPL**，不是可被床呼叫的 library
   ⇒ ★★所以「走 agent_repl 那條 API」的**可執行讀法**是：
     呼它 `_dispatch` 真正打進去的那幾支 —— `_bridge.query_player()`（:148）／
     `_bridge.command_player()`（:157）／`_bridge.advance_ticks()`（:180）
   ⇒ ★★★**床不要起 REPL transport**（那會多一個 TCP／pipe 依賴，而它與被測物無關）
②★動詞母體【有兩層】，而兩層的數不同：
   ·層1 `PlayerCommandApi.dispatch` 的頂層動詞 ＝ **14**
     （cancel_move cancel_order deposit_item equip_item execute_action move_to possess
       post_buy_order post_sell_order refresh_targets respond_to_forced take_team_item
       unequip_item unpossess）
   ·層2 `execute_action` 底下 `_action_registry` ＝ **51**
     ＋ `execute_action_with_target` 的 4 個 case（其中 3 個是不在 registry 的 `_action_*`）
   ·層3 forced_event 的 action 種類 ＝ **5**（diplomacy／extort／join_request／aid_request／choose_heir）
     × 每種的回應集（`_forced_responses()` 動態回，diplomacy 有 2 或 3 種）
③★★★**上游寫「現 37 動詞」，而 14／51／5 都不是 37** ——
   ⇒ 我**不猜**它指哪一層、也**不拿我的數去覆蓋它**。
   ⇒ 已回問 blueprint 那個 37 是怎麼數的（`systems→blueprint` 同日信）。
   ⇒ ★而本票**不等那個答案也能開工**：床的母體**自己導出**（§2①），
     而 `SPEC_*` 常數先填我量到的三個數；★★對不上就回報，不默默改。
```

## ★★§2 做什麼

```
①★母體自己導出、且**印出來跟註冊表比**（不要手抄）：
   ·層1：讀 `PlayerCommandApi.dispatch` 的 match 分支
   ·層2：讀 `_action_registry` 的鍵 ＋ `execute_action_with_target` 的 case
   ·層3：對每種 forced_event 呼 `_forced_responses()` 拿回應集（★動態，不得手抄）
   ⇒ **三個數都印，並各自跟 `SPEC_VERBS_L1=14`／`SPEC_ACTIONS_L2=51`／`SPEC_FORCED_L3=5` 比**
   ⇒ ★★對不上 ⇒ 床紅並印出差集（哪一個多、哪一個少）—— **不是自動採用新的數**
②每個組合各按一遍（動詞 × 合法目標；forced_event × 每個回應），每步核四條：
   (a)守恆：coin／food 等的全域帳（用既有 `CoinAudit`／`InvariantAudit`，★不新寫一份）
   (b)回應↔結果一致：`respond_to_forced("accept")` 之後，結果句／事件流不得說「拒絕」
   (c)★必有回饋：每一次 command 都要產出一句玩家看得到的句子（`command_results` 非空）
   (d)★★玩家面字串**零英文識別字**：面板／結果句／事件流不得出現 `[a-z_]{4,}` 這種 id
      ⇒ ★★★**白名單要印出來**（專有名詞、Team%d 這類），否則它會變成一個沒人看得懂的紅
③★★★陽性對照（上游指定，★這是本票的命門）：用戶兩輪撞到的三件，在**修法前的 sha** 上
   必須被這支床**列出來**：
     ·招募扣錢而搬 0 人（`05befff7f` 之前）
     ·接受變拒絕（`propose_alliance` 不在 `_accept_diplomacy` 的 match 裡；#7 未修前）
     ·「Team11 提議 alliance」原樣 id（#7 未修前）
   ⇒ ★列不出來 ＝ **這支床沒接電**，不是「世界很乾淨」。
   ⇒ ★★第二件若在修法前的 sha 上**綠**：床要**印出實際結果句**給我們讀
     （那表示我們對那個症狀的理解是錯的，而那比床紅更重要）
④產物：矛盾清單落 `docs/measurements/`，**機器讀一份（tsv）＋人讀一份（txt）**
⑤掛進電池註冊表（`@bed-kind: invariant` ⇒ 必須進 `merge-gates.tsv`，否則 bed-kind 閘會紅）
```

## §3 不在本票

```
✘ LLM 自玩（上游明寫：另票、等用戶）
✘ 修任何它抓到的缺陷 —— ★本票只負責【把矛盾列出來】；修是各自的票
✘ 圖形介面方向（等用戶那張）
```

## §4 驗收

```
P1 [母體對帳] 三個數各自印出並與 `SPEC_*` 相符｜★負對照：把 `SPEC_VERBS_L1` 改成 13 ⇒ 必紅
P2 [四條都會紅] 每一條各造一個【真實的】違反樣本 ⇒ 該條必紅（四格，缺一不可）
   ★★★而 (d) 的樣本就用**修法前的 sha**（「提議 alliance」）—— 不要造假樣本
P3 ★[陽性對照三件] 在修法前的 sha 上跑 ⇒ 三件都被列出來｜★★列不出來 ⇒ 本票不算完成
P4 [今天的樹] 在 merge 後的樹上跑 ⇒ ①②③ 那三件**不再出現**
   ★母體地板：P4 要印【本輪走了幾個組合】—— 否則「沒有矛盾」在一個走了 0 個組合的世界裡恆綠
P5 [產物] tsv 與 txt 都產出，且 tsv 的列數 ＝ 矛盾筆數（兩份對得上）
P6 ui-flow 綠；merge 前全電池 BATTERY_RC=0
```

## ★§5 誠實限

```
①本 spec 沒有跑 Godot，全部靜態 file:line。
②★上游的「37」與我量到的 14／51／5 都不符 ⇒ **我沒有解釋它**，只把差異寫出來並回問。
  ★★而我刻意**不讓本票等那個答案**：床自己導出母體，對不上就紅。
③★★★(d)「零英文識別字」的白名單我**沒有列**——我只能定義「它必須被印出來」。
  ⇒ 真正的白名單要由**跑出來的第一份卷面**決定，而那是實作端的第一輪產物，不是我先寫死。
④P3 要 checkout 到修法前的 sha 跑 ⇒ ★那是**唯讀的歷史驗證**，
  ★★而它必須在**專用 worktree**（不得在共用 main dir checkout —— 今天已經立規）。
```
