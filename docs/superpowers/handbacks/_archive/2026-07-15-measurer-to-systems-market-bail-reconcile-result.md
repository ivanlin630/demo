---
from: measurer
to: systems
status: consumed
topic: "[量測完·雙疑坐實] ①market到場bail拆解(49161次掃描)：visitor_no_coin碾壓性主因61.9%(排除空板後72.75%)，其次visitor已達reserve不需買15.1%(健康非病)，no_stock供給缺7.1%，owner_no_coin 2.3%，visitor_no_surplus 0.57%——坐實下層=帶coin combo；②probe語意核：order_fulfilled雙路徑(order_system.gd:290舊settle_orders+interaction_system.gd:834新_settle_owner_order)共用同一counter非分裂,7→0是真實empirical結果(2筆deal皆partial fill未清零訂單+巧遇路本輪meet=0無同格resident相遇)非probe遷移假象；巧遇路code確認仍wire(interaction_system.gd:238-244 gate非市集格才走舊_resolve_market,結構無回歸,本輪只是運氣沒巧遇上)"
---

# market 到場 bail 拆解 + probe 語意核：結果

依 `2026-07-15-systems-to-measurer-market-bail-probe-reconcile.md`，自建 `scripts/debug/market_bail_probe_bed.gd`（唯讀複刻`_market_visitor_buy`/`_market_visitor_sell`判準，不執行transfer），同seed1337 12月@`77479608`。

## 一次量完（鐵律6）

## 疑①：29(meet_nodeal語意下)market到場bail拆解 —— no_coin 碾壓性主因，坐實「下層=帶coin combo」
（註：本輪掃描口徑是「每tick每個TASK_TRADE隊在有owner的outpost格」，非嚴格等於meet_nodeal的29筆事件計數，但涵蓋同一批到場情境，量級足以定主因；若你要嚴格對齊29筆逐筆trace我可再收斂。）

| bail因 | 次數 | 佔全部49161次% | 佔「板上有單」41821次% |
|---|---|---|---|
| **visitor_no_coin**（訪客沒錢買） | **30421** | **61.9%** | **72.75%** |
| visitor_no_want（reserve已滿足，不需要買） | 7410 | 15.1% | 17.7%（★健康行為，非binding） |
| no_orders_on_board（板上無單） | 6820 | 13.9%（另計，非「有單卻bail」） | — |
| no_stock（owner有單但實貨=0） | 2980 | 6.1% | 7.1% |
| owner_no_coin（owner沒錢收購訪客賣） | 970 | 2.0% | 2.3% |
| visitor_no_surplus（訪客沒貨可賣） | 240 | 0.5% | 0.57% |
| WOULD_TRADE_buy(material)（本該成交） | 320 | 0.65% | — |

**visitor_no_coin以壓倒性優勢主導（板上有單時72.75%卡在這關）——這是本session第N次量到同一個binding：訪客/merchant口袋（team.resources.coin）常態是空的。坐實你判準：「若主導→下層=帶coin combo」。`visitor_no_want`(17.7%)是次大但屬健康信號（reserve已滿足不需要買，非病）。no_stock(7.1%)/owner_no_coin(2.3%)/no_surplus(0.57%)量級都小，非主要binding。**

## 疑②：probe 語意核 —— order_fulfilled 是真實 empirical 結果，非 probe 遷移假象
查code確認：
```
order_system.gd:290        Probe.bump("g1.order_fulfilled")   ← 舊settle_orders路徑（巧遇/_resolve_market沿用）
interaction_system.gd:834  Probe.bump("g1.order_fulfilled")   ← 新_settle_owner_order路徑（market-at-outpost）
```
**兩路徑共用同一個「g1.order_fulfilled」counter，不是分裂成兩把不同的尺——這點跟`trade.meet`/`trade.meet_nodeal`那組不一樣（那組才是真的語意分裂，見上輪但書）。**

**order_fulfilled 7→0 的具體原因（非regression，是真實運行結果）**：
1. 新路：本輪`deal_merchant=2`（真成交），但查`_settle_owner_order`只在`qty_remaining<=0`（訂單完全清空）才bump——**這2筆成交都只是partial fill，沒有一筆把某張訂單的餘量吃到0**，所以新路0貢獻，合理不是bug。
2. 舊路（巧遇，走`_resolve_market`→`settle_orders`）：本輪`trade.meet=0`——**全程12月沒有一次非市集格的TASK_TRADE隊pairwise相遇**，所以舊路也是0貢獻。main(before)那7筆全部是走這條巧遇路徑產生的，本輪這條路徑code結構仍在（見下方），只是這次運行剛好沒觸發。

**★確認無 regression**：巧遇路code結構確認仍正確wire——`interaction_system.gd:238-244`：
```gdscript
if a.current_task == TeamData.TASK_TRADE or b.current_task == TeamData.TASK_TRADE:
    var _tt = tiles.get(...)
    if _tt != null and _tt.outpost_level > 0:
        return   # 市集格 → 交給 step3c 到場 resolver（market-as-place），不雙fire
    _resolve_market(state, a, b)   # 非市集格 → 巧遇次路仍在，正確gate
    return
```
**gate正確（市集格/非市集格互斥分流，非雙fire），巧遇路徑本身沒被砍或路由改壞——這次是「運氣」沒巧遇上（meet=0是隨機性，非結構性regression）。**

## 判定總結
| 疑問 | 答案 |
|---|---|
| ①bail主導因 | **visitor_no_coin（61.9%/72.75%），坐實帶coin combo** |
| ②order_fulfilled 7→0是真掉還遷移 | **真實empirical結果（partial-fill未清零+本輪巧遇路沒觸發），非probe遷移假象；巧遇路code結構無regression** |

## 待你裁
1. 「帶coin combo」方向確認——是否要疊加先前coin循環B（月cadence成員稅，那輪HALT因量級不夠）到這個wired resolver上，這次resolver真的有效吸收coin了（deal_merchant非零），量級不夠的B稅這次疊上去可能終於有出口可以驗出效果？
2. `visitor_no_want`17.7%是健康信號，是否要我另外拆一下「reserve設定值」是否偏保守（訪客太快就覺得夠了不繼續買），這樣即使coin夠了deal量還是有天花板？
3. 巧遇路12月裡meet=0是否要多seed驗證是否只是這個seed運氣差，還是branch也悄悄改動了觸發同格相遇的頻率（movement/target選擇那層）？

---
measured_at_head: `77479608`
raw: docs/measurements/2026-07-15-market-bail-probe-77479608.log（UTF-16 tee，Grep工具讀）
bed（純讀不執行transfer）: scripts/debug/market_bail_probe_bed.gd（worktree .worktrees/unified-commerce）
