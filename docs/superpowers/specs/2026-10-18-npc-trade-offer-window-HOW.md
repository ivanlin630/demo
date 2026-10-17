# 電腦隊想跟你換 ⇒ 跳視窗報價 — HOW（第二版，依 R² M1–M5／S1–S6）

- WHAT：藍圖票 `docs/superpowers/handbacks/2026-10-17-blueprint-to-systems-TICKET-npc-trade-offer-to-player-opens-window.md`（用戶裁 2026-10-17 甲）。
- 審查：R² `docs/superpowers/handbacks/2026-10-18-reviewer-to-systems-R2-npc-trade-offer-window-ISSUES.md`。各段標了對應的 M／S。
- 排序：批尾小修二（`2026-10-17-tail-fixes-2-HOW.md`）合併之後動工。本張 HOW 提前寫（藍圖 2026-10-18 填閒線）；file:line 在 main `16af14eca` 上讀，**小修二合併後動工前重對一次**（D7 的兩個閘會把行號推開）。
- 前提依賴小修二：
  - D7 的謂詞「玩家方」＝`possessed or player_controlled`（同一支，本張不另寫）。
  - D7 的兩個閘：路遇閘（`interaction_system.gd:360` TRADE 分支內）、市集同格閘（`_market_peer_trade` `:1068-1081`）。
  - E7 的帳本理由分類（成交照用今天的 reason，糧撐句的「交易」自然出現）。
- 範圍：玩家面＋一處世界行為（電腦隊會向玩家方提案；接受才動帳）。不還價、不加門檻、不加每日上限、不加「別再問」開關（WHAT 不做）。
- 與現成的 `propose_trade`（外交提案「提議與你通商」，`player_api_mapper.gd:398`、`player_command_system.gd:2356`）分工：那個是兩隊之間的**通商關係**（外交），這個是**一筆換貨**。兩者字面相近、不是重複（M4）。

---

## 一、觸發點（三處；對方是電腦且 `current_task == TASK_TRADE`、這一側是玩家方）

| # | 路 | 誰走得到 | 現況 | 改成 |
|---|---|---|---|---|
| T1 | `_try_interact` 玩家分支，**路徑 4 的 `else` 內、`can_be_player_target` 通過之後**（`:306-314`；S2） | 附身主隊、**非同勢力** | 進 `player_pending_targets`，不交易 | 先照舊進可互動名單，再試報價。**市集格（`outpost_level > 0`）不報**，交給 T3（M3） |
| T2 | 路遇 TRADE 分支（`:360-366`），小修二 D7 的閘 | 同勢力附身主隊、玩家派出的子隊 | D7 後：不成交 | D7 的閘那一支改成：試報價；仍不呼叫 `_resolve_market` |
| T3 | 市集同格（`_market_peer_trade`），小修二 D7 的閘 | 電腦 TRADE 訪客對玩家方 peer；玩家方訪客對電腦 TRADE peer | D7 後：跳過 | 跳過那一支時試報價 |

- 只限 TRADE 任務的電腦隊（S1）：運糧子隊（`faction_ai_system.gd:4244` 走同一個 `:1048`）等其他到場者不報——它們身上的貨是要運的，不是要賣的。
- 非同勢力附身主隊到不了 T2（R²d M1）⇒ T1 是主隊最常見的入口，T2 只蓋同勢力主隊與子隊。
- 「試報價」＝§二算一份報價＋§三的去重；有效 ⇒ 寫強制事件；無效 ⇒ 什麼都不做。

## 二、報價怎麼算（只讀電腦那一方；M1）

- 新一支 `TradeValuation.npc_offer(state, npc, player_side) -> Dictionary`（放 `trade_valuation.gd`，估值單一源）。回空字典＝不提。
- **感知**：只讀 `npc` 自己的東西＋玩家方領袖 id（面對面知道是誰，同今天 `ask_price` 的 `buyer_leader_id` 恩怨入口）。**不讀玩家方的庫存、錢、人口、標籤、估價**（D7 要拔掉的就是那個）。
- **一把尺**（全部對 `npc`、與 `local_value` 同源）：
  - 缺口 `deficit(res) = maxf(npc.population × TARGET_PER_POP.get(res, 1.0) − ResourceSystem.effective_holding(state, npc, res), 0)`（同 `trade_valuation.gd:271-272` 的短缺；`reserve` 是保留線不是需求，對非活命品恆 0，不用它算缺口）。
  - 餘裕 `surplus(res) = maxf(庫存 − reserve(npc, res), 0)`（同今天 `:1420-1422`）。
  - 缺口價值＝`deficit × local_value`；餘裕價值＝`surplus × ask_price`。
