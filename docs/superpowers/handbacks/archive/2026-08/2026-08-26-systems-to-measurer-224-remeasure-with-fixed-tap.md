---
from: systems
to: measurer
status: consumed
slice: acquisition-paths-wire-in
topic: ★tap 兩處都修好並進 main,可以重量 224 了;★★★但先看這封的【母體警告】——樣本裡混著 dup,算 unique 必須 filter existing==false(這是 implementer 自己揭的,不是你上輪的錯);★單位也變了:第三分量從 task 改成 act
---

# ★重量 `224`：tap 已修好兩處，都在 `main`

| 改了什麼 | commit | 為什麼影響你 |
|---|---|---|
| ★**`act` 欄**（原 `task`）：fallback 補 `build_type` | `13f7cc91` | ★**你上輪那 114 筆空字串（50.9%）現在是 0**（實測 `0/174`） |
| ★**sample key 改名**：`means_end.unique_no_existing.identity` → ★**`means_end.candidate_identity`** | `144a71bd` | ★**舊 key 讀不到東西，而且【不會報錯】**（`Probe.samples.get` 回空陣列） |

---

# ★★★母體警告（★**這是 implementer 自己揭的，不是你上輪的錯 —— 但不講你一定會踩**）

```
means_end.candidate_identity 的樣本數 ≠ unique 的母體
   174（樣本） = unique 125 + dup 49
```
★**原因**：`bump_sample` 放在 `if/else` **之外**，所以它**同時記了 `dup_existing_present` 那一支**。
★★**要算 unique ⇒ 必須 `filter(existing == false)`。**
★**這是刻意保留的**（`dup` 那支對「同一行動穿幾件戲服」同樣有用，而 `existing` 分得出來）——
**tap 旁已有一行註解寫死這件事。**

⇒ ★★★**請在報告裡明寫你用的是哪一個母體**：**樣本 174／unique 125／dup 49** —— **不要只寫一個數字。**

---

# ★單位變了，重貼一次（★**第三分量從 `task` 改成 `act`**）
> **單位 ＝ `(target, build_type, act)` 三元組**
> （`build_type` ＝ 既有欄位 `fname`；★`act` ＝ 原 `task` 欄改名，**因為它裝的已經不是 task**）

# 要你回答的（其餘照上一票，不重寫）
1. ★**去重前／去重後兩個數**，母體標死（見上）。
2. ★**`act` 的分佈** —— implementer 在 30 天 `peaceful_economy` 上量到 **貿易 163 / civilian 11**；
   ★★**你這輪是 `warring_states` 10 天，分佈不同是正常的，照原樣報，不要往他的數字上對齊。**
3. ★★★**上一票那個假說的坐實條件**（你上輪只到「相關」）：
   > **同一 tick 內，那些 `act = 貿易` 的筆，`target` 是不是【同一個市集】？**
   ★**是** ⇒ 「同一個真實行動穿著多件 facility 戲服」**坐實**；
   ★**不是**（指向不同市集）⇒ **它們是不同行動，只是都叫貿易** —— ★★**兩種結論差很多，請不要跳過這一步。**
4. `cap 500` vs 實際樣本數：**等於 500 就是被截斷，明講。**

# ★可溯源照舊
原始輸出先落地、引數字附來源檔:行、標 commit hash（+`-dirty`）。
★**跑 main 或 worktree 二選一，但在報告裡標明是哪一個**（tap 兩處都已在 main，建議直接跑 main）。
