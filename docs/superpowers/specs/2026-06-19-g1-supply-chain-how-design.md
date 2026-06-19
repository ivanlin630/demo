# G1 供應鏈 — 系統 HOW 設計

> 配對藍圖 WHAT spec `2026-06-19-g1-supply-chain-design.md`。系統解 §11 移交的 HOW + seam + 子 spec 拆解。WHAT 不在此 drift。
> 走查依據（已量）：`message_system`(emit/propagate/distort)、鑄幣廠（faction_ai 建造慾在、**無 ore→coin 操作**=W8）、`coin_eq` 權重 ore_gold×5/silver×1、`_check_*_shortage` 雛形、`TradeValuation`/evaluate_offer。

## 0. 一句話

訂單（買/賣）走既有 message_system 傳播（殘缺/失真）→ 生產朝訂單/短缺、商隊（G2 商業 archetype）套利履約、撲空走既有 local_value glut；coin 由 specie 鑄幣（ore→coin 等值守恆）造出。**全復用，不新做撮合器/價格表/失真。**

## 1. 現狀錨點（接入面）

- `SimMessageSystem.emit_message(state, type, desc, team, params)` + `propagate_on_arrival`（distort/intel）→ **訂單 = 新 message type，沿用傳播**。
- 鑄幣廠：faction_ai:1882 **建造慾望評分在**（ore>10 想蓋），但**無 ore→coin 轉換 tick** → 蓋了不運作 = W8「從沒用」。→ G1a 補**鑄幣操作**。
- `coin_eq` 權重：ore_gold×5、ore_silver×1（faction_ai:1239）→ **鑄幣 recipe 必須等值此權重**（ore_gold→+5 coin、ore_silver→+1 coin），否則 coin_eq 破。**這是 specie 守恆硬閘**。
- `_check_food_shortage`/`_check_goods_shortage`/`_check_mount_demand`（faction_ai:1199-1229）= 短缺信號雛形 → 需求驅動生產復用 + 擴成訂單。
- `TradeValuation`/`local_value`/`evaluate_offer` = 訂單計價 + 撲空 glut，現成。

## 2. 子 spec 拆解（依賴序）

| 子 spec | 依賴 | 範圍 |
|---|---|---|
| **G1a 鑄幣(specie/W8)** | 無（最獨立，先做） | ore_gold/silver harvest + 鑄幣操作(ore→coin 等值) + 鑄幣廠 tick wire。守恆硬閘。 |
| **G1b 訂單系統** | 無 | order message type(買/賣) + 生命週期(發/過期/部分/完成/撤) + 走 propagate。基礎。 |
| **G1c 需求驅動生產** | G1b | 生產讀訂單/在地短缺（取代盲造），擴 `_check_*_shortage` → 發賣盤/買單。 |
| **G1d 商隊履約/套利** | G1b **+ G2b 商業 archetype**（已 merged） | 商業 archetype 隊讀訂單(殘缺 intel)→趕赴→evaluate_offer 履約；撲空→local_value glut 虧。 |

G1a/G1b 不依賴 G2 → 可即推。G1d 需 G2b 的 `ambition_archetype=="商業"`（已 land）。

## 3. G1a — 鑄幣（specie，解 W8）

### 守恆硬約束（不可破）
鑄幣 = 消耗 ore → 產 coin，**等值換形**：`coin += ore_gold_used × 5 + ore_silver_used × 1`（對齊 coin_eq 權重 faction_ai:1239），同時 `ore_gold/silver -= used`。→ coin_eq delta = 0（驗收 §12 硬閘）。face value 1.0 不變、無通膨（供給卡礦量）。

### 接入
- **harvest**：ore_gold/silver 從 tile 採（確認既有 harvest 是否已產 ore_gold/silver；若無，G1a 補 tile resource 採集 wire）。tile 金銀礦 = 領土（咬合 G2 §6）。
- **鑄幣操作**：新 facility-tick（或併既有 facility 結算）——隊有 mint facility + storage 有 ore → 按產能/cadence 轉 ore→coin（等值）。產能/採礦率 = TEST VALUE。
- **不碰** face value / 通膨模型 / 信用幣（藍圖移出）。

## 4. G1b — 訂單系統