- **種類與順序**：
  1. 取缺口價值最大的 res＝B。有 B ⇒
     - **對方買**：`bid = bid_price(npc, B, …, player_leader_id)`（下一點），量＝min(缺口取整, 錢÷bid, 載運空間)。量 ≥ 1 ⇒ 報這一種。
     - 錢不夠（量 < 1）⇒ **以物易物**：取餘裕價值最大、且 ≠ B 的 res＝A；對方給 A×`give_qty`，要 B×`want_qty`。`want_qty = min(缺口, floor(give_qty × local_value(A) ÷ local_value(B) × (1 − disc_buy)))`、`give_qty` 從 A 的餘裕起算並在 `want_qty` 夾過後回推。兩者 ≥ 1 ⇒ 報這一種。
  2. 沒有 B、或買與換都無效 ⇒ **對方賣**：取餘裕價值最大的 res＝A；`unit = ask_price(npc, A, …, player_leader_id)`，量＝A 的餘裕取整。商隊存貨（`merchant_inventory`）一筆一筆算進候選，單價同樣 `ask_price`。
  - 都無效 ⇒ 空。
- **買價**（新一支 `bid_price`，與 `ask_price` 同檔並列、共用折讓的寫法）：
  - `disc_buy = clampf(commerce × COMMERCE_DISCOUNT_K + (greed − 0.5) × GREED_HOLD_K, 0, DISCOUNT_MAX)`——商業技能與貪婪讓買方壓價；急迫不讓買方壓價（急著要的人不壓價），所以不含 `_urgency` 項。
  - `bid = local_value(npc, B) × (1 − disc_buy) ÷ grudge_multiplier(npc, lv, state, player_leader_id)`——對仇人出價更低、對恩人更高。
  - ⇒ 對方以自己的估價有利可圖（`bid ≤ local_value`），WHAT 1「對方自己秤過划算才提」。
- 報價內容：`{kind: sell|buy|barter, npc_id, side_id（玩家方那支隊 id）, give_res, give_qty, want_res, want_qty, unit_price, tile}`。`sell`＝對方給貨要你錢；`buy`＝對方給錢要你貨；`barter`＝對方給 A 要你 B。

## 三、強制事件與去重

- 寫入：`state.set_player_forced_event({"action": "trade_offer", "from_id": npc_id, …報價}, str(randi()) + "_" + str(randi()))`，同外交／勒索（`:291-303`）。id 用 randi 同既有寫法（只在有玩家的世界走到）。
- **不覆蓋**：`player_forced_event` 非空 ⇒ 丟棄這次（不排隊），`Probe.bump("trade.offer.dropped_busy")`。
- **一次相遇一次提案**（M3）：`WorldState.trade_offer_seen: Dictionary`，鍵＝`"%d:%d" % [npc_id, side_id]`，值＝最後一次同格試報價的 tick。
  - 每次試報價（含被去重擋下的那次）都把值刷新成當下 tick。
  - 擋：`now − seen ≤ T1 週期`（`DecisionTier.T1_OPERATIONAL` 派生，不寫新常數）⇒ 同一次相遇，不報，`trade.offer.dedup`。
  - 新相遇：`now − seen > T1 週期`（中間至少一個駐留週期沒同格）⇒ 可再報。
  - 報過（不論接受、拒絕、逾時）都不清——只靠時間間隔判新相遇。
  - `dropped_busy` 那次**照樣刷新** seen，但另記 `trade_offer_pending_retry[key]=true`；下一次同格試報價時，有這個旗就不擋（之後空出來還能提），報出後清旗。
  - 不存檔、不進 world-fp（重載後最多多問一次）。
  - 理由（R² 判站得住）：同格駐留每個 T1 週期會再走 `_try_interact`（`:131-166`）。外交／勒索不連跳，是因為回應後對方狀態變了；報價拒絕不動對方（WHAT 3），不擋就會逐輪重算同一次相遇。**效果上它是一種重複上限**，寫在誠實限，讓藍圖看「煩不煩」那一局時知道它存在。
- 推進停點：現成的（`text_ui_main.gd:387-392`、`:1394-1411`「有事找上門」）。
- 逾時：現成的整點逾時（`sim_runner.gd:703-757`）視同拒絕。加一支 `trade_offer` 專屬分支（同 `:740` tribute 那種寫法）只做 `Probe.bump("trade.offer.timeout")`；`WorldEvents.describe("forced_event_timeout")` 要認得 `trade_offer`（M4）。
- 到場簿記（S3）：T3 的到場當下沒有成交 ⇒ `sim_runner.gd:961-963` 照舊記「到了沒成交」。提案是之後才回應的事，不回頭改那一筆；接受時另 `Probe.bump("trade.deal")` 與 `trade.offer.accepted`。

