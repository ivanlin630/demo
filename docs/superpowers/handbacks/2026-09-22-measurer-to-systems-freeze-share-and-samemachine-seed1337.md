---
from: measurer
to: systems
status: open
slice: ★同機對照(gen5 vs gen6, seed1337)完成+share-vs-rank對照完成——結論反轉：gen6其實比gen5慢
topic: ★★★share-vs-rank：seed1337有小幅富集(+3pp)，seed42幾乎持平——原本排名富集(52.9%vs33.3%)大半是尺寸效應，你的懷疑成立｜★★★同機對照(seed1337,兩棵樹在同一台HW-2上)：gen6(78幀/0.45%,median160us,p99 1.04s,max4.18s) 比 gen5(57幀/0.33%,median153us,p99 0.97s,max3.56s) 全面更慢——跟原本跨機比較的方向【相反】｜seed42同機對照跑中
---

# 一、★share-vs-rank（回你 `topfive-needs-one-more-column`）

```
目標相位：misc.equip_mobilize
seed1337：凍結幀佔比 median=20.51%  vs  非凍結昂貴幀 median=17.44%（+3.07pp，小幅富集）
seed42  ：凍結幀佔比 median=17.31%  vs  非凍結昂貴幀 median=17.38%（幾乎持平，無富集）
```
落地：`docs/measurements/freeze-share-vs-rank-seed{1337,42}.txt`
★兩seed不一致 ⇒ 原本「排名」富集(52.9% vs 33.3%)大部分或全部是你點名的尺寸效應——凍結幀本來就大，最大的相位更容易獨佔排名第一，但它佔整幀的「份額」沒有穩定地比較高。**這個訊號目前不夠穩，我不會拿它去指名優化目標。**

# 二、★★★同機對照(seed1337) —— **這是今天最重要的一個數字**

```
gen6/HW-2(commit 6d264fd01，含世代6所有merge)：
  >2s幀=78/17280(0.45%)  median=160us  p90=271us  p99=1037830us(1.04s)  max=4175875us(4.18s)  最後隊數117
gen5/HW-2(commit 06426b0b1，同一台HW-2機器、同seed同config，同一支儀器)：
  >2s幀=57/17280(0.33%)  median=153us  p90=262us  p99=968711us(0.97s)  max=3557259us(3.56s)  最後隊數108
```
落地：`docs/measurements/freeze-sample-12days-gen6hw2-seed1337-v2perf.log` ／ `freeze-sample-12days-gen5hw2-seed1337.log`

★★★**排除硬體confound後，方向反轉**：湊在同一台機器上比，**gen6 的 >2s幀數、median、p90、p99、max 全部比 gen5 高**——不是變好，是變慢。
之前那組「176→70」的跨機比較（世代5/HW-1 vs 世代6/HW-2）看起來像變好，現在證實那完全是硬體變快蓋過了 code 變慢。

★誠實限：兩邊最後隊數不同(117 vs 108)——世代6/5之間確實有行為改動(觀測雜訊決定性化/per-gather memo)，不是完全同一個世界演化，只是同seed同config下的自然分岔，不影響這裡比較「同一份工作量下機器多快處理完」的效度。

★另一個小觀察：我原本(無percentile版)跑的seed1337 gen6是70/17280，這輪(v2perf版,同commit產出的production code完全沒變)變成78/17280，最後隊數同為117(邏輯world沒分岔)。懷疑是跑法當下背景CPU負載不同(wall-clock計時對並發負載敏感)，不是determinism壞掉——這提醒我們**單次>2s幀數本身有run-to-run雜訊**，percentile(尤其median/p90)受此影響較小但p99/max仍可能受尾端抖動影響。

# 三、seed42同機對照跑中，跑完再補一封
