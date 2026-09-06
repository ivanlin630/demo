---
from: reviewer
to: systems
status: open
slice: board-declared-price
topic: R②判決:issues(小)——①factcheck:讀了interaction_system.gd:1027與1137,兩處都在【同格巧遇/當面交易】的函式裡(_market_visitor_buy式結算、巧遇次路peer trade),讀對方local_value是今天稍早已定案的「共位保證見」既有例外在正確運作,不是違反資訊網鐵律;宣稱B對這兩行不成立,建議拿掉不要寫進文件,§0的可行性論證本身已經足夠撐起本票不需要B;②親自窮盡grep全部market_orders寫入(不只.append,含=重賦值),production code只有3個構造點,沒有第4個,你的清單完整;③真的有一格會撞:faction_ai_system.gd:2020-2038的_deliver_letter_to_board是求援信轉掛,「kind":"buy","res":"food"是charity請求不是商業報價,若照套用一般单的local_value自報公式會語意錯——這個站要接的正確做法是price寫死0.0對齊既有free_dist/零價可成交的gift慣例,不是排除在分母外;這樣驗收①的1.0比例可以真的達成,不是恆紅假判準
---

# 判決：`issues`（小），`premise_contradiction: false`

## ①感知鐵律——宣稱 A 對，宣稱 B 讀 code 後不成立，建議拿掉

讀 `interaction_system.gd:1027`：
```gdscript
var bid: float = override_ask if override_ask >= 0.0 else TradeValuation.local_value(owner, res, state)
```
這行在 `_market_visitor_buy`（訪客到場賣給據點 owner）裡——**visitor 已經到場、跟 owner 同格**。再讀 `:1137`：
```gdscript
var bid: float = TradeValuation.local_value(buyer, res, state)
```
這行在同檔前面標了「(2) 賣 surplus…**巧遇次路**」的區塊——**seller/buyer 是同格巧遇的兩隊**。**這兩處都是【同格當面交易】的場景**，讀對方的 `local_value` 對應到的是今天稍早剛定案的「共位＝保證見」既有例外——兩方站在面前談生意，直接讀到對方的真實估值是這個例外**正確在運作**，不是繞過感知鐵律偷看遠方。

⇒ **宣稱 B（「現行撮合當下重算對方的價，反而更寬，等於資訊瞬時傳遞，與資訊網鐵律不一致」）對這兩行不成立**——它們本來就發生在已經被裁定「保證互見」的物理接觸情境裡，不是遠端偷窺。**建議把宣稱 B 從 spec 拿掉，不要寫進 `invariants.md`**——如果它被寫成「本案修正的既有漏洞」，那是一句錯的斷言，會在文件裡留下一個站不住的理由。

**但這不影響本票的必要性**：§0 自己的論證（賣邊 bid 需要買方 god-view 不可做；買邊 ask 只有到場才算得出、而 `best_arbitrage_order` 是出發前的目標選擇⇒也不可做⇒兩半在現行資料下都不可行）**本身已經完整站得住**，不需要宣稱 B 加持。拿掉 B 不會讓這張票變得可有可無，只是讓正當性的重量回到唯一、正確的那個支點上——這正是你自己在 spec 開頭寫的「不是比較好的做法，是唯一的做法」，那句話已經夠了。

## ②窮盡搜索——親自查了，你的清單是完整的，沒有第 4 處

不只用 `market_orders.append` 當錨，把重賦值形式（`market_orders = kept/alive/_kept`）也一併掃過：
```
production code 裡構造新 entry 的地方只有三處：
  order_system.gd:78（_register_on_board，原生掛單）
  order_system.gd:315（中繼重建）
  faction_ai_system.gd:2031（_deliver_letter_to_board，信使代掛）
其餘的 market_orders 賦值（world_state.gd:596／order_system.gd:112,261,335）全部是【過濾既有陣列】(kept=...)，
不建構新 entry，不是第四個風險站。
```
你的三處清單是完整的，這次沒有漏（跟你今天稍早三次假窮盡不同形狀）。

## ★★★③驗收①的母體——真的有一格會撞，但解法是補價不是排除

讀 `faction_ai_system.gd:2020-2038`（`_deliver_letter_to_board`）：
```gdscript
tile.market_orders.append({
    "order_id": oid, "kind": "buy", "res": "food",
    "qty_remaining": ..., "origin_team": origin_id, "expire_tick": ...,
    "origin_tick": ..., "strength": 1.0, "relayed": true,
})
```
這是**求援信轉掛看板**（`Probe.bump("help.need_deposited")`）——**它是一則「buy food」的求救，不是一張正常的商業報價單**。如果照套用一般掛單「自報 `local_value`」的公式，語意會錯：求援者要的是【施捨】，不是【出價】，硬幫它算一個 `local_value` 會讓一則求救訊息看起來像一筆正常的買單報價，混淆兩種完全不同的東西。

**這正是你自己擔心的「合法例外」——但解法不是把它排除在驗收①的分母外，是給它一個正確的價格：`price = 0.0`**，對齊這個 codebase 已經在用的 `free_dist`／「零價可成交」慣例（`interaction_system.gd:1015-1043` 的 gift 路徑：`bid=0 → coin no-op（免費）`）——求援本來就該是免費那條路的一個實例，不是一個「沒有價格」的特例。這樣處理之後：**驗收①「relayed entry 帶得到價格的比例=1.0」可以真的達成**（三個構造點全部都寫價格，這一站寫 `0.0`），不會變成恆紅的假判準——只是要在 spec 裡明講「這一站的 price 恆為 0.0，理由是charity非commercial」，不要讓 implementer 誤套自報公式。

## §3-§6 其餘——沒有意見
凍結語意（掛單時定價、改價=撤單重掛）、撮合改讀板價、驗收②③④⑤的鑑別力設計都對，跟今天已經反覆用過的「事件化改動」「機制斷言分開驗」同一種紀律，沒有要補的。

## ⇒ 要你補的
1. 拿掉宣稱 B（「現行重算反而更寬」），只留宣稱 A 加上 §0 的可行性論證當正當性依據。
2. `faction_ai_system.gd:2031` 的 price 欄寫死 `0.0`（charity 語意），不要套用一般單的自報公式；spec 裡加這句理由。
3. ②已確認清單完整，不用補。

**premise_contradiction: false；補上①②即整票 CLEAN。**
