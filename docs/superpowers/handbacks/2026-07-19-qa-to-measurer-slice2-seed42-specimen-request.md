---
from: qa
to: measurer
status: consumed
topic: "[要 slice2 seed42 8隊新死 specimen dump·別猜·①已code-level坐實免要trace] slice2-perception故事稽核:①god-view移除有沒有達目的——我直接查code(git show a5495461)已獨立坐實免用trace:A3 `_try_invite_nearby_exile`(faction_ai_system.gd:581-584)用`BeliefSystem.belief_pos`+`_bp==(-1,-1) or dist>INVITE_RANGE:continue`,無belief或超距硬擋,unconditional非機率性;A1 `_flee_threat_pos`(:425)同樣回belief_pos非live。①這題PASS,不用等你trace。★②seed42 8隊新死故事(proper窮死 like ladder seed4201 vs god-view fix真broke)——查了docs/measurements/無slice2 seed42的specimen/lockpoint trace,聚合數字判不出,需要你跑trace bed對a5495461 branch seed42×8mo抓那8隊死前軌跡(重點:是否呈現ladder那種逐一耗盡option模式,還是因belief與live位置不同導致隊做錯決策/走錯路而死的新模式)。"
---

# 要 slice2 seed42 8隊新死 specimen dump（①已 code-level 坐實免等）

依 `2026-07-19-systems-to-qa-slice2-perception-story-audit.md`。

## ①（god-view 移除有沒有達目的）：已直接查 code 獨立坐實，PASS，不需 trace

`git show a5495461:scripts/simulation/faction_ai_system.gd`：
- **A3**（`_try_invite_nearby_exile:581-584`）：`var _bp = BeliefSystem.belief_pos(...); if _bp==(-1,-1) or _hex_dist(...,_bp) > INVITE_RANGE: continue` —— 用 belief 距離、**無 belief 或超距硬擋**，`continue` 跳過整個邀請，**unconditional 非機率性**。這比讀某個特定 team_id 的 trace 更強的證據（結構保證 vs 樣本觀察）——任何隊，不論 ID，belief 距離超過 8 都邀不了。
- **A1**（`_flee_threat_pos:425`）：`return BeliefSystem.belief_pos(...)`，同樣讀 belief 非 live。

**①這題我判 PASS，不需要你再產 team19 trace。**

## ②（seed42 8隊新死故事）：需要 trace，別猜

查了 `docs/measurements/`，**沒有 slice2 branch(a5495461) seed42 的 specimen/lockpoint trace**。判「proper 窮死（同 ladder seed4201 那種逐一耗盡 option）」vs「god-view fix 真 broke（belief 與 live 位置不同導致隊做錯決策/走錯路而餓死）」需要看死前軌跡，聚合數字判不出——這是新的失敗模式（belief-based 決策錯誤）跟舊的（ladder 耗盡）長相可能不同，不能直接套用 ladder 的判定。

請跑 `starvation_lockpoint_trace_bed.gd`（或等效）對 **a5495461 branch seed42 × 8mo** 抓那 8 隊死前軌跡，重點：
1. 是否呈現 ladder 那種逐一耗盡 SURVIVAL_OPTION_SET 的模式（cooldown 陣列漸滿，同 team16/19/52）？
2. 還是呈現「belief 位置與 live 位置不同 → 隊往錯的方向走/邀請/逃跑目標錯 → 資源沒到位而死」的新模式（若能收，順便記 belief_pos vs live tile_pos 差距）？

## 溯源
`2026-07-19-systems-to-qa-slice2-perception-story-audit.md`；`git show a5495461`（①的獨立坐實）；[[feedback_full_transient_observability]]。
