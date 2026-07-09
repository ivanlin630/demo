---
from: systems
to: implementer
status: consumed
topic: [REDO] A2c-1 裁定——can_reach guard 併入本 slice（一行防護），補 commit
---

# 裁定：can_reach dormant bug → 併入 A2c-1（選項 a）

診斷屬實，已核 `faction_ai_system.gd:1057`（`state.teams[target_id]` 無 `.has()`；兄弟 `:1051` guard target_id、`:1052` 走 BeliefSystem，此行漏網）。

## 裁 (a) 併入本 slice，補 commit

```gdscript
"can_reach":
    return target_id != -1 and state.teams.has(target_id) and _hex_dist(leader_team.tile_pos, state.teams[target_id].tile_pos) < 999
```

**理由**：
1. **A2c-1 是觸發者**：餓隊可靠求生併→抹除變多→喚醒此 dormant bug。ship A2c-1 不修=ship 16× SCRIPT ERROR spam。∴ 必須隨本 slice 修，不能另放。
2. **非違「架構已定別打補丁」**（memory `feedback_no_patch_on_settled_architecture`）：那條禁的是**矛盾補丁**；此為**缺失 null-guard 補齊**，且**對齊同檔既有慣例**（`:2002` `.has()`、`:281` `.get()`+null）=一致性修復，非繞過架構。
3. **語意保真**：目標抹除→到不了→false（原 `state.teams[erased]` 索引本就回無效/error，下游視同不可達）。**對 full_probe merge 維度零 confound**（before=error+garbage、after=clean false，both=「can't reach」）→ 量測員 before/after 不受污染。

## 做
- worktree `feat/machine-A2c1` 補上行 guard，單獨 commit（msg 標 `fix(A2c1): can_reach 缺 state.teams.has guard(dormant,A2c-1 併觸)`）。
- 重跑 `game_sim_multi` sanity 確認 SCRIPT ERROR 歸 0（原 16×→0）。
- handback 回 to:systems status:open 報 commit hash + error 歸零確認。

## 完後流轉
guard 補完 → 轉量測員標準 full_probe 3-way（★新流程：量測員下游改**藍圖**判，非 QA，見 `03b_measurer.md`/`04_qa.md` 2026-07-09 banner）。
