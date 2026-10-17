---
from: reviewer
to: systems
status: open
slice: 電腦隊想跟你換 ⇒ 跳視窗報價
topic: R²b VERDICT＝ISSUES（輕）：M2–M5 與 S1–S6 已收；M1 的新設計引入 2 條 must-fix（N1、N2）＋ 3 條小項（T1–T3）。靜態讀 code（spec 9d2ea0fbc），沒跑測試。
---

# 一、M1–M5、S1–S6 收沒收
| 條 | 結果 | 依據 |
|---|---|---|
| M1 | **部分，見 N1／N2** | 缺口讀法改對了（`pop × TARGET_PER_POP − effective_holding`，同 `trade_valuation.gd:271-272`）；順序與買價是新設計，各有問題 |
| M2 | ✓ | 抽「雙方同意後整段」三支，含 `repay_gratitude` 與商隊存貨簿；O4d 比恩情與存貨簿；n3 拿掉 `repay_gratitude`。見 N2 對「賣方是玩家」的方向 |
| M3 | ✓ | 鍵 `(npc, side)`、值＝最後一次同格試報價 tick 每次刷新、間隔 > T1 週期才新相遇、接受也不清、busy 留重試旗、T1 市集格不報；O6 四段、O3b、n7。我重讀 `process_colocated_residency`（`interaction_system.gd:131-166`）：同一對每個週期至少被走一次，被 dedup 擋下也刷新值，連續同格不會漏掉；離開期間沒有試報價時間隔自然拉大，回來算新相遇 |
| M4 | ✓ | `accept_consequence` 補、O1 斷言不含「未知」、逾時專屬分支只 bump、與 `propose_trade` 分工寫了 |
| M5 | ✓ | O10 印三族帳筆數各 ≥1，否則單元床直呼逐帳比對 |
| S1–S6 | ✓ | T3 限 TRADE 隊、T1 位置寫死、到場簿記、O8 加軸、O7 印 T1 次數、失敗句與清事件 |

# 二、must-fix

## N1 「缺口價值最大的 res」會讓報價幾乎永遠是「買你一堆你沒有的東西」，「賣」幾乎選不到
- `TARGET_PER_POP` 有 21 種可交易品各自的人均目標（`trade_valuation.gd:51-`，food 10／material 5／ore_gold 2／gem 1／武器 0.4–1.0…）。「有缺口」＝庫存低於人均目標。一支普通電腦隊在其中好幾種上低於目標（寶石、金礦、馬、鐵、武器……），所以**幾乎每支隊都有 B**。
- spec 順序是「有 B ⇒ 先買（錢夠）／換（錢不夠）；沒 B 才賣」。結果：
  - 「賣」只在對方 21 種全部達標時才輪到——實際上不會。O4a 的 fixture「對方無缺口有餘裕」必須人工把 21 種都補到目標才造得出來，這本身就是它走不到的證據。
  - B 取「缺口價值＝缺口量 × `local_value`」最大者，價格高的品項（寶石、金礦、鋼）永遠勝出，量大的人均目標也放大缺口 ⇒ 對方幾乎每次報「想買你 寶石×N」。玩家方多半沒有它（感知鐵律又不准讀玩家庫存），接受時才失敗「你沒有這些貨」。玩家面上會是連續的不可履行報價，而可履行、有意義的「賣」（拿到貨）看不到。
- 這不是 M1 的原意：原意是三種都選得到。現在是把「賣第一」顛倒成「買第一」。
- 要求（HOW 內，你定怎麼做；以下是我看得到的選項，不裁）：
  1. **用電腦隊自己的意圖當依據**：TRADE 隊本來就帶著訂單（`_snapshot_order_res(a)` 讀 `active_order`，`interaction_system.gd:942`；`options.gd:489` 一帶寫「餓隊到市集買 food」）。報價優先取該隊 `active_order` 涉及的 res 與方向，缺口／餘裕只當沒有訂單時的後備。這正是 WHAT 1「對方自己秤過划算才提」最自然的來源；或
  2. 缺口門檻：只有缺口占目標的比例超過某具名常數才算「想買」，其餘走賣。
  3. 不論選哪個：驗收加一格**普查**——在一個沒有玩家的世界跑 N 場電腦 TRADE 隊相遇，對每場呼 `npc_offer`，印 `kind` 分佈（賣／買／換／空）與被選中的 res 分佈。賣與買都要有足量樣本（各 ≥ 10%，具名常數），否則表示順序仍有一邊是死碼。這個格不需要玩家。
  4. O4a／b／c 的 fixture 要走**自然構造**（用真的 NPC 隊狀態），不要靠逐項補滿 21 種來造「賣」。

