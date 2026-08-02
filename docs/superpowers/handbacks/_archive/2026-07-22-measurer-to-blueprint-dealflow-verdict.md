---
from: measurer
to: blueprint
status: consumed
topic: "[deal-flow sell-side·★discovery 排除+兩 gate] ①post_buy4666≈post_sell4784(賣方有掛,非buy-heavy)⑤discovery 排除:avg_markets_known=42.46/team,68/68隊皆知,255市場514活單→Slice C 沒破 discovery。★兩 gate:(A)routing:seek2207→arrive798(36%),64%到不了市場(discovery 夠→re-eval divert/market-seek 非sticky)(B)meet無貨:sell_no_surplus=302=100% meet(每次會合賣方都沒surplus可賣)+buy_no_want170(matching mismatch)。→分配 keystone 卡在①到不了②到了沒貨可交易(no-surplus=under-production 根,接weapon/goods)。fix:routing stickiness+底層 under-production(分配無法分配零貨)。"
measured_at_head: main
---

# deal-flow SELL-側 measure → blueprint（★discovery 排除，兩 gate）

funnel（seed1337）：seek **2207** → market_arrive **798(36%)** → meet **302** → deal **33(4%)**。

## ⑤ discovery 排除（systems 主要疑點 refuted）
- **avg_markets_known=42.46/team**、**68/68 隊皆知市場**、255 markets、514 活 board order。
- → **discovery 充裕，NOT 稀疏**。god-view Slice C belief-gate **沒破** market discovery。systems「discovery 太稀」**排除**。

## ① 賣方有掛單（非 buy-heavy）
- post_buy 4666 ≈ **post_sell 4784** → surplus-holder **確實掛 sell 單**。市場非全 buy-heavy。

## ★兩個 gate（分配 keystone 卡這兩處）
**Gate A｜routing：seek→arrive 64% 流失**
- seek 2207 → arrive 798（36%）→ **64% 到不了市場**。discovery 夠（知 42 市場）→ **非 discovery**，是 **routing/re-eval divert**（隊 seek market 但中途 re-eval 改別的 task，market-seek 非 sticky）。

**Gate B｜meet 無貨：sell_no_surplus=302=100% meet**
- 到市場會合的 302 次，**每次都有 sell_no_surplus bail**（visitor 想賣卻無 surplus）→ deal 只 33（11% meet→deal）。
- 次因 buy_no_want 170（買家不要板上的 res = **matching mismatch**，市場有 X 買家要 Y）。
- **sell_no_surplus 100% meet = 到了也沒貨可賣** → 這是 **under-production 根**（weapon/goods holding≈0，我前幾輪坐實）在分配層的顯化：**分配無法分配「零貨」**。

## ★判讀：keystone 是 under-production + routing，NOT discovery/matching-alone
- systems「matching miss / discovery / board-only-owner」→ **discovery 排除**；matching（buy_no_want 170）是次因；主因是 **(A) 64% 到不了 + (B) 到了無貨（under-production）**。
- 分配 meta-pattern 的真相：**沒有 surplus 可分配**（sell_no_surplus 100% meet）——deal-flow 打通前得先有貨（weapon/goods build-completion + afford，已在飛）。routing 是第二層（到不了）。

## fix 建議定序
1. **底層 under-production（已在飛）**：weapon/goods 產得出來（build-completion + material afford）→ 才有 surplus 可賣。分配層在此之前修無意義（分配零貨）。
2. **routing stickiness（Gate A）**：market-seek task 別 re-eval 中途 divert（64% 到不了）——與 subteam/task-stickiness 同族。
3. **matching（Gate B 次）**：buy_no_want 170——市場 res ≠ 買家 want，routing+production 修後再看。
- **NOT discovery**（42 市場/隊，別花力氣）。

## 溯源
raw `docs/measurements/2026-07-22-dealflow-sellside-main.json`（funnel + 15 bail 分因 + market_known census）。instrumentation 純 probe 已 revert、main clean、gate 綠。副本 systems。

## 下一站
你定 gate 序（我證：under-production 底層 + routing 第二 + discovery 排除）。systems 據此定 fix。
