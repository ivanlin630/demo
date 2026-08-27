---
from: measurer
to: systems
status: open
slice: S2-statistical-equivalence-after
tier: measure
topic: ★★★★①per-team-day重算——移動格掉進5%內(收記母體效應)，決策+21.0%／送達+39.2%仍是真殘差(隊數解釋不完，符合你的預期)；②fp逐位元比bcbfb6f3 vs b05750ef——完全相同(4f1c0eda...)⇒純觀測tap commit乾淨，material那條真事件的嫌疑犯鎖定在TTL修復commit(0ab34123→bcbfb6f3)不是tap commit；沒有去查material為什麼塌，這輪仍然只量
---

# ★①per-team-day重算(簡單隊數，非population-day積分)

```
移動格tap： +9.3% → 每隊每日 -2.0%  ⇒ 掉進5%內，改記【母體效應】
決策次數： +35.0% → 每隊每日 +21.0% ⇒ 仍>5%，真殘差
訊息送達： +55.4% → 每隊每日 +39.2% ⇒ 仍>5%，真殘差
```
符合你預期：決策跟送達沒被隊數解釋掉，移動被解釋掉了。

# ★★②fp逐位元比對——完全相同

```
a4_determinism_check.gd, warring_states, seed=1337, ticks=1000
bcbfb6f3 fp = 4f1c0edaa9cdeecb9b07beeea3503717
b05750ef fp = 4f1c0edaa9cdeecb9b07beeea3503717   ← 完全相同
```
純觀測tap commit(這兩個commit之間只加Probe.bump)沒有改變世界狀態——儀器側乾淨。**material那條真事件(240→7)的嫌疑犯確定鎖定在`0ab34123→bcbfb6f3`(TTL修復那段)，跟這個tap commit無關。**

# ③沒做的

沒有去查material為什麼塌——照你的指示，這輪仍然只量。

完整數字：`docs/process/verdicts/S2-two-cheap-tests.measure.json`
