# spec：god-view Slice E — 平行 dispatch 路讀 live 位 → belief_pos

> 層級：L2（感知鐵律一致，數處 dispatch 路 move_target 改 belief）。off main HEAD。god-view 殲滅 arc（economy 前零殘留），blueprint 恢復排程 2026-07-20（slice1 all-in 理由已不適用）。scope 見 `2026-07-19-systems-to-blueprint-godview-audit-scope.md` Slice E。
> A(slice2)/F(fallback+deadfields) 已 merged；E 接手（D=path_system 最大塊留後、需 measure；B/C 待 blueprint WHAT）。

## 感知鐵律（invariants.md，違憲點）
決策移動目標讀他隊**當前位置**一律 `BeliefSystem.belief_pos`（last-seen belief），**禁讀 live `target.tile_pos`（god-view，跟蹤已脫視野的隊）**。範式=攻擊 to_task `options.gd:194`「攻擊 target 走 belief last-seen」。terrain/自身位=物理真值合法；**他隊位≠**。

## 病象（audit file:line 坐實）：平行 dispatch 路繞 belief
> **★scope 訂正（R² 2026-07-20）**：真 leak = **E1/E2/E3/E5** 四處。**E4 encirclement（`strategic_ai:137 best_estimate`+F1 sentinel）+ E6 envoy（`faction_ai:1396 best_estimate`+攔截+timeout）前一 slice 已 belief 化**——我 spec 前提過期，**勿再改（重改 regression 風險）**。E5 breakout 確認真敵位 leak（非同-faction tally，不豁免）。

統一 arc（序1-8）沒掃到的 legacy dispatch 路，move_target 直讀 live 他隊位（**訂正後 4 處**）：
| # | site | 現況（讀 live） |
|---|---|---|
| E1 | `_commit_conquest_attack`（`faction_ai:309`，:336） | `try_set(..., state.teams[prey_id].tile_pos, ...)` = 征服攻擊移動目標讀 live prey 位 |
| E2 | `_try_join_target`（`faction_ai:1824`，:1830） | `try_set(..., TASK_JOIN, state.teams[target_id].tile_pos, ...)` = subteam JOIN 移動讀 live target 位 |
| E3 | found_subjugate（`faction_ai:1278`） | `try_set(..., state.teams[prey_id].tile_pos, ...)` = 建國征服移動讀 live 位 |
| E5 | strategic_ai breakout（`strategic_ai_system:159 _assign_breakout` → `_find_escape_dir:207 e.tile_pos`） | 突圍逃跑方向讀 live 敵位（真 leak，R² 確認不豁免） |
| ~~E4~~ | ~~encirclement~~ | **已 belief 化（前 slice），不改** |
| ~~E6~~ | ~~envoy~~ | **已 belief 化+攔截+timeout，不改** |

## 修（統一 belief_pos，範式 slice2）
每處 move_target = `state.teams[X].tile_pos`（live 他隊位）→ 改 `BeliefSystem.belief_pos(state, self, X)`（last-seen）。
- **無 belief 守衛**：無情報 → 不 dispatch（`continue`/return，禁 fallback 回 live，同 slice2 A3/invariants「無估=保守」）。
- **belief_pos 缺 → sentinel + guard**（同 god-view Slice F F1 範式，非 fallback-to-live）。
- **E1/E3 攻擊/征服**：走 belief last-seen → 敵脫視野可甩掉追擊（伏擊/佯動湧現，同 attack/threat evasion=intended 深度，勿當 regression）。
- **E4/E5 strategic 包圍/突圍**：包圍是空間 goal，讀 belief 位算包圍點——locate 確認 encirclement 幾何是否可 belief 化（若涉多隊協調的 faction 級 tally，可能屬同-faction 共享情報豁免，逐 site 判）。
- **E6 envoy**：已有 proximity/timeout（`_tick_envoy`）——只改「target 當前位」讀 belief，別破既有 tracking 刷新機制。

## 逐 site 判準（非全機械）
- 純「他隊當前位當 move 目標」→ belief_pos（E1/E2/E3 明確）。
- 同-faction 內部協調 tally（faction 級 known_member_states）→ 合法豁免，不改（invariants 刻意豁免段）。
- terrain/reachability/自身位 → 物理真值，不改。
- E4/E5/E6 逐 site 讀 code 判屬哪類（locate 時定），別盲改破協調/物理。

## 驗收
- **TDD**：leak 測（真值≠belief 兩向斷言：dispatch 移動目標跟 belief 非 live）補 E1/E2/E3（+ E4/E5/E6 若判定該改）。無 belief→不 dispatch 測。
- **gate** constitution PASS / **headless** 0 new(baseline 3) / **determinism** 2 跑 byte-identical。
- **measure（→measurer）**：seed1337/42/4201 征服/JOIN/包圍行為——敵脫視野可甩掉追擊（intended），真隊無 regression（doom-delta track，同 Slice F）；無「跨圖瞬鎖 live 位」殘留。
- **★god-view audit 局部**：E1-E6 改後，這幾條路 grep 無 live `state.teams[X].tile_pos` 作 move_target（belief 化證）。

## out-of-scope
Slice D（path_system 11 caller，最大，需 measure before/after）留後。B/C 待 blueprint WHAT。

## 排序
off main HEAD。R²（感知鐵律一致性 + 逐 site 判準不誤傷同-faction 豁免/物理位）→ dispatch。
