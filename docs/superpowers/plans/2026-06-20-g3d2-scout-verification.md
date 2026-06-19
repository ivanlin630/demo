# G3d-2 scout 主動查證迴路 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 完成 WHAT §7 核心迴路：**情報打架 → 不確定 → 慎重者派斥候查證 → 親見壓謊 → 確定 → 動；莽者跳過 → 被假情報誘殺**。G3d-1 已有「不確定→按兵」+ 誘殺；本 plan 把慎重者的**被動按兵**升級為**主動 scout 查證**（dispatch 斥候→移入視野→親見→uncertainty 塌→commit）。前提修：uncertainty 改 **credibility-weighted**（否則親見壓不掉舊假 claim、scout 永不收斂）。

**Architecture:** G3d-1 `_evaluate_prosperity_attack` gate-fail = `return`（被動）。本 plan：(1) uncertainty 重定義為 cred-weighted（親見主導→塌），(2) gate-fail → dispatch `TASK_SCOUT`(move_target=prey best_estimate 位置)；斥候移入視野 → vision `_write_tier01` 寫親見 → 下 cadence uncertainty 已低 → confident_enough 過 → 攻擊。莽者(低慎重)從不 gate-fail → 不 scout → 攻假 belief → 誘殺。

**Tech Stack:** Godot 4.2.2 GDScript；`BeliefSystem`/`faction_ai_system`；既有 movement + vision + TaskArbiter；headless harness。

## Global Constraints

- wrapper 跑；改後 `--import`。
- WHAT/HOW 來源：`specs/2026-06-19-g3-info-decision-design`（§7 查證迴路）、`...-how-design`（§5 G3d）。
- 回歸閘：`=== DONE ===` + 0 assert fail + coin_eq=0 + InvariantAudit 0 + 1000 Tick。不用 multi drift。**特別驗：(a) 仍有攻擊（不凍結）；(b) 有 scout 發生（`[Scout]` log）；(c) scout 後 uncertainty 降→該團轉攻擊（迴路收斂，非永 scout）。**
- **行為允許變**；閘 = 不崩+守恆+迴路收斂。
- **OUT（延 post-measure，本 plan 不做）**：
  - **威脅(防禦)uncertainty-gate**（§8）= 極性與攻擊相反，enrichment，量測後評估。
  - **team_known 事件謠言 claim 化**（§3 主味）= 獨立 arc，**碰 WHAT 已告知藍圖**（progress 註，待藍圖確認延後 OK）。
  - 斥候被抓/被餵假（情報戰 C）。

## 鎖定設計決策（實作者勿再設計）

- **uncertainty 改 credibility-weighted**（修 scout 收斂前提）：
  ```
  top    = max effective_credibility(claim)  over claims          # 最強源信度（含時效）
  best   = best_estimate population_est                            # 最高 eff_cred claim 的值
  spread = Σ wᵢ·|vᵢ − best| / max(Σ wᵢ·best, ε)   (wᵢ = effective_credibility, vᵢ = claim pop_est)
  uncertainty = clamp((1 − top) + spread, 0, 1)
  ```
  - 親見單源(cred 1)：top=1, spread=0 → **0**（確定）。
  - 純 relay 單源(cred 0.4)：top=0.4, spread=0 → **0.6**（未驗→不確定，慎重者 scout）。
  - 親見 + 舊假流民：top≈1，假 claim wᵢ 低(類型+時效衰)→spread 小 → **低**（親見壓謊，scout 收斂）。✓
  - 兩新鮮高 cred 矛盾：top≈0.8，spread 大 → **高**（真打架→查證）。
  - 無 claim → 1.0。取代 G3b/c 的 raw 分歧 uncertainty（G3c uncertainty 測試對齊新公式）。
