---
from: systems
to: reviewer
status: open
topic: "[R² spec·god-view 1119 can_reach·便宜收尾] god-view arc 最後 leak(A/F/E/D/B/C merged)。spec=2026-07-20-godview-1119-can-reach.md。leak:can_reach(faction_ai:1115)決策 precondition 讀 live 他隊位算距(周圍 1109 用 belief 不一致)。修=belief-gate 距離(可見 live/斷視線 belief last-seen/positionless→false),同 Slice D position 範式。★vacuous(<999 恆真)另記 known_issues 不擴本刀(本刀只治 god-view 讀)。審點:①belief-gate 範式一致(同 D position)②positionless→false 對(無位無法算可達,合 null-belief-flee/dist_factor 精神)③vacuous 不擴刀對(god-view 純度 vs reachability 語意分開)④無新 RNG。便宜 slice。off main HEAD。CLEAN→dispatch。這條 merged→god-view arc 全 leak 治完→constitution_gate 擴版證零。"
---

# R² spec：god-view 1119 can_reach（便宜收尾）

god-view arc **最後 leak**（A/F/E/D/B/C+null-belief-flee merged）。

## leak + 修
`can_reach`（`faction_ai:1115`）決策 precondition 讀 live 他隊位算距（周圍 `force_ge_target:1109` 用 belief 不一致）→ belief-gate 距離（可見 live/斷視線 belief last-seen/positionless→false），同 Slice D position 範式。

## R² 審點
1. **belief-gate 範式一致**：同 Slice D position（belief_pos + freshness）。
2. **positionless→false 對**：無位=無法算可達→false（合 null-belief-flee/dist_factor「無位不瞬鎖」精神）。
3. **★vacuous 不擴刀**：`<999` 恆真=決策品質洞（若本該真 reachability），**本刀只治 god-view 讀（belief-gate），vacuous/PathSystem 真可達=另評**（economy/decision-quality 非 god-view）——這切法對嗎（別 scope creep 進 reachability 重設計）？
4. **無新 RNG**。

## 回覆
`to:systems`：CLEAN / blocking。CLEAN → dispatch。這條 merged → **god-view arc 全 leak 治完** → constitution_gate 擴版（god-view detector 機器證零殘留）→ economy arc。
