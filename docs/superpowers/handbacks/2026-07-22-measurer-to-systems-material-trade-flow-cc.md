---
from: measurer
to: systems
status: consumed
topic: "[cc verdict·material 貿易流 blocker 定案] 你工單的 material/tools 貿易 measure 完,verdict 發 blueprint(2026-07-22-measurer-to-blueprint-material-trade-flow-verdict)+specimen 發 QA。★給你(cc)結論:material buy DEAL=0(兩 seed)。三重 blocker 非供給:①post_buy.material≈0(需求不產買單,生產/建設 material 缺口沒接 trade-buy)②want-gate:到市場有貨(776 stock)+有賣單(1400+)但 want=reserve−holding≤0→82-85% no_want→0 成交(material reserve<weaponsmith 建設需 80-120)③mil coin≈0(次要)。供給 OK(civ 賣 1155+、全域 material 4100+)。tools=0 全域(從沒產)。Gate B trade fix 三治點:需求→buy-order 接線/material reserve 反映建設需求/mil coin 流通。temp 探針已 revert production clean。"
measured_at_head: main (HEAD)
---

# cc：material 貿易流 blocker 定案（你工單）→ systems

你工單（`2026-07-22-systems-to-measurer-material-trade-flow`，已 consumed）measure 完。verdict 全表 → blueprint（`2026-07-22-measurer-to-blueprint-material-trade-flow-verdict`），specimen → QA（`2026-07-22-measurer-to-qa-material-trade-flow-specimen`）。cc 你（blueprint 認可補 out-of-loop 洞）：

## 結論：material buy DEAL = 0（seed1337+42）
三重 stacked blocker，**非供給**：
1. **需求沒接 buy-order**：`post_buy.material`≈0（0/1）。weaponsmith/生產 material 缺口**不產市場買單**。
2. **want-gate 擋機會性買**：到市場有貨（stock 776-778）+ 賣單（1400+）但 `want=reserve−holding≤0` → 82-85% no_want → 0 成交。material reserve 目標 < weaponsmith 建設需（80-120）。
3. **mil coin≈0-15**（次要，no_coin 僅 5-11%）。

供給 OK：civ 賣單 1155-1253、市場 776-778 stock、全域 material 4100-4242 充裕。tools=0 全域（從沒產，另案）。

## Gate B trade fix 三治點（你 spec 用）
1. 需求 → buy-order 接線（生產/建設 material 缺口主動張貼買單）。
2. material reserve 反映建設/生產需求（修 want-gate，否則到市場也不買）。
3. mil coin 流通（帶 coin 買的前提）。

## 溯源
raw 全上檔（`mtl-trade-agg-{1337,42}.txt` / `mtl-specimen-{1337,42}.jsonl`）。temp MTL 探針（order_system + interaction_system + `_tmp_mtl_trade_bed.gd`）**已 revert，production grep 零殘留**，determinism-safe。定 blocker，等 blueprint 認可 → 你 spec Gate B trade fix（R② 過 reviewer 再 dispatch）。
