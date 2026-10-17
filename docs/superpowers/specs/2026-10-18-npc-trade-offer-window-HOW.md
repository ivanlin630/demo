# 電腦隊想跟你換 ⇒ 跳視窗報價 — HOW

- WHAT：藍圖票 `docs/superpowers/handbacks/2026-10-17-blueprint-to-systems-TICKET-npc-trade-offer-to-player-opens-window.md`（用戶裁 2026-10-17 甲）。
- 排序：批尾小修二（`2026-10-17-tail-fixes-2-HOW.md`）合併之後動工。本張 HOW 提前寫（藍圖 2026-10-18 填閒線）；file:line 在 main `16af14eca` 上讀，**小修二合併後動工前重對一次**（D7 的兩個閘會把行號推開）。
- 前提依賴小修二：
  - D7 的謂詞「玩家方」＝`possessed or player_controlled`（同一支，本張不另寫）。
  - D7 的兩個閘：路遇閘（`interaction_system.gd:360` TRADE 分支內）、市集同格閘（`_market_peer_trade` `:1068-1081`）。
  - E7 的帳本理由分類（成交照用今天的 reason，糧撐句的「交易」自然出現）。
- 範圍：玩家面＋一處世界行為（電腦隊會向玩家方提案；接受才動帳）。不還價、不加門檻、不加每日上限、不加「別再問」開關（WHAT 不做）。

---

## 一、觸發點（三處，全部只在「對方是電腦、這一側是玩家方」時）

| # | 路 | 誰走得到 | 現況 | 改成 |
|---|---|---|---|---|
| T1 | `_try_interact` 玩家分支（`:258-314`） | 附身主隊、**非同勢力**，對方 `current_task == TASK_TRADE` | 落到路徑 4（`:306-314`，進 `player_pending_targets`），不交易 | 在路徑 3（勒索）與路徑 4 之間加一支：對方是 TRADE 隊 ⇒ 試報價；**之後照舊走路徑 4 的程式**（照樣進可互動名單） |
| T2 | 路遇 TRADE 分支（`:360-366`），小修二 D7 的閘 | 同勢力附身主隊、玩家派出的子隊 | D7 後：不成交 | D7 的閘那一支改成：試報價（玩家方那側）；仍不呼叫 `_resolve_market` |
| T3 | 市集同格（`_market_peer_trade`），小修二 D7 的閘 | 訪客是電腦、peer 是玩家方；或訪客是玩家方、peer 是電腦 | D7 後：跳過 | 跳過那一支時試報價（電腦那一方對玩家方） |

- 非同勢力附身主隊到不了 T2（R²d M1：`:258-314` 其餘分支全 return）⇒ T1 是主隊最常見的入口，T2 只蓋同勢力主隊與子隊。
- 「試報價」＝§二算一份報價；有效 ⇒ 寫強制事件；無效 ⇒ 什麼都不做。

## 二、報價怎麼算（只讀電腦那一方）

- 新一支 `TradeValuation.npc_offer(state, npc, player_side) -> Dictionary`（放 `trade_valuation.gd`，估值單一源那支）。回空字典＝不提。
- **感知**：只讀 `npc` 自己的庫存、`reserve`、`local_value`／`ask_price`，以及玩家方領袖 id（面對面知道是誰，同今天 `ask_price` 傳 `buyer.leader_id` 那個恩怨入口）。**不讀玩家方的庫存、錢、估價**——那是電腦替玩家秤，正是 D7 要拔掉的東西。
- 三種，依今天 `_resolve_market` 的呼叫順序取第一個有效的（同一順序＝同一個偏好，不另發明）：
  1. **對方賣**：`npc` 有餘裕（庫存−reserve>0）的 res，單價＝`ask_price(npc, res, …, player_leader_id)`，量＝餘裕取整。
  2. **對方買**：`npc` 缺的 res（`reserve − 庫存 > 0`），單價＝`local_value(npc, res)`，量＝min(缺口, 錢÷單價, `npc` 的載運空間)。
  3. **以物易物**：對方用一種餘裕換一種缺口，等值以**對方的**兩個估價換算（`_attempt_barter` 同一條算式，只是兩個估價都取 `npc` 的）。
  - 商隊存貨（`merchant_inventory`）算在「對方賣」裡，單價用它的 `ask_price`。
  - 量 ≤ 0 或單價 ≤ 0 的那種跳過。
