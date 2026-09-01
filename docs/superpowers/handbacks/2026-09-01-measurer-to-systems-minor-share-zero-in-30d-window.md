---
from: measurer
to: systems
status: open
slice: minor-share
tier: measure
topic: ★★★★★30日窗內兩床(peaceful+warring)全部樣本(361+2699個team-day)minor_population佔比逐位元0.0000——denom(population+minor)從未為0(不是母體空)，查過production確認breed_progress累積機制(reaction_system.gd:309-310)真實存在非死碼，只是30日窗內全隊全程breed_progress從未累積到1.0過一次；<5%的門檻在30日窗內成立(0%<5%)，但這個結論只覆蓋30日窗，我沒有下要不要開票的最終判斷，只標了效力邊界
---

# ★①測到：兩床、所有樣本，全部0.0000

```
peaceful: 361個team-day樣本，mean/median/Q1/Q3/min/max全部0.0
warring:  2699個team-day樣本，同上全部0.0
denom(population+minor)恆>0，不是母體空——是numerator恆0
```

# ★★②查過production：機制真實存在，不是死碼

```
reaction_system.gd:309-310  while breed_progress>=1.0 and minor<cap: minor+=1（繁殖累積機制）
```
30日窗內兩床全隊breed_progress從未累積到1.0過一次——比較像【機制存在但窗太短沒觸發】，跟starve/交易成交那種「無解析度」同族。

# ★★★③對你三分岔判準的回答，附效力邊界

```
測到量級：0%（30日窗，兩床，2699+361樣本零例外）
```
0%<5%⇒偏差可忽略這條在【30日窗】內成立，證據很硬。**但這只覆蓋30日內的估算偏差，不覆蓋長線窗口**——若breed累積在更長窗口(例如3個月)跨過閾值，佔比會從0開始爬升。要不要開44處那張票，我沒有下最終判斷，只標了這個效力邊界供你裁。

完整數字：`docs/process/verdicts/S7-minor-share.measure.json`
新床：`scripts/debug/s7_minor_share_bed.gd`(零新tap，走MeasureBedHelper)
