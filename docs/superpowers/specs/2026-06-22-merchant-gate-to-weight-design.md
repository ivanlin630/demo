# 框架完成塊：is_merchant 貿易 gate → 軟權重

> 藍圖定案原則（`tc7-ruling`/`defer-a-gate`）：角色=權重輸入非硬 gate。`is_merchant` 硬 gate = 過渡債，框架完成塊遷成權重，守 believability「生產隊能 roam-trade 但很少」。
> 本塊 = 清第一條 gate 債（sub-project A 的 `貿易 and is_merchant`）。

## 病
`options.gd` 貿易 applicable `(has_goods or has_arb) and ctx.is_merchant` = **角色硬 gate**（生產隊被禁 roam-trade）。違藍圖原則（角色該軟壓低非禁）。

## 修（gate→軟權重）
1. `options.gd` 貿易 applicable 去 `and ctx.is_merchant` → `if (ctx.has_goods or ctx.has_arb)`（生產隊也入候選）。
2. `terms.gd` `economic_opp` eval 乘**角色因子**：`× (1.0 if ctx.is_merchant else NON_MERCHANT_TRADE_FACTOR)`。新 const `NON_MERCHANT_TRADE_FACTOR = 0.3`（TEST VALUE）。→ 生產隊 roam-trade util 低（能但很少，軟壓非禁）；商隊不變。

= 角色靠 util 量級軟壓（同 survival 量級支配手法），非 pre-filter。商隊（is_merchant）行為零變。

## believability（守藍圖守則）
- 生產隊「能 roam-trade 但很少」：有候選但 economic_opp ×0.3 → 多數時候 util 輸 生產/駐守/建設（原地）→ 偶爾貪婪 leader 才 roam-trade（湧現，藍圖 OK）。
- 富野心/貪婪生產隊終可破框去 trade = 湧現（合藍圖湧現角色轉換）。

## 風險
- **履約回退**：生產隊 roam-trade → 離 outpost → 破 co-location → 履約降。0.3 因子保稀少；2 年 world_sim 量 `order_fulfilled`/`restock_chosen`/成交 vs 切片後基準，若顯著退 → 調低因子（或回報藍圖）。**de-risk 已被藍圖接受**（框架完成塊批次遷+量測）。
- 商隊不變（is_merchant 因子 1.0）→ TC1/4/6/7 原樣。

## 驗收
- 生產隊有貨 → 貿易**入候選**（applicable 含）但 economic_opp ×0.3 < 商隊；單測。
- TC1/4/6/7 原樣全綠（商隊因子 1.0）。
- 2 年 world_sim：`order_fulfilled`/成交 不顯著退（生產隊仍多數原地）；headless 全綠、coin_eq/InvariantAudit 0。

## 檔案
- `options.gd`：貿易 applicable 去 is_merchant。
- `terms.gd`：`economic_opp` eval ×角色因子 + `NON_MERCHANT_TRADE_FACTOR` const。
- `headless_test.gd`：`_test_role_applicable`（sub-proj A）斷言「生產隊無貿易候選」**改為**「貿易入候選但 economic_opp util < 商隊」（契約更新非掩蓋）；加 `_test_merchant_gate_weight`。
- 2 年 world_sim 驗收。

## 非本塊
- 返家補給的 `is_merchant`（結構性=只旅途隊需補給，非角色禁令）暫不動。
- survival 全隊退役 / 他域 / loot-join 還經濟隊 = 各別塊。
