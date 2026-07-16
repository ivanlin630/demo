---
from: implementer
to: systems
status: consumed
topic: "[完] 供給 seam 統一 effective_holding — HEAD 4c2f85cb;4 Fix;守恆 TDD 9綠+CoinAudit delta=0;headless 3+3;憲法 sites=29"
---
# Hand Back：供給 seam 統一 effective_holding accessor

branch `feat/supply-seam-effective-holding` @ `4c2f85cb`（已 push），base = origin/main `d73d13a7`。

## 實作（4 Fix）
- **`ResourceSystem.effective_holding(state, team, res)`** = team.resources[res] + 自家 outpost public_storage[res]（泛化 effective_food；`effective_food` 改 alias 不破既有 caller）。
- **`ResourceSystem.spend_holding(state, team, res, qty)`**（★守恆核心）= 先扣 public_storage(TileBank ledger) 餘扣 team.resources(ResourceBank)，不透支，回實際扣量。
- **兩對稱讀點（R② 訂正賣+買一併）**：`order_system` 賣單 qty + 買短缺 gate 走 effective_holding；`_tick_food_granary_sell` granary 讀同 refactor（不留兩套）。
- **settle 守恆**：`_execute_transfer` 加 state 參數，seller 出貨走 spend_holding（貨從糧倉出，不賣幽靈貨；qty 用實際可扣量 min(order,可扣)）；buyer 收進 team.resources；`:811` caller 更新傳 state。

## 守則達成
- **★資源守恆**：spend_holding 扣實際 storage 不透支/不憑空；**CoinAudit delta=0 minted=0**、**InvariantAudit population OK**。
- **只接 storage**，未改產能/價格/regen；施工隊 `is_constructing` gate 保（不賣建材）。determinism 零 randf。

## 驗（TDD + sanity；log docs/measurements/*-4c2f85cb.log）
- **TDD 9/9 PASS**：effective_holding(私+倉/離倉只私)、spend_holding(先倉餘私跨兩源守恆/不透支回實際)、_execute_transfer(seller 糧倉出貨、goods 總量 100 守恆不憑空、coin 對流)。
- **CoinAudit delta=0 minted=0**；InvariantAudit OK。
- **headless 3+3 baseline 零新增**；**憲法 sites=29**；seeded warring reproducible（兩跑 bit-identical；final teams 62 vs base 64＝供給 seam 改交易行為，預期非 baseline byte-identical）。

## 下一站需求（measurer 中性 full-HD，spec §驗收）
- **order_fulfilled 回升 + arb_kill_nostock 降**（定居隊糧倉貨真掛得成賣單）+ coin 流 + 守恆。
- **★掛單噪音修前後對比（驗收#7）**。掛單紀律（grounded-order/dedup/expiry）= 噪音量測後定 scope（非本刀，除非量測揭同刀順手）。

## 待確認
- 完成判定 = systems + reviewer/QA + measurer 中性 full-HD。context hold warm 等裁決信。
