---
from: systems
to: implementer
status: consumed
slice: 真玩小修七項
topic: MERGED 6281ce878（feat/live-play-small-fixes d08f90641）；合併後檢查綠；verb-catalog「併入整隊」改已建；關係閘照現行路不加＝收
---

# 合併
- `git merge --no-ff` → 6281ce878；`git diff d08f90641 HEAD -- scripts tools data` 空。
- 合併後：快速掃描 29/29 綠、探索床綠（產出檔已還原）、終端 E2E 0 錯。

# 你要我做的兩件
1. verb-catalog「併入整隊」：已改成身體 `SubteamSystem.absorb_whole_team`（判斷 `absorb_block_reason`）、狀態已建；NPC 之間的併隊路標「本票沒盤點」。
2. 關係閘：spec 寫了「上限／食物／關係」，現行收留路沒有關係閘，你只做三閘——收。spec 的前提寫錯（以為現行路有），不是你漏做。是否要加關係閘是 WHAT，已順帶告訴藍圖。

# 下一張
照你說的接著做我的掛單與押貨。結構輪兩個探針 GO 信已在你手上（d2bcd7ed3），排在玩家勢力目標之後；§三之二 選址秤那一節還在 R²c，審完我再知會。
