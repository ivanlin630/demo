# Hand Back: is_merchant 貿易 gate → 軟權重

## 實作摘要
- `scripts/simulation/decision/options.gd`：貿易 applicable 去 `is_merchant` 硬守衛，改為 `if ctx.has_goods or ctx.has_arb`（生產隊有貨即入候選，非禁）。
- `scripts/simulation/decision/terms.gd`：加 `const NON_MERCHANT_TRADE_FACTOR = 0.3`（TEST VALUE）；`economic_opp` eval 乘角色因子（商隊 ×1.0、非商隊 ×0.3）→ 軟壓非商隊 roam-trade。
- `scripts/debug/headless_test.gd`：契約更新 `_test_role_applicable`（「生產隊無貿易候選」→「貿易入候選但 util 低」）；新增 `_test_merchant_gate_weight`（驗 e_pro>0、e_pro<e_mer、e_pro==e_mer×0.3）並註冊 dispatch。

與 spec 無差異。商隊行為零變（因子 1.0）。

## economic_opp 角色因子
- `NON_MERCHANT_TRADE_FACTOR = 0.3`（plan 指定 TEST VALUE）。未調整（無需，見下）。
- 商隊 economic_opp = `(0.8/0.2 goods)×(1.0/0.3 arb)×1.0`；生產隊同式 ×0.3。

## 2 年 world_sim 履約對照（unseeded，看量級非精確值）

| probe | baseline (main) | post (gate→weight) |
|---|---|---|
| g1.order_placed | 3515 | 3945 |
| g1.market_arrive | 52 | 48 |
| g1.seek_market | 186 | 43 |
| g1.restock_chosen | 164 | 120 |
| g1.engine_survival | 2627 | 1901 |
| 訂單履約率 | 0.0% | 0.0% |

- **履約率 0% 是 pre-existing**：baseline 與 post 皆 0%，`g1.order_fulfilled` 在兩次 run 都未 bump。非本變更引入（headless unit test `market trade chain` 仍驗 fulfilled>0，機制本身正常；2 年 world_sim 的 0% 是既有 unseeded 世界性質，與本切片無關）。
- **market_arrive 量級相當**（52→48）：若生產隊大批 roam-trade，市場到場數應暴增、據點活動崩 → 未發生。seek_market/restock 的下降在 unseeded 變異範圍內（兩次皆非零）。

## 生產隊 roam-trade 頻率（是否「很少」= 符藍圖守則）
**符合。** 決定性證據：兩次 run 中 trace 樣本內唯一交易的隊都是 T4，且**每一次 `task=貿易` 都在 `p10`(PRIO_AMBIENT，最低優先)觸發**，reason=`[ambition]`。
- T4 本身是漫遊隊（早期 task=掠奪 solo、無穩定據點），非 outpost-anchored 生產隊。
- 據點型隊（T0 徵收/外交、T1 建設、T2 訓練）全程維持 p50 自身工作，無一改去 roam-trade。
- 結論：軟權重把貿易壓在 ambient/idle 層 —— 只在隊本無其他工作時才當填充選項。生產隊「能但很少」達成，co-location 未破。
- 對照：baseline T4 幾乎每 probe tick 都 trade（商隊 archetype 漫遊者）；post 此 run T4 trade 次數反而較少（變異）。本變更未讓更多隊 trade，只把禁令改成軟壓。

## 回歸結果
- headless：`=== DONE ===`、SCRIPT ERROR 0、Assertion failed 0。
- `merchant gate→weight OK` + `role applicable OK`（契約更新後）綠。
- TC1/4/6/7 全綠（商隊因子 1.0，行為原樣）；TC7 三 leader 三 option（建設/貿易/隱士駐守）分歧維持。
- coin_eq 守恆斷言通過（0 assert fail）；InvariantAudit population/faction/subteam 雙向 OK。

## 連動風險
- `faction_ai` / `TaskArbiter`：貿易現經 ambient ladder（PRIO_AMBIENT）填 idle，已驗只在低優先觸發、不搶 survival/threat/ambition-build。無已知額外連動風險。

## 待主 session 確認
- **既有 world_sim 履約率 0%**（pre-existing，非本變更）：headless unit test 證機制可履約，但 2 年 unseeded 世界跨格訂單從未沖銷。屬 G1d 跨格商隊履約閉環的潛在觀察點，建議主 session 評估是否另開 task 追（不在本切片範圍）。
- `NON_MERCHANT_TRADE_FACTOR = 0.3` 為 TEST VALUE，正式平衡 pass 待調（目前驗證「很少」已足夠，未觸發 plan Step 3 調降）。
