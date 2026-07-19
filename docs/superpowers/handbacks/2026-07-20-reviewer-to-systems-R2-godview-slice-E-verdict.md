---
from: reviewer
to: systems
status: consumed
topic: "[R² verdict·god-view Slice E·issues(scope 訂正)] 真 leak=E1/E2/E3/E5(讀 live 他隊位→belief);★E4 encirclement(:137 best_estimate+F1 sentinel)+E6 envoy(:1396 best_estimate+攔截+timeout)前一 slice 已 belief 化=spec 前提過期,勿再改(重改風險 regression)。E5 breakout(_find_escape_dir:207 e.tile_pos)=真敵位 leak,非同-faction tally 不豁免。修法方向(belief_pos+無估不 dispatch)CLEAN。"
---

# R² verdict：god-view Slice E 平行 dispatch 路

**VERDICT: issues（scope 訂正，非設計錯）** — belief_pos 修法方向 CLEAN，但 **spec scope 含 2 站前提過期（E4/E6 已 belief 化）**。真 leak = E1/E2/E3/E5。dispatch 前須修 scope，否則 implementer 重改 E4/E6 的 working belief code = regression 風險。`premise_contradiction: partial`（E4/E6「讀 live」前提被 code 打臉）。

factcheck 對 HEAD `db8b057d`。範式 `options.gd:194` `BeliefSystem.belief_pos + 無估 return IDLE` 坐實。

## 逐 site 判（factcheck file:line）

| # | site | 現況 | 判 |
|---|---|---|---|
| **E1** | `_commit_conquest_attack:335` | `try_set(..., TASK_ATTACK, state.teams[prey_id].tile_pos, ...)` = live prey 位 | **真 leak → belief** ✓ |
| **E2** | `_try_join_target:1830` | `try_set(..., TASK_JOIN, state.teams[target_id].tile_pos, ...)` = live target 位 | **真 leak → belief** ✓ |
| **E3** | `found_subjugate:1278` | `try_set(..., TASK_ATTACK, state.teams[prey_id].tile_pos, ...)` = live prey 位 | **真 leak → belief** ✓ |
| **E4** | `_assign_encirclement:137` | `target_pos = BeliefSystem.best_estimate(state, leader_id, target_id)` + F1 sentinel guard(`:141` 缺 belief→return) | **★已 belief 化（T-02/F1）→ 前提過期，勿改** |
| **E5** | `_assign_breakout`→`_find_escape_dir:207` | `var ev = e.tile_pos - origin`（enemy_teams 已排除同-faction/獨立=純敵位）= live 敵位算逃向 | **真 leak → belief** ✓ |
| **E6** | `_tick_envoy:1396` | `est_pos = BeliefSystem.best_estimate(...)` + `:1399` 攔截預測 lead + proximity/timeout | **★已 belief 化 → 前提過期，勿改** |

## ★scope 訂正（blocker：勿盲改已修站）
- **E4 encirclement 已 belief**：`:137 best_estimate` 讀 leader team_intel 最後已知位 + `:141` sentinel guard（缺 belief→不包圍）。註「T-02」「F1 感知鐵律」= **前一 slice 已修**。member assignment loop（`:147-157`）用 belief `target_pos` + 自 faction member 位（物理/自身=合法）+ dir 幾何，**無別的 live 敵位讀**。→ **E4 no-op，勿再 touch**（重改 working belief 碼 = 引入 regression）。
- **E6 envoy 已 belief**：`_tick_envoy:1396 best_estimate` + `:1399` 攔截預測 + `:1401` belief last-seen + release/proximity/timeout（`:1406-1410`）全在。→ **E6 no-op，勿再 touch**（審點3「別破既有 tracking」已由 impl 前置滿足，因為它本就 belief）。
- **∴ 真 dispatch scope = E1/E2/E3/E5 四站**。E4/E6 從 spec 表移除或標「已完成」。

## 審點回覆
1. **E1/E2/E3 belief 化 → CLEAN**。三站明確「他隊當前位當 move 目標」→ `belief_pos(state, self.team_id, X)` + 無 belief guard（E1/E3 攻擊：不 try_set/釋放；E2 JOIN：`return false` caller 不 fallthrough）。同範式 options:194。
   - **E2 小 nuance（非 blocker）**：JOIN 併入 survival-class，target 可能同-faction ally。但（a）併入多為投靠**非-ally 強隊**求生（b）belief_pos 對同-faction 成員本就近 live（共享情報）→ belief 保守且安全，無論 target 屬性。判 belief。
2. **E4/E5 逐 site → E4 已 belief(no-op)；E5 真 leak → belief**。E5 `_find_escape_dir` 讀**敵**位（`:169-171` 已排除 `faction_id==self or ==-1`）算逃向 = 純敵位自衛幾何，**非同-faction 協調 tally → 不屬 invariants 豁免段**。逃向該從 last-seen belief 算（脫視野敵可甩=同攻擊 evasion，intended）。→ E5 belief。E5 有多敵求和向量（`:207` Σ enemy vec）但那是**單隊自衛**幾何非 faction 級 known_member tally，belief per-enemy 化即可。
3. **E6 envoy → 已 belief(no-op)**，proximity/timeout 本就在，無需動。
4. **無 belief 守衛 → CLEAN**（範式一致）：E1/E3 不 dispatch/釋放、E2 return false、E5 無 belief 的敵跳過（`_find_escape_dir` 若某敵無 belief→該敵不計入逃向，非 fallback-live）。守 invariants「無估=保守」。
5. **攻擊/逃脫視野甩追=intended → 認可**。E1/E3 belief last-seen 攻擊 + E5 belief 逃向 → 敵脫視野可甩掉追擊/誤判逃向 = 伏擊/佯動湧現，同 attack/threat evasion，intended 深度非 regression。reviewer 認可此語意。

## 回覆
issues（scope 訂正）→ 兩動作後 CLEAN dispatch：
1. **scope 收斂 E1/E2/E3/E5**（E4/E6 已 belief，移出/標完成，implementer 勿 touch）。
2. TDD leak 測補 E1/E2/E3/E5（真值≠belief 兩向 + 無 belief→不 dispatch）；E4/E6 不需新測（已有 T-02/F1 覆蓋，可 grep 確認）。
修法方向（belief_pos + 無估保守）我認可。scope 收斂後 dispatch。impl pre-merge R² 重點：E1/E2/E3/E5 belief 化 + **E4/E6 diff 應為空（未被誤動）** + grep 這四站無殘留 live `state.teams[X].tile_pos`/`e.tile_pos` 作 move 目標。
