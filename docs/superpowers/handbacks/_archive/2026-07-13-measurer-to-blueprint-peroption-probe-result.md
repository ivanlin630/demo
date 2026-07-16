---
from: measurer
to: blueprint
status: consumed
topic: per-option probe full_probe結果——★驗收④(不死鎖)不成立：貿易/備戰/求和/駐守等9個option applicable數千~上萬次但chosen恆0(結構性死鎖，非稀有)；驗收①全覆蓋成立(12新option applicable側全非0)；TC7 collapse坐實(貿易確認0選中)；determinism CLEAN
---

# 量測回報：per-option decision probe full_probe（3seed×3mo, default.json）

工單：`2026-07-13-implementer-to-measurer-peroption-probe.md`。`.worktrees/peroption-probe`（feat/peroption-probe @d54e465）。determinism CLEAN（`po_det1.json`/`po_det2.json` byte-identical）。headless 0新增SCRIPT ERROR。

## ①全覆蓋——applicable側成立，coeff_pressed側成立
三seed聯集共見21個option（含`survival`）。12個implementer點名的新覆蓋option（生產/建設/駐守/囤貨/徵收/歸建/備戰/迎戰/求和/吸納/乞食/佔村）**applicable全部>0**（至少一seed），且`opt_coeff_pressed`數值**恆等於`opt_applicable`**（每筆都被coeff處理，非只部分）——coeff確實接入全部option非只舊11個，此項成立。

## ★④不死鎖——不成立，9個option結構性0選中
以下option三seed（有applicable資料的seed）**applicable數千~上萬次，`opt_chosen`恆=0**：

| option | seed1337 applicable/chosen | seed42 | seed7 |
|---|---|---|---|
| **貿易** | 1587/0 | 3233/0 | 5774/0 |
| **備戰** | 9233/0 | 10625/0 | 14184/0 |
| **求和** | 9233/0 | 10625/0 | 14184/0 |
| **駐守** | 7722/0 | 3143/0 | 7499/0 |
| 乞食 | 1/0 | 34/0 | 245/0 |
| 併入 | 743/0 | 483/0 | 13/0 |
| 吸納 | 2293/0 | 2665/0 | 2783/0 |
| 訓練 | 5/0 | 596/0 | 3655/0 |
| 買糧 | 2643/0 | 4757/0 | 5118/0 |

**貿易/備戰/求和/駐守四項applicable量級達數千到上萬（非稀有邊緣case），跨3seed全部chosen=0**——這不是巧合噪音，是結構性argmax永遠選不到。implementer信§驗收④「無option結構性0次」**本輪測出不成立**。

真正有活性的option：`survival`(232-3395)、建設(4140-6057)、生產(2269-4752)、覓食(2614-5688)、徵收(seed42/7有941-1418，seed1337無applicable)、囤貨/歸建/返家補給/掠奪(個位數~數十，稀有但非0)。

## ★TC7 collapse——坐實，非猜測
implementer信§校準項提及「貿易獨大？」的疑慮——**本輪數據反過來**：貿易不是獨大，是**完全選不到**（0/1587、0/3233、0/5774）。`survival`/建設/生產/覓食四項瓜分絕大多數chosen次數，其餘option（含implementer特別標注待校的「駐守」）全部歸零。

## 判讀（誠實列現象，不代判tune方向）
- affinity表或coeff壓制強度可能對貿易/備戰/求和/駐守這幾個option系統性壓過頭（這幾個applicable量都不小，代表evaluation頻繁進入，但每次argmax都輸給survival/建設/生產/覓食四大項）。
- 這現象跨3seed一致（非單seed噪音），符合implementer信§「校準項」預告的「organic full_probe看跨seed人格是否真collapse→帶數據tune平衡點」——本輪即該數據。
- 是否要調affinity權重/coeff steepness/floor，或這本身是「設計意圖：生存優先層天然壓過其他」的預期現象，我不代判，回你裁。

## 產物
`po_det1.json`/`po_det2.json`（determinism），`po_organic_3mo.json`（3seed×3mo full_probe），`tools/orchestrator/runs/opt_dist_readable.txt`（跨seed可讀版逐option表）。

## 待你
①全覆蓋通過，④不死鎖不通過（9個option結構性0選中，其中貿易/備戰/求和/駐守量級明顯非邊緣case）——這是否要回頭tune affinity/coeff平衡點，或是設計本就預期低層需求壓過高層意圖，交你判。
