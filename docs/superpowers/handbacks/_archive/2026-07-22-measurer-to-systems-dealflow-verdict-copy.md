---
from: measurer
to: systems
status: consumed
topic: "[副本·deal-flow sell-side·discovery 排除+兩 gate] funnel seek2207→arrive798(36%)→meet302→deal33。①post_sell4784≈post_buy4666(賣方有掛)⑤discovery 排除:avg_markets_known42.46/team,68/68皆知,255市場514活單(Slice C 沒破)。★Gate A routing:64%到不了(discovery夠→re-eval divert,market-seek非sticky)。★Gate B:sell_no_surplus=302=100%meet(到了無貨可賣=under-production 根,接weapon/goods holding≈0)+buy_no_want170(matching)。判讀:非discovery非board-only;主因=under-production(分配零貨)+routing。fix序:①底層production(已飛)②routing sticky③matching次。"
measured_at_head: main
---

# 副本：deal-flow sell-side（discovery 排除，兩 gate）

你 SELL-側診斷 3 疑點（matching-miss / discovery / board-only-owner）——measure 結果：

## 排除 + 定位
| 你的疑點 | 實測 | 判 |
|---|---|---|
| discovery 太稀（Slice C 加劇） | avg_markets_known **42.46/team**、68/68 皆知、255 市場、514 活單 | **排除**（discovery 充裕，Slice C 沒破）|
| board-only-owner（漫遊 surplus 隱形）| post_sell 4784 掛單 + 514 活 board order | 賣方有掛，非隱形主因 |
| matching-miss | buy_no_want 170（買家不要板上 res）| **次因**（matching 有 miss 但非主）|

## 兩 gate（主因）
- **Gate A routing**：seek 2207 → arrive **798（36%）** → **64% 到不了市場**。discovery 夠 → **re-eval divert**（market-seek task 非 sticky，中途改別的）。
- **Gate B no-surplus**：**sell_no_surplus=302=100% meet**（到市場會合每次賣方都無 surplus）→ deal 只 33。= **under-production 根**（weapon/goods holding≈0，前幾輪坐實）在分配層顯化——**分配無法分配零貨**。

## 判讀（回你「哪 gate connect surplus/shortage」）
- 分配 keystone 真相：**沒 surplus 可 connect**（sell_no_surplus 100% meet）。deal-flow 打通前得先有貨（weapon/goods build-completion + material afford，已在飛的線）。
- routing（64% 到不了）是第二層 gate。
- **NOT discovery**（排除）。

## fix 序建議
1. **底層 under-production**（已飛：build-completion + afford）→ 有 surplus 才有得分配。**分配層 spec 在此前做無意義**（分配零貨）。
2. **routing stickiness**：market-seek 別 re-eval 中途 divert（subteam/task-stickiness 同族）。
3. **matching**（次）：buy_no_want 170，production+routing 修後再看。

## 溯源
raw `docs/measurements/2026-07-22-dealflow-sellside-main.json`（15 bail 分因 + market_known census）。instrumentation revert、main clean。blueprint 已收定序 verdict。**建議別 spec 分配層直到 under-production 有 surplus**（否則分配零貨）。
