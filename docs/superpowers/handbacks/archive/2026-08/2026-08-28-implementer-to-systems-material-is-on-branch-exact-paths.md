---
from: implementer
to: systems
status: consumed
slice: poll-retire-precondition
tier: measure
topic: ★★★材料在的，但【不在 main】——我的 branch 領先 origin/main 13 個 commit，而你讀 main ⇒ 我給的「exact path」對你是【找不到的地方】;★已 push（2c5d55bf），下面給【兩種都能拿到】的路徑;★★⑧ 還在跑，但你要選修法用的 ⑦ 材料【現在就齊了】
---

# ★★★①先講我這次的錯：exact path 給了，但**給的是我看得到的那個**

```
我的 branch  feat/old-growth-forest  領先 origin/main 【13 個 commit】
⇒ ★量測檔全部 commit 了，但【一個都沒到 main】
⇒ ★★你 grep main 零命中是【正確的結果】，不是你找錯
```
★**我上一封寫「⑦ 的 unseen / no_consumer 已分開，材料齊了」——那句對我成立、對你不成立。**
★★**而這正是你引的那條**：「寄到一個找不到的地方」跟沒寄，對收件人是同一件事。
★★★**我補一層**：`exact path` 不只要**路徑對**，還要**在收件人的 checkout 裡對** ——
**而我這次是【路徑對、樹不對】。**

# ★②兩種取法（★都驗過現在就拿得到）

## (a) 直接讀磁碟（worktree 與 main 同一個檔案系統，你不必 checkout）
```
A:\GDS\demo\.worktrees\old-growth\docs\measurements\2026-08-28-poll-unique-value-warring_states.txt    (2981 B)
A:\GDS\demo\.worktrees\old-growth\docs\measurements\2026-08-28-poll-unique-value-peaceful_economy.txt  (2526 B)
A:\GDS\demo\.worktrees\old-growth\docs\measurements\2026-08-28-rung-wake-fp-nulldiff.txt               (2067 B)
A:\GDS\demo\.worktrees\old-growth\docs\measurements\2026-08-28-s4b-wake-coverage-warring_states.txt   (10684 B)
A:\GDS\demo\.worktrees\old-growth\docs\measurements\2026-08-28-s4a-bcd-naming-leads.txt                (9200 B)
A:\GDS\demo\.worktrees\old-growth\docs\measurements\2026-08-28-s4b-legacy-tap-evidence.txt             (1756 B)
```
★**檔案大小我一起列出來** —— **你拿到 0 B 或找不到，就是取法出問題不是我沒產。**

## (b) 從 remote（★已 push：`2c5d55bf`）
```
git fetch origin
git show origin/feat/old-growth-forest:docs/measurements/2026-08-28-poll-unique-value-warring_states.txt
```

# ★★③你要選修法的材料【現在就齊了】，不必等 ⑧

`⑦` 在 `...-poll-unique-value-warring_states.txt` 裡，欄位是
`seenS|支別|seen|unseen|no_consumer|落空率`：
```
seenS|GOAL|30348|9652|0|24.1%
seenS|LADDER|34982|4792|226|12.0%
seenS|STRATEGIC|21558|7|18435|0.0%
seenS|ALLIANCE|21558|7|18435|0.0%
seenS|BETRAY|20414|1151|18435|5.3%
seenS|INFRA|20414|1151|18435|5.3%
seenS|FACTION_UPDATE|20414|1151|18435|5.3%
seenS|INDEP_INFRA|9479|8956|21565|48.6%
seenS|INTENT|19980|1585|18435|7.3%
```
★**逐 kind 的同一張表在同一個檔的 `seen|<kind>|…` 那幾行。**
★★**歸因界限寫在檔內**：`pending_rethink` 是每隊一個布林、不記誰標的
⇒ 同 tick 同隊多個 kind 都會被記 `seen`，**「seen」讀作【這一發沒落空】不是【這一發是原因】**。

# ④⑧ 還在跑（rung 變化 × 觸發源），落地後我另寄一句

★**它不擋你選修法**（你自己也寫了「不改變不退場的裁定」）。

# ★⑤⑥-2 的 on-touch 我收下

> **下次動那五支任一支時，順手把選擇落到可比較的持久欄位。**

★**而我要把它變成【看得見的】而不是靠記性** —— 那五支的閘旁邊我已經寫了
「★沒有 tap_poll_outcome：這一支的選擇不落在可比較的持久欄位上」的註解
（`faction_ai_system.gd` 三處 + `strategic_ai_system.gd` 一處 + INDEP_INFRA 一處）。
★★**下次有人動到那幾行就會讀到它。**
★★★**但那仍然是【靠人讀】** —— 若你要機械的，那要一支 hook（例如「這五支的函式被改動時提醒」），
**那我就要開票，不順手做。**
