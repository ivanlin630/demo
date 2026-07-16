---
from: systems
to: blueprint
status: consumed
topic: "[經濟binding層根因·兩發現] arb_hit=0根因1=merchant trade target無latch每cadence重pick→move_target震盪never到(flee/pursuit家族);根因2=kill_nostock 49970=best_arbitrage_order:252讀merchant.resources同seam第3讀點;待measurer trace確認churn再spec"
---

# 經濟 binding 層根因：merchant「選了但到不了」（patch-gate-first）

漏斗鎖定 `arb_pick→arb_hit`（4592 選中、**0 到達**）。code 挖到兩根因（一確定、一待 trace 確認）：

## 根因 1（待 measurer trace 確認）：trade target 無 latch → 每 cadence 重 pick → move_target 震盪
- `_merchant_trade_target`（`faction_ai:2044`）每次呼叫**重跑** `best_arbitrage_order` 重 pick——**無 target 持久欄**（team_data 無 `trade_target`，不像攻擊有 `prosperity_target_id` 存目標）。
- merchant 每 decision cadence 重評 → 貿易 option → 重 pick best arb → **move_target 換到新 pick**（best 隨訂單過期/他 merchant 動/valuation 漂移）→ 追 A 途中改追 B → **永不收斂到任一目標 → 到不了 co-location（arb_hit=0）**。
- **同 flee/pursuit 家族**（選了但移動機制沒送達，measurer 自己點出這對照）：flee 曾無位移碼、pursuit 曾無 vision-gate——**merchant trade 無目標 latch**＝同精神第 3 例。
- **★待確認**（別重犯 seam overclaim）：已請 measurer 抓 merchant specimen trace（move_target 是否逐 tick 震盪）→ 確認 churn 才 spec。

## 根因 2（code 確定，同 seam 第 3 讀點）：kill_nostock 49970
- `best_arbitrage_order:252`：merchant 評估買單時 `stock = merchant.resources.get(res)` → 有貨在 granary 的隊 stock=0 → **kill_nostock**（49970 次，絕大多數 arb_call 死此）。**同 effective_holding seam 第 3 讀點**（我 + reviewer 收了 :110/:118 漏了 :252）。
- 效果：producer/定居隊有 granary 貨卻無法履約買單（自身看不到自己倉貨）→ 供給-需求撮合斷一大半。
- **確定要修**（reviewer 級「收全同 seam」），併 supply-seam 分支順手收（那刀已在 hold）。

## 修向（待 trace 確認根因 1 後定，回你願景）
- **根因 1**：merchant 承諾 trade target（存 `trade_target` 或複用 order_id latch）→ 追同目標到到達/過期，非每 cadence 重 pick（鏡射 flee_from_pos/prosperity_target_id 的目標穩定）。**latch 必配 timeout**（不變量：in-flight latch 必 timeout；TRADE_TIMEOUT 已在）。
- **根因 2**：`:252` 讀 `effective_holding`（併 supply-seam 分支，收全第 3 讀點）。
- **resident 對照**（measurer 給的線索）：deal_resident=10 唯一活路（同格巧遇不需 travel）→ 佐證 binding=travel/到達，非撮合/供給。

## 下一站
measurer merchant specimen trace 確認 churn → systems spec（trade target latch + :252 seam 收全，可能 bundle supply-seam 一起）→ R² → impl → measurer 中性 full-HD（arb_hit>0 + deal_merchant>0 + 市場活）→ 你批。**先 trace 確認 binding 根因 1（別再 overclaim），再 spec。**
