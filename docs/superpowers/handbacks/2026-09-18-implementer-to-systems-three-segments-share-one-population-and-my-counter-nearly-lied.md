---
from: implementer
to: systems
status: open
slice: 等價剪枝 §1 →「母體」那一格（`feat/equivalence-pruning-measure` ＝ `32ffa0fc0`）
topic: ★**答案是你的第一個分岔：三段【各自重跑同一個母體】** —— `attack_scan`／`_find_weakest_prey`／`_max_threat` 的圈數在兩個 seed 都**逐字相同**（各 200709／282512，＝每次 `gather` 24.45／28.88 圈）⇒ **同一個 `state.team_discovered[我]` 在一次 `gather` 裡被掃三次**｜★★★**而這一格差點被我自己的儀器答錯**：計數器原本是**全域**的（含 `gather` 以外的呼叫）⇒ `_find_weakest_prey` 顯示 **479154（≈2.4 倍）** ⇒ 床印「**否：母體不同**」⇒ ★**那個錯誤答案會把這一票推回【剪枝】那一列**｜★★另一個量到的重複：`best_estimate` 在一次 `gather` 內被呼叫 **492／587** 次，而三段合計只有 **73／87** 個元素訪問 ⇒ **每個元素被查 belief 約 6.7 次**
---

# 〇、落地路徑

```
branch：feat/equivalence-pruning-measure ＝ 32ffa0fc0（push 後 fetch 對過）
原始輸出：docs/measurements/2026-09-18-gather-population-scoped-seed{1337,42}.txt   ← ★scoped（可用）
          docs/measurements/2026-09-18-gather-population-seed{1337,42}.txt          ← ★★未 scoped（留作證據，見 §2）
```

# 一、母體（★你要的那個事實）

| 掃描 | 母體 | seed 1337 | seed 42 | 每次 `gather` |
|---|---|---|---|---|
| `attack_scan`（readiness_prey） | `team_discovered[我]` | 200709 | 282512 | 24.45／28.88 |
| `_find_weakest_prey`（weak_prey） | `team_discovered[我]` | **200709** | **282512** | 24.45／28.88 |
| `_max_threat`（threat） | `team_discovered[我]` | **200709** | **282512** | 24.45／28.88 |
| scout 迴圈（home_food） | ★`state.teams`（**不同母體**） | 49810 | 57833 | 6.07／5.91 |

⇒ ★**前三段逐字相同** ⇒ **同一個集合，一次 `gather` 裡走三趟**
⇒ 照你預先聲明的分岔：**真正的頭是「掃描本身」**，形狀 ＝ **掃一次、多段共用**
（★輸入相同 ⇒ 輸出相同 ⇒ **等價是構造保證，不需要證明上界**）。
★★**而 `home_food` 不在這一組**（它掃 `state.teams`）—— **不要把它一起併進去**。

# 二、★★★而我的儀器差點給你一個【錯的答案】（這一格請你看）

```
第一版：計數器是【全域】的
  ⇒ `_find_weakest_prey` = 479154（≈2.4 倍）／`attack_scan` = `_max_threat` = 200709
  ⇒ 床印：「★前三段的圈數是否逐字相同：否 ⇒ 母體不同或有提前跳出」
修法：`DecisionContext._in_gather` 旗標（進入設 true、【唯一】的 return 前設 false），
      所有樁改成 `Probe.enabled and _in_gather`
  ⇒ 三段當場對齊：200709／200709／200709
```
⇒ ★**差額是 `gather` 以外的呼叫端**（`_find_weakest_prey` 別處也有人叫）。
⇒ ★★**那個錯誤答案的方向最糟**：它會讓你走回「母體各不相同 ⇒ 回原表 ⇒ 剪枝」，
而**剪枝需要證明上界**，也就是**一張更大、更容易做錯的票**。
⇒ ★★★**教訓不是「我不小心」**：**把一個全域計數器除以一個局部母體（每次 gather）——
那個除法在形狀上就不成立**，而它印出來是一個**很像答案的數**。

# 三、順帶量到的第二層重複（★不是我要的結論，是數字自己冒出來的）

```
一次 gather 內：三段合計 73.36／86.63 個元素訪問
                而 BeliefSystem.best_estimate 被呼叫 492.28／586.50 次
⇒ ★每個元素訪問對應約 6.7 次 belief 查詢（兩個 seed：6.71／6.77）
```
★**我不下「所以要快取 belief」的結論** —— 那是設計格，而且我今天已經證明過
「少算一次」這種修法會踩到別的通道。★★**我只報這個比值，它是「掃一次多段共用」之外的第二個候選。**

# 四、我沒有做的事

★**我沒有動任何行為**：production 只有 Probe 樁 ＋ 一個 `_in_gather` 旗標（`Probe.enabled` 關閉時零成本）。
★★**形狀（掃一次多段共用）要怎麼落地，等你 §2 的 spec** —— 而照你 `ORDER` 那封，
**我接下來做的是【②位置情報有效期 Slice 1】**，剪枝修法排第三。
