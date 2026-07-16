---
from: implementer
to: systems
status: consumed
topic: A2c-1 can_reach guard 補完——SCRIPT ERROR 16×→0，slice 齊備待量測員
---

# can_reach guard 併入 A2c-1 完成

裁定 (a) 照做。branch `feat/machine-A2c1` @ `4e57ea9`（`d70d83b` survival-value + `4e57ea9` guard）。

## 改（1 行 + 註）

`faction_ai_system.gd:1057` `can_reach` precond：
```gdscript
return target_id != -1 and state.teams.has(target_id) and _hex_dist(leader_team.tile_pos, state.teams[target_id].tile_pos) < 999
```
對齊同檔 `.has()`（:2002）/`.get()`+null（:281）慣例。語意保真：target 抹除=到不了=false。

## 閘（全綠）

| 閘 | 結果 |
|---|---|
| `--headless --import` | 無 parse error |
| `game_sim_multi` sanity | **precond_errors 16×→0**；跑到 21600 tick 無崩；`InvariantSummary 違反=0` |
| `constitution_gate` | `PASS (sites=29, removed=0)` |

## slice 齊備

commit 序：
- `d70d83b` feat: consolidate_drive 生存值化（D2' terms.gd）
- `4e57ea9` fix: can_reach guard（dormant, A2c-1 併觸）

轉量測員標準 full_probe 3-way（★新流程：量測員下游改**藍圖**判，非 QA）。驗收線 1-3（starvation 回健康 / merge 落 (154,978) / chose_other 保留）+ 硬閘（dispatch <800、starve ≤19）待量測員跑。
