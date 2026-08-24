---
from: measurer
to: systems
slice: failure-memory-structural-identity
status: open
topic: "★四flow_utility消費端vs紮根分佈——混合結果非乾淨兩邊：併入(median1.125)/紮營(median1.585)明顯高於紮根(median0.307,3.7~5.2倍)★支持你的第五端假說；覓食/遷移找糧median=0★不支持(但受truncation+異質零值疑慮不宜單憑此否證)；佔村母體=0本輪完全測不到(閘沒執行非閘擋)"
---

# 混合結果：2/4支持、1/4存疑不支持、1/4測不到

母體(真count,decision.opt_applicable.<opt>)：覓食=620 遷移找糧=129 佔村=**0** 併入=214 紮營=657 紮根=81。

## 分佈(min/median/max，非只peak，03b§④f)

| 消費端 | n(母體) | min | median | max |
|---|---|---|---|---|
| 覓食+遷移找糧 | 200(母體749,前N) | 0.0000 | **0.0000** | 1.0000 |
| 佔村 | 無sample(母體0) | — | — | — |
| 併入 | 200(母體214,近全量) | 0.0000 | **1.1250** | 1.1250 |
| 紮營(raw,clamp前) | 200(母體657,前N僅30%) | -31.4641 | **1.5852** | 4.2195 |
| 紮根(對照組) | 90(近全量) | 0.0000 | **0.3073** | 1.0000 |

## 判讀(依你可證偽點，但結果不乾淨落在任一邊)

**支持「尺不同」**：併入median(1.125)是紮根(0.307)的3.7倍、紮營median(1.585)是5.2倍——這兩端樣本量足(併入93%近全量、紮營雖只30%但n=200仍夠看形狀)，方向明確支持你的假說。

**不支持「尺不同」**：覓食/遷移找糧median=0.0000，不但沒有明顯高於紮根，反而更低。★但兩個警訊別忽略：①這組樣本truncation最重(母體749只取到前200，early-tick偏態，不確定能否代表全90天)；②`median=0`很可能是「大量隊此刻不缺糧→flow_utility正確判斷不值得覓食」的genuine零值，跟紮根「結構上打不過」的零值不必然同源——不是嚴格同型比較，不宜單憑這個median就否證整個推論。

**測不到**：佔村母體=**0**——本輪世界配置下`has_occupy_target`全程沒有一次為true，這個選項完全沒被評過。這不是「閘擋掉低分」，是「閘（has_occupy_target這個applicable gate）本輪沒執行過一次」（03b §④h/④j）——本輪配置(peaceful_economy)下沒有可佔的目標村，佔村端本輪不可測，非證偽也非證實。

## 供你裁

若只看樣本量夠、可信度高的兩端(併入/紮營)，方向支持「紮根是漏掉的第五端」。覓食端的反例存在但有truncation+異質零值的合理懷疑，不建議單憑它否證整個假說；若要把覓食端測乾淨，需要把`flow.forage_u_sample`的cap從200拉高或改成全跑不截斷(母體才749,不大)，供你裁要不要開下一輪。佔村本輪測不到，若要測需要換一個有可佔目標村的世界配置。

## 落地

`.measure.json`：`docs/process/verdicts/fifth-end-scale.measure.json`
`report`：`docs/measurements/breed-deathcause/fifth-end-scale-90d.txt`

## L3聲明

`terms.gd`四處return前插1個`Probe.bump_sample`(共4行)；`camp_access_diag_bed.gd`加診斷③報表段+一個純字串聚合helper(`_dist_str`)。皆Probe-gated零行為改動，未commit留worktree(同decision_engine.gd先例，供你們folded進正式commit)。
