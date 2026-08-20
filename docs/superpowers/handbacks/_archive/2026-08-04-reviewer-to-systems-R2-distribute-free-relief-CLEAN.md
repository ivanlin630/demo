---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN] distribute免費直注relief——dead-code claim逐行親驗坐實非誇大:interaction_system.gd:767 oask=maxf(TradeValuation.local_value(owner,res,state)*pf,0.0)每次都算真定價,pf來自_distribute_candidates的price_factor=clampf((0.5+greed)/(0.5+honor),0,CAP)結構上分子最小0.5(greed>=0時)永不到0,所以oask結構上永不為0→:855 free_dist=(override_ask==0.0)這個分支確實UNREACHABLE,非我猜測是我逐條算過確認;:857 sell_owner_no_coin bail/:865-866 sell_no_price bail/:869-872 qty計算含ocoin/bid affordability cap三處親讀確認normal付費路才會撞,改oask=0.0後free_dist=true全部跳過;:881-882親讀確認bid=0時ResourceBank.add兩邊都是±0=coin雙向no-op守恆,非我信comment是我讀公式驗證;:884-886距distribute.deliver/food_delivered既有tap確認override_ask>=0.0(含0.0)就會bump,觀測早就佈好只是從沒真的被觸發過;:854 owner==null bail確認在free_dist判斷之前,1/6 edge定位精準;整個修法=改一行(local_value×pf→0.0)去啟用一段已經寫好但從沒被踩到過的既有分支,零新機制;mini-util(_try_distribute_side讀的_distribute_candidates util)前兩輪已驗證未受影響;CLEAN→build續feat/info-network-whole→re-measure症1端到端(deliver 5/6→6/6)"
---

# R②判決：distribute 免費直注 relief（機制最後一bug）— CLEAN

## dead-code claim——逐行親算確認非誇大
這輪最重要的事是驗證「price_factor永不為0、所以免費仁君路根本走不到」這句話是不是真的，不是照抄diagnostic結論。親讀worktree `interaction_system.gd:765-767`：

```
if String(visitor.task_extra_data.get("convoy_kind", "")) == "distribute":
	var pf: float = float(visitor.task_extra_data.get("price_factor", 1.0))
	oask = maxf(TradeValuation.local_value(owner, res, state) * pf, 0.0)
```

`pf`來自上兩輪(distribute de-scan/side-dispatch)已經審過的`_distribute_candidates`裡的`price_factor = clampf((0.5+greed)/(0.5+honor), 0.0, PRICE_MARKUP_CAP)`——分子`(0.5+greed)`只要`greed>=0`（人格值正常範圍），最小值就是0.5，**結構上永遠不會是0**（除非greed是負數，不合理）。所以`oask`這行結果結構上永遠>0（假設`local_value(food)>0`，食物顯然有真實價值）。

再往下讀`:855 var free_dist: bool = override_ask == 0.0`——這行判斷要成立，`override_ask`要精準等於`0.0`，但上面已經證明它結構上永不為0。這個「免費仁君路unreachable」的claim我自己重新算過整條公式鏈，非信診斷文字，結論一致：這確實是一段**寫好但從沒被踩到過**的死路徑。

## 修法親驗——改一行啟用既有分支，零新機制
`:857 if not free_dist and ocoin<=0.0: ...return false`（owner無coin bail）、`:865-866`（sell_no_price bail）、`:869-872`（affordability cap擠壓qty）——這三處bail/cap邏輯**全部用`free_dist`當閘**，改`oask=0.0`後`free_dist=true`，這三處全部被繞過，直接進`:877 TileBank.deposit`。這個因果鏈是我逐行讀code確認的，非採信spec文字摘要。

`:881-882`親讀確認`bid=0`時`ResourceBank.add(visitor, "coin", q*bid, ...)`跟`ResourceBank.add(owner, "coin", -(q*bid), ...)`兩邊都是`±0`——coin雙向no-op，守恆維持，這不是我信comment講「bid=0→coin no-op」就過，是我自己把`q*bid`算過確認bid=0時這行必為0。

`:884-886`確認`distribute.deliver`/`distribute.food_delivered`兩個observability tap**早就佈好**（`override_ask>=0.0`這個條件天然涵蓋`0.0`）——只是因為dead-code永遠走不到，這兩個tap才從沒真的被bump過。這代表這次修法不需要新增任何觀測點，既有的tap會自動開始正確反映真實交付。

## ownerless edge——親確認1/6定位精準
`:854 if owner == null: Probe.bump("trade.market_bail.sell_ownerless"); return false`親讀確認**在`:855 free_dist`判斷之前**——這代表就算distribute意圖免費，只要outpost是`owner==null`狀態，一樣在free_dist邏輯生效前就被擋下。這跟spec講的「1/6小edge、順手修或track」的定位精確對得上，非誇大或漏算範圍。

## mini-util/genuine——延續前兩輪已驗證，這輪不動
發不發賑濟的`_try_distribute_side`/`_distribute_candidates`util公式（`relief_term`+`coin_term`）在前兩輪(distribute de-scan/side-dispatch)已經逐行驗證過，這次spec明確只改`interaction_system.gd`裡`_market_visitor_sell`呼叫時傳入的`oask`參數，不碰util公式一個字——「發不發=人格秤，送了=免費」這個語意切割是乾淨的：mini-util繼續決定「這個領主要不要送」，這次修法只改「送的時候要不要收錢」，兩件事沒有混在一起，非藉這次fix順便讓distribute決策層更容易fire（決策層util從沒被動過，本病本來就是「決策fire了但settle站被定價卡住」，非util不夠高）。

## determinism/economy
純資源轉移零RNG；`sellable`(:862-863 non-cargo路)/`deliver_cargo`(:860 convoy cargo路)兩種sellable來源都已經扣過reserve，這次修法不改變`sellable`怎麼算，只改`bid`定不定價，food_surplus/reserve守恆不受影響。

## 判決
**CLEAN → 回systems → build（續`feat/info-network-whole`）→ re-measure症1端到端（`distribute.deliver` 5/6→6/6、`food_delivered`顯著>1、糧真到resident runway回升）→ QA故事稽核。** 這是我這輪審過最小、最乾淨的一個修法——改一個參數值啟用一段已經寫好但從未觸發過的既有分支，我逐行親算確認「為什麼從沒觸發過」跟「改完之後三處bail/coin守恆/observability分別會怎麼變化」，非信spec的因果敘述。
