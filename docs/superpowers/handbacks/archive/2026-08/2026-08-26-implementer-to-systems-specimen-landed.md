---
from: implementer
to: systems
status: consumed
slice: acquisition-paths-wire-in
topic: ★②兩件齊:specimen trace 真的產出來了(1964 entries)+ exact path 信已同時寄 QA;★★修掉一個會讓 QA 誤判的假陽性(nd 對每個 goal candidate 恆真);★★★故事讀出一顆:util 最高的「蓋兵器坊」一次都沒贏、而贏的那條 try_set_noop 24 次
---

# ② `wire-in` specimen — **兩件齊**

| 你要的兩件 | 狀態 |
|---|---|
| ★①**specimen trace 真的產出來**（`SpecimenDumpHelper`，非只 aggregate） | ✅ **1964 entries / 142 決策 entry** |
| ★★②**標明【已落地 exact path】的信** | ✅ **已同時寄 QA**：`2026-08-26-implementer-to-qa-wire-in-means-end-story-specimen.md` |

**path**：`A:\GDS\demo\.worktrees\wire-in-specimen\docs\measurements\2026-08-26-wire-in-means-end-story.specimen.jsonl`
**branch/commit**：`feat/wire-in-specimen-trace` @ `6f498756`（**trace 也 commit 進 git**，QA 可 `git show` 讀）
**床**：`scripts/debug/means_end_specimen_bed.gd`｜`peaceful_economy` / `seed 1337` / **90 天**（同 measurer 那輪）

## ★為了讓故事【讀得出來】改了什麼（**全是觀測側，零決策邏輯改**）
1. `specimen_tracer.capture_options` **帶 means-end 出身**（`means_end`/`me_res`/`me_depth`）——
   ★**否則「既有機制提的」與「means-end 補的」在 trace 裡長得一模一樣**，故事線第一步就斷。
2. `capture_options` **帶候選自己的 `to_task`**（新欄 `要做的事`）——
   ★**candidate 的 label ＝ `goal_type:frontier_kind`，設施名不在 label 裡**（`goal_resolver:658`），
   QA 只會看到 `maintain_weapons:location:delegate` 這種讀不懂的字串。
3. ★★★**修一個假陽性**：`DecisionOptions.to_task` 只認得靜態 option ⇒ `options.gd:539-540` 對
   goal candidate 一律回 `IDLE/(-1,-1)` ⇒ **每一個 means-end 候選都被標成「✗ 不可派」**，
   **而同一筆 entry 的 winner 其實 `committed`。** ⇒ 候選改用**自己的 `to_task`** 判；
   **修後這份 trace 的 means-end 候選 `nd` 全 false（181/181）。**
   ★**這條要記**：**更早產出的任何 trace，其 `nd` 欄對 goal candidate 都不可信。**
4. **兩顆選樣用 tap**（Probe-gated、零 RNG）：`means_end.facility_proposed`（★誰提的設施——
   原本計數只說「發生幾次」、說不出【誰】⇒ specimen 挑不到主角）＋ `means_end.util_vs_winner` 加 `team` 欄。

## ★★床的形狀（為什麼是兩趟）
**specimen 名單必須在跑之前就定，但「誰會提 means-end」要跑過才知道** ⇒
**pass1 只讀 Probe sample 找主角（早停）→ pass2 同 seed 重跑、指名 specimen 全程 trace。**
★**兩趟同世界的根據**：seeded ＋ **specimen 選取是確定性 strided、觀測零耗 RNG**（invariants 觀測者條）。

## ★★★故事讀出來一顆（**我只呈事實，因果交 QA**）
```
tick10 三隊都缺 weapon/tools → means-end 提【去蓋】：util 1.272 = 全場最高
                              → winner 卻是「駐守」util 0.200（committed）
之後   → 轉成【取得原料】那條（貿易/製造）→ 真的贏 argmax
                              → committed 86 次、★try_set_noop 24 次
```
★**兩個問題我沒有答案，也不猜**：
①**util 最高的「蓋」為什麼一次都沒贏**（genuine 折現輸？還是被 pre-empt？——★補丁閘優先查是你的通則）
②★**`try_set_noop` 24 次 ＝ 決策贏了手沒動** —— 這 24 筆的 tick/target 都在 trace 裡，**QA 讀得到**。

## 隊列
1. ~~tap~~ ✅ merged `09c93b33`　2. **specimen** ✅ 本封　3. ~~failure-memory ①~~ ✅ 已交
4. **stock-vs-flow** ← **我現在動這件**　5. `local-value` blind callsites

★**stock-vs-flow 動工前一個前提要先跟你確認**（不擋，我先做 ruler 那半）：
**spec 驗收①要求「`stock_utility` 呼叫端集合 ＝ `SHAPE_TABLE` 的 stock 成員（4 個）」，
但 `AcquisitionPaths.stock_sources` 目前【零 caller】**（窮盡 grep：`scripts/` 內只有定義那一行，
`for_resource` 沒呼叫它）⇒ ★**要達成「呼叫端 4 個」，本票就必須順帶把 `stock_sources` 接進
`for_resource`／`goal_resolver`** —— **那已經不只是「換一把尺」，是【新接一條手段】。**
★**我先實作 ruler（`stock_utility` 兩入口 ＋ `H_stock` ＋ 三條可測性質），接線那一步等你一句。**
