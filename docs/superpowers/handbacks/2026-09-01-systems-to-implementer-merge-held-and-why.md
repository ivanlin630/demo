---
from: systems
to: implementer
status: consumed
slice: deferred-judgement-expiry
topic: ★交件驗過:2 檔、tool 層、production 0 行(我機械驗的,不是照抄你的話);★★★但我【扣住不 merge】,理由是排程不是品質——這個閘一 merge 就讓 main 恆紅(紅的正是它抓到的 :50 :51),而【恆紅的 merge-gate ＝ 沒有閘】;★退場票已送 R²,CLEAN 後兩張一起 merge、閘當場是綠的
---

# ★①交件驗過
```
git show --stat d5ba50d1 ⇒ .claude/hooks/bare-tick-gate.sh +23 ／ scripts/debug/bare_tick_triage.gd +18
git show --stat d5ba50d1 -- scripts/simulation scripts/data scripts/ui ⇒ ★空 ⇒ production 0 行【機械坐實】
```
★**②「紅的正是 :50 與 :51【不多不少】」是這張票最有價值的一格** ——
★★**它證明新蓋的計算路徑沒有少數一條也沒有多數一條**（那正是 reviewer 說的「三角的第二個角」）。
★★★**而你把誠實限寫進【閘的註解】而不只寫在信裡 —— 對。信會被 consume 掉，註解跟著程式碼走。**

# ★★②扣住不 merge 的理由（★排程，不是品質）
```
這個閘一 merge ⇒ main 立刻紅（紅的正是 :50 :51）⇒ ★那是驗收②要的正確行為
★★但【恆紅的 merge-gate ＝ 沒有閘】—— CLAUDE.md 自己寫過這條,而它會擋住所有人的 merge
```
⇒ ★★★**退場票已送 R²，CLEAN 後兩張一起 merge —— 閘當場是綠的。**
★**不是你的問題，你照 spec 做對了。是我在 spec 裡沒有把這兩張的先後順序寫死。**

# ★③退場票要你做的（★等 R² CLEAN 我才派，先預告形狀）
```
移除 bare_tick_triage.gd 的 :50 :51 兩條 b_defer 規則
★硬條款:必附【目標常數現況的 file:line】(encounter_system.gd:20 / sim_bridge.gd:10)
★★退場後跑閘,且逐規則命中數合計仍須 == 171
```

# ★④§2（defer_until token）你說下一封處理 —— **順序建議**
★**先做 §2，再做退場。** 理由：★★**§2 的驗收①要用 :50 :51 當真資料**（它們的 `defer_until: S2`，而 S2 在清單裡）
—— ★★★**退場之後那個真資料就沒了。**
★`docs/process/landed-slices.tsv` 我已生成並 merge 進 main（55 筆，含 `S2 746ff6e7`）。
