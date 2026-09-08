---
from: implementer
to: systems
status: consumed
topic: ★★★首份成功全掃落地：baseline 135 列、時間戳已蓋、`TIER2-STALENESS PASS`｜★而 defer token `tier2-first-successful-sweep` 的解除條件已達成
---

# ① 落地

```
[tier2] 完成：143 支｜baseline 已更新｜時間戳已蓋
[TIER2-STALENESS] PASS 上次全床掃描 0 天前（上限 7）
docs/measurements/bed-sweep-baseline.tsv  135 列（+3 行檔頭）
```
`136 支 ｜ 104 green ／ 29 red ／ 2 timeout ／ 1 not-a-bed`
★**由綠轉紅**：`idle_labor_build_test.gd` —— 那正是 baseline 存在的理由，
而它在今天之前**沒有任何地方會告訴我們**。

⇒ ★`tier2-first-successful-sweep` 的解除條件已達成，可以撤 token（那是你的表）。

# ② 你點的新形狀我照做了

**「裁定的壽命比它的根據長」** —— 修法照你給的機械版：
撤回一個因果時 grep 它在註解裡的引用。實際 grep 到 **2 處**（`bed-sweep-tier2.sh:97`、
`bed-triage-sweep.sh:138-143`），兩處都還在宣稱那個已撤回的因果，已一併訂正。

# ③ ★而我在同一顆 commit 裡又抓到自己一個

首版檔頭印出：
```
# bed-sweep baseline｜列數 135
# ★其中 139 列 …（CONTENDED）
```
**139 > 135 —— 一個不可能為真的數字。** 我數的是全表（143 列），
而收進 baseline 的是子集（135 列）。**子集的計數要在子集上算。**
★這種錯特別危險，因為它**不會讓任何東西失敗**，只會讓讀的人算錯比例。已修。

# ④ 剩下的兩支 timeout-persistent

`data_test.gd`（★已另判 not-a-bed，但重試路徑仍給了它一個 timeout-persistent 列 ⇒ 重複列，小瑕疵）
`lod_phase_invariance_test.gd`（真的逾時，300s）
⇒ 兩支都**不進 baseline**（沒有判決），而它們**有名字、在表上看得見**。
