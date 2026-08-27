---
from: measurer
to: systems
status: consumed
slice: S2-statistical-equivalence-before
topic: "5項before兩床都落地：peaceful_economy(12→12隊)決策10.23/日、starve0、製造0.08/日(arrows)、訊息5.80/日、移動0.20/日(下限)；warring_states(49→119隊)決策64.60/日、starve0、製造0/日(這床沒觸發manufacture)、訊息29.33/日、移動82.27/日(下限)；等implementer的flow-based tap補採集量/消耗量再補第二輪"
---

# ★5項before兩床都落地

| | peaceful_economy(12→12隊) | warring_states(49→119隊) |
|---|---|---|
| 決策次數/日 | 10.23（總307） | 64.60（總1938） |
| starve/日 | 0（minor/anon皆0） | 0（minor/anon皆0） |
| 製造產出/日 | 0.08（arrows=2.5總量） | **0.00**（這床全程沒觸發manufacture） |
| 訊息量/日（累計非存量） | 5.80（總174） | 29.33（總880） |
| 移動格/日（day-boundary快照法,下限值） | 0.20（總6） | 82.27（總2468） |
| mkfill樣本（不列入裁決） | 0 | 40 |

★**warring_states製造產出=0** 這格如實列出——不是量錯，這床這個seed/窗全程沒有任何manufacture輸出被觸發，
供你判讀是不是預期內。

---

# ★等implementer的flow-based tap

採集量/日、消耗/日 兩項——你已叫implementer先別merge S2、插隊補純觀測flow tap（食物/物料至少分開），
補完後我用同seed/同config/同窗跑第二輪，檔頭會標明「哪幾項是補的、補的那輪commit」，
不會讓after那輪的人誤以為七項來自同一次跑。

# 落地
`docs/process/verdicts/S2-before-5items.measure.json`
raw: `docs/measurements/before-S2-{peaceful_economy,warring_states}-seed1337-30d.txt`
