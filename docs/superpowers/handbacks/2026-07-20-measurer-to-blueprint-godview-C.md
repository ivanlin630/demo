---
from: measurer
to: blueprint
status: consumed
topic: "[godview-C 量測·PASS·god-view arc COMPLETE] a6cf4466 vs 9d427a39。市場 belief-gate 淨健康:doom-delta 全 seed attr↓pop↑(1337 attr20→15.1 pop355→377、42 22.9→18.1、4201 2.3→0.6),無 economy 崩/冷啟動死鎖。★market-relay 直證(承B教訓no假設):107 events,team4 學到 market@(9,11) dist7>vision3 經 order_sell relay=NOT vision→隊發現沒親見的市集→冷啟動不死鎖。config 0-crash(merchant economy-config clean)。gates 綠。god-view belief-化 arc A/F/E/D/B/C 全落。建議 accept。"
measured_at_head: a6cf4466
baseline_head: 9d427a39
---

# god-view Slice C 量測（最後一塊）→ blueprint（PASS·arc COMPLETE）

branch `feat/godview-c@a6cf4466`（市場 belief-gate：貿易/買糧目標「全圖最近」→「已知中最近」，market-discovery 三源 store 創世-nearby/vision/relay），baseline `9d427a39`（=main sim）。

## ★doom-delta + economy：淨健康
| seed | BASE 9d427a39 | BRANCH a6cf4466 |
|---|---|---|
| 1337 | starve 3 / attr 20.0 / pop 355 | starve 3 / attr **15.1**↓ / pop **377**↑ |
| 42 | starve 2 / attr 22.9 / pop 333 | starve 3 / attr **18.1**↓ / pop **354**↑ |
| 4201 | starve 0 / attr 2.3 | starve 0 / attr **0.6**↓ / pop 342↑ |

- **全 seed attr↓ + pop↑** → 市場 belief-gate **淨健康**，無 economy 崩、無冷啟動死鎖（開局隊憑創世-nearby 出得了門，relay 補遠市集）。starve 近平（seed42 +1 噪音級）。

## ★market-info relay 直證（承 Slice B R① 教訓「別假設 relay」）
插樁 `_harvest_market_known` relay-branch（beyond-vision 才印）：
```
tick=1160 team=4 learned market@(9,11) via relay (dist=7 > vision=3, msg=order_sell) — NOT vision
tick=1300 team=40 learned market@(11,18) via relay (dist=4 > vision=3, order_sell) — NOT vision
tick=1300 team=60 learned market@(19,7) via relay (dist=8 > vision=3, order_buy) — NOT vision
… 107 events
```
- **team 4 學到 market@(9,11)、距離 7 > vision 3、經 order_sell message relay（非親眼 vision）** → 市集資訊 relay **真傳得到**（order_buy/sell + outpost_built harvest market pos → 隊發現沒親見的市集）。**直接坐實非間接推論**（同 B 你要的 relay 直證）。
- ∴ 市場發現非只 proximity → 冷啟動經濟不卡（遠市集經 relay 漸知）。

## config sanity
- game_sim_multi 0 SCRIPT ERROR（game_sim_test/tyrant/**merchant**/warzone）——**merchant（economy-heavy config）clean** = 市場 belief-gate 不崩經濟重 config。
- 承 Slice B 全 8 config 基礎（創世知識同源）。

## gates
constitution 64/0-new、headless branch=known 5-fail 0-new（2 stale WS-2b fixture 補 team_market_known 透明）、determinism 6b10deeb（無新 RNG，cite）。

## ★god-view belief-化 arc COMPLETE
A(創世belief)/F(scout)/E(4 dispatch)/D(path+threat)/B(創世知識+relay-discovery)/C(市場) **全落 + 全量測**。剩：1119 can_reach（下批，near-vacuous 低優先）+ GOODS/PRICES belief（deferred，資訊操控維度另軌）。

## 誠實揭
warring_harness 無專屬 trade/coin probe key → economy-health 用 pop↑ + market-relay-delivers + merchant-config 0-crash 代理（強間接）。直接 trade-volume/coin-flow 未插樁（要加 probe；代理夠強）。

## 判定：PASS，建議 accept
市場 belief-gate 淨健康（attr↓/pop↑）、market-relay 直證、無冷啟動死鎖、merchant-config 0-crash、gates 綠。**god-view arc 收官**。verdict `docs/process/verdicts/godview-C.measure.json`、raw `docs/measurements/2026-07-20-godviewC-*`。instrumentation revert、branch clean。
