# Plan: 貿易環點火（漏斗 measure→fix）

Spec: `docs/superpowers/specs/2026-07-04-trade-loop-ignition-design.md`
藍圖裁定輸入（main 1fcb658，本 branch base 外）：①准插隊 ②granary 需求側原則=生存自給/繁榮須貿易（缺口咬成長不咬生存、別 nerf regen、度=漏斗後校）。

## Task 1 — 六站漏斗探針（零行為變）

### 探針插點（全 `Probe.bump` 純 counter，無 randf、無 state 寫）

| 站 | 插點 | key |
|---|---|---|
| 1 張貼 | `order_system.post_order`（既有 `g1.order_placed`）+ buy/sell 分流 | `trade.post_buy` / `trade.post_sell` |
| 2 收到 | bed 側月邊界 read-only 掃商業隊 `team_known` order message 數 | bed 印表 |
| 3 選中 | `best_arbitrage_order`：呼叫/非空/濾鏈殺數（range 殺/無貨殺/零 gain） | `trade.arb_call` / `trade.arb_pick` / `trade.arb_kill_*` |
| 4 dispatch | `_decide_unified` td.task==TRADE 成功時 + `member_trade` + ambient；打斷=`TaskArbiter.try_set` 搶走 TRADE 時記 new_task+source | `trade.dispatch.*` / `trade.preempt.*` |
| 5 到場 | sim_runner arrival（TASK_TRADE 到 move_target）；中途放棄=`trade.release_midroute`（_resolve_market 中 tile≠move_target 即 release）+ `trade.timeout`（TRADE_TIMEOUT） | `trade.arrive` / `trade.release_midroute` / `trade.timeout` |
| 6 成交 | `_resolve_market`：meet / deal（coin 動或 barter）/ nodeal；deal 主體分流 merchant vs resident | `trade.meet` / `trade.deal` / `trade.deal_merchant` / `trade.deal_resident` / `trade.meet_nodeal` |

已知結構嫌疑（量測定罪，不先修）：`_resolve_market:696` 同格任意相遇即 release TASK_TRADE → 商隊途中碰任何隊=貿易 task 蒸發，永到不了單點。

### Bed：`scripts/debug/trade_funnel_bed.gd`
- 仿 longwindow_bed：`seed()` 播 + Probe on + config `default.json`。
- env：`TF_SEED`(1337) / `TF_MONTHS`(6) / `TF_CONFIG`(default) / `TF_DIAG`(=1 開 util 排名，內含 randf 擾流勿混 baseline)。
- 月邊界：probe delta 表 + 商業 archetype 隊數 + 站2 team_known 掃描。
- 收尾：六站漏斗表（per-月轉化率）。
- 加碼：成交主體看 `[Market]` print grep；util 前三 TF_DIAG 專跑。

### 驗證
- headless 回歸綠（探針 no-op：Probe.enabled=false 一般跑零成本）。
- seeded warring reproducible 測仍過（RNG 流未擾）。

## Task 2 — 修主斷（漏斗數據出來才定）
候選預載見 spec。禁補丁 hack/新 judge；latch 必 timeout；身分=權重。

## 驗收
1. 漏斗表進 handback，主斷有數據。
2. fix 後兩 seed 6 月成交量級起跳（6→數十）+ 商隊完整弧可追。
3. 不塌房（mass-starve 無、狼弧在、緩坡舊）。
4. headless + framework_validation + coin_eq 綠。
