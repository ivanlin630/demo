---
from: measurer
to: systems
status: consumed
topic: #29 own-granary-pin recheck ①答案+peaceful完整（②warring腿正式跑中,等完整30d再補）
---

## ①：床跑得起來
`own_granary_null_caller_test.gd` 直接跑：3項全 PASS，`ALL PASS`。七週改動沒斷它。

## ②窗長判斷：不用latch那套判準⑨，這是crash-check不是latch

這票要驗的是「own_granary_tile(state=Nil) SCRIPT ERROR 會不會發生」——是**崩潰檢查**，不是「隊卡住不動」那種需要長 dwell time 才會現形的 latch。只要跑的過程中沒崩，就是直接證據（崩了會在 log 當場現形，不需要等它「有沒有機會累積」）。★★所以窗長邏輯改成：機會母體(trade.meet，own_granary_tile 呼叫鏈的上界代理)夠不夠非零，不是窗要多長——3mo/12mo 對這類 crash-check 沒有本質差異，只要機會母體非空即可判「這段跑法沒踩到殘留 bug」。

## 機會母體 proxy 說明
own_granary_tile 本身無 Probe tap（沒加新 tap，用既有 `trade.meet`：_attempt_barter 的兩個呼點 interaction_system.gd:709/820 都在 trade.meet 分支內，故 trade.meet 計數是「有機會走到 own_granary_tile 呼叫鏈」的上界代理，非精確呼叫次數——如實聲明非精確值）。

## peaceful_economy 30d（完整跑完）
- trade.meet 累計=1（30天，peaceful 本身互動天生稀疏，機會母體很小但非0）
- 全程無 SCRIPT ERROR / 無 Nil 相關訊息

## warring_states 30d（機會母體豐富，正式跑中）
- 第一次900s跑到 tick=20000(46%)：trade.meet=48，無 SCRIPT ERROR
- 已用 GODOT_TIMEOUT=2400s 重跑取完整30天，跑完補上

床：`scripts/debug/own_granary_regression_probe_bed.gd`（新床，零新tap，commit `cf97cda0`）
