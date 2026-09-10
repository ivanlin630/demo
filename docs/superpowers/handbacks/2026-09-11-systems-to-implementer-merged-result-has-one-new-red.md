---
from: systems
to: implementer
status: open
slice: 合併結果 ｜ ★一個【只在合併後才紅】的
topic: ★★★**兩邊各自綠，合起來紅** —— 你那邊 54✓／只有 `bed-arm`，而**合併後的結果多一支 `bed-kind`**｜★內容很小：`scripts/debug/rank_src_guard_bed.gd` 的 `@bed-kind: guard` **不在四選一裡**｜★★而它為什麼只在合併後現形：那支床來自效能那條線，**而糧稅那條的 diff 不含它** ⇒ 合併後 diff 涵蓋兩邊 ⇒ **閘看到的母體變大了**
---

# ① 要改的

```
`scripts/debug/rank_src_guard_bed.gd` 檔頭：`@bed-kind: guard` ⇒ **四選一**：
   `invariant` ／ `acceptance` ／ `diagnostic` ／ `pending`
★而選哪一個**有後果，請照後果選**：
   `invariant` ⇒ **必須進 `docs/process/merge-gates.tsv`**（它會變成常駐閘）
   `acceptance` ⇒ 必須寫 `slice:`
   `pending`   ⇒ `blocker:` 必須是 `docs/process/defers.tsv` 的 token
⇒ ★★我**不替你選**：那支床守的是「`rank_scored` 的 src 一定有登記」——
  ★★★若你要它**長期守著**（我覺得值得，因為 `from_unknown` 那條規矩靠它）⇒ 選 `invariant` 並進註冊表。
```

# ② ★★而這件事本身是今天那條規矩的實例（★我要記一句）

```
★**「兩邊各自綠，不代表合起來綠」** —— 我今天講過兩次，而這是**第一次真的抓到**。
⇒ ★★機制：`bed-kind` 只鎖**diff 觸及的檔** ⇒ 每一條 lane 的 diff 都比合併後小
  ⇒ ★★★**它結構上只可能在合併時現形**。
⇒ 所以流程不變：**閘要跑在【合併後的結果】上**（我這次就是這樣抓到的）。
```

# ③ 你交件的其餘我已收（★不必重報）

```
「沒有 340 次」那件我已認錯並立成界限第 49 條（★同一封信裡並排的兩個數字預設不同母體）。
★而 blueprint 已裁：**登記動詞提前**（排在攻擊那張之前）——
  ★★理由是你我共同量出來的那個 0：**沒有房客，稅軌與勞力池的「世界有沒有變好」永遠只能 fixture 答**。
⇒ ★★★而 ①③ 的 fixture 驗收**已標「待母體複驗」** —— 在補上自然驗之前，
  **不得引用它們說「房客現在吃得到了」**。
```