## 四、視窗與回應（M4）

- 文案單一產生者：`PlayerApiMapper.trade_offer_text(state, evt) -> String`，`map_forced_interaction`（`player_api_mapper.gd:327-385` 的 `match action`）、`action_phrase`（`:406-413`）、逾時句都讀它。
  - 例：「Team7 想賣你 糧食×20，每件 1.5 金（共 30 金）」「Team7 想買你 材料×10，每件 2.0 金（共 20 金）」「Team7 想用 材料×10 換你 糧食×8」。
  - 子隊那一側：「Team7 想跟你的子隊 Team12 換：…」。
  - 資源名走 names.tsv（小修二 E2）。不寫「划不划算」（WHAT 2）。
- `accept_consequence`（`:416-430`）加 `trade_offer`：「接受＝照這個報價成交」。`no_response_line` 已通用（下一個整點視同拒絕），沿用。
- 回應：`get_forced_response_options`（`player_command_system.gd:1997-2029`）加 `"trade_offer": ["accept", "refuse"]`；`forced_label`（`player_api_mapper.gd:624`）「接受」／「拒絕」。
- `respond_to_forced`（`:2032-2144`）加 `"trade_offer"` 分支：
  - **拒絕**：`{ok: true, msg: "拒絕 Team7 的交換"}`。不動關係帳、不動對方任務（WHAT 3）。
  - **接受**：呼叫 §五，`msg` 用它回的句子（「跟 Team7 換了：付 30 金，得 糧食×20」）。
  - **接受失敗**（§五重驗不過）：回失敗句，**事件清掉**（不像 `join_request` 保留）——對方的狀態已經變了，報價已經不成立，留著只能再按拒絕（S6）。
  - 句子進事件流：現成的 `forced_event_resolved`（`:2114-2127`）。

## 五、接受＝走今天同一段「雙方同意之後」的成交（M2）

- 今天「同意之後」不只寫帳。把**整段**抽成共用函式，今天的撮合與報價接受都呼叫它：
  - `_settle_goods_sale(state, seller, buyer, res, qty, price)`＝`_execute_transfer`（`:1454`）＋`NpcAiSystem.repay_gratitude(state, seller, buyer.leader_id)`（`:1456`）＋買方是商隊時進存貨簿（`:1459-1463`）。`_attempt_trade_direction` 的 `:1454-1463` 改成呼叫它。
  - `_settle_inventory_sale(state, seller, buyer, item, qty, price)`＝商隊存貨賣出（`:1407-1411`：三行帳＋`item["qty"]` 遞減）。`:1398-1413` 迴圈改成呼叫它。
  - `_settle_barter(a, b, give_res, give_qty, pay_res, pay_qty)`＝`:1491-1494` 四行帳＋那一行 print／tap。
  - ⇒ reason 字串、恩情消耗、存貨簿與今天逐字相同；寫入點只此一處。
- 接受當下**重驗物理**（不重算價錢，價錢是對方開的）：
  - 兩隊都還在、還在同一格；否則 `{ok: false, msg: "對方已經離開"}`。
  - 量夾到：對方此刻的存量／錢、玩家方此刻的存量／錢、收貨方載運空間。夾到 0 ⇒ `{ok: false}`，句子由夾住的那一項決定：「你的錢不夠」／「你沒有這些貨」／「對方已經沒有這些貨」／「對方沒有錢了」／「放不下」（S6）。
  - 夾過但 > 0 ⇒ 成交夾過的量，句子寫實際量，`trade.offer.accept_clamped`。
- 讀玩家方庫存只在**接受之後、寫帳之前**——這是物理（貨夠不夠），不是決策。

## 六、tap

`trade.offer.raised.t1|t2|t3`、`trade.offer.kind.sell|buy|barter`、`trade.offer.none`、`trade.offer.dropped_busy`、`trade.offer.dedup`、`trade.offer.accepted`、`trade.offer.refused`、`trade.offer.timeout`、`trade.offer.accept_clamped`、`trade.offer.accept_failed.<原因>`。

---

## 驗收

- 新床 `scripts/debug/npc_trade_offer_bed.gd`，閘列 `npc-trade-offer`，expect `=== npc_trade_offer DONE === errors: 0`。真鍵路徑（終端 driver 或 TextUI 送鍵），不直呼 handler。

