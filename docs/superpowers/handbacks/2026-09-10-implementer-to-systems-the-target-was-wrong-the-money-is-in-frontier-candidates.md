---
from: implementer
to: systems
status: open
slice: 效能線 ｜ 切開「評一個 option」
topic: ★★★**目標的前提不成立**：評一個 option 實測 **31.9 us**（98.4% 落在 <100us 桶，最大 <5 ms）—— 與「14.6 ms/option」**差三個數量級**｜★★所以我把 `rank_scored_ctx` 再切四段找錢：**`GoalResolver.frontier_candidates` ＝ leader 225.5 ms/call ＝ 該呼叫端的 99.7%**；option 迴圈 0.56 ms（0.25%）｜★term 側是**攤平**（最貴的 `camp_drive` 佔 21%，整層總共 0.09 s ＝ `rank_scored_ctx` 的 **0.06%**）⇒ 你給的兩個岔路（集中／攤平）**都不是**，因為 term 層根本不是標的
---

★落地：`docs/measurements/2026-09-10-option-term-cost.txt`（commit `b93911280`，main）
  ＋ `scripts/debug/option_term_cost_bed.gd`

# ① 你要的兩個數字（照做了，而第一個就把前提打掉）

```
①逐 option：**31.9 us/次**；分佈（直方圖桶，★不是平均）：
   lt100us **4478（98.4%）**／lt1ms 73（1.6%）／lt5ms 1／lt20ms 0／lt100ms 0／ge100ms 0
   ⇒ ★★★**沒有任何一個 option 的評分超過 5 ms**。
   ⇒ 母體：`rank_scored_ctx` 呼叫 590 次／逐 option 樣本 4552 個（★母體地板：> 0）
②逐 term：**攤平** —— `camp_drive` 40.6 us/次（佔 21.1%）、`settle_fit` 15.7（11.2%）、
   `intent_fit` 14.7（10.7%）…★而整個 term 層總共 **0.09 s**。
```

# ② ★★那 14.6 ms 是怎麼來的：它是【真的】，但它不是 option 的成本

```
上一輪我報的是 `score` 段（＝整個 `rank_scored_ctx`）÷ options 數 ＝ 14.59 ms/option。
★那個除法**成立**，而它預設了一件沒被驗證的事：**`rank_scored_ctx` 的時間都花在評 option 上**。
⇒ ★★實測：**不是**。四段（每次呼叫平均 us）：
   呼叫端      applicable   option迴圈     frontier         sort   options/次
   leader           144.4        557.4   **225472.6**        52.8       9.78
   member           139.1        456.9      28937.0         24.9       7.37
   solo_body        143.2        457.9     172626.1         37.7       7.13
   threat           127.4        289.1      68173.1         18.8       5.47
   subteam          154.3        231.0      17030.5         14.7       4.67
⇒ ★★★**`GoalResolver.frontier_candidates` ＝ leader 的 99.7%**。
⇒ 而「14.6 ms/option」這個說法會把人送去改 term ——★而 term 層改到 0 也只回收 0.06%。
```

# ③ ★所以我要把這個形態講清楚（它今天已經是第二次）

```
★上一次：`loop2.solo_cheap` 名字說便宜、裝著 642 s ⇒ **命名騙人，守恆抓到**。
★★這一次：**除法騙人** —— `總時 ÷ 次數` 得到的「每次成本」，
  ★★★它的意思完全取決於【那個總時裡到底裝了什麼】，而除法本身**不會告訴你**。
⇒ 而抓到它的方法與上次同族：**再切一層，看新的段是否加得回舊的總數**
  （這次：557 us ＋ 144 ＋ 52 ＋ 225473 ≈ 226 ms ≈ 舊的 `score` 段）。
⇒ ★所以我建議下一張票的驗收多一格（★不是提修法，是提**驗收形狀**）：
  **任何「每次 X」的數字，要附上【它的分母涵蓋了哪些段】** —— 否則它會被拿去指錯地方。
```

# ④ 驗收

```
①根守恆：仍綠（本輪沒有改任何 `PHASE_PARENT`；床 `phase_root_conservation_bed` 3/3 是本 commit 前跑的）
②母體地板：`rank_scored_ctx` 590 次／option 樣本 4552 個，**且都印出來了**
③分佈：直方圖桶（★不用 `bump_sample` —— 它是 first-N，長跑會被開局的便宜呼叫佔滿）
④fp：`rank_calls_bed` 600t 同窗同 seed ＝ `34110029e24ea79da457a0212388b796`，**與加儀器前逐字相同**；零 RNG
⑤誠實限：3000 tick（2.1 遊戲天）／單一 config／**Probe=ON**（全 sim 開銷 6000t +13.9%，且隨規模放大）
```

# ⑤ 我沒做

```
★沒有碰 `GoalResolver.frontier_candidates` 一行（照「看到最大的那一格先別動手」）。
★★也沒有再往它裡面切 —— ★★★那是下一張票，而它現在有一個【被三段守恆夾住的】主詞：
  `frontier` 段 225.5 ms/call，而它旁邊三段加起來 0.75 ms。
```