- **scout dispatch**（gate-fail → 主動查證，取代 G3d-1 被動 return）：
  - 位置：`_evaluate_prosperity_attack` 的 `if not confident_enough(...)` 分支。
  - 行為：`TaskArbiter.try_set(state, team, TeamData.TASK_SCOUT, <prey best_estimate tile_pos>, TaskArbiter.PRIO_DISPATCH, "scout")` + 記 `team.prosperity_target_id = prey_id`（scout 對象 = 待查 prey）；set `team.move_target = prey best_estimate pos`。**不設 combat_target**（純觀察不交戰）。print `[Scout] team=%d → verify prey=%d`。
  - **去重/不 spam**：已在 TASK_SCOUT 且同 prey → 不重 dispatch（移動中）。
  - **收斂**：scout 與 attack 同 `PRIO_DISPATCH` → 下次 prosperity cadence，若 confident_enough now true（親見已寫）→ `try_set TASK_ATTACK` 同 prio 覆蓋 → 攻擊。若 prey 親見後顯示其實強 → find_prosperity_prey/score 不再選它 → 自然放棄（避誘殺）。
  - **timeout**：scout 逾 `SCOUT_TIMEOUT`(TEST VALUE, e.g. TICKS_PER_DAY*3) 未收斂 → release 回常規（防卡）。
  - 莽者(低慎重)：confident_enough 恆過 → 不入此分支 → 直接攻 → 誘殺（不變）。

## File Structure

- `scripts/simulation/belief_system.gd`（uncertainty 重寫 cred-weighted + SCOUT_TIMEOUT const）。
- `scripts/simulation/faction_ai_system.gd`（prosperity gate-fail → scout dispatch + timeout release）。
- `scripts/debug/headless_test.gd`、`docs/invariants.md`、`docs/known_issues.md`、`docs/progress.md`、`docs/superpowers/specs/2026-06-19-g3-info-decision-how-design.md`（系統 owner，記 G3d 拆 + B/C 延後）。

---

### Task 1: uncertainty → credibility-weighted（scout 收斂前提）

**Files:**
- Modify: `scripts/simulation/belief_system.gd`
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- `BeliefSystem.uncertainty` 重寫（介面不變，回 float 0..1；語義改 cred-weighted）。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_uncertainty_credweighted() -> void:
	print("--- G3d-2：cred-weighted uncertainty ---")
	var s := WorldState.new(); s.world = WorldData.new(); s.team_intel = {}
	# 親見單源 → 0
	BeliefSystem.record_claim(s, 1, 2, 1, "親見", {"population_est": 50}, 1.0, false)
	assert(BeliefSystem.uncertainty(s, 1, 2) < 0.05, "親見確定→~0")
	# 純 relay 單源低 cred → 高（未驗）
	var s2 := WorldState.new(); s2.world = WorldData.new(); s2.team_intel = {}
	BeliefSystem.record_claim(s2, 1, 2, 9, "流民", {"population_est": 50}, 0.4, false)
	assert(BeliefSystem.uncertainty(s2, 1, 2) > 0.4, "純 relay→不確定")
	# 親見 + 舊假流民 → 親見壓謊 → 低（scout 收斂關鍵）
	BeliefSystem.record_claim(s, 1, 2, 9, "流民", {"population_est": 300}, 0.3, true)
	assert(BeliefSystem.uncertainty(s, 1, 2) < 0.3, "親見壓舊假→低(收斂)")
	# 兩新鮮高 cred 矛盾 → 高
	var s3 := WorldState.new(); s3.world = WorldData.new(); s3.team_intel = {}
	BeliefSystem.record_claim(s3, 1, 2, 8, "隊友", {"population_est": 50}, 0.8, false)
	BeliefSystem.record_claim(s3, 1, 2, 7, "隊友", {"population_est": 200}, 0.8, false)
	assert(BeliefSystem.uncertainty(s3, 1, 2) > 0.4, "高 cred 矛盾→高")
	print("cred-weighted uncertainty OK")
```

- [ ] **Step 2: 跑 harness 驗證失敗**（舊 raw 公式不符新斷言）

- [ ] **Step 3: 重寫 uncertainty**

```gdscript
static func uncertainty(state: WorldState, obs_id: int, tgt_id: int) -> float:
	var cs: Array = claims(state, obs_id, tgt_id)
	if cs.is_empty(): return 1.0
	var best_val: float = float(best_estimate(state, obs_id, tgt_id).get("population_est", 0.0))
	var top := 0.0
	var wsum := 0.0
	var num := 0.0
	for c in cs:
		var w: float = effective_credibility(state, c)
		top = maxf(top, w)
		wsum += w
		num += w * absf(float((c["value"] as Dictionary).get("population_est", best_val)) - best_val)
	var spread := 0.0
	if wsum > 0.0001 and best_val > 0.0001:
		spread = num / (wsum * best_val)
	return clampf((1.0 - top) + spread, 0.0, 1.0)
