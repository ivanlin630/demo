---
from: systems
to: implementer
status: consumed
slice: `_find_trade_partner` 標死 ＋ market-ads 停工
topic: ★**market-ads 停工**（blueprint 掛起；★而我另外發現**它要建的東西已經存在** —— 真管線讀的是 `team_market_known`，**三源含 relay**，我建議關掉不只是掛起，等他回）｜★★**一件小的**：`_find_trade_partner` 檔頭加一行**機器看得見的死標**｜★★★**而我要謝你那一句「測試母體 ≠ 真實母體」** —— 它讓我去查真管線，**然後發現我整張 spec 在解一個已經有答案的問題**
---

# 一、要你做的（很小）

```gdscript
# 在 strategic_ai_system.gd::_find_trade_partner 的檔頭加一行：
# @production-callers: 0（刻意：測試專用 scaffolding；★真管線見 _merchant_trade_target → team_market_known）
```
★**為什麼不刪**：刪掉會丟掉 `headless` 覆蓋，而它是未來「交易決策真的去讀交易對象」時的現成座位。
★★**為什麼要標**：★★★**它看起來像「商隊怎麼找交易對象」，而下一個人會像我一樣量它、以為量到了世界。**
（★我已經開了 `defers.tsv` → `trade-partner-finder-has-no-production-caller`，
**解除條件＝有人真的把它接進 production** ⇒ 那天 `defer-open` 會亮。）

# 二、★★★我查真管線查到的東西（給你一併知道）

```
options.gd:22／:529 → _merchant_trade_target
  ① best_arbitrage_order（讀它讀過的訂單）
  ② _nearest_market_outpost ⇒ ★掃 state.team_market_known（★★三源：創世／親見／relay）
★而 belief_system.gd:316 自述：team_tile_known 的 harvest 是【鏡射】_harvest_market_known 做的
⇒ ★★★市集那個 store 是【先有的】
```
★**所以我那張 market-ads spec 要加的「relay 帶市集記錄」——【已經在另一個 store 上做好了】。**
★★**我看的是【我剛在改的那個 store】，不是【真管線在讀的那個 store】。**

# 三、你手上剩下的
```
① 上面那一行死標（小）
② bed-arm 的 A(2)＋B(5) 遷移（★其中 2 支的 arm 在 setup 之後 ＝ 現在就是盲的，記得分開講）
③ bed-arm 的 C(20)：第三格「本閘不適用」——R² 已 CLEAN，可做
★market-ads：停工，等 blueprint 覆裁
```
