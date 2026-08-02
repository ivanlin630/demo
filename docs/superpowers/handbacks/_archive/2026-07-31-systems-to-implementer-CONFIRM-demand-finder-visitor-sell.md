---
from: systems
to: implementer
status: consumed
topic: "[★確認:你抓對(good catch,建前抓免建錯)·親驗坐實採demand-finder+visitor_sell·spec §1/§2/§3/§4已訂正·DELIVER改:賣方直達買方市場呼_market_visitor_sell(deposit X入buyer tile+_settle_owner_order settle buy單→order_fulfilled++ +coin)=這步就是fulfill(非deposit自家等買方雙跳,measure證買方seek_market=5不visit雙跳不fulfill)·demand finder=best_arbitrage_order(order_system:233掃received_buy_orders回買方市場pos,belief)·deliver option不gate ARCHETYPE_TRADE(任何surplus holder,Team3生產隊菜單缺=根)·開工] 你抓對。採demand-finder(best_arbitrage_order)+visitor_sell。spec已訂正。DELIVER=賣方直達買方市場visitor_sell直接settle→fulfilled++。開工。"
branch: feat/logistics-slice-A
---

# ★確認：你抓對（good catch）——採 demand-finder + visitor_sell

親驗坐實**你完全對**（建前抓、免建錯 L1，好）：
- `best_arbitrage_order`（order_system:233）掃 `received_buy_orders` → 回下 buy 單隊市集 pos+res+order_id（belief）＝**demand 市場 finder**。
- `_market_visitor_sell`（interaction:805）：賣方=visitor deposit X 入 buyer tile granary + `_settle_owner_order`（settle buy 單→`order_fulfilled++`）+ coin 換手＝**fulfill hook**。
- 我原 spec 名 `_nearest_market_outpost_with`/`_market_visitor_buy`＝**買方側函式、對 seller 角色反向**。你抓對。measure 也證買方 seek_market=5 幾乎不 visit → deposit 自家等買方雙跳不 fulfill；**只有賣方直達買方市場 visitor_sell 能達驗收線②**。

## spec 已訂正（§1/§2/§3/§4）
- **(A) deliver option**：surplus + `best_arbitrage_order` 找到 known 買方市場掛 buy X（belief-gate via received_buy_orders）→ 生 candidate 目標=**買方市場 pos**，帶 `order_id`。★**不 gate ARCHETYPE_TRADE**（任何 surplus holder，Team3 生產隊菜單缺這個=根）。
- **(B) DELIVER 步**：到買方市場 → 呼 **`_market_visitor_sell`**（賣方=visitor、buyer=owner）→ deposit + settle buy 單 → `order_fulfilled++` + coin。★**這步就是 fulfill**。
- FETCH/OUTBOUND/RETURN + ②③④ plumbing 不變（各階段專屬 `_evaluate_subteam` 分支防 :1753 攔截、撤 persist-hold、RETURN 釋放 pop）。

## 開工
照訂正版 spec 建。**★交付附賣方 per-option util dump 驗 deliver candidate 真 fire**（別假設，本 session 鐵律）+ 三驗收線（①真派真 deposit ②`order_fulfilled>0` ③貨真離賣方）+ 不凍 + cargo 守恆。卡住報 `to:systems`。★感謝建前確認（省一次建錯 L1）。
