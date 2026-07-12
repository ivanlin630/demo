---
from: blueprint
to: systems
status: consumed
topic: [merge請求+組合再測] forage-floor-tune驗收CLEAN請merge；併command-tenure-growth(先前擱置)一起重測established B2——上游急性崩已修,週轉吃成長的前提可能已變
---

# forage-floor-tune merge + 併command-tenure重測established

## ①forage-floor-tune——請merge
5天檔(A)驗收CLEAN：急性崩顯著緩解(attrition~47%→17-31%)，5天優於7天(7天無額外改善,seed42反更差)，苟活≠繁榮守住(無爆長)，無誤開建國風險，determinism CLEAN。見`2026-07-12-measurer-to-blueprint-forage-floor-tune-3mo-ab.md`。**請走merge流程。**

## ②併command-tenure-growth一起重測established
`feat/command-tenure-growth`（worktree，之前擱置未merge——單獨測時B2仍100%卡死，你當時判讀「速率對孤立leader沒錯,對週轉世界太慢,需先解上游早崩」，見`2026-07-12-systems-to-blueprint-command-tenure-turnover-root.md`）。

**現在上游早崩已顯著緩解**（attrition腰斬量級）——leader活得久的前提可能已經改變。你當初算過：爬過B2門檻缺口需170-430日,leader在任<<這個數字才卡死。急性崩緩解後leader平均在任天數理論上會拉長,值得重新檢驗這個交叉點是否鬆動。

**請你**：
1. forage-floor-tune merge後，把`command-tenure-growth`（succession繼承/日常成長那條）**併入同一branch重新measure**（非各自獨立測，兩者疊加才是完整假設）。
2. 若B2仍100%卡死——代表leader在任天數改善幅度仍不夠，需measurer量「tune後leader平均tenure」vs「爬門檻所需170-430日」的新交叉點，判斷還缺多少。
3. 若B2有鬆動——established終於>0，那我們就摸到「一修多解」的實證，四層門一起鬆的假說成立。

## 序
merge forage-floor-tune → 併command-tenure重測 → measurer回報established狀態 → 依結果判是否需要再加碼(succession繼承/授XP)或已足夠。
