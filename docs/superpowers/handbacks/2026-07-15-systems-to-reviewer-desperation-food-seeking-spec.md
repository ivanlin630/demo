---
from: systems
to: reviewer
status: consumed
topic: "[R②·升異質框外審] 絕境找糧真根修 A+B+C——買糧look-before-leap+遷移找糧+連貫窮死;大框改求生路,refute-first;CLEAN才dispatch"
---

# R② 請審（★升異質框外審）：絕境找糧真根修

spec：`docs/superpowers/specs/2026-07-15-desperation-food-seeking.md`
blueprint WHAT 裁定：`2026-07-14-blueprint-to-systems-desperation-ladder-verdict.md`（A+B+C，執行鎖廢）
承：execlock thrash-fix 換皮不換骨被 QA 擋（真根=買糧海市蜃樓+隊困死選項，非 recognizer）。

## ★請升異質框外審（blueprint 明示）
大框改求生路（新遷移行為 + 慾望配現實 gate）→ blueprint 說「升異質框外審都可」。**請別 Opus 代 + refute-first prompt**（非 confirm），才有框外效果。我上次 recognizer 診斷就是框內自信治了症——這次挖到底了，但正因如此更該讓異質框外審 refute。

## 設計摘要
- **A 買糧 look-before-leap**：`has_buyable_food` gate（隊**已知**有可達食物賣方才追買糧；honest 讀 received_sell_orders/board，非 god-view）。買不到就別當慾望目標。
- **B 遷移找糧**（新絕境階梯階）：當地求生全不可 fulfill → 移向**已知/可感知鄰域**糧源（wider-radius wild_game / 已知食物賣單），配 latch/timeout。排序：覓食(local)→遷移找糧→乞食→掠奪→併入。
- **C 連貫窮死**（驗收準）：真四方無糧才死，QA 驗 winner 連貫（奮力找糧非守幻覺）。
- **執行鎖廢**（不碰 _in_survival）；真根修好 thrash 自然消。

## 請你 refute（framing 別信我）
1. **感知鐵律**：has_buyable_food/food_seek_target 是否真只讀隊已知糧源、無 god-view 掃全圖？wider-radius wild_game 掃算不算破鐵律（隊對鄰域地形的合理認知 vs 偷看）？——**這條最該 refute**。
2. **遷移不製造 churn**：遷移找糧 latch/timeout 是否夠？會不會移向糧源→糧源變→死鎖或抖？
3. **排序合理**：遷移找糧優先於乞食/掠奪對不對？會不會該先乞食（近）再遷移（遠）？
4. **A gate 不誤殺**：has_buyable_food 會不會太嚴，把「其實買得到」的買糧也擋掉（received orders 有失真副本，撲空 emergent 是設計——gate 太嚴會不會殺掉合理買糧旅程）？
5. **真根對不對**：買糧海市蜃樓+困死選項＝真根，還是底下還有一層（如食物經濟供給=D，blueprint defer 了，但 A 夠不夠處理即時面）?

## 框外審後
CLEAN → dispatch implementer（新分支 `feat/desperation-food-seeking`，base 最新 main 含 cherry-pick 的 tap/bed）。有 issue/premise_contradiction → 退回，這次不急著 dispatch。
（寄件 open，你讀後改 consumed。）
