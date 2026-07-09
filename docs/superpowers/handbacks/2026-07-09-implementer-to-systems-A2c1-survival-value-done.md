---
from: implementer
to: systems
status: consumed
topic: A2c-1 survival-value 實作完成 + 浮現 pre-existing dormant bug (can_reach 缺 guard) 待裁
---

# A2c-1 survival-value — 實作完成

branch `feat/machine-A2c1` @ `d70d83b`（base 423924c 之上 +1 commit）。

## 做了什麼（照 spec，1 檔實改）

`scripts/simulation/decision/terms.gd`：
- `CONSOLIDATE_DRIVE=2.0`（flat）→ 拆三常數 `CONSOLIDATE_DRIVE_BASE=0.8` / `CONSOLIDATE_SURVIVAL_BOOST=3.0` / `CONSOLIDATE_CRITICAL_POP=2`。
- `consolidate_drive` eval 換 D2' 算式：`hunger_factor = clampf((DESPERATION_DAYS - ctx.food_days)/DESPERATION_DAYS, 0, 1)`（主）+ `critical_pop = 1 if ctx.population<=2 else 0`（次 floor），`survival_boost = BOOST * maxf(hunger, critical)`，return `BASE + survival_boost`。用既有 `ctx.food_days`/`ctx.population`，無新 ctx 欄（D3' 作廢確認）。

**item 2（merge_appl probe bump）已在 base @423924c 就位**（`faction_ai_system.gd:1495-1500`），未動——已符 reviewer caveat：`chose_other` 只在 `consolidate_target_of != -1` 同一 applicable 分支內 bump，`total == chose_整併 + chose_other`。工單以為未接、實已接。

## 自跑閘（spec §驗收法 1-3）全綠

| 閘 | 結果 |
|---|---|
| `--headless --import` | 無 parse error |
| `constitution_gate` | `PASS (sites=29, removed=0)` |
| `game_sim_multi` sanity | 跑到 day90=**21600 tick 無崩**；`InvariantSummary 違反=0` |

驗收線 4+（3-way full_probe：starvation 回健康 / merge 落 (154,978) / chose_other 保留）交量測員 + QA。

## ★浮現 pre-existing dormant bug（需 systems 裁，非我 slice）

sanity 出 16× 非致命 `SCRIPT ERROR: Out of bounds get index '11' (on base: 'Dictionary')` @ `faction_ai_system.gd:1057`：

```gdscript
"can_reach":
    return target_id != -1 and _hex_dist(leader_team.tile_pos, state.teams[target_id].tile_pos) < 999
```

- **根因**：strategic-intent means-end 的 `target_id`（`_nearest_independent` 快照）在派前若目標隊已被抹除，`state.teams[target_id]` 直接索引無 `.has()` guard → out-of-bounds。**非致命**（GDScript error 續跑，invariants=0，跑滿 21600 tick）。
- **非我改動引入**：此行在 `faction_ai_system.gd`，我 slice 只動 `terms.gd`；同檔其他 `state.teams` 存取有 guard（`:2002` `state.teams.has(tid)`、`:281` `.get()`+null），`:1057` 是漏網。base code 就有此洞。
- **為何 base 跑出 0、我 16**：base=pure-fold under-merge（154 dispatch）→ 併少→隊少抹除→此路罕觸；A2c-1 令餓隊可靠求生併→抹除變多→喚醒 dormant bug。**A2b 型「合法改動喚醒 pre-existing dormant bug」**，非 A2c-1 有罪。
- **建議修**（一行、語意保真：目標抹除→到不了→false）：
  ```gdscript
  return target_id != -1 and state.teams.has(target_id) and _hex_dist(leader_team.tile_pos, state.teams[target_id].tile_pos) < 999
  ```
  請 systems 裁：(a) 併入本 slice（我補 commit），(b) 另開 fix slice，(c) 記 known_issues 暫放。我不擅自 patch 他子系統。

## 完成判定

非自判。task 完成由 systems + reviewer/QA。量測員 full_probe 3-way 驗收線待跑。
