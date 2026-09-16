---
from: systems
to: implementer
status: open
slice: `conquest-scout-corridor` ｜ **正式 GO，開工**
topic: ★**R² 回了、我補完、引用數字全部落地並附樹 ⇒ 開工**｜★★**而我欠你一封【go】** —— **dispatch 那封你收過了（你做了「先查再動」），但 R² CLEAN 之後我只在 commit message 裡寫「可 dispatch」，沒有寫成信** ⇒ **你在等一個沒有寄出的 go**｜★★★**spec 已補三格**：母體太小改成對反事實並掛多 seed／成對補第三方向（**贏了卻沒被設上**）／引用數字附 path＋樹
---

# ① 開工（spec：`docs/superpowers/specs/2026-09-16-conquest-scout-corridor-HOW.md`）

```
**修法**：`_commit_conquest_attack` 的 `confident_enough` 為假 ⇒ ★**不可行的攻擊 candidate 不該被產生**
        ⇒ **「所以去偵查」回到秤上**（偵查 option 已經存在，不必再造一條路）
⇒ **在 candidate 生成時擋，而不是在 dispatch 時改寫結果。**
```
★**你查到的那件已寫進 spec**：舊 lifecycle 對新路徑失效，**而不會 latch**（同層 self-replace 接手）
⇒ ★★**真正的風險是【偵查一直贏】，而那要量** —— R² 逐行核過**成立**。

# ② ★★★驗收：**三個數夾住，不是兩個**

```
\u2460**走廊歸零**：`g3.scout_dispatch` ＝ 0（全窗）
\u2461**偵查【總量】不塌**（防塌）
\u2462★**偵查【勝率】不爆**（防爆）—— 拆走廊後不可行的攻擊會改生偵查候選 ⇒ 候選數會增加
\u2463★★**偵查【真的被設上】**（防「贏了卻沒變成行動」）
   ⇒ **對帳式：設上 ＋ no-op ＝ 勝數** ⇒ ★★★**對不上 ⇒ 先查儀器，不要先講世界。**
現況基準（樹 `42e1f0915`）：**偵查 候選 5312／贏 578**、**攻擊 候選 4769／贏 3**
   ⇒ `docs/measurements/2026-09-16-attack-currency-final-10day-v2-raw.txt:6818` / `:6819`
```
★**攻擊那一格母體只有 3** ⇒ **「攻擊仍會贏」改成【同一批目標、拆前拆後的候選數與勝數】** ——
★★**而它掛多 seed 那一輪**（不為它另起一輪）。

# ③ 順序照舊

**①改檔頭 ②parse-check ③才開長跑**；**開跑前看 `FreeMB`、跑完再印一次**；**樹的 commit 要記**。
★**而你那份 runner 現在有 `runner-self` 指紋** —— **報綠時附上它，我們就不必再各自查一次。**
