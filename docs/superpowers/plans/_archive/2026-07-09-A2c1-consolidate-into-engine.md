# A2c-1 Implementation Plan — FA5 consolidate 折入統一引擎 option

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development or superpowers:executing-plans. Steps use checkbox (`- [ ]`).

**Goal:** faction 整併(MERGE) 從 `_assign_member_tasks` 的 weigh 前 pre-gate → 引擎 option「整併」競秤（FA5），行為保真。

**Architecture:** 鏡射 A2a/A2b option-fold：新 ctx 欄 `consolidate_target_id`（`consolidate_target_of` 抽現行兩支 target 決策）→ 新 option「整併」+ term `consolidate_drive`（flat 高量級保「現行 fire 恆勝」）→ 拆 `_assign_member_tasks` pre-gate。`order_target` 由既有 `_wire_threat_task:1535` 消費（零新 dispatch-key）。survival-sticky 由 TaskArbiter priority-gate 保（非 rank 內競秤）。

**Tech Stack:** Godot 4.2.2 GDScript；測試=headless bed 斷言（`.\tools\godot.ps1 --headless --script <bed>`）。

## Global Constraints（spec 原文，每 task 隱含）

- **觸發三常數不動**：`SMALL_TEAM_RATIO=0.3` / `SMALL_VS_LARGE=0.33` / `CONSOLIDATE_MAX_DIST=3`。
- **行為保真硬線**：`seeded_warring_bed` before/after `total_diffs=0`（measure 階段校準 `CONSOLIDATE_DRIVE`）。
- **`consolidate_target_of` 逐條件等價** 現行 `_try_consolidate_merge`（1419-1443）。
- **不碰**：`_decide_unified` 決策邏輯（唯依賴既有 `_wire_threat_task` order_target 消費）、survival/threat/faction_duty/intent_fit term、`interaction_system` TASK_MERGE 消費端、leader/子隊/solo 路、FA6/7/8。
- spec：`docs/superpowers/specs/2026-07-09-A2c1-consolidate-into-engine.md`（file:line 改點權威）。
- 逐步 commit；UTF-8 wrapper 跑 godot。

---

### Task 1: ctx 欄 `consolidate_target_id` + `consolidate_target_of` helper

**Files:**
- Modify: `scripts/simulation/decision/decision_context.gd`（+欄 + gather 內算）
- Modify: `scripts/simulation/faction_ai_system.gd`（+static `consolidate_target_of`）
- Test: `scripts/debug/a2c1_consolidate_bed.gd`（新）

**Interfaces:**
- Produces: `DecisionContext.consolidate_target_id: int`；`FactionAISystem.consolidate_target_of(state, mt, f) -> int`（回 absorber_id / leader_team_id / -1）。

- [ ] **Step 1: 寫失敗測試** — `a2c1_consolidate_bed.gd`：造 faction（leader + 1 小 member near 有容量 absorber member），斷言 `FactionAISystem.consolidate_target_of(state, small_mt, f)` == absorber_id；再造「small member 不夠小」case 斷言 == -1；「攻擊 goal + member 近 leader 有容量」case 斷言 == leader_team_id。**同時對照現行**：暫存 `_try_consolidate_merge` 結果應與 `consolidate_target_of` 是否命中一致（等價證）。
- [ ] **Step 2: 跑測試確認 fail**（`consolidate_target_of` 未定義）— `.\tools\godot.ps1 --headless --script scripts/debug/a2c1_consolidate_bed.gd` → 期 FAIL。
- [ ] **Step 3: 實作** — `faction_ai_system.gd` 加 static `consolidate_target_of`（spec D3 code；內用 `FactionAISystem.new()._find_absorber`/`._hex_dist` instance-call，逐條件鏡射 1421-1442）。`decision_context.gd` +欄 `var consolidate_target_id: int = -1`，`gather` 內算（spec D3：`team.faction_id != -1 and team.parent_team_id == -1 and team.team_id != f.leader_team_id` 才呼 helper）。
- [ ] **Step 4: 跑測試確認 pass** — 期三 case + 等價對照全 PASS。
- [ ] **Step 5: godot import 綠 + commit** — `.\tools\godot.ps1 --headless --import` 無錯；`git add -A && git commit -m "feat(A2c-1): consolidate_target_id ctx + consolidate_target_of（抽 FA5 target 兩支，等價現行）"`。

---

### Task 2: term `consolidate_drive` + weight

**Files:**
- Modify: `scripts/simulation/decision/terms.gd`（+const、+eval 分支、+w_term 映射）
- Test: `scripts/debug/a2c1_consolidate_bed.gd`（擴充）

**Interfaces:**
- Consumes: `ctx.consolidate_target_id`（Task 1）。
- Produces: term `"consolidate_drive"`；`const CONSOLIDATE_DRIVE: float = 2.0`。

- [ ] **Step 1: 寫失敗測試** — bed 加：ctx 有 `consolidate_target_id != -1` → `DecisionTerms.eval("consolidate_drive", ctx, "整併")` == `DecisionTerms.CONSOLIDATE_DRIVE`；opt≠"整併" 或 target==-1 → 0.0。
- [ ] **Step 2: 跑測試確認 fail**（term 未定義回 0）。
- [ ] **Step 3: 實作** — `terms.gd`：`const CONSOLIDATE_DRIVE: float = 2.0`；`eval` 加 `"consolidate_drive"` 分支（spec D2）；w_term 映射表 +`"consolidate_drive": 1.0`（查 terms.gd 現有 weight 映射處補）。
- [ ] **Step 4: 跑測試確認 pass**。
- [ ] **Step 5: commit** — `git commit -m "feat(A2c-1): consolidate_drive term（flat 高量級,保現行 fire 恆勝）"`。

