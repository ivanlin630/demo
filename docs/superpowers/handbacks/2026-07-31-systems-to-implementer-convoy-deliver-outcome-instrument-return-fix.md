---
from: systems
to: implementer
status: open
topic: "[★釘死SLICE A make-or-break鐵指標(blueprint命,別放大2筆=成了,量真值非visible-log)·兩件·①修convoy.return計數器telemetry漏算(faction_ai:769觸發比真[Merge]窄→拉齊真merge點)·②★instrument DELIVER成交結果:現faction_ai:1786-1787呼_resolve_market_at_outpost後無條件bump convoy.deliver(計抵達非成交)→改記真成交vs bail分因(convoy.deliver_settled當_market_visitor_sell回true / convoy.deliver_bail_<reason>當false:sell_no_surplus/sell_owner_no_coin/sell_storage_full等)·+bed dump真值:每deliver convoy的market granary material deposit後真值(>0?)+g1.order_fulfilled真筆數(和平床0→?)·目的:3趟unclear分清真delivery失敗(visitor_sell bail=機制沒到位要修)vs log-gap(settled沒印log=只telemetry)·純觀測+telemetry修零行為變·落地docs/measurements] 釘convoy驗收線真值:①修return計數器②instrument DELIVER成交vs bail分因+dump granary material真值+fulfilled真筆數。3趟unclear分真失敗vs log-gap。量真值別靠visible-log。"
branch: feat/logistics-slice-A-nail
---

# ★釘死 SLICE A make-or-break 鐵指標（量真值、別放大 visible-log）

blueprint 命：convoy 驗收線＝**fulfilled>0 真值非計數器**。QA 5 趟 2 趟 visible 成交、3 趟 unclear。**別放大「2 筆看到=成了」，量真值分清真 delivery 失敗 vs log-gap**。兩件：

## ① 修 convoy.return 計數器（telemetry 漏算）
`faction_ai:769` `convoy.return` bump 觸發**比真 [Merge] 窄**（QA：5 派 5 合併回家，但 return telemetry=1）→ 漏算。**拉齊真 merge 點**（convoy porter 真 merge_back 時每次 bump，對齊 [Merge] 事件）。純 telemetry 修、零行為變。

## ②★instrument DELIVER 成交結果（分清真失敗 vs log-gap）
現 `faction_ai:1786-1787`：呼 `_resolve_market_at_outpost(state, sub, tile)` 後**無條件 bump `convoy.deliver`**（計**抵達市場**非**成功成交**）。改：
- `_resolve_market_at_outpost` / `_market_visitor_sell` **回 true（settled、fulfilled++）** → bump `convoy.deliver_settled`。
- **回 false（bail）** → bump `convoy.deliver_bail_<reason>`（對映 `_market_visitor_sell` 的 bail：sell_no_surplus / sell_owner_no_coin / sell_no_price / sell_zero_qty / sell_storage_full / sell_ownerless）。
- （`_resolve_market_at_outpost` 若吞了 visitor_sell 回值需回傳出來讓 _tick_convoy 分流。）

## +bed dump 真值（別靠 visible-log）
和平床 dump：
- **每 deliver convoy DELIVER 後、買方 tile granary 的 res material 真值**（deposit 真發生→>0？）。
- **`g1.order_fulfilled` 真筆數**（material，和平床 0→? 真幾筆）。
- `convoy.deliver_settled` vs `convoy.deliver_bail_*` 分佈（5 趟：幾趟真 settle、幾趟 bail 哪因）。

## 目的
**3 趟 unclear 分清**：`deliver_bail_*>0`（visitor_sell 真 bail＝機制沒到位、要修）vs `deliver_settled` 但無 visible log（settled 真成交、只 telemetry log-gap）。★量真值定 make-or-break（fulfilled 真到底幾筆 + granary material 真 >0）。

## 驗 + 交付
- 純觀測 instrument + telemetry 修（零行為變、零數字變、determinism 保）。convoy_delivery_test 仍 4/4 + gates 全綠 + headless 0-new。
- **re-run 落地 `docs/measurements/`**（標 path）帶：granary material 真值 + fulfilled 真筆數 + deliver_settled/bail 分佈 + return 修後計數。
- handback `to:systems`。→ 我讀真值定 make-or-break（真 fulfill vs 機制 gap）→ 回 blueprint。★別下結論（只交真數）。卡住報 `to:systems`。
