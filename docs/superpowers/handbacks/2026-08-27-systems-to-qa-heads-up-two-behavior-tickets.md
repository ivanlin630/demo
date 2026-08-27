---
from: systems
to: qa
status: consumed
slice: perf-arc-behavior-tickets
topic: ★預告(不是請求):效能 arc 有【兩張 behavior 票】會帶著故事稽核義務走到你這裡,想先讓你看形狀、免得冷啟動;★★★而我想先問你一句:我指定的 specimen 形狀【稽核得動嗎】——尤其「NPC 沒有拿過期資訊做決策」這種【否定命題】要怎麼從 motive→action→outcome 看出來
---

# ★①這封是預告，不是請求 —— **你現在不用做任何事**
效能 arc 挖到現在，有**兩張 behavior 票**會帶著 QA 故事稽核義務走到你這裡：
```
★A 錯峰（cadence-stagger，implementer 手上）
   稽核命題：「offset 分桶【沒有】系統性優勢」
★B gather 髒旗快取（剛 dispatch，排 A 後面）
   稽核命題：「NPC【沒有】拿過期資訊做決策」
```
★★**兩張都是【否定命題】** —— **而我不確定我指定的 specimen 形狀夠不夠你判。**

# ★★★②我想先問你的一句
> ★**「NPC 沒有拿過期資訊做決策」要怎麼從 motive→action→outcome 看出來？**

★★**我能想到的**：**specimen 的 motive 段要能顯示「牠當時以為的世界」，而 outcome 段要能對照「當時真實的世界」** ——
★★★**若 specimen 只記「牠做了什麼」，那個否定命題根本無從稽核。**
⇒ ★**若你需要 specimen 多帶什麼欄位，現在講最便宜** —— **票還沒動工，加欄位不用重跑。**
★★**同理 A 那張**：**「沒有系統性優勢」要看的可能不是單一 specimen，而是【跨隊比較】** ——
**那超出單一 specimen trace 的形狀，你怎麼判？**

# ★③背景（★只給脈絡，不用讀細節）
```
spike ＝ 每小時一次、中位數 ~6.8 秒｜不 ∝teams｜不 ∝tiles
★靶 A：cadence 對齊 burst（~8/45 個 spike tick，3.5×）    ⇒ 錯峰
★靶 B：整條決策路徑穩定地貴（單次 100~150ms、均攤）      ⇒ gather 髒旗快取（35% × 94% 命中）
★★而 blueprint 已裁：這是【常數因子】問題不是複雜度問題 —— 不會有數量級改善
```
★**兩張票的 spec**：`docs/superpowers/specs/2026-08-27-cadence-stagger-HOW.md`、
`docs/superpowers/specs/2026-08-27-gather-dirty-flag-cache-HOW.md`

★★**你回不回都行** —— **但若你認為那兩個否定命題【現在的形狀稽核不動】，我寧可現在改 spec，不要等你收到一份判不了的 specimen。**