```

- [ ] **Step 4: --import + 回歸**

Expected `cred-weighted uncertainty OK`、`=== DONE ===`。**既有 G3b/c uncertainty 測試對齊**（`_test_belief_multiclaim` 分歧斷言、`_test_confidence_gate` 等）→ 改用新公式預期值。漂移逐一核對非 bug。

- [ ] **Step 5: Commit**
```bash
git add scripts/simulation/belief_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g3d2): uncertainty 改 credibility-weighted(親見壓謊→scout 可收斂)"
```

---

### Task 2: scout 查證 dispatch（gate-fail → 派斥候）

**Files:**
- Modify: `scripts/simulation/belief_system.gd`（SCOUT_TIMEOUT const）、`scripts/simulation/faction_ai_system.gd`
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- `_evaluate_prosperity_attack` gate-fail 分支：被動 `return` → scout dispatch + timeout。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_scout_verification() -> void:
	print("--- G3d-2：scout 查證迴路 ---")
	# 慎重 leader team + prey；team 對 prey 持純 relay 不確定 belief
	#   → 跑 prosperity 評估 → 不攻、改 TASK_SCOUT(move_target=prey best_estimate pos)
	# assert team.current_task == TASK_SCOUT 且 move_target 指向 prey 估位
	# 再注入親見 claim(uncertainty 塌) → 下次評估 → 轉 TASK_ATTACK
	# 莽者(慎重低)同 belief → 直接 TASK_ATTACK(不 scout)
	print("scout verification OK")
```

- [ ] **Step 2: 跑 harness 驗證失敗**

- [ ] **Step 3: 實作**

`belief_system.gd`：`const SCOUT_TIMEOUT := WorldState.TICKS_PER_DAY * 3  # TEST VALUE`。

`_evaluate_prosperity_attack` gate-fail 分支（取代 G3d-1 的 `return`）：
```gdscript
	if not BeliefSystem.confident_enough(state, team.team_id, prey_id, _caution):
		# G3d-2：不確定 → 主動派斥候查證（移入視野→親見→uncertainty 塌→下 cadence 攻）。
		var prey_t: TeamData = state.teams.get(prey_id)
		var scout_pos: Vector2i = BeliefSystem.best_estimate(state, team.team_id, prey_id).get("tile_pos", prey_t.tile_pos) if prey_t else team.tile_pos
		# 已在 scout 同 prey → 不重派（移動中）
		if not (team.current_task == TeamData.TASK_SCOUT and team.prosperity_target_id == prey_id):
			if TaskArbiter.try_set(state, team, TeamData.TASK_SCOUT, scout_pos, TaskArbiter.PRIO_DISPATCH, "scout"):
				team.prosperity_target_id = prey_id   # try_set 已設 move_target=scout_pos
				print("[Scout] team=%d → verify prey=%d" % [team.team_id, prey_id])
		return
```

scout timeout release（在 `_evaluate_prosperity_attack` 開頭或 threat-eval 處，避免永 scout）：
```gdscript
	# scout 逾時未收斂 → 釋放回常規（防卡）
	if team.current_task == TeamData.TASK_SCOUT and team.task_reason == "scout" \
			and state.world.current_tick - team.task_start_tick > BeliefSystem.SCOUT_TIMEOUT:
		TaskArbiter.release(team)
```
> 已驗：`task_start_tick`（try_set 設）+ `task_reason`（try_set `_source` 寫入，本 plan 用 `"scout"`）存在。`try_set` 已設 `move_target`，勿重設。

> **scout 追蹤刷新**：scout 移動中，prey 若移動 → move_target 可沿用既有 prosperity 追擊刷新（依 best_estimate 最後已知位置）。確認 scout task 下 movement 會走 move_target。

- [ ] **Step 4: --import + 回歸**

Expected `scout verification OK`、`=== DONE ===`、coin_eq=0、InvariantAudit 0、1000 Tick。**驗：`[Scout]` 出現、仍有 `[ProsperityAttack]`、scout 團最終轉攻擊或 timeout 釋放（無永 scout 卡死）。**

