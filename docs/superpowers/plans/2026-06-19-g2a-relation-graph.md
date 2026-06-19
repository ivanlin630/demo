# G2a 關係圖 schema Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建 typed-edge 關係圖基礎縫（`RelationGraph` helper + `PersonData.relation_edges`），並在既有 memory 寫入點**同步填** typed 邊（feud/gratitude/protect）。純結構 + 寫入，**無 reader → 無行為改**（G2b/G2d 才消費）。

**Architecture:** 仿 `AnonCohort` 模式——`RelationGraph` 純 static 函數操作 `Array` of 邊 dict，核心只按 `type`/`target` filter（加型別=加 reader，零核心改，達 WHAT spec §4 硬約束）。保留扁平 `relations` 純量泛好感不動（migration 裁定 (a)，語義分職）。

**Tech Stack:** Godot 4.2.2 GDScript；新 `class_name RelationGraph` → 建後須 `--import` 重建 class 快取；headless harness（`_test_*` 註冊於 `_initialize()`，`assert` 失敗即中止）。

## Global Constraints

- 跑 wrapper：`.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`（UTF-8）。新增 class_name 後先 `.\tools\godot.ps1 --headless --import`。
- 新 `_test_*` 須在 `_initialize()` 加呼叫註冊。
- **無行為改**原則：本 plan 只加結構 + 寫入，**不加 reader**（讀 = G2b/G2d）。回歸閘須與改前**完全一致**（既有測試 0 變動）。
- WHAT 來源：`specs/2026-06-19-g2-goal-anchor-design`（§4 硬約束）；HOW：`specs/2026-06-19-g2-goal-anchor-how-design` §2。
- 回歸閘：`=== DONE ===` + 0 assert fail + InvariantAudit 0 + coin_eq 守恆。

## File Structure

- `scripts/simulation/relation_graph.gd`（新，`class_name RelationGraph`，純 static helper）。
- `scripts/data/person_data.gd`（加 `relation_edges` 欄位）。
- `scripts/simulation/npc_ai_system.gd`（`write_memory` 同步寫 typed 邊）。
- `scripts/debug/headless_test.gd`（測試）。

---

### Task 1: `RelationGraph` helper + `PersonData.relation_edges` 欄位

**Files:**
- Create: `scripts/simulation/relation_graph.gd`
- Modify: `scripts/data/person_data.gd`（:60 `relations` 附近加 `relation_edges`）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Produces: `class_name RelationGraph` 純 static——
  - `add_edge(edges:Array, type:String, target:int, intensity:float, tick:int) -> void`（同 type+target 已存在 → 取 max intensity + 更新 tick；否則 append）
  - `edges_of_type(edges:Array, type:String) -> Array`
  - `edges_to(edges:Array, target:int) -> Array`
  - `strongest(edges:Array, type:String) -> Dictionary`（intensity 最高，無回 `{}`）
- `PersonData.relation_edges: Array = []`（邊 dict：`{type,target,intensity,tick}`）。

- [ ] **Step 1: 寫失敗測試**

加到 `scripts/debug/headless_test.gd`：

```gdscript
func _test_relation_graph_core() -> void:
	print("--- RelationGraph 核心 ---")
	var edges: Array = []
	RelationGraph.add_edge(edges, "feud", 7, 0.5, 100)
	RelationGraph.add_edge(edges, "gratitude", 8, 0.3, 100)
	assert(edges.size() == 2, "兩條邊")
	# 同 type+target → 取 max intensity，不新增
	RelationGraph.add_edge(edges, "feud", 7, 0.9, 120)
	assert(edges.size() == 2, "同邊不重複新增")
	assert(RelationGraph.strongest(edges, "feud")["intensity"] == 0.9, "取 max intensity")
	assert(RelationGraph.strongest(edges, "feud")["tick"] == 120, "tick 更新")
	# 較低 intensity 不覆蓋
	RelationGraph.add_edge(edges, "feud", 7, 0.2, 130)
	assert(RelationGraph.strongest(edges, "feud")["intensity"] == 0.9, "低值不蓋")
	# 查詢
	assert(RelationGraph.edges_of_type(edges, "feud").size() == 1, "feud 1 條")
	assert(RelationGraph.edges_to(edges, 8).size() == 1, "指向 8 的 1 條")
	assert(RelationGraph.strongest(edges, "protect").is_empty(), "無 protect 回 {}")
	print("RelationGraph core OK")

func _test_person_relation_edges_default() -> void:
	print("--- PersonData.relation_edges 預設 ---")
	var p := PersonData.new()
	assert(p.relation_edges is Array and p.relation_edges.is_empty(), "預設空 Array")
	print("relation_edges default OK")
```

