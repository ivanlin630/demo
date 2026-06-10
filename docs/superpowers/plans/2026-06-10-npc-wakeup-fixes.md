# NPC Wakeup Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 7 個 surgical fix 救活 NPC 自主行為。解 0 Combat / 0 Trade / 0 Promotion zombie 狀態。

**Architecture:**
- StrategicAI 派 target 加 in-map check + 縮 dir 倍率 + 加距離 guard
- AI gate 加「stuck 視為 idle 重評」邏輯（task 保留）
- Survival SURVIVAL_TASKS 移除 TASK_LOOT
- StrategicAI 加 trade_net handler
- stuck log 加 source

**Spec:** `docs/superpowers/specs/2026-06-10-npc-wakeup-fixes-design.md`

---

## 檔案結構

| 檔案 | 變更 |
|---|---|
| `scripts/simulation/strategic_ai_system.gd` | in-map check + dir 倍率 + 距離 guard + trade_net handler |
| `scripts/simulation/faction_ai_system.gd` | stuck 視為 idle 邏輯 + SURVIVAL_TASKS 移除 TASK_LOOT |
| `scripts/simulation/movement_system.gd` | stuck log 加 source |
| `scripts/debug/headless_test.gd` | 8 個測試 |

## 測試命令

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_multi.gd
```

---

## Task 1: StrategicAI in-map helpers + 套到 encirclement/breakout

**Files:**
- Modify: `scripts/simulation/strategic_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_strategic_in_map_check() -> void:
	print("--- Wakeup Task1: in-map check ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	for x in range(0, 5):
		for y in range(0, 5):
			var tile := HexTileData.new()
			tile.tile_pos = Vector2i(x, y); tile.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tile
	# off-map (10,10) → nearest valid 應在 (4,4) 附近
	var pos = StrategicAiSystem._nearest_valid_tile(state, Vector2i(10, 10), Vector2i(0, 0))
	assert(StrategicAiSystem._is_valid_tile(state, pos), "回 in-map tile，實際=%s" % str(pos))
	assert(StrategicAiSystem._is_valid_tile(state, Vector2i(2, 2)), "(2,2) in map")
	assert(not StrategicAiSystem._is_valid_tile(state, Vector2i(10, 10)), "(10,10) out")
	print("Wakeup Task1 OK (nearest=%s)" % str(pos))
```

- [ ] **Step 2: 加 const + helpers**

於 `strategic_ai_system.gd` 開頭加：

```gdscript
const BREAKOUT_DIST: int = 2     # 原 5，縮為 2
const ENCIRCLE_DIST: int = 1     # 原 2，縮為 1
const BREAKOUT_NEAREST_THRESHOLD: int = 3   # 鄰敵 > 此距不觸發

static func _is_valid_tile(state: WorldState, pos: Vector2i) -> bool:
	return state.world.tiles.has(pos.x * 1000 + pos.y)

static func _nearest_valid_tile(state: WorldState, target: Vector2i, fallback: Vector2i) -> Vector2i:
	if _is_valid_tile(state, target): return target
	var dir: Vector2i = fallback - target
	var step: Vector2i = Vector2i(sign(dir.x), sign(dir.y))
	if step == Vector2i.ZERO: return fallback
	var cur: Vector2i = target
	for _i in range(20):
		cur = cur + step
		if _is_valid_tile(state, cur): return cur
	return fallback
```

- [ ] **Step 3: 套到 _assign_encirclement / _assign_breakout**

找原 `team.strategic_assignments[target_id] = target_pos + dir * 2` 改：

```gdscript
var sa_pos: Vector2i = target_pos + dir * ENCIRCLE_DIST
sa_pos = _nearest_valid_tile(state, sa_pos, target_pos)
team.strategic_assignments[target_id] = sa_pos
```

找 `_assign_breakout` 內 `self_team.tile_pos + best_dir * 5` 改：

```gdscript
var sa_pos: Vector2i = self_team.tile_pos + best_dir * BREAKOUT_DIST
sa_pos = _nearest_valid_tile(state, sa_pos, self_team.tile_pos)
self_team.strategic_assignments[-1] = sa_pos
```

- [ ] **Step 4: 跑 + Commit**

```powershell
git add scripts/simulation/strategic_ai_system.gd scripts/debug/headless_test.gd
git commit -m "fix(strategic_ai): in-map check + dir BREAKOUT/ENCIRCLE const (Task 1)"
```

---

## Task 2: breakout 距離 guard

**Files:**
- Modify: `scripts/simulation/strategic_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_breakout_distance_guard() -> void:
	print("--- Wakeup Task2: breakout 距離 guard ---")
	# Setup: 2 enemy 都在 5 hex 外 → 不觸發 breakout
	# 1 enemy 在 2 hex → 觸發
	# (簡化：直接呼叫 _assign_breakout 並檢查 strategic_assignments)
	# ...
	print("Wakeup Task2 OK")
```

- [ ] **Step 2: 加 guard**

`_assign_breakout` 開頭，於 `if enemy_teams.size() < 2: return` 後加：

```gdscript
# 鄰敵 > 3 hex 不觸發 breakout（看遠敵不必恐慌）
var nearest_dist: int = 9999
for e in enemy_teams:
	var d: int = _hex_dist(self_team.tile_pos, e.tile_pos)
	if d < nearest_dist: nearest_dist = d
if nearest_dist > BREAKOUT_NEAREST_THRESHOLD: return
```

需確認 `_hex_dist` 已存在或加 helper。

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/strategic_ai_system.gd scripts/debug/headless_test.gd
git commit -m "fix(strategic_ai): breakout requires nearest enemy <= 3 hex (Task 2)"
```

---

## Task 3: stuck 視為 idle 重評（AI gate）

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: grep AI gates**

```powershell
grep -n "current_task != TeamData.TASK_IDLE\|current_task in \[" scripts/simulation/faction_ai_system.gd
```

預期找 `_evaluate_prosperity_attack`、`_assign_tasks` 內 攻擊/掠奪 branch、`_trigger_survival` 內。

- [ ] **Step 2: 加 helper + 套**

```gdscript
const STUCK_TASKS: Array = [TeamData.TASK_ATTACK, TeamData.TASK_LOOT]

static func _is_stuck(team: TeamData) -> bool:
	return team.current_task in STUCK_TASKS and team.move_target == Vector2i(-1, -1)
```

各 gate 內加：

```gdscript
# 既有
# if team.current_task != TeamData.TASK_IDLE: return
# 改
if team.current_task != TeamData.TASK_IDLE and not _is_stuck(team): return
```

對 `_evaluate_prosperity_attack`、`_assign_tasks` 攻擊 branch、`_trigger_survival` 開頭。

注意 `_evaluate_prosperity_attack` 也 check `combat_target != -1` → stuck 時 combat_target 仍 -1（未真開戰），無衝突。

- [ ] **Step 3: 測試**

```gdscript
func _test_stuck_allows_reeval() -> void:
	print("--- Wakeup Task3: stuck 視為 idle ---")
	# Setup team task=攻擊 + move_target=(-1,-1) + 環境讓 prosperity 可重新評
	# Expected: 重新派出 attack
	# ...
	print("Wakeup Task3 OK")
```

- [ ] **Step 4: 跑 + Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "fix(faction_ai): stuck task allows re-eval (preserve intent) (Task 3)"
```

---

## Task 4: Survival 從 SURVIVAL_TASKS 移除 TASK_LOOT

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: grep**

```powershell
grep -n "SURVIVAL_TASKS" scripts/simulation/
```

確認所有 caller 都能接受 TASK_LOOT 不在內。

- [ ] **Step 2: 改 const**

```gdscript
# 舊
const SURVIVAL_TASKS: Array = ["return_home", "乞食", TeamData.TASK_LOOT, "投靠"]
# 新
const SURVIVAL_TASKS: Array = ["return_home", "乞食", "投靠"]
```

- [ ] **Step 3: 測試**

```gdscript
func _test_survival_reeval_in_loot() -> void:
	# Setup: team task=掠奪 + food < 3 天
	# Expected: _evaluate_survival 仍跑（不 early-return）
	# ...
	print("Wakeup Task4 OK")
```

- [ ] **Step 4: 跑 + Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "fix(faction_ai): TASK_LOOT 從 SURVIVAL_TASKS 移除（允許 loot 中重評）(Task 4)"
```

---

## Task 5: StrategicAI trade_net handler

**Files:**
- Modify: `scripts/simulation/strategic_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 找 match top["type"]**

```powershell
grep -n 'match top\["type"\]\|"trade_net"' scripts/simulation/strategic_ai_system.gd
```

- [ ] **Step 2: 加 handler**

```gdscript
match top["type"]:
	"expand":
		_dispatch_expand(...)
	"trade_net":
		_dispatch_trade_net(state, faction, leader_team, top)

func _dispatch_trade_net(state: WorldState, faction, leader_team: TeamData, goal: Dictionary) -> void:
	var traders: Array = []
	for tid in faction.team_ids:
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		if not ("商隊" in t.tags): continue
		if t.current_task != TeamData.TASK_IDLE: continue
		traders.append(t)
	if traders.is_empty(): return
	for trader in traders:
		var partner_id: int = _find_trade_partner(state, trader)
		if partner_id == -1: continue
		var p: TeamData = state.teams[partner_id]
		trader.current_task = TeamData.TASK_TRADE
		trader.move_target = p.tile_pos
		print("[StrategicAI] Faction%d 商隊 Team%d → trade Team%d" % [
			faction.faction_id, trader.team_id, partner_id])

func _find_trade_partner(state: WorldState, trader: TeamData) -> int:
	for tid in state.team_discovered.get(trader.team_id, []):
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		if t.faction_id != -1 and t.faction_id == trader.faction_id: continue
		# 對方有 goods 或 coin 即可
		if float(t.resources.get("goods", 0)) > 0 or float(t.resources.get("coin", 0)) > 50:
			return tid
	return -1
```

- [ ] **Step 3: 測試 + Commit**

```gdscript
func _test_trade_net_dispatches() -> void:
	# Setup: 商隊 idle + 鄰商隊有 goods → 派 trade
	# Expected: trader.current_task = TASK_TRADE
	# ...
	print("Wakeup Task5 OK")
```

```powershell
git add scripts/simulation/strategic_ai_system.gd scripts/debug/headless_test.gd
git commit -m "fix(strategic_ai): add trade_net dispatch handler (Task 5)"
```

---

## Task 6: stuck log 加 source

**Files:**
- Modify: `scripts/simulation/movement_system.gd`

- [ ] **Step 1: 改 print**

於 stuck 偵測點（`movement_system.gd:170` 附近）：

```gdscript
# 舊
print("[Move] Team %d stuck at (%d,%d), clearing move_target" % [
	team.team_id, team.tile_pos.x, team.tile_pos.y])
# 新
print("[Move] Team %d stuck at (%d,%d) target=(%d,%d), task=%s, sa=%s" % [
	team.team_id, team.tile_pos.x, team.tile_pos.y,
	team.move_target.x, team.move_target.y,
	team.current_task, str(team.strategic_assignments)])
```

- [ ] **Step 2: 跑 + Commit**

```powershell
git add scripts/simulation/movement_system.gd
git commit -m "fix(movement): stuck log 加 source (task + strategic_assignments) (Task 6)"
```

---

## Task 7: 整合驗證 + handback

**Files:**
- Create: `docs/superpowers/handbacks/2026-06-10-npc-wakeup-fixes.md`

- [ ] **Step 1: 跑全測試 + multi**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_multi.gd > godot_multi.log 2>&1
Get-Content godot_multi.log -Encoding UTF8 | Select-String "ProsperityAttack|Combat Start|Promote|Trade|FactionAI" | Group-Object | Select-Object Count, Name | Sort-Object Count -Descending
```

預期：Combat > 0, Trade > 0（或至少有 trade 派發），StrategicAI plan 數降低。

- [ ] **Step 2: 寫 handback**

`docs/superpowers/handbacks/2026-06-10-npc-wakeup-fixes.md`：

```markdown
# Hand Back: NPC Wakeup Fixes

## 實作摘要

- strategic_ai_system：in-map check + ENCIRCLE/BREAKOUT_DIST const + breakout 距離 guard + trade_net handler
- faction_ai_system：stuck 視為 idle 重評 + SURVIVAL_TASKS 移除 TASK_LOOT
- movement_system：stuck log 加 source

## 行為變化

- StrategicAI 不再派 off-map target
- breakout dir 從 5 → 2，encircle 從 2 → 1
- breakout 需鄰敵 ≤ 3 hex 才觸發
- team stuck 後 AI 可重新評估（task 保留意圖）
- Survival 在 loot 中可重評
- 商隊 faction 自動派 trade target
- stuck log 可看誰派的座標

## 驗證結果

- headless_test：N/N 過
- game_sim_test：ALL INVARIANTS PASSED
- game_sim_multi 4 config × 90 天：Combat > 0、Trade > 0、stuck 減少

## 連動風險

- AI gate 多處改，需所有 task type 覆蓋
- breakout 縮 dir 可能逃太短
- trade_net 派發後實際成交仍受 trade_system 限制（baseline Trade=0 不完全解）

## 待主 session 確認

- breakout dist 2 是否合理 / map 適應
- trade_net 是否需 cadence cap
- 居民鎖白名單擴張另 spec
```

- [ ] **Step 3: Commit**

```powershell
git add docs/superpowers/handbacks/2026-06-10-npc-wakeup-fixes.md
git commit -m "docs: NPC wakeup fixes handback (Task 7)"
```
