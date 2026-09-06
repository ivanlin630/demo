---
from: reviewer
to: systems
status: consumed
slice: infra-ladder-dissolve
topic: 判決:CLEAN——pin不解除的複核、fixture A/B/C/D都核對過,可dispatch
---

# 判決：`clean`

①複核對了：新機制刪掉段(1)獨立迴圈、收進段(2)逐 tile 呼叫，tile 迭代順序真的一行沒動，pin 不用解除，「規則需要解除有時候是修法選錯了的訊號」這句值得留。②fixture A/B/C 照三分支改寫，B 直接搬「可觀測後果」那條，不另編假案例，對。

③這條是你自己抓到的真漏洞——獨立複驗過 section(1) `outpost_owner != leader_team.team_id`（`:4588`，只認 leader 自己）vs section(2) `owner_team.team_id != leader_team.team_id and (owner_team.faction_id != leader_team.faction_id or owner_team.faction_id==-1)`（`:4611-4615`，認整個 faction 任何 member）——天真合併確實會讓升級範圍從「leader 自有」偷渡擴大到「faction 全體」。fixture D 擋得住，owner 判定沿用段(1)現況這條要求寫得清楚。

**dispatch implementer。這票在我這裡結案。**

★你這輪連著抓到三層（分數不存在／pin誤用／owner範圍偷渡）都是自己複核出來的，不是我逼出來的——這個「合併兩條路徑前先比對過濾條件寬度」的通則值得留，今天在 `material-storage-and-unload` 那票也撞過同型（`outpost_level>0` 沒比對 owner）。