`_initialize()` 加兩行註冊。

- [ ] **Step 2: 跑 harness 驗證失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `RelationGraph` class 不存在 / `relation_edges` 欄位無 → parse 或 assert 失敗。

- [ ] **Step 3: 建 RelationGraph + 欄位**

建 `scripts/simulation/relation_graph.gd`：

```gdscript
class_name RelationGraph

# typed-edge 關係圖。邊：{ "type": String, "target": int, "intensity": float, "tick": int }
# 純 static 操作 Array；核心只按 type/target filter → 加型別=加 reader,零核心改(WHAT §4)。
# G2 用型別：feud / killed / protect / gratitude。未來 kin/spouse/master 等同型塞入。

static func add_edge(edges: Array, type: String, target: int, intensity: float, tick: int) -> void:
	if target == -1:
		return
	for e in edges:
		if e["type"] == type and e["target"] == target:
			e["intensity"] = maxf(float(e["intensity"]), intensity)
			e["tick"] = tick
			return
	edges.append({ "type": type, "target": target, "intensity": intensity, "tick": tick })

static func edges_of_type(edges: Array, type: String) -> Array:
	var out: Array = []
	for e in edges:
		if e["type"] == type:
			out.append(e)
	return out

static func edges_to(edges: Array, target: int) -> Array:
	var out: Array = []
	for e in edges:
		if e["target"] == target:
			out.append(e)
	return out

static func strongest(edges: Array, type: String) -> Dictionary:
	var best: Dictionary = {}
	var best_i: float = -1.0
	for e in edges:
		if e["type"] != type:
			continue
		if float(e["intensity"]) > best_i:
			best_i = float(e["intensity"])
			best = e
	return best
```

`scripts/data/person_data.gd` 在 `var relations: Dictionary = {}`（:60）下加：

```gdscript
var relation_edges: Array = []   # G2 typed-edge 關係圖（feud/killed/protect/gratitude；見 RelationGraph）
```

- [ ] **Step 4: 重建 class 快取 + 跑 harness 驗證通過**

```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `RelationGraph core OK` / `relation_edges default OK`，整輪 `=== DONE ===`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/relation_graph.gd scripts/data/person_data.gd scripts/debug/headless_test.gd
git commit -m "feat(g2a): RelationGraph typed-edge helper + PersonData.relation_edges"
```

---

### Task 2: write_memory 同步填 typed 邊（additive，無行為改）

**Files:**
- Modify: `scripts/simulation/npc_ai_system.gd`（`write_memory` :6-14）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: `RelationGraph.add_edge`（Task 1）。
- Produces: `write_memory` 在既有 `_update_relations`/`_trigger_goals` 後**additive** 寫 typed 邊。映射（對齊既有 `_trigger_goals`）：`betrayal/looted/extorted → feud`、`kindness/aided_in_battle → gratitude`、`master → protect`。**無 reader → 行為不變**。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_g2a_memory_writes_edges() -> void:
	print("--- G2a：write_memory 同步填 typed 邊 ---")
	var ai := NpcAiSystem.new()
	var p := PersonData.new(); p.id = 1
	ai.write_memory(p, "looted", 9, 100, 0.7)      # → feud
	ai.write_memory(p, "aided_in_battle", 10, 100, 0.5)  # → gratitude
	ai.write_memory(p, "master", 11, 100, 0.6)     # → protect
	assert(RelationGraph.strongest(p.relation_edges, "feud").get("target", -1) == 9, "looted→feud→9")
	assert(RelationGraph.strongest(p.relation_edges, "gratitude").get("target", -1) == 10, "aided→gratitude→10")
	assert(RelationGraph.strongest(p.relation_edges, "protect").get("target", -1) == 11, "master→protect→11")
	# 既有行為不變：flat relations + goals 照常
	assert(p.relations.has(9), "扁平 relations 仍寫")
	assert(p.goals.size() >= 1, "goals 仍觸發")
	# subject_id -1 不寫邊
	var before: int = p.relation_edges.size()
	ai.write_memory(p, "looted", -1, 100, 0.5)
	assert(p.relation_edges.size() == before, "subject -1 不加邊")
	print("G2a memory edges OK")