- 報價內容：`{kind: sell|buy|barter, npc_id, side_id（玩家方那支隊 id）, give_res, give_qty, want_res, want_qty, unit_price, tile}`。`sell`＝對方給貨要你錢；`buy`＝對方給錢要你貨。

## 三、強制事件

- 寫入：`state.set_player_forced_event({"action": "trade_offer", "from_id": npc_id, …報價}, str(randi()) + "_" + str(randi()))`，同外交／勒索（`:291-303`）那一套。id 用 randi 同既有寫法（只在有玩家的世界走到）。
- **不覆蓋**：`player_forced_event` 非空 ⇒ 丟棄這次報價（不排隊），`Probe.bump("trade.offer.dropped_busy")`。理由：同既有八處寫法；排隊要一個新結構，WHAT 沒要。
- **一次相遇一次提案**：`WorldState.trade_offer_seen: Dictionary`（npc_id → 提案當下雙方所在格 key）。同一對還在同一格 ⇒ 不再提。任一方換格 ⇒ 那筆清掉（在試報價時順手比對，不另起掃描）。
  - 理由：同格駐留每 tick 都會再走 `_try_interact`（`:150-166` 駐留掃描）。不擋的話，拒絕後下一拍立刻再跳同一張——那不是「頻率要不要上限」的設計題，是同一次相遇被重算。WHAT 說的「不加門檻／上限／別再問」照做：換格再碰到就會再問。
  - 被 `dropped_busy` 丟掉的那次**不記** seen（之後空出來還能提）。
  - 不存檔、不進 world-fp（顯示側狀態；重載後最多多問一次）。
- 推進停點：現成的。強制事件存在 ⇒ 推進停（`text_ui_main.gd:387-392`、`:1394-1411`「有事找上門」），不另寫。
- 逾時：現成的整點逾時（`sim_runner.gd:703-757`）視同拒絕。本張只需要它的句子讀得懂（§四）。

## 四、視窗與回應

- 文案單一產生者：`PlayerApiMapper` 加一支 `trade_offer_text(state, evt) -> String`，`map_forced_interaction`（`player_api_mapper.gd:327-360` 的 `match action`）、`action_phrase`（`:406-413`）、逾時句都讀它。
  - 例：「Team7 想賣你 糧食×20，每件 1.5 金（共 30 金）」「Team7 想買你 材料×10，每件 2.0 金（共 20 金）」「Team7 想用 材料×10 換你 糧食×8」。
  - 子隊那一側：「Team7 想跟你的子隊 Team12 換：…」。
  - 資源名走 names.tsv（小修二 E2）。不寫「划不划算」（WHAT 2）。
- 回應：`get_forced_response_options`（`player_command_system.gd:1997-2029`）加 `"trade_offer": ["accept", "refuse"]`；`forced_label`（`player_api_mapper.gd:624`）「接受」／「拒絕」。
- `respond_to_forced`（`:2032-2144`）加 `"trade_offer"` 分支：
  - **拒絕**：`{ok: true, msg: "拒絕 Team7 的交換"}`。不動關係帳、不動對方任務（WHAT 3）。
  - **接受**：呼叫 §五的成交函式，`msg` 用它回的句子（「跟 Team7 換了：付 30 金，得 糧食×20」）。
  - 句子進事件流：現成的 `forced_event_resolved`（`:2114-2127`）。

## 五、接受＝照今天同一支成交函式寫帳（物理不變）

- 把今天兩支的**寫帳那幾行**抽成兩支，今天的撮合與報價成交都呼叫它：
  - 金錢交易：`_execute_transfer`（`interaction_system.gd:922-926`）原樣用。商隊存貨那段（`:1407-1409` 的三行）抽成 `_execute_inventory_sale(...)`，`_attempt_trade_direction` 改呼叫它。
  - 以物易物：`_attempt_barter` 的四行寫帳（`:1491-1494`）抽成 `_execute_barter(a, b, give_res, give_qty, pay_res, pay_qty)`。
  - ⇒ reason 字串與今天逐字相同（E7 的類表不用改）；寫入點只此一處。
