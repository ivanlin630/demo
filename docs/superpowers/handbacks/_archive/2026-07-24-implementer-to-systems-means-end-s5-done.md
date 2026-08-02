---
from: implementer
to: systems
status: consumed
topic: "[done·means-end S5 委派 peer option·gate②正解·_try_dispatch_or_invite 不退 flag followup·收+驗+S5 R²請] feat/means-end-s5-delegate 3f765ad8 off local main 65f5d331(含 S4)。修:_delegate_variant(build/settle 產委派變體)/★gate②正解(viability pop−settler≥10,attempt=dispatch 同源)/餘力 gate/consumer wiring _dispatch_goal_delegate(unified/solo 派 subteam skip)。★_try_dispatch_or_invite residency 語意不同→不退 flag followup(你判+R² 收)。TDD 9/9(gate② pop 8-12 not applicable/pop≥13 applicable)/headless 0-new/gate 74 removed=0/determinism 0efd2191。完成→收+驗+S5 R²→CLEAN merge→dispatch S6。"
branch: feat/means-end-s5-delegate
commit: 3f765ad8
spec: docs/superpowers/specs/2026-07-24-long-range-planning-means-end-HOW.md
---

# done：means-end S5 委派 peer option（gate② 正解，請 systems 收+驗+R²）

HOW spec §10 S5+§5。build/settle 型 action「派子隊做」變體進 rank 池，跟「自己做」並列競 util（多線平行）。

## 修（組件 D）
1. **`_delegate_variant`**：build/settle candidate（TASK_BUILD/SETTLE）產委派變體（`delegate:true`）並列 rank 池。非 build/settle → 無變體。
2. **★gate② 正解**：委派變體 applicable = 真 viability（`pop − settler[clampi(pop/4,2,5)] ≥ MIN_PARENT_POP_AFTER_DISPATCH=10`）——★**attempt=dispatch 同源** → 根治 pop 8-12 浪費帶（舊 `_try_dispatch_or_invite:567` attempt≥8 vs dispatch guard≥13 矛盾）。pop 不夠→無委派變體（只自己做）。
3. **委派 util** = 自己做 util + 多線紅利（母隊留守本業+子隊並行=不離 food base）− 餘力成本；clamp < survival（must-fix① 沿用）。TEST VALUE（S6 折現+校準）。
4. **餘力 gate 配額** = pop-guard（窮隊少線/強權多線=寫實；multi-line 無委派恆贏由 pop-guard applicable 擋）。
5. **consumer wiring `_dispatch_goal_delegate`**：winner delegate candidate → `SubteamSystem.dispatch`（advisor via `_pick_or_promote_advisor` + settler pop + action task/target）；unified/solo 派、**subteam skip**（避 sub-sub nesting）。派失敗→試次佳（自己做）。

## ★_try_dispatch_or_invite 退役判斷（你判）→ **不退，flag followup**
- `_try_dispatch_or_invite`（`faction_ai:554`）= **residency repopulate**（派子隊/invite 補既有 owned outpost 居民）——語意 **≠** 我 S5 委派（build/settle **goal action** 派子隊建設）。**不自然涵蓋** residency。
- ∴ **不強退**（照 dispatch 指示；residency 是不同機能，強退需驗融合 residency 不退化=風險）。gate `removed=0`。
- **★followup**：`_try_dispatch_or_invite` 自身 attempt(≥8) vs dispatch(pop-settler≥10) 8-12 浪費帶仍在（residency 路），可另 slice de-patch（用 S5 同源 viability idiom）。非本 slice blocker。你 R² 裁是否納 followup backlog。

## 驗（皆綠）
- TDD `means_end_s5_test` **9/9**（①delegate 變體出現 ②★gate② pop 8/12 not applicable + pop≥13 applicable ③餘力 gate pop 5 無變體 ④delegate to_task settler ⑤must-fix① regression 委派 util clamp≤GOAL_UTIL_CAP ⑥非 build/settle 不委派）。
- headless **0-new**（3 baseline）。
- **gate PASS sites=74 removed=0**（委派讀狀態 + `SubteamSystem.dispatch` 既有；無新 god-view/RNG；`_try_dispatch_or_invite` 未退故 removed=0）。
- determinism seed1337×2mo×2 跑 byte-identical MD5 `0efd2191`（委派讀狀態禁 randf，tie-break；=S4 digest：delegate 在 2mo 場景少觸發，delegate 讀狀態零 RNG 一致）。

## ★whole-system-first
S5 只委派 + gate② + 餘力；折現完整 = S6 / goal 生成 cadence 泛化 + perf（S4 flagged）= S7 未提前。

## 完成判定 = systems + reviewer R²（★非自判）
請 systems 收 + 驗 + S5 R²（★reviewer 查 **gate② 正解**[viability=attempt=dispatch 同源無浪費] + 委派 viability + **multi-line 無委派恆贏**[pop-guard applicable 擋] + _try_dispatch_or_invite 不退判斷是否認可 + must-fix① regression）→ CLEAN merge → dispatch S6（折現：投資型延遲折現+人格折現率）。
base=local main 65f5d331（含 S4）。
