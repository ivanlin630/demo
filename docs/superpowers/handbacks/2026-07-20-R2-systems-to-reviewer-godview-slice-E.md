---
from: systems
to: reviewer
status: open
topic: "[R² spec·god-view Slice E 平行 dispatch 路·感知鐵律一致] blueprint 恢復 god-view 排程(slice1 all-in 理由已不適用),Slice E 接手。spec=2026-07-20-godview-slice-E-parallel-dispatch.md。統一 arc 沒掃到的 legacy dispatch 路 move_target 讀 live 他隊位=god-view:E1 _commit_conquest_attack(:336)/E2 _try_join_target(:1830)/E3 found_subjugate(:1278)/E4-5 strategic_ai encircle/breakout/E6 envoy。修=belief_pos(範式 slice2/options.gd:194),無 belief→不 dispatch(禁 fallback-live)。審點:①E1/E2/E3 明確他隊位當 move 目標→belief 對②E4/E5 包圍/突圍幾何可否 belief 化 or 屬同-faction 協調豁免(逐 site 判)③E6 envoy 別破既有 proximity/timeout tracking④無 belief 守衛=保守不 dispatch 非 fallback-live⑤攻擊脫視野甩追=intended 深度非 regression。A/F 已 merged,D(path_system)/B/C 留後。off main HEAD。CLEAN→dispatch。"
---

# R² spec：god-view Slice E 平行 dispatch 路

spec：`docs/superpowers/specs/2026-07-20-godview-slice-E-parallel-dispatch.md`。god-view 殲滅 arc（A/F 已 merged，E 接手，D/B/C 留後）。

## 病象（audit 坐實）
統一 arc 沒掃到的 legacy dispatch 路 move_target 讀 live 他隊位（god-view）：
- **E1** `_commit_conquest_attack:336`：`state.teams[prey_id].tile_pos` 征服攻擊移動。
- **E2** `_try_join_target:1830`：`state.teams[target_id].tile_pos` JOIN 移動。
- **E3** found_subjugate `:1278`：live prey 位。
- **E4/E5** strategic_ai `_assign_encirclement:122`/`_assign_breakout:159`（locate 確認讀啥）。
- **E6** envoy tracking（locate 確認；envoy 已有 proximity/timeout）。

## 修：belief_pos（範式 slice2/options.gd:194）
move_target = live 他隊位 → `BeliefSystem.belief_pos`；無 belief → 不 dispatch（禁 fallback-live）。

## R² 審點
1. **E1/E2/E3 belief 化對**：明確「他隊當前位當 move 目標」→ belief_pos 正確（同 slice2 A1）。
2. **E4/E5 逐 site 判**：strategic 包圍/突圍幾何——讀 belief 位算包圍點 OK，還是涉 faction 級多隊 tally = 同-faction 共享情報**合法豁免**（invariants 刻意豁免段）不該改？請幫判 E4/E5 屬哪類。
3. **E6 envoy 別破**：只改「target 當前位」讀 belief，別破既有 `_tick_envoy` proximity/timeout tracking。
4. **無 belief 守衛**：無情報→保守不 dispatch（`continue`/return），**非 fallback-live**（守 invariants「無估=保守」）。
5. **攻擊脫視野甩追=intended**：E1/E3 belief last-seen → 敵脫視野可甩掉追擊=伏擊/佯動湧現（同 attack/threat evasion），勿當 regression 要 reviewer 認可此語意。

## 回覆
`to:systems`：CLEAN / blocking(file:line)。CLEAN → dispatch implementer（off main HEAD）。逐 site 判準（E4/E5/E6 哪些真該改）幫定，避免盲改破協調/物理位。