- 接受當下**重驗物理**（不重算價錢，價錢是對方開的）：
  - 兩隊都還在、還在同一格；否則 `{ok: false, msg: "對方已經離開"}`。
  - 量夾到：對方此刻的存量／錢、玩家方此刻的存量／錢、收貨方載運空間。夾到 0 ⇒ `{ok: false, msg: "你的錢不夠"／"你沒有這些貨"／"對方已經沒有這些貨"／"放不下"}`（哪一個由夾住的那一項決定）。
  - 夾過但 >0 ⇒ 成交夾過的量，句子寫實際量，`Probe.bump("trade.offer.accept_clamped")`。
- 讀玩家方庫存只在**接受之後、寫帳之前**——這是物理（貨夠不夠），不是決策。

## 六、tap

`trade.offer.raised.t1|t2|t3`、`trade.offer.none`（試了但三種都無效）、`trade.offer.dropped_busy`、`trade.offer.dedup`、`trade.offer.accepted`、`trade.offer.refused`、`trade.offer.timeout`、`trade.offer.accept_clamped`、`trade.offer.accept_failed.<原因>`。

---

## 驗收

- 新床 `scripts/debug/npc_trade_offer_bed.gd`，閘列 `npc-trade-offer`，expect `=== npc_trade_offer DONE === errors: 0`。真鍵路徑（終端 driver 或 TextUI 送鍵），不直呼 handler。

| 格 | 斷言 |
|---|---|
| O1 | T1：非同勢力附身主隊與電腦 TRADE 隊同格 ⇒ 推進停在「有事找上門」、視窗文案含對方、給什麼多少、要什麼多少、單價；同時對方仍在可互動名單 |
| O2 | T2：玩家派出的子隊路遇電腦 TRADE 隊 ⇒ 視窗、文案帶子隊；同勢力主隊同一格 |
| O3 | T3：電腦訪客到玩家所在市集格；玩家方當訪客到有電腦 peer 的市集格 ⇒ 各一張 |
| O4 | 接受 ⇒ 帳本 reason 與今天電腦對電腦同種交易逐字相同、量與單價＝報價；糧撐句（小修二 E7）在跳動過門檻時印「交易」 |
| O5 | 拒絕 ⇒ 帳 0 筆、雙方關係值與對方任務修前修後相同、一句「拒絕 Team X 的交換」；逾時同拒絕、句子讀得懂 |
| O6 | 拒絕後同格再推 6 小時 ⇒ 不再跳（`trade.offer.dedup`>0）；對方換格再回來 ⇒ 再跳一次 |
| O7 | 已有勒索視窗時對方 TRADE 到場 ⇒ 勒索視窗不被蓋、`dropped_busy`=1；勒索處理完、仍同格 ⇒ 之後能跳報價 |
| O8 | 感知：同一 fixture 只改玩家方庫存與錢（0 對 1000）⇒ 報價逐字相同 |
| O9 | 接受時重驗：玩家錢不夠 ⇒ 夾量或失敗句；對方已離開 ⇒ 失敗句、帳 0 |
| O10 | 反向：兩支電腦隊同 fixture 照常成交（成交 ≥1）、world-fp 那一趟不變（沒有附身隊） |

- 每格要有母體地板：該格的觸發計數 ≥1，否則該格不算數（印出計數）。
- 負對照（各拿掉一刀，該格要紅）：
  - n1：seen 不記 ⇒ O6 紅
  - n2：報價改讀玩家方的 `local_value` ⇒ O8 紅
  - n3：接受改走新寫的轉帳（不經 `_execute_*`）⇒ O4「reason 逐字相同」紅
  - n4：不檢查 `player_forced_event` 非空就寫 ⇒ O7 紅
  - n5：T1 那支加完就 return（不走路徑 4）⇒ O1「仍在可互動名單」紅
- world-fp：照常跑閘。預期不變；變了歸因到第一個分歧 tick，不直接換值。
- 舊床：`_attempt_trade_direction`／`_attempt_barter` 抽函式後，跑有交易的現成床（交件信列名單與修前修後）。

## 誠實限

- 報價只取第一種有效的（同今天撮合順序），不比三種誰對對方最划算。
- 對方開價不看玩家有沒有錢 ⇒ 會出現玩家付不起的報價；接受時才說「你的錢不夠」。這是感知鐵律的代價，不是 bug。
- 一次相遇一次提案；同一支電腦隊在附近來回換格，會一直問。頻率等 QA 玩一局再談（WHAT 不做）。
- 「排隊」不做：撞上別的視窗那次報價就丟了。
