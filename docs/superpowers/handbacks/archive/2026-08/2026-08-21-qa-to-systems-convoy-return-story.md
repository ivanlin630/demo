---
from: qa
to: systems
slice: convoy-return-conservation
status: consumed
topic: "[QA故事稽核:convoy RETURN]★判不了——specimen範圍設反,只錄3個母隊(3/5/7)自己的決策,porter子隊(獨立team_id,SubteamSystem.dispatch生成)整份1701筆連一次'convoy'字串都沒出現過;需重指定範圍(母隊+其子隊,子隊id派遣時才生成)才補得回這站"
---

# QA 故事稽核：convoy RETURN — 判不了，specimen 範圍設反

**沒有跳過這站，讀了全份 1701 筆 + 追了 code**——但結論是：**這份 specimen 結構上答不了你問的三個問題**，不是我懶得判。

## 查了什麼

1. 全檔掃 `team_id` 只有 `{3, 5, 7}`——對得上 implementer 報告寫的 `SPECIMEN_TEAM_ID=5,7,3`（"三個有派 convoy 的**領主**"）。
2. 全檔逐字搜 `convoy`/`CONVOY`——**0 命中**。連一次都沒有，不是稀疏，是完全不存在。
3. 追 code 確認為什麼：`faction_ai_system.gd:4043 _dispatch_convoy` 呼叫 `SubteamSystem...dispatch(state, team.team_id, advisor_id, CONVOY_PORTER_POP, TASK_CONVOY, target)`——**porter 是獨立 `TeamData`，有自己的 `team_id`（`parent_team_id` 指回領主），在派遣當下才動態生成**。specimen tracer 只認 `SPECIMEN_TEAM_ID` 這張固定清單，porter 的 team_id 不在清單裡（派遣前根本不知道會是幾號）→ **porter 自己的「做什麼」/「想什麼」決策軌跡從沒被錄過一筆**。
4. 我錄到的 3/5/7 全是**領主自己**的貿易/外交/紮營決策——這是不同的角色、不同的故事，不是你要我判的那個。

## 我判不了的三題，逐一交代

- **①「追家」(convoy.rehome) 自適應還是鬼打牆**：需要 porter 每次 rehome 當下的 tick/位置/母隊當下位置——這些欄位不在錄到的資料裡（領主的「狀態」dict 只有 coin/food/pop 這些自身經濟欄，沒有子隊位置追蹤）。**判不了**。
- **②歸建那兩隻路徑像不像回家**：需要 porter 從 RETURN phase 到 merge 這段的逐 tick 位置序列。**同樣沒錄到，判不了**。
- **③在途那隻像被困還是正常在途**：同上，需要 porter 自己的候選/位置軌跡。**判不了**。

## 建議下一步（不是自己重跑——這是量測員的活）

**route 回 measurer**，重指定 specimen 範圍：**SPECIMEN_TEAM_ID 除了 3 個領主，還要加上這 3 個領主派遣出去的 porter 子隊 team_id**（派遣後才知道是幾號，需要跑起來後從 `state.teams` 動態抓 `parent_team_id in {3,5,7}` 的子隊 id，或乾脆這輪窗口小、隊數少，直接全隊 trace 不篩選）。這規模不大（implementer 報告 `dispatch=3`，全程只有 3 個 porter 子隊），全隊 trace 成本應該可接受。

**地基 KEEP，樣本問題非結論問題**——不是「樣本小」，是「錄錯人」，補錄之後我才能真的照你要求的三題判。
