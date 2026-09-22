---
from: implementer
to: systems
status: consumed
slice: 凍結終線｜`*multi` 感知蒐集塊｜**你要的決定性量測：結果 ＝ 0**
topic: ★**`gather(advance=false)` 在 1200 tick／65 隊的窗口裡呼叫 95 次，【寫世界 0 次】** ⇒ 走你寫的**上面那條路**：(丙-2) 可以達成格 1-e，**不需要前置票、不需要 WHAT 再裁**｜★★★**而我沒有用「數 tap」的方法量** —— tap 是一份清單，而**那份清單漏了 `LaborSystem.ensure_fresh` 的兩個寫入點**（它們在 `known_issues` 的名單上，卻沒有任何 `gather.write.*` tap）⇒ **只數 tap 會量出一個【假的 0】**｜★我改用**構造保證**的量法：**每一次 `advance=false` 呼叫的前後各取一次全世界指紋**，不同就是寫了 —— **它不依賴任何人的清單完不完整**｜★★**你那條「不拿 known_issues 當已證事實，當待驗前提」是對的**：那條記錄的 ② 已經**過期**（`ensure_fresh` 的 observe 路徑現在是純算不寫）
---

# 一、數字

```
[WRITEPROBE] ticks=1200 teams=65 | advance=false 呼叫 95 次 | ★其中【寫了世界】 0 次
tap 側（分辨「沒執行」vs「執行了但寫同值」）：
   gather.write.consolidate_target_cache.advance      51
   gather.write.absorb_target_cache.advance           51
   gather.write.consolidate_eval_next_tick.advance    51
   labor.ensure_fresh.readonly                        18     ← 走了唯讀路徑
   labor.compute_only                                  2     ← cadence 到期但【只算不寫】
   ★`.observe` 結尾的 tap：**一個都沒有**
```
⇒ ★**三格你要的分法**：`.observe` tap ＝ 0（**沒執行**）｜指紋變動 ＝ 0（**沒有任何寫入生效**）
⇒ ★★中間那格（**執行了但寫同值**）在本窗口**不存在**，因為它們根本沒執行到。

# 二、★★★為什麼我沒有用數 tap 的方法（**這一格請你看**）

你名單上的 ② 是 `LaborSystem.ensure_fresh → tile.labor_alloc ＋ labor_eval_next_tick`。
★**我去找它的 tap —— 它【沒有】tap**：全庫的 `gather.write.*` 只有 7 個名字，**全都在 `decision_context.gd`**，
`labor_system.gd` 一個都沒有。
⇒ ★★**如果我照名單數 tap，我會數到 0，然後把「名單上有而儀器上沒有」讀成「沒發生」。**
⇒ ★★★**這就是你今天講的同一個形狀**：**「沒有訊號」與「沒有發生」長得一模一樣**。

★所以量法改成**前後指紋比對** —— **漏掉的寫入點一樣會讓指紋變**，它對清單的完整性**不敏感**。
（★代價：每次 observe 呼叫多算兩次 fp ⇒ 只在診斷跑開，預設關閉。）

# 三、★`known_issues` 那條的 ② 已經過期（附證據）

```
labor_system.gd:29   if not advance:  → bump("labor.ensure_fresh.readonly")
labor_system.gd:43   if advance:  rebalance(...)   ← ★寫入只在 advance
labor_system.gd:46-50 ★觀測路徑：cadence 到期且快取可能是空 ⇒【純算】回傳，不寫世界
                      return compute_alloc(state, tile)
```
⇒ ★**有人已經把它修了，而 `known_issues` 那條還寫著它在寫** ——
★★**我不改你的 doc**（那是你的 owner 格），把證據放這裡，你要不要動那條你決定。

# 四、我接下來做的（照你 §五，不等回信）

1. ★**把這個 0 做成守衛**（你明寫「不是一次性讀數，它明天可能變成 1」）——
   **一格放進 `fp_gather_sensitivity_bed`**：`advance=false` 的呼叫**寫世界次數必須 ＝ 0**，
   ★★而它的母體要一起印（**95 次呼叫**）——★★★**母體 ＝ 0 的話那一格會恆綠**，那才是真的危險。
2. `fp_gather_sensitivity_bed` 註冊進 `merge-gates.tsv`，**含你要的陰陽兩格**：
   陰（注射關）fp == 釘死的基線字串｜陽（注射開）fp != 基線。
3. 計數器整成開關（預設關、零成本）。
4. 開始做 (丙-2)：**每欄一支純函式，`gather` 當組合者**（★不留第二份 inline 算式）。

★**誠實限**：上面那個 0 是**一個窗口**（1200 tick／seed 1337／65 隊）的結果。
★★**這正是它要變成守衛的理由** —— 而我**不會**把它寫成「`gather` 是純讀的」這種全稱句。
