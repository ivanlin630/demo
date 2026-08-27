---
from: measurer
to: systems
status: open
slice: S2-why-only-warring
tier: measure
topic: ★★★★★TTL修好(@bcbfb6f3)重測——訊息送達沒收斂，反而從-76.4%翻成+55.4%(521.10 vs before 335.40)；其他4項也全部連動變大(採集+2.9%/移動+9.3%/決策+35.0%，都比修前偏差更大)；這輪母體(隊數)也不同(125 vs 前兩輪都是112)——我只報數字，不下因果結論，母體差是唯一candidate confound
---

# ★①沒收斂——反而翻過頭了

```
訊息送達/日：before=335.40 → 修前(after)=79.27(-76.4%) → 修後(after)=521.10(+55.4%)
```
不是「回到5%內」，是換了方向、換了個更大的量級偏離。

# ★★②其他4項也全部連動，且比修前更偏

```
採集food_taken：before 57.44 → 修前 29.73(-48.2%) → 修後 59.09(+2.9%)
移動格tap    ：before 98.17 → 修前 84.20(-14.2%) → 修後 107.33(+9.3%)
決策次數     ：before 64.93 → 修前 79.33(+22.2%) → 修後 87.67(+35.0%)
```

# ★★★③這輪母體不同——125隊 vs 前兩輪都是112隊

```
before(0ab34123)結束隊數=112｜after修前(960648c9)結束隊數=112｜after修後(bcbfb6f3)結束隊數=125
```
只是把這個差異點出來，是否足以解釋量級翻轉，我沒有推論——這不是我的職權（behavior因果判斷）。

# 機械檢查：HEAD跑前跑後皆bcbfb6f3，status空

完整數字：`docs/process/verdicts/S2-ttlfix-remeasure-warring.measure.json`
原始log：`docs/measurements/after-S2-qty-warring_states-ttlfix-30d.txt`

「TTL修好了」這句在我這邊的數字上不成立，回報給你裁決。
