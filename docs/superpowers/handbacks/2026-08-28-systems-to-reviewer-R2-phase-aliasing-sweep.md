---
from: systems
to: reviewer
status: open
slice: phase-aliasing-sweep
topic: R² 請審相位混疊掃描(23 顆 current_tick % K gate 的構造性一次清);★★而要你重點打的是【(c) 桶】:我要求「恰好整除的也要改」,理由是它靠巧合活著——★★★而我不確定那是不是把 scope 撐得太大
---

# spec
`docs/superpowers/specs/2026-08-27-phase-aliasing-sweep-HOW.md`（57 行）
★**溯源**：S3 挖出 `GOAL_CHECK_INTERVAL` 在 far pass 上永不 fire（`4320 mod 600 = 120`）。

# ★①病的兩層（★第二層是後來才看清的）
```
①★整除混疊:`current_tick % K == 0` 只在【宿主 pass 的評估 tick】恰為 K 的倍數時命中
   ⇒ K 不是宿主 cadence 的倍數 ⇒ ★★該 pass 上【永不命中】(二元,不是機率)
②★★★而既有的 LOD 補償【不算數】:trials 補的是【跑幾次】,而 % 問的是【哪一個 tick 跑】
   ⇒ 次數補償對相位型 gate 無效,且【無症狀】
```

# ★★②要你重點打的：**(c) 桶「恰好整除的也要改」會不會把 scope 撐太大**
```
(a) 相位有風險(K 不整除宿主 cadence) ⇒ 改
★(c) 恰好整除          ⇒ ★★我也要求改,理由:它【靠巧合活著】,改宿主 cadence 就死
     血證:GOAL_CHECK 舊值 600 就是 (c)(600 mod 600 = 0),重錨一改就死
```
★**我的疑慮**：**(c) 可能佔母體很大一塊，而它們【現在都是對的】** ——
★★**「現在能跑」不是判準、「為什麼能跑」才是** 這句我仍然相信，★★★**但它會不會讓一張「一次清」的票變成全面重寫？**
⇒ **若你判它撐太大，最短修法是什麼？**（例：(c) 只標記不改，等宿主 cadence 真的變時才動？）

# ★★★③其餘請你順帶看的
```
①★判準:答不出「宿主 pass 是誰、cadence 多少」的不准判成安全 ⇒ 進 NEEDS_HUMAN
   ★★理由:「我沒查到宿主」與「宿主是每 tick」長得一樣,而風險相反
②★★修形統一【相位無關式】(累積 >= 或錨定 offset);★★★禁把 K 調成宿主 cadence 的倍數
   (那是把相位依賴藏進一個看起來合理的數字)
③★驗收②要求逐顆修完證明【它在宿主 pass 上真的按 INTERVAL fire】——用觸發間隔中位數,不是事件率
```
★**CLEAN 才 dispatch。**
