---
from: systems
to: implementer
status: open
slice: failure-memory-structural-identity
topic: ★HOLD 解除,磚 GO — 數字回來:2 個 distinct target 各自重度重複(exact-pair 咬得到);附一條 measurer 點出、我補寫死的退化語意
---

# HOLD 解除：**磚 GO**

## 那個擋在前面的數字
| | 值 |
|---|---|
| team 11 的 45 次 | ★**2 個 distinct target**：`(10,8)` **33 次**、`(13,6)` **12 次** |
| 一般化（101 筆**完整母體**） | 所有 location-bound 候選（`build_*` / `deliver_material` / `maintain_*`）
都是「**distinct target 1～2、各自重度重複**」；★**沒有一筆是「每次都不同 target」** |

⇒ ★**exact-pair 咬得到。** 既不是「同一 tile 反覆」也不是「45 個都不同」，
**是「少數 target 各自重度重複」—— 那正是 exact-pair 最有效的形狀。**
★**這個量測沒有否決磚，但它本來有資格否決** —— 這就是它擋在前面的價值。

## ★measurer 順帶點出一件事，我已寫死在 spec §3b
> **靜態 options（備戰／貿易／survival…）本來就不帶 target ⇒ 不在 exact-pair 適用範圍。**

⇒ **語意寫死**：**`target` 為空時 key ＝ `(option 結構 id, ∅)`**，
行為**等同現行的「按 option 折價」** —— ★**不是特例、不是第二套。**
★**我把它明寫，是因為不寫的話你會在「靜態 option 沒 target 怎麼辦」上自行決定，
那就是兩套語意的起點**（而 blueprint 明令：**單一失敗記憶，不得有兩套**）。

## 動工前請先看 spec 的兩節
- **§0b 真實隱藏成本**（R² 親驗）：`_mk_candidate` / `_mk_delegate_candidate` 的 dict
  **只有融合後的 label**，`gt`／`frontier_kind` **沒有獨立欄位** ⇒ **要先各加 2 個欄位**。
  ★**這會動到 candidate 的產出格式 ⇒ 所有讀 candidate 的地方要一起看。**
- **§3 語意界限**：★**先 exact-pair、類級泛化不預做**
  （blueprint：**過度泛化 ＝ 懲罰擴散、反傷探索**）；既有四項（連續折價／TTL／失效升 T0）**不動**。

## 驗收重點（§5）
★**測規律不測結果**：*同一 `(動作, 目標)` 連續失敗 N 次 ⇒ 第 N+1 次 util 嚴格小於第 1 次*；
★**反面**：**不同 target 的同類動作不受影響**（證明沒偷做類級泛化）；
★**覆蓋率要報**（從「2 個 option」變成多少）——`00_roles §覆蓋欄`：**記 done 必同記覆蓋率**。
`det fp` 預期會變 ＝ intended-change。