---

### Task 3: option「整併」（REGISTRY + applicable + to_task）

**Files:**
- Modify: `scripts/simulation/decision/options.gd`
- Test: `scripts/debug/a2c1_consolidate_bed.gd`（擴充）

**Interfaces:**
- Consumes: `ctx.consolidate_target_id`（Task 1）、`consolidate_drive`（Task 2）。
- Produces: option `"整併"`；`to_task` 回 `{task: TASK_MERGE, target: tile, order_target: ctid}`。

- [ ] **Step 1: 寫失敗測試** — bed 加：`ctx.consolidate_target_id != -1` → `"整併" in DecisionOptions.applicable(ctx)`；==-1 → 不在。`DecisionOptions.to_task(state, small_mt, "整併")` 回 `task==TASK_MERGE`、`target==absorber.tile_pos`、`order_target==absorber_id`。
- [ ] **Step 2: 跑測試確認 fail**。
- [ ] **Step 3: 實作** — `options.gd`：REGISTRY +`"整併": ["consolidate_drive"]`；`applicable` +`"整併"` 分支（`if ctx.consolidate_target_id != -1: out.append(opt)`）；`to_task` +`"整併"`（spec D1：局部 `DecisionContext.gather` 取 `consolidate_target_id`，回 TASK_MERGE + target tile + order_target）。
- [ ] **Step 4: 跑測試確認 pass**。
- [ ] **Step 5: commit** — `git commit -m "feat(A2c-1): 整併 option（applicable gate + to_task TASK_MERGE+order_target）"`。

---

### Task 4: 拆 `_assign_member_tasks` consolidate pre-gate

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（拆 1396-1404 pre-gate；`_try_consolidate_merge` 無他 caller 則刪）
- Test: `scripts/debug/a2c1_consolidate_bed.gd`（擴充：整合行為）

**Interfaces:**
- Consumes: option/term/ctx（Task 1-3）。

- [ ] **Step 1: 寫失敗測試** — bed 加整合 case：小 member（有整併 target、非 survival）跑一次 faction tick 後，斷言其 `current_task == TASK_MERGE` 且 `order_target_id == absorber_id`（現在**經引擎**達成）；且 grep 確認 `HandBrainProbe` 該 member src 標 `unified` 非 pre-gate。survival case：餓 member（food<DESPERATION，已在 survival task）跑 tick 後仍 survival task、**非**整併（priority-gate 保）。
- [ ] **Step 2: 跑測試確認 fail 或 mixed**（拆前：member 走 pre-gate 而非 unified src）。
- [ ] **Step 3: 實作** — `faction_ai_system.gd` `_assign_member_tasks`：刪 1396-1404 的 `_try_consolidate_merge` 呼叫 + `continue` + phase_timing 包裹（spec D4）。grep `_try_consolidate_merge` 確認無他 caller → 刪該 func（1419-1443）；`_find_absorber`（1568）保留（`consolidate_target_of` 用）。
- [ ] **Step 4: 跑測試確認 pass** — 整合 case：整併經引擎達成；survival case：survival 保。
- [ ] **Step 5: sanity + commit** — `.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd` ≥1000 tick 無崩、`[Merge]…完全合併` print 仍出現；`git commit -m "refactor(A2c-1): 拆 _assign_member_tasks consolidate pre-gate（整併走引擎競秤）"`。

---

### Task 5: 憲法閘 baseline 更新 + gate 綠

**Files:**
- Modify: `scripts/debug/constitution_baseline.txt`

- [ ] **Step 1: 跑 gate 看現況** — `.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd`。拆 pre-gate 後預期：`_try_consolidate_merge` 兩 try_set(1428/1439) 消失、整併 try_set 現走 `_decide_unified`→to_task 的引擎 dispatch（既有落點）。若 gate 抓差異 → 記下。
- [ ] **Step 2: 更新 baseline** — `constitution_baseline.txt`：移除 `_try_consolidate_merge` 兩 try_set 指紋；`_assign_member_tasks` 註記更新（pre-gate→引擎 option）。若整併 dispatch 為新指紋 → 收編（合法引擎 dispatch，非 off-engine）。
- [ ] **Step 3: 跑 gate 確認綠** — `[CONSTITUTION-GATE] PASS`（current ⊆ baseline）。
- [ ] **Step 4: commit** — `git commit -m "chore(A2c-1): constitution baseline 更新（consolidate pre-gate→引擎 option）"`。

---

## measure 階段交接（量測員，非本 plan task）

- **CONSOLIDATE_DRIVE 校準**：measure 跑 `seeded_warring_bed` before(main)/after(本 worktree) 逐點對照。`total_diffs != 0` → 調 `CONSOLIDATE_DRIVE`（升→整併更常勝；若 threat 下整併行為變無論如何 ≠0 → 報藍圖）。目標 `total_diffs=0`。
- **守衛數字**（measure 產、QA 判門檻）：`[Merge]` count > 0 且量級同 before（整併不塌成零）；餓/危小隊選 survival 非整併（抽驗計數）。
- HOB bed：`GODOT_TIMEOUT=600`；整併 member src=`unified`、obey% 不降、determinism PASS。

## Self-Review
- **Spec coverage**：D1(Task3+order_target 依賴既有)/D2(Task2)/D3(Task1)/D4(Task4)/D5(Task5) 全覆蓋。✓
- **Placeholder scan**：無 TBD；每 code step 指 spec file:line。✓
- **Type consistency**：`consolidate_target_id:int`、`consolidate_target_of(state,mt,f)->int`、`CONSOLIDATE_DRIVE:float` 跨 task 一致。✓
