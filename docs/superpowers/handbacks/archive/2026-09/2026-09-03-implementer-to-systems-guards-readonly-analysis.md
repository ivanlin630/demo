---
from: implementer
to: systems
status: consumed
slice: 不跑床的那一段：兩張守衛的【讀 code】做完，兩個 fixture 已改（待你放行才驗）
touches: scripts/debug/seam1_registry_test.gd / scripts/debug/unified_commerce_test.gd
topic: ★seam1 根因坐實:`_mk_ctx_order()` 沒設 `threat_pos`/`flee_dest`,而 survival 的 applicable 從 2026-09-02 起要【兩個】belief 座標(`options.gd::survival.applicable` 白紙黑字)⇒ 已補;★★unified_commerce 根因坐實在【買方沒有需求】:material 的 reserve 走 need_keep→_construction_facility_need,而它【沒有自家據點就 return 0】(:38-40)⇒ want 恆 0 ⇒ 那一單永遠不成交;★★★修法不是放寬閘,是給買方一個真的自家據點+facility 全 0 級,讓需求從【真的想蓋】導出——而 desire 那關也是真的(farming 的 deficit 由 food 缺口導出,買方 food=0 ⇒ deficit≈1)
---

# ★①seam1：根因坐實（★不是猜，是兩處 file:line 對讀）
```
床：scripts/debug/seam1_registry_test.gd::_mk_ctx_order()
    ⇒ 設了 threat_react/threshold，★但 threat_pos 與 flee_dest 都留在預設 (-1,-1)
機制：scripts/simulation/decision/options.gd  survival.applicable
    ⇒ `return ctx.threat_pos != (-1,-1) and ctx.flee_dest != (-1,-1)`
    ★★兩個都要 —— 2026-09-02 flee-to-safety 之後多了 `flee_dest`（藍圖裁「逃＝逃往安全」）
⇒ ★★★fixture 停在舊前提 ⇒ survival 不 applicable ⇒ 兩個 want 陣列都對不上
```
★**已補**：`c.threat_pos = (3,3)`、`c.flee_dest = (1,1)`，並在床裡寫明**為什麼是兩個而不是一個**。
★★**而我在註解裡留了一句給下一個人**：**「fixture 沒跟上機制」與「機制壞了」現形的方式一模一樣
（都是這張床變紅）⇒ 判是哪一種只能去讀 `applicable` 本體。

# ★★②unified_commerce：根因**不在撮合**，在**買方沒有需求**
```
`interaction_system.gd::_market_visitor_buy`：可購量 = min(單餘, 現貨, 買得起, ★want, carry)
   want = reserve(visitor, res) − holding
`trade_valuation.gd::reserve`（:101）：非活命品 ⇒ need_keep × 液化係數
`need_oracle.gd::need_keep`（:14）  ⇒ _self_use + _supply_chain + ★_construction_facility_need
`need_oracle.gd::_construction_facility_need`（:38-40）：
   ★★★`_find_own_outpost(...) == (-1,-1)` ⇒ 【return 0.0】
⇒ ★而那張 fixture 的 visitor【沒有任何自家據點】
⇒ ★★material 的 reserve 恆 0 ⇒ want 恆 0 ⇒ 那一單【永遠不會成交】
```
⇒ ★★★**所以第一次 triage 寫的「交易整條沒發生（訪客 material 0→0／owner coin 0→0／庫存沒扣）」
是【症狀描述正確、歸因錯誤】**：★**撮合沒壞，是買方根本不想買。**
★★**而這兩者現形的方式一模一樣** —— 都是「四個數字全都沒動」。

## ★修法（★不是放寬閘）
```
★新增 `_give_construction_demand(state, team, pos)`：給買方一個【真的自家 civilian 據點】
  （outpost_level=1、facility 全 0 級、terrain=plains），並 `OwnerOutpostIndex.invalidate()`
  ——★★直接寫 `outpost_owner` 是繞過 bank 的，不失效索引就查不到（檔頭 chokepoint③ 寫著）
★★需求由此【導出】而不是塞：farming(cost material 30)/workshop(60)/apothecary(50)/mint(100)
  都是 civilian-allowed 且 0 級 ⇒ build-cost 含 material
★★★而 desire 那一關（CONSTRUCTION_DESIRE_MIN=0.3）也是真的：
  farming 的 deficit 由 `need_keep(food) vs 持有 food` 導出 ⇒ 買方 food=0、pop 10 ⇒ deficit≈1
  ⇒ 它是【真的想蓋】，不是我把門檻調低
```

# ★★★③而我要先標一件【我還不知道的事】
```
★我只改了 TDD1（`_test_visitor_buy_from_stock`）。
★★這張床還有 8 個測試，其中幾個也買 material（conservation／probe_full_funnel／combo_taxed_buyer）
   ⇒ ★★★它們【會不會是同一個因】，我【沒有量】——因為你要我這段別跑床。
⇒ ★我不會現在就把同一個 helper 灑到每個測試上：那等於在沒有量的情況下宣稱它們同因，
  ★★而今天已經有兩次「同一個症狀、不同的因」（observability 那張床、pop_back 那顆）。
⇒ ★★★放行後我一個一個跑、一個一個確認，每一個都附它自己的 bail 分因
  （`trade.market_bail.buy_no_want` 對得上才算同因）。
```

# ④現況
```
樹：seam1 fixture ＋ unified_commerce helper＋TDD1 已改，★尚未 commit（要驗過才 commit）
★等你說「可以跑了」我就跑：seam1／unified_commerce／耗時 3 跑最小值
★★`tracer_completeness` 仍待那格量測（Team7 在那 400 tick 窗裡有幾次 result != committed）
★★★fixture B（slot 滿＋升級買得起 ⇒ upgrade 該贏）仍紅，等 blueprint 裁設施 vs 據點升級優先序
```
