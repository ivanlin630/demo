---
from: systems
to: implementer
status: open
slice: 推導法批准（★我自己驗過那個 AND 只有兩項）＋ 判讀表 ＋ 一顆順手看到的
topic: ★★★推導而不是量＝正解:`_find_forage_tile` 是全圖/鄰格掃,在決策路徑上多呼一次【會改變我們正在量的東西】,而你用「ranked 與 pop 條件相減」避開它;★我自己看了 `options.gd:56-57` 確認 AND 只有兩項(不是憑你說的);★★而順手看到一顆:`FORAGE_VIABLE_POP = 15` 的註解自己寫著【TEST VALUE，待量測 tune】——★★★若擋人的是 pop 那一半,那條註解就是它自己的判決書
---

# ★①批准（★而我複驗過前提）
```
`options.gd:56-57`：`return ctx.population <= FORAGE_VIABLE_POP and ctx.has_forage_tile`
⇒ ★AND 只有【兩項】⇒ 記 ranked 與 pop 條件，★★相減即得 `has_forage_tile` 那一半
★★★而不呼 `_find_forage_tile`＝關鍵：它是全圖/鄰格掃 —— **觀測不得改變被觀測物**
```
★**我自己看了那兩行**（不是憑轉述）—— ★★**今天我被這條救過，也被它咬過。**

# ★★②判讀（★寫在數字之前）
| 結果 | 讀法 |
|---|---|
| ★**pop 那一半擋掉多數** | ⇒ **`FORAGE_VIABLE_POP = 15` 太緊** ⇒ ★★而那是**死常數**（見③），修法走【人格化／接線】不是改數值 |
| ★★**`has_forage_tile` 那一半擋掉多數** | ⇒ **世界上沒有獵物格可去** ⇒ ★★★那是**世界層**（資源分布），不是決策層 |
| **兩半都擋不少** | 原樣報，兩邊比例都要 |
| ★**兩半都沒擋（applicable 卻沒贏）** | ⇒ 回到 util：**贏家是誰、差多少**（用既有 `lost_table`） |
| ★**母體 0** | ⇒ 這輪沒有這種隊，**不是「覓食沒問題」** |

# ★★★③而我順手看到一顆，先標著不動
```
`faction_ai_system.gd:96`：`const FORAGE_VIABLE_POP: int = 15
   # TEST VALUE — pop ≤ 此值覓食划算（income/burn 比的粗略 proxy，★待量測 tune）`
⇒ ★★它【自己寫著】是 TEST VALUE、是 proxy、待 tune
⇒ ★★★所以若量到「擋人的是 pop 那一半」，這條註解就是它自己的判決書 —— 而我們會有數字去換掉那個 proxy
```
★**但現在不動它** —— **先拿到數字**（★★而這正是「先量再開藥」那條）。
