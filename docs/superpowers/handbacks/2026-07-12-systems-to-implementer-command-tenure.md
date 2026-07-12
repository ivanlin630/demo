---
from: systems
to: implementer
status: consumed
topic: [工單] 統領日常領導成長—loop2外層cadence _grow_leadership_tenure;spec+R²CLEAN;疊新worktree feat/command-tenure-growth
---

# 工單：統領日常領導成長（絕境經濟第三層根修）

spec：`docs/superpowers/specs/2026-07-12-command-tenure-growth-technical.md`（R² CLEAN）。established B2 硬牆根：統領唯一成長=P4_expand 被繁榮閘鎖→絕境隊統領凍結→100% 立國不了。修=加日常領導被動成長。**新 worktree `feat/command-tenure-growth` 疊當前 main（已 push）。**

## 做（照 spec §1-§4）
1. **§2 常數**（`faction_ai_system.gd` 頂）：
   ```gdscript
   const LEADERSHIP_TENURE_INTERVAL: int = WorldState.TICKS_PER_DAY   # TEST VALUE
   const LEADERSHIP_TENURE_GROWTH: float = 0.0006                     # TEST VALUE
   ```
2. **§1 `_grow_leadership_tenure(state, team)`**：leader 帶隊被動長統領（魅力×毅力×mult 公式，復用 `SkillSystem.cap_add`）——見 spec §1 pseudocode。守 `leader_id==-1`/null。
3. **§1 呼叫落點**——見下 ★，別出岔。

## ★★呼叫落點（reviewer 特別提醒，本 arc 已兩次巢狀範圍出岔）
`_evaluate_all_body` loop2（`faction_ai:665 for tid in state.teams`）有**三分支**：`if parent_team_id!=-1`（子隊）/ `elif faction_id==-1`（獨立）/ `else`（faction 成員含 leader）。

**`_grow_leadership_tenure` 的 cadence 呼叫必須在三分支判斷之前（外層）統一觸發**，覆蓋**所有 leader_id 存在的 team 型別**（子隊/獨立/faction 成員 leader 都要長）：
```gdscript
for tid in state.teams:
    var team: TeamData = state.teams[tid]
    if state.world.current_tick % LEADERSHIP_TENURE_INTERVAL == 0:   # ★三分支外層,先觸發
        _grow_leadership_tenure(state, team)
    if team.parent_team_id != -1:
        _evaluate_subteam(...)
    elif team.faction_id == -1:
        ...
    else:
        ...
```
**別誤植進某單一分支內**（會漏子隊/獨立隊 leader）。B2 讀的是 faction leader 統領（else 分支），但成長要覆蓋全型別（獨立隊要建國也需統領爬升）。

## 不動（spec §4）
- **P4_expand 路徑零改**（`_score_expand`/REACTION_SKILL_MAP/on_reaction 不碰）——純加底層路徑,繁榮隊照舊。
- ESTABLISH_COMMAND 門檻/初始統領 gen/B3/B4 不動（本 slice 只解 B2 成長路徑）。

## TDD + 驗收
- 加 headless_test 斷言：leader 統領經 N 個 LEADERSHIP_TENURE_INTERVAL 後 > 初始（成長生效）；cap 不超 1.0；leader_id==-1 不崩。
- 完成 → handback **to:measurer**（驗收見 spec §驗收法：B2 gate_fail 從 100%→有通過/統領爬升軌跡/established>0（誠實區分 B2 解鎖 vs established 大漲，A 門人口上游未解）/determinism byte-identical + baseline 位移標記/P4_expand 不回歸/融合閘）。

## 註
- 行為改動（統領數值變→established 變），非 regression——measurer baseline 位移標「command-tenure 位移」（比照 world-gen）。
- 絕境經濟第三層根修（farming 第一層/A門人口第二層之後）。established 完整解需 A 門也修（另 slice）。
- 卡點 → to:systems（別問 user）。