```

`_initialize()` 加註冊。

- [ ] **Step 2: 跑 harness 驗證失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `relation_edges` 空（write_memory 還沒寫邊）→ `strongest` 回 {} → assert 失敗。

- [ ] **Step 3: 實作 additive 寫邊**

`scripts/simulation/npc_ai_system.gd` 的 `write_memory`（:6-14）末加（`_trigger_goals` 後）：

```gdscript
func write_memory(p: PersonData, type: String, subject_id: int,
		tick: int, intensity: float) -> void:
	p.memory.append({
		"type": type, "subject_id": subject_id,
		"tick": tick, "intensity": intensity,
	})
	_trim_memory(p)
	_update_relations(p, type, subject_id, intensity)
	_trigger_goals(p, type, subject_id)
	_write_relation_edge(p, type, subject_id, tick, intensity)   # G2a：同步 typed 邊

func _write_relation_edge(p: PersonData, type: String, subject_id: int,
		tick: int, intensity: float) -> void:
	# G2a additive：對齊 _trigger_goals 映射，填 typed 邊。reader 在 G2b/G2d。
	match type:
		"betrayal", "looted", "extorted":
			RelationGraph.add_edge(p.relation_edges, "feud", subject_id, intensity, tick)
		"kindness", "aided_in_battle":
			RelationGraph.add_edge(p.relation_edges, "gratitude", subject_id, intensity, tick)
		"master":
			RelationGraph.add_edge(p.relation_edges, "protect", subject_id, intensity, tick)
```

> `add_edge` 內已 guard `target==-1` → subject_id -1 安全。

- [ ] **Step 4: 跑 harness 驗證通過 + 無行為改**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `G2a memory edges OK`；整輪 `=== DONE ===`、**既有測試 0 變動**（additive，無 reader）、coin_eq 守恆、InvariantAudit 0、1000 Tick 無崩潰。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/npc_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g2a): write_memory 同步填 typed 關係邊(additive,無reader)"
```

---

### Task 3: invariant 落檔

**Files:**
- Modify: `docs/invariants.md`

- [ ] **Step 1: 加 invariant**

`docs/invariants.md` 加：

```markdown
### 關係圖（typed-edge）
- typed 關係事實只經 `RelationGraph`（add_edge/edges_of_type/edges_to/strongest）寫讀 `PersonData.relation_edges`。
- 圖核心**型別無關**：只按 `type`/`target` filter；加新型別 = 加 reader，**禁改 RelationGraph 核心**（WHAT spec §4 硬約束）。
- 扁平 `relations`（純量泛好感）與 typed 圖**語義分職**並存：前者連續情感（loyalty/反應），後者事件型關係邊（feud/protect/gratitude/killed）。
- G2 用型別：`feud`/`gratitude`/`protect`（write_memory 填）/`killed`（G2d 死亡鏈）。未來 `kin`/`spouse`/`master` 等同型塞入。
```

- [ ] **Step 2: Commit**

```bash
git add docs/invariants.md
git commit -m "docs(g2a): 關係圖 typed-edge invariant(核心型別無關)"
```

---

## Self-Review 註記

- **spec 覆蓋**：RelationGraph helper(Task1，§4 硬約束)、relation_edges 欄位(Task1)、memory→邊填充(Task2)、invariant(Task3)。
- **無行為改保證**：本 plan 不加任何 edge **reader**；write_memory 寫邊為 additive。既有測試須 0 變動——若漂移即 bug，停查。
- **遷移裁定 (a)**：扁平 `relations` 不動（泛好感保留），新增 `relation_edges`（typed）。
- **OUT of G2a**（不做）：邊的 reader（G2b 階梯 / G2d 脫軌）、血仇傳播（G2d 死亡鏈寫 feud）、死者邊 cleanup（待有 reader 再加，現無害）、`killed` 型別填充（G2d）、`decay`（暫不需，YAGNI）。
- **新 class_name**：Task1 後必 `--import` 才跑得動測試。
