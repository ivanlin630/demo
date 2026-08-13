---
from: systems
to: reviewer
status: open
topic: "[R② 審 A2 fix(佔據率主槓桿、dispatch 前)·diagnostic CLOSE 雙100%死路:dispatch路 35/35 卡 MIN_PARENT_POP_AFTER_DISPATCH=10(領主分settler後自保、genuine 保留不動)、invite路 250/250 卡 `\"流亡\" in t.tags` filter(流亡tag只faction_ai:5194 uprising_exile專屬、一般wanderer從沒此tag=結構不可能被邀)·★fix=拓寬 invite 候選 filter(_try_invite_nearby_exile:600):`if not (\"流亡\" in t.tags): continue`→`if t.tags.has(TeamData.TAG_PRODUCE) or t.parent_team_id != -1: continue`(=只邀非生產隊[wanderer/流亡]、排生產隊[已settled]+子隊)·★審點:(1)感知鐵律:filter 讀 t.tags(TAG_PRODUCE)——現有 filter 本就讀 t.tags(`流亡`)=established pattern、不讀 live t.tile_pos(is_resident_static:501 讀 live 位=god-view 故不用它);候選來自 team_discovered(belief)+range 用 belief_pos(:605 已 belief-legal)→拓寬後仍 belief-legal?(2)over-invite:每領主邀每鄰近 wanderer 會不會爆settle/churn? rate-limit=invite_cooldown+RESIDENCY_COOLDOWN*4+diplomacy accept+belief INVITE_RANGE8——夠不夠擋?(3)semantic:領主招募 wanderer 進空outpost=intended emergence(用戶直覺『有初始據點能進入生產』)、非crank(_try_dispatch_or_invite personality 分流不動、只放寬候選池)(4)dispatch pop gate 保留 genuine(小領主不該掏空自己分settler)妥?(5)founding-path(establish_crude_camp)=blueprint令量完再評第三槓桿、本slice不擴scope、僅 A2 fix·CLEAN→implementer+measurer bounded gate(佔據率升 AND 不over-invite churn/bounded)·halt項明列·地基KEEP"
---

# R② 審 A2 fix — 拓寬 invite 候選（佔據率主槓桿、dispatch 前）

diagnostic CLOSE（雙 100% 死路、零混雜）：
- **dispatch 路 35/35** 卡 `MIN_PARENT_POP_AFTER_DISPATCH=10`（領主分 settler 後自保 = **genuine、保留不動**）。
- **invite 路 250/250** 卡 `"流亡" in t.tags`（流亡 tag 只 faction_ai:5194 uprising_exile 專屬、一般 wanderer 從沒此 tag = 結構不可能被邀）。

## ★fix（單點、拓寬 invite 候選 filter）
`_try_invite_nearby_exile`（faction_ai:600）：
```
- if not ("流亡" in t.tags): continue
+ if t.tags.has(TeamData.TAG_PRODUCE) or t.parent_team_id != -1: continue   # 只邀非生產隊(wanderer/流亡)、排已settled生產隊+子隊
```
= 領主可邀**一般無家 wanderer**（非生產隊）進自家空 outpost。invite 機制其餘（belief range/diplomacy accept/cooldown/try_set TASK_SETTLE）不動。

## ★審點（skeptical、只信 file:line）
1. **感知鐵律**：filter 讀 `t.tags`（TAG_PRODUCE）——現有 filter 本就讀 `t.tags`（`流亡`）=**established pattern**；**不讀 live `t.tile_pos`**（`is_resident_static`:501 讀 live 位=god-view、故**不用它**）。候選來自 `team_discovered`（belief）+ range 用 `belief_pos`（:605 已 belief-legal）→ 拓寬後仍 belief-legal？
2. **over-invite**：每領主邀每鄰近 wanderer 會不會爆 settle/churn？rate-limit=`invite_cooldown`+`RESIDENCY_COOLDOWN*4`+diplomacy accept+`INVITE_RANGE`=8——夠不夠擋？
3. **semantic**：領主招募 wanderer 進空 outpost=intended emergence（用戶直覺「有初始據點能進入生產」）、非 crank（`_try_dispatch_or_invite` personality 分流不動、只放寬候選池）。
4. **dispatch pop gate 保留**（小領主不該掏空自己分 settler）= genuine 妥？
5. **founding-path**（`establish_crude_camp`）= blueprint 令量完再評第三槓桿、**本 slice 不擴 scope**、僅 A2 invite fix。

CLEAN → implementer + measurer bounded gate（佔據率升 **AND** 不 over-invite churn/bounded）。halt 項（crank/感知鐵律違/over-invite 隱患）明列。地基 KEEP。
