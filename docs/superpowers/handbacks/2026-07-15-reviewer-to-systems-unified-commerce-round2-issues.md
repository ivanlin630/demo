---
from: reviewer
to: systems
status: consumed
topic: "[R²round2判決·issues] 統一商業框架——3結構缺口+6補完項共9項逐一核對全補齊,唯一issue:spec內「invariant守」段落殘留舊版belief措辭跟M1剛修正的豁免清單設計自相矛盾,一行訂正即可CLEAN"
---

# R² round2 判決：統一商業框架 spec 補齊複核

verdict: **issues**
premise_contradiction: false

## 9 項逐一複核（比對 spec 內文，非採信摘要表）

1. **賣方變現半環（M2 `:26-29`）**：確認補上雙側——訪客買（既有）+ 訪客賣（向 owner buy 單，貨入 public_storage，`owner.coin→visitor.coin`）。守恆結構對稱（買賣兩路都走 ResourceBank/TileBank chokepoint，方向相反但機制相同），商隊套利「高賣」端現有 resolver。CLEAN。
2. **belief 基底（M1 `:21`）**：確認採路線 b——不假裝 belief，保留既有 `_nearest_market_outpost` 全圖掃描（WS-2b 死鎖破除器），誠實寫入 `invariants.md` 感知鐵律豁免清單。核對 `invariants.md:170`「刻意豁免...★位置/reachability=可見性物理(PathSystem讀真位),不在此限」——**專案已有同類型豁免先例**，本刀的市場公開地標豁免與此precedent 精神一致，非新發明破例。方向 CLEAN（但見下方 issue）。
3. **履約記帳（M2 `:30`）**：確認改按 `order_id` 權威側直沖 `active_orders`+board，`settle_orders` 降級服務巧遇路。CLEAN。
4. **無主 outpost coin（M2 `:33`）**：確認 fallback 入 `tile.public_storage.coin`/`abandoned_coin`（CoinAudit 池內）。CLEAN。
5. **賣超語意（M2 `:31`）**：確認以 `TileBank.withdraw` 實際取出量計價，禁信 board 鏡像。CLEAN。
6. **「+」語意鎖（M2 `:32`）**：確認 `min(board單餘量,現貨)`+無單不賣+SURVIVAL_GOODS強制有單。CLEAN。
7. **deal_merchant probe（驗收 `:59`）**：確認改按 `ARCHETYPE_TRADE` 分流，`merchant_inventory` 死路一併處理。CLEAN。
8. **巧遇/市場路交界（M2 `:34`）**：確認明文分工——outpost tile（有board）＝market resolver 專屬，pairwise 巧遇限非市場格，不雙 fire。CLEAN。
9. **死常數 kill-list（M5 `:48`）**：確認補全，涵蓋我列的全部項目（`FOOD_BUY_TARGET_DAYS`/`SHORTAGE_QTY`/`×0.5`/`20.0`/`TRADE_MIN_STOCK`/arb`×0.1`/`_can_trade` 殭屍公式/`MERCHANT_MAX_RANGE` 兩處重複收單一源）。CLEAN。

## issue：spec 內部矛盾——「invariant 守」段落殘留舊版措辭

`spec:53`（「invariant 守」總結段）仍寫：「**感知鐵律**：目標選市場走 belief（去過/傳聞），非 god-view 掃全 tile」——這句話描述的是**round1 被我打回的舊設計**（純 belief 化），與 **M1（`:21`）剛正確修正的內容直接矛盾**（M1 明文「不假裝 belief-based」+ 保留全圖掃描 + 誠實入豁免清單）。這正是缺口 2 要解決的問題本身，卻在同一份 spec 的總結段落留下一句自相矛盾的殘句——像是 round1→round2 修訂時漏改的殘留。

**為何要訂正**：這種矛盾若不清，implementer 讀到 spec 尾端「invariant 守」總結時可能誤以為又要走純 belief（跟 M1 的正確設計對著幹），或者 QA/measurer 拿這句話當驗收依據去質疑 M1 的合理設計是否過關。**要求**：`:53` 改成與 M1 一致的措辭，例如「目標選市場：市集 outpost 視為公開地標（誠實豁免感知鐵律，見 invariants.md 豁免清單，非 belief 冒充）；其餘敵情/社交目標仍走 belief last-seen」。

## 結論
9 項結構缺口+補完項全數核對真收斂。**唯一 issue＝spec 尾端「invariant 守」總結段一句殘留矛盾措辭**（跟 M1 已修正的設計打架），一行訂正即可。**issues → halt，退回訂正這一句後可 CLEAN**（非結構問題，純內部一致性收尾）。
