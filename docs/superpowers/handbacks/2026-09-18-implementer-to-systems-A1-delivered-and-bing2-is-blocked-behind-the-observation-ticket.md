---
from: implementer
to: systems
status: open
slice: 凍結終線｜(A1) lazy **交件**（`feat/freeze-multi-perception` ＝ `e07e16dc1`，origin 已對過）
topic: ★**A1 做完，三個消費者全部遷移**（含 R² 掃出的第三個 `headless_test.gd:9262`）｜★★**WHAT 條件①：三跑 byte-identical ＝ `67c011dc430e2d69e3fc433f36f4c0b9`**；條件②**跨這顆 commit 的前後對照不可歸因**已寫進 commit 訊息｜★★★**而我把 (丙-2) 那一步【撤回了】** —— 量出來的：**A1 之後它仍然過不了 1-e**，因為 `gather` 還有**合法的**抽取（`_find_strong_neighbor → estimate_catch_up → observed_speed`，**它是真的在用那個速度值**）⇒ **(丙-2) 卡在你登的【觀測模型】那張獨立票之後，不是卡在 A1**｜★這句話的後果請你看 §4：**「讓 gather 少跑」這條路，在那張票落地前【整條】不可用**
---

# 一、A1（已交）

```
observe_velocity()   ⇒ { visible, direction, noise_factor }   ★不再抽亂數
PathSystem.observed_speed()  ⇒ ★唯一抽那個亂數的地方
三個消費者：path_system.gd estimate_catch_up／predict_intercept／debug headless_test.gd:9262
```
★`speed` 這個鍵**從回傳裡拿掉**，不是留一個 0 —— 留 0 會讓漏改的呼叫端**安靜地拿到錯的值**；
拿掉 ⇒ **大聲壞掉**。★★而那正是 R² 用來掃出第三個消費者的判準（`0 > 0` 會是 loud fail）。

**WHAT 兩個條件**：

| 條件 | 結果 |
|---|---|
| ①修後三跑 byte-identical | ★**是**：`67c011dc430e2d69e3fc433f36f4c0b9` ×3（A1 單獨；含 丙-2 的那版是 `d7f0f199…` ×3） |
| ②跨這顆 commit 的單 seed 前後對照**不可歸因** | ★已寫進 commit 訊息：修法前 `3951597c0fd9…` → 後 `67c011dc430e…` 的差異**不得**拿來論證任何效能或行為結論 |

# 二、★★★(丙-2) 撤回了，而理由是量出來的

```
A1 單獨        fp = 67c011dc430e2d69e3fc433f36f4c0b9
A1 ＋ (丙-2)   fp = d7f0f1991289ab45139916a8071eacba     ⇒ ★仍然不同 ⇒ 1-e 紅
```
為什麼 A1 沒解掉它：

```
A1 拿掉的是【被丟掉的】那個抽取（threat 路）
★而 gather 還有【合法的】抽取：
  _find_strong_neighbor → PathSystem.estimate_catch_up → observed_speed → randf()
  （estimate_catch_up **真的在用**那個速度值 ⇒ 這個抽取不是浪費，不能拿掉）
★★實測（A1 之後）：gather(advance=false) 仍有 31／40 的隊會抽亂數
   _find_strong_neighbor 27／30｜_find_occupy_target 2／30
```
⇒ ★**只要「觀測雜訊」還綁在【呼叫次數】上，「讓 gather 少被呼叫」就【在構造上】到不了語意零改變。**

# 三、★一個我差點漏掉的取樣錯誤（順帶報）

我 bisect 時單獨測 `estimate_catch_up` ⇒ **回報「零抽」**，而 `_find_strong_neighbor` 是 27／30。
★原因同上一次：**我餵的那一對目標不可見** ⇒ 沒走到會抽的分支。
⇒ ★★**同一個取樣病在同一天第三次**（前兩次：注射沒咬到、bisect 三支全零抽）。
★★★我現在的習慣是：**單點樣本回「沒有」時，先問「我的樣本走到那條分支了嗎」**，再下結論。

# 四、★★所以效能票現在的形狀（**請你裁下一步**）

```
(丙-2)／甲／乙 —— 三個形狀的共同動作都是「讓 gather 少跑幾次」
⇒ ★它們全部卡在【觀測雜訊 vs 呼叫次數】那張票之後
⇒ ★★在那之前，`*multi` 這塊的效能【不能】用「少蒐集」來省
```
★**我不自己挑下一步**。我看得到的選項有兩個，都不在本票裡：
1. **先做那張觀測模型票**（決定性雜訊 ⇒ 抽取不再跟呼叫次數綁）⇒ 再回來做 (丙-2)。
2. **改攻另一個軸**：不是「少呼叫」，而是「**同一次呼叫裡少做事**」（例如那些 O(隊數) 掃描本身）
   —— ★這一條**不動呼叫次數** ⇒ 不踩 RNG 那顆地雷，★★但它是**另一個 spec**。

# 五、branch

```
feat/freeze-multi-perception ＝ e07e16dc1（origin 逐字相同，push 後 fetch 對過）
  a67c684c7 陽性對照床＋三個預設關閉的開關＋註冊表一列
  911aeaac8 影子尺改呼既有的 EphemeralStateHash
  e37b1fdf9 WIP(丙-2)          ← ★保留在歷史裡（它是那個結論的證據）
  50baa5d01 撤回 (丙-2)         ← ★附完整量測理由
  e07e16dc1 (A1) lazy
`fp-gather-sensitivity` 閘：★A1 之後仍綠（6／6，寫世界 0／127、cadence 影子 0／127）
```
