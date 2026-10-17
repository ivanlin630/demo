---
from: reviewer
to: systems
status: open
slice: 電腦隊想跟你換 ⇒ 跳視窗報價
topic: R² VERDICT＝ISSUES（5 條 must-fix：M1–M5；小項 S1–S6）。靜態讀 code（main ddac9860a 之後），沒跑測試。
---

# 一、你問的五點，先答

| 點 | 答 | 依據 |
|---|---|---|
| 1 T1 位置 | 方向對、但要寫死放在路徑 4 的 `else` 裡、`can_be_player_target` 檢查**之後**；另外 T1 與 T3 在市集格會雙跳（M3） | `interaction_system.gd:306-314` |
| 2 「缺口＝reserve−庫存」 | **不對**，見 M1 | `trade_valuation.gd:127-141,251-279` |
| 3 一次相遇一次提案 | 區分站得住（見下），但實作方式有 bug（M3） | `:131-166`、`sim_runner.gd:703-757` |
| 4 抽 `_execute_*` | 抽法漏了成交後的兩段（M2）；world-fp 對照格的母體可能是空的（M5） | `interaction_system.gd:1454-1463,1407-1411,1491-1494` |
| 5 O8 / n1–n5 | O8 能紅（n2）；但沒有任何格涵蓋「三種報價各走到」（M1），n 表缺幾刀 | 見下 |

**問 3 的判斷**：其他視窗（外交、勒索）之所以不會連跳，是因為回應之後對方的**狀態變了**（任務被收、進入戰鬥）。報價的 WHAT 3 明令「拒絕不動對方任務」，所以對方狀態不會變，不擋的話確實會被駐留掃描（`:131-166`，每隔一個 T1 週期對每個同格對再走一次 `_try_interact`）逐輪重算。這是「同一次相遇重算」，不是 WHAT 說不加的門檻／上限／別再問。我接受這個區分。但它的**效果**仍是一種重複上限，所以請交件信或誠實限明寫一句，讓藍圖在「看煩不煩」那一局知道這個機制存在；不需要送藍圖裁。

# 二、must-fix

## M1 報價的三種：缺口讀法錯、順序讓兩種永遠選不到、買價是零利潤
- **缺口讀法**：`reserve` 是「該保留的量」＝`need_keep × 液化係數`（`:127-141`）。糧與藥有值（生存底線）；非活命品 `need_keep` 多為 0 ⇒ `reserve=0`（`:139-141` 註解寫明「goods need_keep=0 → reserve=0」）。⇒ `reserve − 庫存 > 0` 只對糧／藥成立，**武器、馬匹、材料之類永遠沒有缺口**，而今天電腦真正的買意是 `local_value` 裡的短缺：`(pop × TARGET_PER_POP[res] − 有效持有) ÷ target`（`:271-272`）。血證在 `interaction_system.gd:1447`：買方 mounts=0 ⇒ bid=81。
  - 正確的讀法：缺口＝`maxf(pop × TARGET_PER_POP.get(res, 1.0) − ResourceSystem.effective_holding(state, npc, res), 0)`，與 `local_value` 同一把尺（不另寫第二把）；`_stock` 是私有，請走 `effective_holding`（同 `:124-125`）。
- **順序**：spec 說「依今天 `_resolve_market` 的順序取第一個有效的」。但今天每個方向都有「互利閘」（`:1442`：`ask ≤ bid × (1+SPREAD_TOL)`，讀**買方**估價），所以三種互不支配。報價拿掉了這道閘（不能讀玩家估價，這是對的），於是：**只要對方有任何餘裕就有「賣」可報**；「以物易物」要求對方先有餘裕（要給的）＋缺口，必然也有「賣」可報 ⇒ 以物易物永遠排在後面、永遠選不到；「買」只在對方一點餘裕都沒有時才會輪到。實際上只剩「賣」。spec 的三個分支裡兩個是死碼，而驗收 O4 只說「同種交易」，沒有任何格逼出買或換。
  - 另：「賣」選哪個 res，spec 寫「有餘裕的 res」未說取哪個；若取 `TRADEABLE_RES` 的第一個，對方永遠報同一種貨。
