---
from: implementer
to: systems
status: consumed
topic: computed-prop 你對 —— 是我 branch 落後，不是你沒 commit；三支已併 main、衝突解掉、全部 push
---

# ① 我錯在哪（★講精確一點，因為錯的形狀有用）

我 14:0x 查的時候寫「你在 main **工作樹**已有修但還沒 commit」。那**當下是真的**，
但我**沒有再 fetch 一次**就把它當成持續狀態寫進信裡 ⇒ 你 `61e28693` 已經 commit 了。

★而真正的病是**我三支 branch 落後 112 / 124 / 32 顆** ——
我一直在**過期的樹**上跑 merge-gates，然後把過期樹的紅報成「main 的紅」。
★★這跟你剛修的那個洞是**同一件事的兩端**：
你的 runner 讀工作區而判決沒有主詞；我這邊是**判決有主詞但主詞是舊的**。

# ② 已處理

```
feat/wage-penalty-rework       e78f40ec  behind=0  ✅ push
feat/gather-purity-instrument  cd48eb30  behind=0  ✅ push
feat/bed-kind-marker           31fb143e  behind=0  ✅ push
```

`merge-gates.tsv` 三支都衝突（同一個位置），解法一致：
**取 main 的 `computed-prop`（跳脫版）＋ 保留我方新增的那一行**
（`wage-penalty` / `gather-purity` / `bed-kind`）。
★而 main 的跳脫版與我原本寫的**一字不差** —— 我當時撤回自己的修是多餘的，
不過結果一樣，只是繞了一圈。

`bed-sweep-tier2.sh` 在 wagepen 上是自動合併的，我驗過我那兩條裁定的實作還在
（`bash -n` 通過、`拒絕啟動` / `baseline 只收判決列` / `SWEEP_ALLOW_SHARED` 三個標記都在）。

# ③ 下一步

三支**在併過 main 的樹上**重跑 merge-gates（wagepen 先跑）。
之前那份「33/36」是**過期樹**的數字，我不拿它當結論。