- [ ] **Step 5: Commit**
```bash
git add scripts/simulation/belief_system.gd scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g3d2): scout 主動查證(不確定→派斥候→親見→收斂攻擊;莽者跳過誘殺)"
```

---

### Task 3: invariant + HOW spec + progress + 回歸

**Files:**
- Modify: `docs/invariants.md`、`docs/superpowers/specs/2026-06-19-g3-info-decision-how-design.md`、`docs/known_issues.md`、`docs/progress.md`

- [ ] **Step 1: invariant 補**

`docs/invariants.md` belief 段補：
```markdown
- **uncertainty = credibility-weighted**：`(1−top_eff_cred) + cred 加權值分歧`；親見高 cred 主導 → 壓低不確定（查證可收斂）。
- **scout 查證迴路**：攻擊性 commit gate-fail（慎重者不確定）→ dispatch TASK_SCOUT(移向 best_estimate 位)→ 親見壓謊 → 下 cadence uncertainty 降 → 攻；逾 SCOUT_TIMEOUT 釋放。莽者跳過 → 誘殺。
```

- [ ] **Step 2: HOW spec 更新（系統 owner）**

`...-g3-info-decision-how-design.md`：
- G3d 拆 **G3d-1（決策讀+風險 gate，merged）/ G3d-2（scout 查證+uncertainty cred-weight，本 plan）**。
- 記 **延 post-measure**：威脅(防禦)uncertainty-gate（§8）、team_known 事件謠言 claim 化（§3 主味）→ 待 G3 核心迴路量測後決定。

- [ ] **Step 3: progress / known_issues**

- progress：**G3d-2 ✅ → G3 核心迴路落地**（情報不對稱→可信度→技能識破→決策查證/誘殺全鏈）。延後：威脅 uncertainty、team_known claim 化、情報戰 C。
- **告知藍圖（progress 註）**：team_known 事件謠言 claim 化（§3「主味」）延 post-measure——核心隊伍情報迴路先量，event 謠言獨立 arc。**請藍圖確認延後**。
- TEST VALUE：SCOUT_TIMEOUT、uncertainty top/spread 權重。

- [ ] **Step 4: 全回歸**
```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、coin_eq=0、InvariantAudit 0、1000 Tick、`[Scout]`+`[ProsperityAttack]` 並見、無永 scout。

- [ ] **Step 5: Commit**
```bash
git add docs/invariants.md docs/superpowers/specs/2026-06-19-g3-info-decision-how-design.md docs/known_issues.md docs/progress.md
git commit -m "docs(g3d2): scout 查證+uncertainty invariant + HOW spec(G3d 拆,B/C 延 measure) + 進度"
```

---

## Self-Review 註記

- **uncertainty cred-weight 是 scout 收斂前提**：舊 raw 分歧下親見壓不掉舊假 claim → scout 永不收斂。新公式親見高 cred 主導 → 壓謊 → 收斂。Task1 必先於 Task2。
- **迴路收斂硬驗**：Task2/3 驗 scout 團最終轉攻或 timeout 釋放（無永 scout 卡死）；`[Scout]`+`[ProsperityAttack]` 並見。
- **誘殺 vs 查證對照**：莽者(低慎重)恆過 gate→不 scout→攻假 belief→誘殺；慎重者→scout→親見→真相→攻真弱/放棄真強→避誘殺。= WHAT §7 圖。
- **不凍結**：scout 同 PRIO_DISPATCH 可被攻擊覆蓋；timeout 防卡；莽者不受影響。
- **scope 收斂 = 核心迴路**：威脅(防禦,極性反)+team_known(主味,獨立 arc)延 post-measure。**team_known 碰 WHAT → 已告知藍圖呈報**（非自決）。
- **行為非保留**：uncertainty 公式 + scout 行為。閘 = 不崩+守恆+收斂。既有 uncertainty 測試對齊新公式。
- **執行確認**：新 const/重寫 uncertainty → `--import`；既有 G3b/c uncertainty 斷言對齊；scout task_start_tick/label 欄位確認存在；scout 下 movement 走 move_target 確認。
