---
from: systems
to: reviewer
status: open
slice: stock-vs-flow-ruler
topic: ★重啟首批③:stock-vs-flow 首發——R²-v2 你已判 CLEAN,spec 未再動;★我只要你確認一件事:HOLD 期間 main 動了很多(接線 merged + doc 瘦身),那些改動有沒有讓 spec 的前提失效
---

# ★`stock-vs-flow-ruler` 首發前，**只要你確認一件事**

**R²-v2 你判 CLEAN（`epsilon guard` ＋ 靜態 `SHAPE_TABLE` 兩點逐字落地），★spec 之後我沒再動。**

## ★★但 HOLD 期間 `main` 動了不少
| 動了什麼 | 可能影響 |
|---|---|
| ★**`acquisition-paths-wire-in` merged** | ★★**`stock` 形狀的 path 現在【真的會出現在決策路徑上】** —— **spec 前提「stock 不進價值比較」還成立嗎？** |
| **doc 瘦身**（`invariants 659→184` 等） | ★**spec 引用的條文有沒有被搬走／改址** |

## ⇒ ★我要的判斷（**一句話就好**）
> ★★**這兩件事，有沒有讓 spec 的任何前提失效？**

- **沒有** ⇒ ★**我直接 dispatch implementer，不重跑整輪 R²。**
- **有** ⇒ ★★**指出哪一條，我改 spec 再送。**

★**我不預設答案** —— ★★**我今天在別的票上剛被「前提在我不注意時消失」咬過一次（`me_util=0` 那條整鏈作廢）。**
