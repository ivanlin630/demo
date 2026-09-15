---
from: implementer
to: systems
status: consumed
slice: 攻擊幣別 final ｜ 你的 vision 斷言**我覆核過，成立** ＋ **spec 改之前請一併處理「桶 0」**
topic: ★**覆核成立**：`vision_system.gd:150` `snap["population_est"]` **無條件寫**；`:173` `if dist <= 1:` … `:184` `snap["resource_scale"] = scale` ⇒ **遠距 belief 天生沒有 `resource_scale`**｜★★**而 `dist <= 1` ＝【貼身或同格】** —— 比「遠距」更嚴：**不是同一格或隔壁，就沒有資產情報**｜★★★**而我發現同一段還有第三種形狀你 spec 要一起收**：`:183` `scale = clampi(scale + randi_range(-1,1), 0, 3)` ⇒ **貼身看過、卻可能得到 `resource_scale = 0`**，而 `bucket_floor(0) = 0` ⇒ **它與「沒有資產欄」在數值上又變成同一個東西**｜★**我照裁不動 code、不動 fixture、不 merge**
---

# ① 覆核你的斷言（★我沒有只信，我開檔看了）

```gdscript
vision_system.gd:150   snap["population_est"] = pop_est          ← ★無條件
vision_system.gd:173   if dist <= 1:
vision_system.gd:184       snap["resource_scale"] = scale        ← ★只有貼身才寫
```
⇒ ★**成立**。而且**比你寫的更嚴**：`dist <= 1` ＝ **同格或相鄰一格**
⇒ ★★**「有人口、無資產」不只是「遠距」的形狀，它是【絕大多數】belief 的形狀** ——
**只有貼到臉上那一刻才會拿到桶號。**

★★★**所以那 6 條紅比我們原本以為的更重要**：
**它們不是「fixture 描述了一個少見的情況」，是「fixture 描述了預設情況」。**

# ② ★★★而同一段還有第三種形狀（★請在改 spec 時一起收）

```gdscript
vision_system.gd:183   scale = clampi(scale + randi_range(-1, 1), 0, 3)
```
⇒ ★**貼身看過、而且對方確實有東西，仍可能得到 `resource_scale = 0`**（噪音 −1）。
⇒ ★★**而 `bucket_floor(0) = 0`** ⇒ **它的 richness ＝ 0**
⇒ ★★★**「貼身看到桶 0」與「根本沒有資產欄」在【值】上又變成同一個東西** ——
**而這正是本票一路在拆的那個病：兩種不同的世界狀態被壓成同一個數。**

**三種形狀要分清楚（我列，你裁）**：

| 形狀 | 意思 | 現況的數 | 該有的處置？ |
|---|---|---|---|
| (a) 沒有 claim | **真・零情報** | 排除 | ★**結構排除**（你已裁，不變） |
| (b) 有 claim、無資產欄 | **不知道它多肥**（預設形狀） | 目前被誤判成 (a) | ★**你要改的那一條**：不排除、richness 缺席 |
| (c) 有資產欄、桶 ＝ 0 | **看過了，它很窮**（或被噪音壓到 0） | richness ＝ 0 | ❓**與 (b) 的數值相同 ⇒ 分不開** |

★**(b) 與 (c) 的差別是真的**：
**(b) 是「我不知道」**、**(c) 是「我知道，而且它很窮」** ——
★★**在【要不要去偵查】這一題上，兩者的答案相反**：
(b) **值得去看**；(c) **看過了，不必再看**。
⇒ ★★★**而我現在的 `pick_recon_target` 用的是 `belief_has_priced_items()`** ——
**它把 (c) 也當成「還沒看過」** ⇒ **會派人去重看一個已知的窮鄰居。**
★**這一條我沒有量過**（10 天窗沒有分這兩桶）⇒ **標【待驗】，不宣稱。**

# ③ 我照裁停在這裡

- ★**沒有動 code**、**沒有動 `headless_test.gd`**、**沒有 merge**。
- 樹 `dbf6f0e13` 乾淨。
- ⏳ 等：**你改 spec → R² CLEAN → 我改 code → 再跑 55 支**。
- ⏳ 另外兩支（`bed-kind` 的 `probe_stats.gd` 無 kind、`defer-open` 的 `met_check` 比條件文字寬）
  **也還等你**。

# ④ 一句我要留下的

★**這一輪三次，錯的都是【上游的前提】而不是【下游的實作】**：
1. `.by.` 有主詞，但不是我要的那一個
2. `confident_enough` 有人格參數，但軸是可信度不是粒度
3. `_belief_richness` 的 `return 0.0` 有兩個來源，而 spec 只想到一個

⇒ ★★**三次都是「名字看起來對」而「行為不是那樣」** ——
★★★**而三次都是靠【跑一次、看實際輸出】抓到的，沒有一次是靠讀 code 想出來的。**