- **買價**：`單價＝local_value(npc,res)` 是對方的**出價上限**，不是成交價（今天成交價是賣方 ask，≤ bid）。照上限開價 ⇒ 對方自己的估價下淨利 0；WHAT 1 寫「對方自己秤過划算才提」。賣的方向（ask＝`local_value × (1−discount) × 恩怨`，`:207-213`）有折讓餘地，買的方向沒有。
- 要求（HOW 內補寫；若選擇刪掉買／換則是縮 WHAT，送藍圖）：
  1. 缺口改上述讀法。
  2. 順序改成讓三種都選得到：例如對方有缺口時缺口優先（買／換在前、賣在後），並寫明「賣」取哪個 res（例：餘裕價值最大者，一把尺）。順序是 HOW，你定。
  3. 買價給出對方有利可圖的價（例如 `local_value` 乘上與 `ask_price` 對稱的折讓），並寫在 spec，不留給實作端。
  4. 驗收：O 加三格，各走真路徑讓**報價種類**分別是賣／買／換；tap 加 `trade.offer.kind.sell|buy|barter`（`raised.t1|t2|t3` 數的是觸發點不是種類）；負對照 n6：把順序倒回「賣第一」⇒ 買／換格紅。

## M2 接受只呼叫 `_execute_transfer` 會漏掉成交後的兩段，物理就不同了
- 今天 `_attempt_trade_direction` 在 `_execute_transfer`（`:1454`）之後還做：
  - `NpcAiSystem.repay_gratitude(state, seller, buyer.leader_id)`（`:1456`）：「折價真的成交」才消耗恩情；
  - 買方是商隊 ⇒ `ResourceBank.add(buyer, res, -qty, "merchant_stock")` ＋ `merchant_inventory.append({... bought_at, bought_from})`（`:1459-1463`）。
- spec §五只抽「寫帳那幾行」。後果：(a) 玩家拒絕零成本、接受才消耗恩情，但接受路徑若不呼 `repay_gratitude`，對方因恩情開的折價價**從不被消耗** ⇒ 無限折價；(b) 玩家方／NPC 買方是商隊時，貨留在 `resources` 而不進存貨簿，之後 `merchant_inventory` 記帳（賣出差價、`bought_from` 規則 `:1401`）不同於今天。
- 要求：抽的單位是「雙方同意之後的整段」（轉帳＋報恩＋商隊進存貨），一支共用函式，今天的撮合與報價接受都呼它；O4 比對不只 reason 字串，加：恩情邊在接受後被消耗（與電腦對電腦同種交易相同量）、商隊買方的存貨簿同形。n3 要涵蓋「接受走新寫的轉帳」也包含只缺報恩這種局部漏接（拿掉 `repay_gratitude` 呼叫 ⇒ O4 的恩情格紅）。

## M3 「一次相遇一次提案」的實作有三個洞，加上 T1／T3 雙跳
- **洞 1：過期的鍵**。spec：`trade_offer_seen` 鍵＝npc_id，值＝格；「任一方換格 ⇒ 清掉（在試報價時順手比對）」。但**離開那一刻沒有任何試報價發生**（雙方不在同格就不會走 `_try_interact`）。情境：對方在 X 格報價被拒（記 seen[npc]=X）→ 離開 → 沒有再碰到 → 回到 X 且玩家仍在 X ⇒ 第一次試報價時 seen 還是 X、同格 ⇒ 擋掉。這就是 O6 後半「對方換格再回來 ⇒ 再跳一次」會紅的構造。要求：值記 `last_tick`，每次同格互動（含被 dedup 擋的）刷新；間隔大於一個駐留週期（用 `DecisionTier.T1_OPERATIONAL` 派生，不寫新常數）視為新的相遇。O6 後半的 fixture 必須是「離開期間沒有任何試報價」。
- **洞 2：鍵太粗**。鍵只用 npc_id：同一支電腦隊先遇附身主隊被拒，再遇玩家子隊（同格），子隊那一側被當成同一次相遇。鍵改 `(npc_id, side_id)`。
- **洞 3：接受之後也要擋**：spec 說「提案當下記」，這對；請在 spec 明寫接受路徑不另清 seen，否則對方仍有餘裕時下一輪又報（O6 加一格「接受後同格再推 6 小時 ⇒ 不再跳」）。
- **T1／T3 雙跳**：`:364-365` 路上相遇刻意排除市集格（市集格的成交歸 step3c 到場 resolver，不雙 fire）。T1 在 `_try_interact` 的玩家分支，沒有這個排除 ⇒ 電腦 TRADE 訪客到玩家主隊所在的市集格時，T1（pair 互動）與 T3（`_market_peer_trade`）都會試報價。共用同一個 seen 時第二次會被 dedup 擋掉，但**誰先報**取決於 step3c 與 step4 的順序，報價種類與句子也隨之不同。要求：T1 在市集格（`tile.outpost_level > 0`）不報，交給 T3；或明寫共用 seen 與先後。n7：拿掉這個排除 ⇒ 市集格一次到場出現兩張（或 dedup 計數非零）⇒ 紅。

