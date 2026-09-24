---
from: systems
to: implementer
status: open
slice: 打聽 v1（merge 前審）
topic: ★合規面我逐項核過（一個寫入點／簽章只加尾參數／三句話三個字串／例外有理由／payload 空判準）｜★★兩點：(A) `out["written"]` 沒有歸零而 `out` 是【預設參數】⇒ 一行 `out["written"] = 0` 讓這個問題不必被回答；(B) 數字要連【數法】一起報（`state.world.tiles` 裸 grep 在你分支上是 3＝1 碼＋2 註解）
---

# 一、我核過而**合規**的（唯讀，沒碰機器）

```
・`record_claim(` production 呼叫點：faction_ai／interaction／message_system／vision 各 1 ⇒ **仍是 4**
・`_exchange_intel` 只加**有預設值的尾參數**（`topic := ""`, `out := {}`）⇒ 7 個床不受影響
・三句話是**三個不同的字串**：「他不願多說」／「他也不知道」／「他說了些事情（記下 N 筆，來自 TeamX）」
・`ask_faction_status` 的例外**在 code 裡寫明理由**（self-knowledge，不是別人給的情報）
・★`_inquiry_payload_empty` 處理「有 key 但陣列是空的」那個坑 —— `is_empty()` 會讓第三句
  永遠搶在第二句前面。**這個你抓得好，而它正是「兩句要分」真正的實作難點。**
・`out["giver_known"]` 在 `silent` **之前**就記 ⇒ 「不願說」與「不知道」在卷面上分得出來（P5 要的）
```

# ★★二、(A) `out["written"]` 沒有歸零（merge 前處理）

```
:232 out["mode"] = mode
:235 out["giver_known"] = ...
:304 out["written"] = int(out.get("written", 0)) + 1     ← ★沒有任何地方歸零
而 `:187/:188`（到達交換）**不傳 out** ⇒ 走預設值
```
```
★問題：GDScript 的 `= {}` 預設值是【每次呼叫新建】還是【整支函式共用一個】？
  —— 我不知道，而這正是**不該用讀的來回答**的那種問題（靜態讀 code 的認識論界限）。
  ·若共用 ⇒ 到達路徑每 tick 在同一個隱藏 dict 上累加（今天沒人讀它 ⇒ 無行為影響，
    ★但它是一個看不見的累積物，下一個在那條路上讀 `out` 的人會拿到垃圾）
  ·玩家那條路 `:819 var out_gi: Dictionary = {}` 每次新建 ⇒ **那條路今天是對的**
★★處置＝一行，而它讓這個問題【不必被回答】：在 `out["mode"] = mode` 旁加 `out["written"] = 0`。
★★★理由與「`out` 要帶 `written`」同源：**`out` 必須由【做事的那一趟】完整寫滿** ——
  沒有歸零的話，它帶的是「這一趟 ＋ 之前不知道幾趟」。
（要量的話 5 行：`func f(d := {}) -> void: d["n"] = int(d.get("n",0))+1; print(d["n"])`
  連呼三次 ⇒ 1,1,1 是新建、1,2,3 是共用。★但即使量出「每次新建」我仍要那一行：
  **契約不該依賴一個語言細節。**）
```

# ★三、(B) 數字要連【數法】一起報

```
你分支上 `grep -c 'state.world.tiles' inquiry_system.gd` ＝ **3**（1 行碼 ＋ 2 行註解），
而 spec 寫「2 → 1」。你的機械格有剝註解所以判決是對的 ——
★但**卷面要把數法印出來**（「非註解行」），否則下一個人直接 grep 得到 3，會讀成回歸。
★★而這正是你今天自陳的那一族：**註解裡解釋指標的句子本身含有它要數的字串**。
  工具你已經修了，現在把【它的說明】也修一下。
```

**其餘無意見。電池收了敲我，我審 merge。**
