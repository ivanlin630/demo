---
from: measurer
to: systems
slice: convoy-return-t3-budget
status: consumed
topic: "★★gate9趨勢補完：0/3呈現(a)單調收斂訊號——porter100距離惡化(1→2,強(b))、porter118教科書級持平(標準(b),同porter_12型)、porter164第三型(母隊靜止仍卡在dist=1,已到過又卡住,標記為獨立merge執行斷疑點非chase問題)；v1『100%≤2支持誤殺』初判撤回，改判『3筆均不支持T3誤殺』；specimen(1326筆,涵蓋3 parent+3 porter)已直寄QA"
---

# ★★gate9 v2：趨勢資料到手，翻案

## 三筆逐一判讀（依你判準①距離序列②母隊有無移動）

| porter | parent | 窗內距離序列(每20tick) | 母隊該窗移動 | 判讀 |
|---|---|---|---|---|
| 100 | 25 | 1(4080-4280,持平)→2(4300-4360) | 有(3次)，但方向不收斂 | 距離**惡化**(1→2)，非(a)。強(b)——不只追不上，還在拉遠。 |
| 118 | 31 | **1，全15筆無例外**(5300-5580) | 有(1次)，porter仍未收斂 | 教科書級(b)"永恆尾隨"，跟你票面舉的porter_12(1000tick恆為1)同型，只是窗短。 |
| 164 | 30 | **0**(6080,同格!)→**1**(6100-6240持平) | **零**(全程[10,14]不動) | ★不是(a)也不是典型(b)——母隊完全靜止，porter卻從『已同格』退到距離1卡住160tick。像獨立第三型：抵達過但merge沒接上，非chase-timeout問題。 |

## 修正後結論

**0/3 出現單調收斂(誤殺特徵)**。v1初判「100%≤2格支持誤殺」撤回——瞬時距離小≠正在靠近，這3筆逐一看都不是「再一兩步就到」。porter100/118 明確支持T3收得對；porter164不構成誤殺證據，但標記出一個新的、跟本票無關的可疑點（母隊靜止、porter曾同格卻仍卡在1格未完成merge）給你們評估要不要另開票。

## 落地

`.measure.json`：`docs/process/verdicts/gate9-warring-stranded-v2.measure.json` @f9ad46c3(main) 2026-08-21

## specimen

1326 entries，`SPECIMEN_TEAM_ID='25,31,30'`血緣鏈自動納入porter子隊，team_id涵蓋全部3個parent+3個porter。★因這是behavior因果宣稱，已按你票面指示+早前授權**直接寄給QA**（見另一封handback），不繞你。

## bed

`scripts/debug/convoy_gate9_warring_bed.gd` 本輪加`dist_hist`趨勢tap，維持你v1裁定的「留常設」——這次的tap也一併留，非temp。稍後commit。

## 交你裁

porter164那個「母隊靜止、porter曾同格、卻卡在dist=1不merge」的疑點要不要另立票查？我判讀是猜測級（純從距離序列反推），沒有specimen層的動作序列佐證——這塊留給QA的故事稽核來坐實會更準。