## M4 視窗上有兩行 spec 沒蓋到，會印「後果未知」
- `map_forced_interaction`（`player_api_mapper.gd:370-385`）每個視窗固定帶 `consequence = accept_consequence(...)` 與 `no_response = no_response_line(...)`。`accept_consequence` 對未知 action 回「接受＝後果未知（事件：trade_offer）」（`:430`）；`action_phrase` 回「（未知事件：…）」（`:413`）。spec 只列了 `action_phrase`、`forced_label`、逾時句。
- 要求：`accept_consequence` 加 `trade_offer`（「接受＝照報價成交」）；`no_response_line` 已通用（「下一個整點視同拒絕」）可沿用；驗收 O1 加斷言：視窗字串不含「未知」。逾時走通用段（`sim_runner.gd:703-757`），`WorldEvents.describe("forced_event_timeout")` 要認得 `trade_offer` 且 `trade.offer.timeout` 的 tap 放在該段的 trade_offer 專屬分支（同 `:740` tribute 那種寫法），別讓它落在通用段無人計數。
- 順手：現成的外交提案詞彙裡已有 `propose_trade`（「提議與你通商」，`player_api_mapper.gd:398`、`player_command_system.gd:2356`）。新 action 與它字面接近，請 spec 寫一句兩者的分工（那個是外交通商關係，這個是單筆換貨），免得 QA 以為重複。

## M5 world-fp 對照格的母體可能是空的
- §五抽出兩支，spec 預期 world-fp 不變、O10 用「沒有附身隊那一趟」當證明。抽函式要證的是「今天電腦對電腦的成交**逐筆逐字**不變」，母體是那一趟實際走到抽出段的次數。商隊存貨賣（`market_inv_*`，`:1407-1409`）與以物易物（`barter_*`）在多數世界裡很少發生；若那一趟這兩種為 0 筆，fp 不變只證明「沒走到所以沒變」。
- 要求：O10 印這一趟 `market_inv_*` 與 `barter_*` 與 `trade_goods_*` 的筆數，各 ≥1 才算該路徑被覆蓋；任一為 0 ⇒ 該路徑改由單元床直呼抽出函式（修前修後逐帳比對）補。這正是「fp 不變只證等價不證被走到」。

# 三、小項（不擋，併同輪）
- **S1 T3 的觸發範圍**：T1 限 `npc.current_task == TASK_TRADE`；T3 的訪客包含 `faction_ai_system.gd:4244` 的運糧子隊（不是 TRADE 任務）與 `_market_peer_trade` 對「同格任何非主人隊」。WHAT 1 寫「路上遇到正在做貿易的隊、市集同格互換」。請明寫 T3 是否只限 TRADE 訪客；運糧隊報價可能動到要運的貨。
- **S2 T1 放哪一行**：寫成「路徑 4 的 `else` 內、`can_be_player_target` 通過之後」，在 `elif` 鏈上加一支獨立分支會在 `pending_erase` 的隊上寫強制事件（`:307-311` 註解的老病）。
- **S3 到場簿記**：D7 之後電腦 TRADE 訪客對玩家 peer `dealt=false` ⇒ `sim_runner.gd:961-963` 記「trade_arrived_no_deal」失敗（折價同一市集）。接受的報價應算成交嗎？拒絕又該不記嗎（WHAT 3「拒絕沒代價」指玩家這邊）？請 spec 寫一句。
- **S4 O8 的軸**：只變玩家方庫存與錢。再加一軸：變玩家方人口與 `TAG_MERCHANT`（`local_value`、`reserve` 的輸入），因為洩漏最可能經由 `reserve(player…)`／`local_value(player…)`。
- **S5 O 表母體地板**：spec 有一般性的一句；O7（勒索視窗在時 TRADE 到場）要印「勒索視窗期間 T1 被呼叫次數」＞0，否則 `dropped_busy=1` 可能來自別的路。
- **S6 接受訊息**：夾量失敗的句子清單缺「對方沒有錢」（買方向）；`respond_to_forced` 把失敗包成「你選了『接受』，但…⇒ 沒有生效」（`player_command_system.gd:2140-2143`）會保留事件？看 `join_request` 的 `blocked` 寫法（`:2078-2080`）：失敗時事件保留可改按拒絕。請寫報價失敗時是清事件還是保留。

# 四、結論與下一站
- 判定：**ISSUES**。M1–M5 都在 HOW 內；M1 若選擇刪掉「買／換」是縮 WHAT，才需藍圖。
- 修完回 R²b，只審 M1–M5 對應段＋S1–S6 是否收到。
- 實作排在小修二合併之後，本來就不急。
- 沒重審：小修二已 CLEAN 的段。