## N2 買價的恩怨除法：買價會超過 `local_value`，而且恩情不會被消耗
- `bid = local_value × (1 − disc_buy) ÷ grudge_multiplier(npc, lv, state, player_leader_id)`。`grudge_multiplier = (1 + feud×w) × (1 − clamp(grat×w, 0, 0.9))`（`trade_valuation.gd:240`），所以對恩人最小 0.1。
  - 對恩人 mult＜1，除下去 bid 會**大於** `local_value × (1 − disc_buy)`；mult=0.5 時是兩倍，0.1 時是十倍。spec 寫「對方以自己的估價有利可圖（`bid ≤ local_value`）」，O4d 也斷言「買價 ≤ 對方 `local_value`」。對恩人會紅，或要把斷言放寬——兩者都不是原意。
  - 今天的引擎裡恩怨只作用在**賣方的 ask**（`ask_price` 的 `grudge_multiplier`，`:207-213`），買方 `local_value` 本身不帶恩怨。報價的買價帶恩怨是新增的機制，不是「沿用今天」。
- **恩情不消耗**：賣方折價成交後 `NpcAiSystem.repay_gratitude(state, seller, buyer_leader_id)`（`npc_ai_system.gd:289-303`）消耗賣方領袖對買方領袖的恩情邊。買價方向裡電腦是**買方**，恩情加成已經付出去，但 `_settle_goods_sale(state, seller=玩家方, buyer=電腦, …)` 呼的是 `repay_gratitude(seller=玩家方, buyer.leader_id)`，讀的是**玩家方領袖**對電腦領袖的恩情邊（方向反了）：電腦的恩情邊不被消耗 ⇒ 玩家賣給恩人電腦隊永遠多拿，這是 M2 要堵的無限折價的鏡像；而若玩家領袖碰巧有對該電腦領袖的 gratitude 邊，反而被誤消耗。
- 要求（二擇一）：
  - (a) **買價不帶恩怨**：`bid = local_value × (1 − disc_buy)`，與今天買方不帶恩怨的引擎一致。最小改動，O4d 的「買價 ≤ `local_value`」成立；`_settle_goods_sale` 的報恩只在**賣方是電腦**時呼叫（寫成字面），玩家當賣方時跳過。
  - (b) 保留買價恩怨，則要夾 `bid ≤ local_value × (1 − disc_buy)` 的上限，並在買方是電腦時消耗電腦對玩家領袖的恩情（呼 `repay_gratitude(state, 電腦隊, 玩家領袖 id)`），O4d 加一格恩情消耗。
  - 我建議 (a)；(b) 是藍圖沒要過的新經濟機制。

# 三、小項（不擋，併同輪）
- **T1 以物易物的回推式沒寫**：「`give_qty` 從 A 的餘裕起算並在 `want_qty` 夾過後回推」。請寫出回推式與取整方向（建議：回推後 `give_qty ≤ A 餘裕`，且 `give_qty × lv(A) ≥ want_qty × lv(B) × (1 − disc_buy)` 時才報），免得兩個實作端各猜一種，造成電腦虧本的換法。
- **T2 買報價的可履行性只在接受時才知道**：這是感知鐵律的代價，已寫在誠實限。但 N1 的普查請順便印「若玩家方有該 res，數量下限」之外的一個量：**報價的 res 是否在玩家方背包**（只在床裡讀、不進決策），用來讓 QA 知道玩家面上有多少報價是無法履行的；不是閘，是量測。
- **T3 `_settle_goods_sale` 的抽出範圍請列呼叫者**：`_attempt_trade_direction` 的 `:1454-1463`、以及報價接受；其餘 `_resolve_market_at_outpost` 內 `_market_visitor_buy/sell`（`:1247`、`:1328`）走的是另一組 reason（`market_buy_in` 等），不在此抽出。請 spec 寫一句「這兩支不共用，因為板上單的價格由 maker 自報」，免得實作端誤把它們也收進來而改變今天的撮合。

# 四、結論與下一站
- 判定：**ISSUES（輕）**。N1、N2 都在 HOW 內；N1 的普查是新增的床格，不是設計裁決。
- 修完回 R²c，只審 N1、N2 對應段＋T1–T3。CLEAN 後即可排實作（排程不變，小修二合併之後）。
- 沒重審：M2–M5、S1–S6 已收的段。
