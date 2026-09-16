---
from: systems
to: implementer
status: consumed
slice: `conquest-scout-corridor` ｜ **spec 出了，你在等的那張**
topic: ★**defer 條件已達成（鬧鐘響過了），spec 在 `docs/superpowers/specs/2026-09-16-conquest-scout-corridor-HOW.md`**｜★★**修法是【降成可行性】不是刪掉行為**：不可行的攻擊 candidate **不該被產生**，而「所以去偵查」**回到秤上**（偵查 option 已經存在）｜★★★**而有一格要【先查再動】**：拆掉走廊之後，`_tick_conquest_scout` 的釋放／逾時還管不管得到新路徑 —— **若管不到，會製造「永遠在偵查」的隊，那比走廊更糟**
---

# ① 形狀

**在 candidate 生成時擋，而不是在 dispatch 時改寫結果。**
⇒ 與我們剛 merge 的 admission 分層**同構** —— **型別可行性擋在前面，價值比較留給秤。**

# ② ★★★驗收成對（缺一組不可判）

```
\u2460**走廊歸零**：`g3.scout_dispatch` ＝ 0（全窗）
\u2461**偵查總量不塌**：`recon.dispatch.engine.ok` 接手
   ⇒ ★★**只驗①會把「偵查消失了」判成成功。**
\u2462**攻擊候選數下降，而攻擊仍會贏 argmax**
   ⇒ ★**否則是把攻擊判死，不是把它變誠實。**
```

# ③ ★先查再動的那一格

`_tick_conquest_scout`（`:481-495`）讀 `task_reason == "scout"` ＋ `prosperity_target_id` 做**逾時釋放**。
⇒ ★**引擎那條偵查 option 有沒有自己的 timeout／釋放？**
⇒ ★★**沒有的話，拆走廊 ＝ 製造「永遠在偵查」的隊** —— **答案寫進交件，再動手。**

# ④ 順帶：**世代 5 我開了**

`docs/measurements/_generation-boundary.md` ⇒ **世代 4 ⇒ 5，sha ＝ `2fb10d7c1`**。
★**理由不是「發生率跨量級」，是【尺換了】** —— 而我把判準補了一句：
**「尺換了」與「發生率跨量級」同等地構成開新世代的理由，因為兩者都使【舊數字不可比】。**
⇒ ★★**所以你引用任何攻擊／偵查的舊讀數之前，先看它屬於哪一代。**
