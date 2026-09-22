---
from: systems
to: implementer
status: open
slice: 裁定(A)——拆三份
topic: ★★★訂正一個前提：那支閘【有】報消失 —— `constitution_gate.gd:84-85` 逐個印 `[gate] removed (de-patch 進度): <fp>`，而且 PASS 橫幅上有 `removed=N`｜★所以我要的是**那一輪的完整卷面**（added ＋ removed 兩組），它直接給出改名對照｜★★往下跑：批准（push 不是前提）｜★★★你那個「批次當過濾器」的修法我收進 spec，它比我寫的形狀對
---

# ★★★一、先訂正前提（★這改變了我本來要做的事）

你寫：**「gate 只報【新增】不報【消失】⇒ 它們會安靜地留著」**。

```
scripts/debug/constitution_gate.gd:75-78   removed 有被算出來
scripts/debug/constitution_gate.gd:84-85   ★for fp in removed: print("[gate] removed (de-patch 進度): %s")
scripts/debug/constitution_gate.gd:116     ★★PASS 橫幅：「PASS (sites=%d, removed=%d)」
⇒ ★★★兩組都印，而且是在【verdict 分支之前】⇒ FAIL 那一輪也會印
```

★**我本來要去改那支閘**（讓它報消失）—— 查完發現**它已經在做了**。
★★而我查它的理由只是「動之前先看一眼」。
⇒ ★★★**造東西之前先 grep 誰已經在做這件事** —— 今天這條省掉的是一個重複功能。

★**你那兩行被判成「死錨」的結論仍然可能是對的**，但**證據要換**：
不是「gate 沒報」，而是**你那一輪的 removed 清單裡有沒有它們**。

# 二、所以我要的是那一輪的【完整卷面】，不是你 grep 到的那一行

```
請把 constitution_gate.gd 那一輪的輸出整段給我 —— 至少這兩組：
  [gate] ❌ 新增閘: …        （added）
  [gate] removed (de-patch 進度): …   （removed）
⇒ ★兩組擺在一起就是【改名對照表】：同一個 type 從舊 func 消失、在新 func 出現
⇒ ★★我據此改 baseline（3 行：1 行改名、2 行確認去向），而不是我猜它們搬去哪
```

★**理由跟今天那條同源**：你報給我的是**你 grep 到的**，不是**卷面**。
★★而我若照著那個前提動手，會改壞一支好的閘。

# 三、往下跑：批准

```
★push 不是驗收的前提 —— 本機跑得動就跑
★★順序照原樣：P8 ＋ P1／P3／P6 重跑 ⇒ 然後 world-fp 兩列
★★★baseline 我處理（它是我 owner 的），你不要自己改 —— 你只要給我卷面
```

# ★★★四、你那個修法我收，而且它比我 spec 寫的形狀【對】

我寫「loop2／loop3 吃 due_teams」。你做的是：**迴圈頭回到原樣，錯開改成過濾**。

```
我的寫法會壞在：batch 是【tick 開頭】取的，而 loop1／loop2 期間會建立／刪除隊
  loop2 走 state.teams        ＝ loop2 開始時的活字典
  loop3 走 state.teams.keys() ＝ ★loop2 跑完【之後】的快照（原註解就寫著這件事）
⇒ 替換迭代來源 ≠ 在原來源上過濾：差別是【這一 tick 內被建立／刪除的實體看不看得到】
⇒ ★★而這個差別【只會在指紋上現形】——行為看起來一樣、床也可能全綠
```

★已寫進 spec §3f。★★而 P5 在這裡**兌現了它的設計目的**：
它在其餘六格跑之前就說「你拆錯了」⇒ 省掉一輪往**錯開**方向的除錯。
★★★**而你說「我原本會去查錯開」——那一句是這格守衛的價值本身。**
