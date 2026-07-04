# 經濟零頭：food 買單側（飢荒隊買糧）

> 藍圖 economy-direction（B 市集）。WS-1 只做 food **賣**單（糧倉滿→賣）；**買**側未做（飢荒隊表達糧需求 → 商隊送糧）。本塊補。

## 病
`order_system.tick_team_orders` 短缺買單（line 108-117）只對 weapon/material/ore 發；**food 不發買單**。→ 缺糧隊無法表達糧需求 → 商隊無糧訂單可運 → food 市集單向（只賣不買）。

## 修
`tick_team_orders` 加 food 買單：隊 `effective_food` days < `FOOD_BUY_DAYS` 且無 active food 買單 → 發 food buy（補到 buffer）。
```
var fdays = effective_food(state,team) / (pop × FOOD_PER_PERSON_PER_DAY)
if fdays < FOOD_BUY_DAYS(4.0) and not _has_active(team,"buy","food"):
    var need = int((FOOD_BUY_TARGET_DAYS(8.0) - fdays) × pop × FOOD_PER_PERSON_PER_DAY)
    if need > 0: post_order(state, team, "buy", "food", need); Probe.bump("g1.food_buy")
```
新 const `FOOD_BUY_DAYS=4.0`/`FOOD_BUY_TARGET_DAYS=8.0`（TEST VALUE）。用 `ResourceSystem.effective_food`（私產+糧倉，WS-2c 單源）。

## believability / 守恆
- 買單=需求表達；履約需 coin（既有 trade resolve 守恆，破產隊發單但成交不了=合理）。
- 純記帳/訂單，**不碰 resources/coin 池**（post_order 只登錄）→ coin_eq/InvariantAudit 無關。
- 與 survival 互補：缺糧隊既 forage（survival）又掛買單（商隊送糧）→ 經濟解飢途徑。

## 驗收
- 缺糧隊（effective_food days<4）→ 發 food buy 單（`g1.food_buy>0`）；單測。
- 飽糧隊不發。
- 2 年 world_sim：food buy 單出現、food 雙向市集（買賣皆有）；headless 全綠、coin_eq/InvariantAudit 0。

## 檔案
- `order_system.gd`：`tick_team_orders` 加 food 買單分支 + const。
- `headless_test.gd`：新測（缺糧→food buy / 飽糧→無）。
- 2 年 world_sim 驗收。

## 非本塊
- 飢荒隊優先買糧 vs forage 的決策權衡（引擎 term）= 不做（買單是 order 層，決策層另議）。
- mint/鑄幣 = 他域（未決）。
