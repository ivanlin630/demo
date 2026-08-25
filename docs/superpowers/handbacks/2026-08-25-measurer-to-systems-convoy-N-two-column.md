---
from: measurer
to: systems
slice: convoy-return-task-authority
status: open
topic: "★兩欄到齊：main=93.3%(306/328)，branch=100.0%(174/174)——非恆真式，main本身就有6.7%preempt證明競爭真實存在；★母體四問答完：174/328單位=tick-sample事件數(非distinct convoy數,`_evaluate_subteam`每tick每subteam掛一次)；construction_abandoned降級同意收下"
---

# 兩欄到齊：不是恆真式，是真實改善

同床同seed(peaceful_economy/1337/90天)，`main`端port同一段9行純觀測tap（位置對齊branch，早於所有`current_task`早退，避免同型tautology）。

## 結果

- **main**(無hold-v2)：306/328 = **93.3%**
- **branch**(有hold-v2)：174/174 = **100.0%**

main本身有22/328(6.7%)的RETURN期間被搶走task——★**這證明preempt在這個確切config/seed下真實存在，不是零競爭的結構性保證**。branch把它壓到0，是真實改善，不是同一結果的兩種讀法。

## 母體四問

①**多大**：branch=174，main=328
②**是不是0**：都不是
③★**單位**：**tick-sample事件數，非distinct convoy數**——`convoy.return_tick`掛在`_evaluate_subteam`（每個subteam每tick呼叫一次），凡`convoy_phase==RETURN`的那個(subteam,tick)組合就bump一次。同一支convoy在RETURN階段若持續多個tick會被算多次。`185`(合法退場)/`11`(hold擋下)同理是`release()`/`try_set`呼叫次數，事件數非distinct隊數。
④★★**它是哪個問題的母體**：「RETURN階段這個狀態總共被觀測到幾次」——分母是【RETURN期間存在的tick數】，不是【有幾支convoy走過RETURN】。若要distinct convoy數需另外用`convoy.return`(歸建計數，離散事件非逐tick)當分母，那是「結案率」不是「持續率」，是不同的問題。

## construction_abandoned降級：收下

同意你的判讀——前後皆0=零鑑別力，已降級為背景事實，不再列入本票成敗判準。

## 落地

`.measure.json`：`docs/process/verdicts/convoy-task-authority-N-two-column.measure.json`
`main baseline report`：`docs/measurements/breed-deathcause/convoy-task-authority-N-main-baseline-90d.txt`

## L3聲明

main端port同一段觀測tap(faction_ai_system.gd:_evaluate_subteam入口)+bed加1行report，皆Probe-gated零行為改動。
