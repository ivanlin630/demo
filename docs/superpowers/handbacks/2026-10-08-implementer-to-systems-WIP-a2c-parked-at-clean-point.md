---
from: implementer
to: systems
status: open
slice: A2c（spec 2026-10-08-a2c-trade-target-lands-on-non-market-tile）——照改序停在乾淨點，退深層批
topic: ★WIP 已推、不 merge｜branch `feat/a2c-trade-target-off-market` tip `e7b702bf5`（基在 main df40dfe5f）｜床修前紅→修後綠、負對照紅在自己的格｜★沒跑全電池、world-fp 未換基準（量到 fcc71f83，舊基底上的值，回來要重量）
---

## 停在哪

- `355ddf08f` 床（修前紅）＋進註冊表 `a2c-trade-target-off-market`
- `327e08e13` 修法：①套利兩個迴圈各加 `_pos_is_known_market`（讀 team_market_known）＋Probe `trade.arb_kill_not_market`；②`_step3c` 對「TRADE、具體目標格、站在上面、腳下非 outpost」放手＋Probe `trade.arrived_off_market`；(-1,-1) 不碰
- `e7b702bf5` 床 P2 佈置改有鑑別力（第一版用 food、商人估值 0 ⇒ 修前修後都回空 ＝ 假紅；改挑估值最高的貨）

## 已驗

| 格 | 修前 | 修後 | 負對照（拔①＋拔②，同一棵 detached） |
|---|---|---|---|
| P2 兩張都有 ⇒ 選市集那張 | （第一版假紅，見上） | 綠 | 紅（選到空地 (3,13)） |
| P2 只有漫遊單 ⇒ 回空 | 綠 | 綠 | 紅（選到空地） |
| P4 站在非市集目標 ⇒ 放手 | 紅 | 綠 | 紅 |
| P4b (-1,-1) 不放手（佈置＋真世界） | 綠 | 綠 | 綠 |
| P1 真世界 seed 7：「貿易」站上具體目標而人不在市集格 | 23 | **0** | 23 |

- P1 的 probe：`trade.arb_kill_not_market` 30 天 ≈ 389 萬次（每次呼叫×每張單計一次；best_arbitrage_order 呼叫頻率很高——回來時值得看一眼成本）；`trade.arrived_off_market` ＝ 0（①已經讓目標不再落在空地，②是防禦）。
- A2 修的判決格在這棵樹上仍綠（61／62）。

## 回來時要做

1. 重量 world-fp、換基準（同 commit）。
2. 跑全電池。
3. 交件信。

## 現在

接友善度 F1–F10（派工信＋檔尾追加一到四），之後 #9 地圖記憶。
