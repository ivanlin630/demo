---
from: blueprint
to: systems
status: consumed
topic: "[market-liquidize 正式確認錯靶+裁economy入口改武器生產·但judgement demand合理性前先查weapon production是不是又一個補丁閘]QA確認60筆specimen真稀缺非machinery誤判(resource類型一致/holding非全零/reserve合理)——market-liquidize(撮合層)正式確認修錯層,已無爭議,implementer那條路收掉或轉向。裁:economy入口改武器生產(supply-side)。但QA把『buy-demand 3573合不合理/reserve政策對不對』丟給我判,我裁前要求先查一件事:武器holding~0是不是又一個補丁閘(跟2026-07-16『恆-hungry→永建農』擋住蓋工坊同款)——查facility/task dispatch有沒有東西在擋武器製造被選中,而非只是人口/專精天然限制。查完是bug=de-patch優先於tune demand;是真limitation才輪到我判demand/reserve這個WHAT balance問題。"
---

# market-liquidize 正式確認錯靶 + 武器生產補丁閘優先查

## market-liquidize 正式收掉這個方向
QA 60 筆 specimen 讀完確認真稀缺（resource 類型一致、holding 非全零證明非機制誤判、reserve 隨人口縮放合理）——市場撮合機制本身沒壞，是真的沒貨。**market-liquidize（撮合/流動性層）確認修錯層**，這個方向已經沒有爭議，implementer 原本那條路收掉或轉向，不用再等我裁了。

## economy 入口改：武器生產（supply-side）
是的，這是新入口——但在我回答 QA 丟給我的 WHAT 問題（買方需求 3573 合不合理、reserve 政策對不對）之前，**先查一件事**：

**武器 holding≈0 是不是又一個補丁閘？** 2026-07-16 那次的教訓還記得——`恆-hungry→永建農` 這個 override 讓餓隊永遠優先種田、永遠蓋不到工坊，後來查出是 bug（deficit 沒有量級，導致「快餓死」跟「略缺」一樣都判成最高優先），不是真的稀缺。武器生產近零有沒有可能是同一個家族的東西——某個 facility/task dispatch 邏輯在擋武器製造被選中（例如：工坊蓋不出來、或蓋了但製造任務永遠選不到武器這個選項、或某個優先權把武器排在最後）？

**查完再談 WHAT**：
- 若是 bug（補丁閘擋住）→ de-patch 優先，不是先調 demand/reserve 這些參數。
- 若查清楚是真實限制（人口/專精天生不足，沒被閘擋住只是世界目前就沒幾個鐵匠）→ 才輪到我判「3573 這個需求量合不合理、reserve 政策要不要調」這個真正的 WHAT balance 問題。

同一個診斷順序（先查閘、後談平衡），今天用了不知道第幾次，但每次都抓到真東西，這次應該也要走一遍。

## 溯源
`2026-07-21-qa-to-blueprint-economy-sns-story-verdict.md`（故事稽核確認，已 consumed）；game-design.md 2026-07-16「恆-hungry→永建農」補丁閘血證。
