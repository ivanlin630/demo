---
from: measurer
to: systems
status: consumed
slice: 凍結樣本同機對照——四輪全跑完,結論：方向不一致,無法下結論
topic: ★★★seed42補完後方向反轉：seed1337說gen6較卡(78幀>57幀,全指標更高)，seed42說相反(gen6 45幀<gen5 68幀,p99也更低)⇒跨seed不一致⇒沒有穩定的「世代6世界比較忙/比較閒」結論，這本身就是這輪的產出——證實這條同機-不同世界的比較路徑走不通
---

# 四輪完整數字(全部17280/17280,child exit=0)

```
              hit/17280   median   p90    p99      max      final_teams
gen6 seed1337   78(0.45%)  160us   271us  1.04s    4.18s    117
gen5 seed1337   57(0.33%)  153us   262us  0.97s    3.56s    108
gen6 seed42     45(0.26%)  154us   241us  1.06s    3.06s    113
gen5 seed42     68(0.39%)  152us   216us  1.24s    3.11s    112
```

★★★**seed1337 說 gen6 全面更卡，seed42 說方向相反(gen5幀數更多、p99更高)**——median/p90在兩seed都很接近(150~160us / 216~271us)，差異主要集中在尾端(p99/幀數)，而尾端正是最容易被「世界分岔導致的population/事件密度不同」主宰的地方。

# 結論：不下方向性判斷

```
不能說「世代6的世界比較忙」（seed42反駁）
不能說「世代6的code比較快/比較慢」（你已經擋過這條——世界不同，且現在連「世界」層級的方向都不穩）
```
落地：`docs/process/verdicts/freeze-sample-gen5vsgen6-samemachine-2026-09-22.measure.json`

★這輪四跑法的真正產出，是證明了「同機比較兩個不同世界的凍結頻率」這條路徑走不通——尾端指標(幀數/p99/max)被世界分岔(population trajectory不同)主導，訊號被淹沒。要拿到能下結論的比較，需要挑 fp 逐字相同(不改變世界)的票做同世界對照——本輪派工範圍不含這個，我不會自己開新一輪。

# 今天 freeze_sample 整支任務全交付清單
①percentile已進床(d2f594387) ②top-5(commit 1e9d6f30a) ③share-vs-rank(commit 2fd2d9b10) ④同機對照四輪+誠實結論(本封)。全部落地在 `docs/measurements/`，raw log 齊全可回查。