### 資料模型（HOW 決策）
訂單 = message + 結構化 params：
```
emit_message(state, "order_buy"/"order_sell", desc, team, {
  "order_id": int, "want": {res: qty}, "pay": {res: qty},   # pay 可含 coin 或貨(barter 一籃)
  "expire_tick": int, "qty_remaining": int, "origin_team": int, "origin_pos": Vector2i
})
```
- **生命週期**：發布(emit)→傳播(propagate，distort 可失真 want/pay/pos=假情報)→履約(部分扣 qty_remaining)→完成(qty_remaining=0)/過期(expire_tick)/撤單。
- **儲存**：訂單**活躍狀態**存何處？(a) 發起隊上一份權威 `active_orders`（履約改其 qty_remaining）；message 是其傳播副本（殘缺）。(b) 全域 order registry。→ **傾向 (a)**：權威在發起隊（單一真值源），message 副本可失真 = 殘缺情報自然湧現，履約須回發起隊核對（撲空＝副本過時/失真）。G1b plan 釘。
- **barter = pay 非 coin 的 order**，同套 evaluate_offer，不另做（藍圖 §5）。

### 傳播 = 殘缺市場
複用 propagate/distort：傳遠/久 → pos/價/qty 失真或過期 → 履約撲空風險（§4）。**不新做失真**。

## 5. G1c — 需求驅動生產

- 生產設施輸出選擇：讀**在地短缺**(`_check_*_shortage` 擴) + **收到的買單** → 朝需求造（取代盲造）。
- 短缺/餘量 → 自動發**買單/賣盤**（礦村餘礦發賣盤、軍隊缺武器發買單）→ 分工鏈訊號。
- 接 G2 archetype 需求：武力→武器買單、商業→貨/商路。

## 6. G1d — 商隊履約/套利

- **商業 archetype 隊**（`team.ambition_archetype == AmbitionLadder.ARCHETYPE_TRADE`，G2b 已 land）：讀**收到的訂單 message**（殘缺 intel，禁上帝視角）→ 評估套利（買低賣高/履約報酬）→ TASK_TRADE 趕赴。
- **履約**：到場核對發起隊權威 order → evaluate_offer 估值 → 成交（扣 qty_remaining、雙方資源轉、守恆）。
- **撲空**：order 已過期/失真/被搶 → 該地 local_value 已 glut → 賤賣或白扛（既有 glut 定價，§4）= 真虧。**復用 local_value，不新做。**

## 7. §11 決策點對照
| §11 項 | HOW 裁定 |
|---|---|
| 訂單型別+生命週期 | order_buy/order_sell message + params；發起隊權威 active_orders + message 殘缺副本；發/過期/部分/完成/撤 |
| 接 message 傳播 | 沿用 emit_message + propagate_on_arrival distort（殘缺/失真=撲空因） |
| 需求驅動生產接點 | 生產讀短缺(`_check_*_shortage` 擴)+收到買單；餘/缺自動發單 |
| 鑄幣 | ore harvest + 鑄幣操作 tick(ore→coin 等值 ×5/×1)+ mint facility(建造慾已在,補操作) |
| 商隊履約/套利 | 商業 archetype(G2b) 讀殘缺訂單→趕赴→evaluate_offer→撲空 glut |
| 撲空走 local_value glut | 是,復用無新機制 |
| 訂單計價 | evaluate_offer/TradeValuation 復用 |
| 閾值 | 鑄幣率/採礦率/訂單壽命 全 TEST VALUE,平衡 pass |

## 8. invariants（隨子 spec 落 invariants.md）
- **鑄幣守恆**：mint = ore→coin **等值換形**（coin += ore_gold×5 + ore_silver×1，ore 同步扣），coin_eq delta=0。禁憑空造 coin 價值（specie 硬約束）。
- **訂單單一真值源**：active order 權威在發起隊；message 為可失真傳播副本，履約須回核對權威（殘缺情報湧現）。
- **訂單估值單一源**：履約計價只經 evaluate_offer/TradeValuation，禁另立價。

## 9. 回歸閘（承藍圖 §12）
headless 1000+ tick 無錯 + **coin_eq delta=0**（鑄幣守恆硬驗證）；行為可見 log（訂單發→傳→履約、分工鏈跨隊貨流、coin 被鑄 Δ>0、barter 在 coinless 區、撲空虧損案例）。不用 multi drift。

## 10. 建議起手
**G1a 鑄幣先**（最獨立、守恆閘最清楚、解 W8 死碼）→ 同時可推 **G1b 訂單**（基礎）。G1c/G1d 依賴後續。
