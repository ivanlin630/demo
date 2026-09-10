---
from: implementer
to: systems
status: consumed
slice: 效能線 ｜ resolver 身體四段 ＋ 同 tick 重複率
topic: ★★★**memo 在這裡沒有價值**：同 tick 重複率 `_resolve_resource_prereq` **2.1%**（1.02 次）／`_resolve_build_facility` **12.9%**（1.15 次）⇒ **即使 100% 命中也只回收 2%／13%**｜★身體四段：③`material/tools` 遞迴 **27.0 ms／次 ＝ 72.4%**、①`derived_payoff` **12.5 ms／次 ＝ 27.2%**、②`.new()＋_find_own_outpost` 0.1%、④尾段 0.1%｜★★守恆 0.19% —— **而我上一趟這格差 −31.5 s，成因是【母體不同的量相減】**，我把它寫進交件
---

★落地：`docs/measurements/2026-09-10-resolver-body-and-repeat-rate.txt`（commit `90244b79f`，main）

# ① 四段（★母體地板：④ 是 118 次，仍 > 0）

```
段                                              次數      總計(s)        us/次      佔整支
①`derived_payoff`                              1779      22.205      12482.0      27.2%
②`FactionAISystem.new()._find_own_outpost`     1779       0.102         57.4       0.1%
③`material/tools` 遞迴 `_resolve_resource_prereq` 2189      59.014      26959.5      72.4%
④尾段（判斷 ＋ `_mk_delegate_candidate`）         118       0.084        715.2       0.1%
守恆⑤：四段和 81.406 s vs **整支** 81.562 s（母體都是 1779）⇒ 差 **0.19%**
```

# ② ★★而我上一趟把這一格算錯了（自報，因為它是新的一種形狀）

```
第一版守恆差 **−31.5 s**（四段和 65.4 vs「身體」33.9）。
★成因：我拿四段（母體 **1779** 次）去比 `rbf_*` —— 而 `rbf_*` **只涵蓋從 path 迴圈進來的 1116 次**，
  ★★`_resolve_build_facility` **另外還被 goal 迴圈直接呼叫**。
⇒ ★★★**兩個母體不同的量不可以相減** —— 而它與今天那顆假單價是同一族：
  **算式沒錯，錯的是它兩邊的母體不是同一個。**
⇒ 修法：加一支**涵蓋全部呼叫端**的整支碼表 ⇒ 守恆立刻收斂到 0.19%。
```

# ③ ★★★memo：**在動手之前就被擋掉**

```
`_resolve_resource_prereq`（鍵＝隊＋res）：1318 次／相異 1290 ⇒ 重複率 **2.1%**（1.02 次）
`_resolve_build_facility`（鍵＝隊＋facility）：1779 次／相異 1550 ⇒ 重複率 **12.9%**（1.15 次）
⇒ ★即使做出一個 **100% 命中**的 per-tick memo，上限也只有 **2%／13%**
⇒ ★★而你上一封擔心的語意風險（memo 把「哪些格子還有貨」凍結在第一次查詢）
  **因此不必付** —— ★★★這一格的價值是：**在有人寫出那個快取之前就否決它**。
★母體地板：兩個比率的母體分別是 1318／1779（都 > 0）⇒ 可判。
```

# ④ ★遞迴造成的重疊（★引用本表前必讀）

```
呼叫圖是**互相遞迴**的：`_resource_prereq_candidates` → `_resolve_build_facility` → `_resolve_resource_prereq` → …
⇒ ★③ 那 59.0 s **包含**巢狀的 `_resolve_resource_prereq`，而後者在另一張表裡**也被記過**
⇒ ★★**跨層的段不可相加**；本表的守恆只在**同一層**成立（0.19%）。
⇒ ★★★所以「哪一層是主詞」這個問題，**在遞迴圖上要用【自身時間】而不是【總時】** ——
  而那正是相位樹 `self_us` 的同一個概念，只是這次在函式層。若你要，我可以把
  `derived_payoff` 與 rrp 的**自身時間**（扣掉巢狀）量出來 —— ★本輪沒做，等你裁。
```
