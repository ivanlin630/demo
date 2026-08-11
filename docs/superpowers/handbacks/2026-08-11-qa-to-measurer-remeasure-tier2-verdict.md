---
from: qa
to: measurer
status: consumed
topic: "★re-measure tier2 seed8181翻轉verdict=premise不成立(day60-90之間dispersed沒有任何新事件、population全平)——讀team_daily(0-3)day1-90逐日:team0 pop=5全程(day1後)不變、team1 pop=6→day37跳10(Team2併入)後恆10到day90不變、team2(day37起gone_or_merged)、team3 pop=4全程不變——這是我今天稍早iii④那輪已完整記錄的同一個Team2併入Team1故事(day24 unrest18/day25脫離/day37併入),merge事件在day37、遠早於day60,day37之後到day90整整53天population逐位元零變化,沒有第二波famine/新threat/anon耗盡再搬空——你問的『day60後到day90之間發生什麼讓dispersed落後』這個前提在population數據上不成立,這段窗口內DISPERSED的世界狀態是靜止的。★這代表兩種可能之一:(a)你引用的『2mo attrition=8.3%/3mo=20.83%』這兩個數字不是同一條run在day60/day90分別取樣算出來的、是兩次獨立跑法(不同config/不同attrition計算口徑)算出來的,不能直接拿來說『這段期間內發生了什麼』——時間軸上根本沒有『之間』這件事;(b)attrition_pct的計算方式本身不是單純population-based(可能有別的定義,例如某個中途最低點snapshot或別的統計口徑),需要你說明公式讓我對得上population數據。建議先確認這兩個數字是否來自同一持續run的兩個checkpoint,還是兩次分開的模擬——determinism二跑驗的是『同一組config重跑兩次結果一樣』,不等於『2mo/3mo兩個不同長度的run用的是同一套attrition口徑』,這是兩件不同的事,值得先排除再往下追concentrated對照跟seed1337/42背景這幾條(那些我還沒查,等這條核心疑點先解決)"
---

# ★re-measure tier2 seed8181 翻轉 verdict — premise 不成立

裁：**「day60~90 之間發生了什麼讓 dispersed 落後」這個前提，在 population 數據上不成立——這段窗口裡 DISPERSED 世界完全靜止，沒有任何新事件**。

## 逐日核對 team_daily（0-3），day1-90 全程

```
team0: pop=5 全程不變(day2起)
team1: pop=6 → day37 跳到 10（Team2 併入） → 恆 10 到 day90，全程不再變
team2: day37 起 note=gone_or_merged（day37 已完全併入 team1）
team3: pop=4 全程不變
```

這正是我今天稍早「iii④」那輪已經完整記錄的**同一個 Team2 併入 Team1 故事**（day24 unrest=18 → day25 defect fire 脫離 → day36 unrest=308 → **day37 併入 Team1**）。**Merge 事件發生在 day37，遠早於 day60**。day37 之後到 day90，整整 **53 天population 逐日零變化**——沒有第二波 famine、沒有新 threat、沒有 anon 池再度耗盡搬空——**你問的「day60 後到 day90 之間發生了什麼」，這個時間窗口內 DISPERSED 的世界狀態是靜止的，沒有東西可以稽核**。

## 這代表什麼

兩種可能之一，我沒辦法從 specimen 本身判斷是哪一種，需要你澄清：

**(a) 兩個數字（2mo=8.3%/3mo=20.83%）不是同一條 run 在 day60/day90 分別取樣算出來的**，是兩次獨立跑法（可能不同 config、可能不同 attrition 計算口徑）算出來的——那「這段期間內發生了什麼」這個問題本身問錯了方向，時間軸上根本沒有連續的「之間」可言，是在比較兩個不同實驗，不是同一個故事的前後兩段。

**(b) `attrition_pct` 的算法本身不是單純 population-based**（可能是某個中途最低點 snapshot、或別的統計口徑），需要你說明公式讓我對得上 population 數據——如果公式跟我讀到的 population 曲線對不上，那是公式定義的問題，不是世界模擬本身有隱藏事件。

## 建議

先確認 2mo/3mo 這兩個數字是否來自**同一個持續 run 的兩個 checkpoint**，還是**兩次分開的模擬**。你提到「determinism 二跑確認翻轉真實可重現」——但這驗的是「同一組 config 重跑兩次結果一樣」，**不等於**「2mo/3mo 兩個不同長度的 run 用的是同一套 attrition 計算口徑」，這是兩件不同的事。建議先排除這條，再往下追 concentrated 對照跟 seed1337/42 背景那幾條——那些我這輪還沒查，等這個核心疑點先解決，避免白工。

---
*QA 驗收官 · 2026-08-11*
