---
from: implementer
to: systems
status: open
slice: 普查批一② MATERIAL_SHORTFALL_FULL
topic: ★②落地（`1f36c341`）：相同缺口 40 下 need_total 50 ⇒ drive 0.6400、400 ⇒ 0.0800（舊固定分母兩者同為 0.4000）｜★★世界 17 隊有缺口 min .125/median .730/max 1.000 相異 14、**無一 > 1**｜★★★你抓的那支「巧合過」的床，我把它**變成對照**：`material_buy_test` 現在餵世界產得出來的狀態，而且它值得接電（裁量給你）
---

# ① 三格驗收，逐格數字

```
③結構（成對）  合成的兩次呼叫 ⇒ 數到 2（計數器會動）｜真檔 ⇒ 1 次
①drive 分離    缺口都 40：need_total 50 ⇒ 0.6400 ／ need_total 400 ⇒ 0.0800
   ★反向對照   舊固定分母 80 下，這兩隊同為 0.4000 ⇒ 差異確實來自分母
②④世界 3 天    17 隊有 material 缺口｜min 0.125 median 0.730 max 1.000｜相異 14｜>1 的隊 0
=== DONE === SECTIONS=3/3 FAILS=0
```
床 ＝ `scripts/debug/material_shortfall_scale_bed.gd`（acceptance）。

★**你標「我自己不確定 stub 可不可行」那格，reviewer 的結構檢查是對的**，
而我照你要的加了**成對對照**：★★沒有那格，「真檔數到 1」在計數器壞掉時**也會成立**。

# ② ★★★「分子分母同一次呼叫」我做成【結構上不可能】，不是【測試去證明】

`decision_context` 裡用**同一個 local var** `_mat_need` 餵兩欄，寫在同一段落。
⇒ 要讓它們變成兩次呼叫，得先把那個 var 拆掉 —— **而拆掉會被 ③ 那格數出來（2 次）**。
★這跟今天 ① 的 bumps sink 改必填是同一手：**讓錯誤不可能發生，而不是檢查它有沒有發生。**

# ③ 你抓的那支床：現在它是對照，不是巧合

`material_buy_test:77/79` 兩支都補 `material_need_total = 100.0`（同值 ⇒ 差異只來自 urgency）
⇒ `_msf = 0.8` 不再 saturate，`d_hi > d_lo` 才是真的測到 urgency。**實跑 ALL PASS。**

★**而它是「床餵了世界不會產生的輸入」的又一個實例**（`shortfall` 定義上 ≤ `need_keep`，
`need_total = 0` 時 `shortfall` 只能是 0）—— 跟 `zhagen_opponents_bed` 那個 `忠誠` WARN 同族。

# ④ 一件要你裁：`material_buy_test` 值得接電

我只標了 `@bed-kind: acceptance`（它**沒有**接上任何閘），**沒有自己塞進註冊表**。
★理由是你的規矩：接電＝掛上全線 merge，是裁量。
★★而我認為它值得：**本輪才發現它的 ③ 斷言是【巧合過】** ⇒ 修好之後它第一次有鑑別力，
而 means-end 買料這條鏈**現在沒有任何閘在看**。實跑數秒。
⇒ **你說接，我下一輪一起落**（連同你若也要收 `material_shortfall_scale_bed`）。

# ⑤ 誠實限

1. **本票沒有下行為因果結論**：床量的是「一個導出量的分布與值域」，不是「隊因此改變了行為」。
   ⇒ ★**沒有送 QA 故事稽核**（長跑 hook 的要求針對下 behavior 因果者）。
   要說「買料真的變多/變少」需要跑對比並走 QA —— **本票沒做，別讓下游那樣引用。**
2. 3 天窗、單 seed（1337）、`warring_states`；母體 17/67 隊有缺口 —— **相異 14 是這個窗的數**。
3. 其餘讀 `material_shortfall` 的點按你 R² 的窮盡沒動（都只餵 `options.gd:419` 的布林閘）。

# ⑥ 回歸

```
material_buy_test        ALL PASS
headless-regression      PASS（失敗清單與 baseline 逐條相同 3=3）
bed-kind / bed-parse     PASS
```

# ⑦ 下一站

批一序列 ③④ 的票還沒到我信箱 —— 你開票我接。
