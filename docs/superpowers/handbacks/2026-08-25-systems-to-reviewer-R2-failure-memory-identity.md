---
from: systems
to: reviewer
status: consumed
slice: failure-memory-structural-identity
topic: R² — 失敗記憶改結構身分 key(零人工表);請優先打【結構身分真的到得了嗎】與【exact-pair 會不會等於沒折價】兩顆
---

# R²：`failure-memory-structural-identity`

**磚由 blueprint 定**：失敗記憶 key ＝ **`(option 結構 id, target id)`**，
**由 dispatch 自帶的結構欄位機械導出**（goal type／frontier kind／target），**不經 label 字串對照**
⇒ ★**覆蓋從「2 個 option」變成構造性 100%**。

## ★請優先打這兩顆（我最沒把握的）

### ①**「結構欄位本來就在」這個前提，到得了 `decision_engine` 嗎？**
磚的整個價值建立在「**dispatch 自帶結構欄位**」。
我看到 `goal_resolver.gd:447` 的 candidate 是 `{"label": gt + ":" + frontier_kind, ...}`
—— ★**label 是組合出來的字串，但 `gt` / `frontier_kind` / `target` 是不是也以【欄位】形式在 dict 裡？**
**如果只有組合後的 label 傳下去，那「零人工表」就得先做一次結構欄位的補傳** ——
★**那是本票的隱藏成本，我需要你確認它存不存在。**

### ②**exact-pair 會不會等於「幾乎不折價」？**
blueprint 明令**先 exact-pair、類級泛化不預做**（理由：過度泛化＝懲罰擴散反傷探索）。
★**但如果 target 幾乎每次都不同**（例如每次挑的工坊 tile 都不一樣），
**exact-pair 的命中率會趨近 0 ⇒ 折價形同不存在 ⇒ 我們做出第二個「恆 1.0」的機制。**
⇒ 我已在 §5 驗收放了**死水兩欄**（新 key 的呼叫頻率／輸入變異性）當防線，
★**但請你判：這個防線是不是【事後才發現】？要不要在 spec 就要求先量 target 重複率？**
（team 11 那 45 次是不是**同一個 tile**，我**沒有這個數字** —— 診斷票沒問。）

## 其他可查項
- **folding**：candidate 路與靜態 option 路**收斂到同一 key 空間**，⛔**不得兩套記憶**
- **語意界限**：反面驗收「**不同 target 的同類動作不受影響**」＝ 證明沒偷做類級泛化
- **既有四項不動**：連續折價／TTL／失效升 T0
- `OPTION_FAIL_KEY` 這張人工表**消失**（已列管於 `00_roles §覆蓋欄`：**手工對照表是暫時形態不是終態**）

**CLEAN → 我轉 implementer。有 premise_contradiction 直接 halt 我**（①那顆就是我請你打的前提）。
