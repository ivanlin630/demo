---
from: systems
to: implementer
status: open
topic: "[cheap-win 修(blueprint GO c、續 feat/faction-cohesion 同 branch 同檔 faction_ai)·uprising 缺 faction_id 前置閘:_evaluate_uprising(faction_ai_system.gd:4536)開頭缺 if team.faction_id == -1: return——對照 defect(event_faction_defect.gd:6-8 有此閘)、uprising 沒→已 independent 隊(faction_id=-1)反覆空觸發整段起義流程(print+鄰格恐懼 cascade+取消施工副作用、即使 clear_team_faction 本身因已 -1 而 no-op)·measurer occupancy-map 血證:rep 床 Team5 對已 independent 自己 4 次空 uprising(day15/18/24/38 old_owner=自己)·修=加 if team.faction_id == -1: return 到 _evaluate_uprising 開頭(鏡射 defect 既有寫法、_is_resident_team 檢查後)·★純清空觸發雜訊+副作用、不改真 uprising 行為(有 faction 的隊照常)·TDD:already-independent 隊(faction_id=-1)不再觸發 uprising 流程(RED 無閘→空觸發)+有 faction 隊照常 uprising·determinism byte-identical(消副作用可能改軌跡=標明非退化)·可跟 g3 extension 同 commit or 分開·完成 handback to:systems·地基 KEEP"
---

# uprising 缺 faction_id 前置閘 cheap-win（blueprint GO c）

續 `feat/faction-cohesion`（同 branch 同檔 `faction_ai_system.gd`）。

## bug（measurer occupancy-map 血證）
`_evaluate_uprising:4536` 開頭**缺 `if team.faction_id == -1: return`**——對照 defect（`event_faction_defect:6-8` **有**此閘）、uprising **沒**→ 已 independent 隊（faction_id=-1）**反覆空觸發整段起義流程**（print + 鄰格恐懼 cascade + 取消施工副作用；即使 `clear_team_faction` 本身因已 -1 而 no-op）。
- rep 床 Team5 對已 independent 自己 **4 次空 uprising**（day15/18/24/38、old_owner=自己）。

## 修
加 `if team.faction_id == -1: return` 到 `_evaluate_uprising` 開頭（鏡射 defect 既有寫法、`_is_resident_team` 檢查後）。**★純清空觸發雜訊 + 副作用、不改真 uprising 行為**（有 faction 的隊照常）。

## TDD
already-independent 隊（faction_id=-1）不再觸發 uprising 流程（RED 無閘→空觸發）+ 有 faction 隊照常 uprising。determinism byte-identical（消副作用可能改軌跡=標明非退化）。

## 序
可跟 g3 extension 同 commit or 分開。完成 handback `to:systems`。地基 KEEP。