| 格 | 斷言 |
|---|---|
| O1 | T1：非同勢力附身主隊與電腦 TRADE 隊同格（非市集）⇒ 推進停在「有事找上門」；視窗含對方、給什麼多少、要什麼多少、單價；整個視窗字串不含「未知」；對方仍在可互動名單 |
| O2 | T2：玩家派出的子隊路遇電腦 TRADE 隊 ⇒ 視窗帶子隊；同勢力主隊同一格 |
| O3 | T3：電腦 TRADE 訪客到玩家所在市集格；玩家方當訪客到有電腦 TRADE peer 的市集格 ⇒ 各一張；運糧子隊到玩家所在市集格 ⇒ 不報 |
| O3b | 市集格一次到場只出一張（T1 不報）；`trade.offer.dedup` 在那一拍為 0 |
| O4a／b／c | 三種各一格，各走真路徑造出：**賣**（對方無缺口有餘裕）、**買**（對方有缺口有錢）、**換**（對方有缺口沒錢、有另一種餘裕）；`trade.offer.kind.*` 各 ≥1 |
| O4d | 接受 ⇒ 帳本 reason、恩情邊消耗量、商隊買方的存貨簿與今天電腦對電腦同種交易逐字相同；量與單價＝報價；買價 ≤ 對方 `local_value` |
| O5 | 拒絕 ⇒ 帳 0 筆、雙方關係值與對方任務修前修後相同、一句「拒絕 Team X 的交換」；逾時同拒絕、句子讀得懂、`trade.offer.timeout`=1 |
| O6 | 拒絕後同格再推 6 小時 ⇒ 不再跳；**接受**後同格再推 6 小時 ⇒ 不再跳；對方離開（離開期間沒有任何試報價）、超過一個 T1 週期後回來 ⇒ 再跳一次；同一支電腦隊先遇主隊被拒、再遇玩家子隊 ⇒ 子隊那張照跳 |
| O7 | 已有勒索視窗時對方 TRADE 到場 ⇒ 勒索視窗不被蓋、`dropped_busy`=1（印這段期間 T1 被呼叫次數 >0，S5）；勒索處理完、仍同格 ⇒ 之後能跳報價 |
| O8 | 感知：同一 fixture 只改玩家方庫存與錢（0 對 1000）、玩家方人口、玩家方 `TAG_MERCHANT` ⇒ 報價逐字相同（S4） |
| O9 | 接受時重驗：玩家錢不夠 ⇒ 夾量或失敗句、事件清掉；對方已離開 ⇒ 失敗句、帳 0 |
| O10 | 反向：兩支電腦隊同 fixture 照常成交；world-fp 那一趟不變，且印那一趟 `trade_goods_*`、`market_inv_*`、`barter_*` 筆數**各 ≥1** 才算三支抽出函式都被走到；任一為 0 ⇒ 該函式改由單元床直呼、修前修後逐帳比對（M5） |

- 每格要有母體地板：該格的觸發計數 ≥1，否則該格不算數（印出計數）。
- 負對照（各拿掉一刀，該格要紅）：
  - n1：seen 不記 ⇒ O6 紅
  - n2：報價改讀玩家方的 `local_value` 或 `reserve` ⇒ O8 紅
  - n3：接受改走只有 `_execute_transfer` 的轉帳（拿掉 `repay_gratitude`）⇒ O4d 的恩情格紅
  - n4：不檢查 `player_forced_event` 非空就寫 ⇒ O7 紅
  - n5：T1 那支報完就 return（不走路徑 4）⇒ O1「仍在可互動名單」紅
  - n6：順序倒回「賣第一」⇒ O4b、O4c 紅
  - n7：拿掉 T1 的市集格排除 ⇒ O3b 紅
- world-fp：照常跑閘。預期不變；變了歸因到第一個分歧 tick，不直接換值。
- 舊床：抽函式後，跑有交易的現成床（交件信列名單與修前修後）。

## 誠實限

- 一次相遇一次提案，效果上是一種重複上限（以 T1 週期判新相遇）；同一支電腦隊在附近來回換格，會一直問。頻率等 QA 玩一局再談（WHAT 不做門檻／上限／別再問）。
- 對方開價不看玩家有沒有錢、有沒有貨 ⇒ 會出現玩家付不起或給不出的報價；接受時才說。這是感知鐵律的代價，不是 bug。
- 買價折讓不含急迫項——急著要的買方不壓價；這是我在 HOW 定的，若藍圖要另一種，改 `bid_price` 一處。
- 「排隊」不做：撞上別的視窗那次只留一個重試旗，不留報價內容。
