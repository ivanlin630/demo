# Encounter Engagement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 解 W1 (Combat 0) + W2 (Trade 成交 0)：B prey awareness + C attacker predict + D prey active reaction + W2 trader → outpost-only target.

**Architecture:**
- 新 `ThreatAssessment`（threat_score 評估，限視野 + reputation + intel + 朝我移動）
- `PathSystem.predict_intercept`（observe_velocity 自適應 N 步預測）
- `FactionAISystem._evaluate_threat` cadence + `_dispatch_threat_response`（4 反應評分）
- 新 task: 迎戰 / 備戰
- 居民鎖白名單加 備戰（不加迎戰）
- `StrategicAiSystem._find_trade_partner` 改 outpost-only
- trade task timeout 防 zombie

**Spec:** `docs/superpowers/specs/2026-06-10-encounter-engagement-design.md`

**Class names (verified)**：`FactionAISystem` / `PathSystem` / `StrategicAiSystem` / `InteractionSystem` / `AnonTierSystem`

---

## 檔案結構

| 檔案 | 變更 |
|---|---|
| `scripts/simulation/threat_assessment.gd` | **新檔**：static class，score 公式 |
| `scripts/simulation/path_system.gd` | 加 `predict_intercept` |
| `scripts/simulation/faction_ai_system.gd` | `_evaluate_threat` + `_dispatch_threat_response` + cadence + stuck handle |
| `scripts/simulation/strategic_ai_system.gd` | `_find_trade_partner` 改 outpost-only |
| `scripts/simulation/movement_system.gd` | 居民鎖白名單加 備戰 |
| `scripts/data/team_data.gd` | 加 `TASK_DEFEND` / `TASK_PREPARE` + `threat_eval_next_tick` + `trade_task_start_tick` 欄位 |
| `scripts/debug/headless_test.gd` | ~12 個測試 |

## 測試命令

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_multi.gd
```

---

## Task 1: `PathSystem.predict_intercept`

**Files:**
- Modify: `scripts/simulation/path_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_predict_intercept_static() -> void:
	print("--- Engagement Task1a: prey 不動 → 回當前 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	for x in range(0, 10):
		for y in range(-1, 2):
			var tile := HexTileData.new()
			tile.tile_pos = Vector2i(x, y); tile.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tile
	var attacker := TeamData.new()
	attacker.team_id = 0; attacker.tile_pos = Vector2i(0, 0)
	state.teams[0] = attacker
	var prey := TeamData.new()
	prey.team_id = 1; prey.tile_pos = Vector2i(5, 0)
	prey.last_tile_pos = Vector2i(5, 0)   # 不動
	state.teams[1] = prey
	state.team_discovered[0] = [1]
	var p = PathSystem.predict_intercept(state, attacker, prey)
	assert(p == prey.tile_pos, "靜止 prey → 回當前，實際=%s" % str(p))
	print("Engagement Task1a OK")

func _test_predict_intercept_moving() -> void:
	# prey 朝 (1,0) 移動 → 預測 future
	# ...
	print("Engagement Task1b OK")

func _test_predict_intercept_out_of_sight() -> void:
	# prey 不在 discovered → fallback 回當前
	# ...
	print("Engagement Task1c OK")
```

- [ ] **Step 2: 加函數**

```gdscript
static func predict_intercept(state: WorldState, attacker: TeamData,
		target: TeamData) -> Vector2i:
	var obs: Dictionary = observe_velocity(state, attacker, target)
	if not obs.get("visible", false):
		return target.tile_pos
	var direction: Vector2i = obs.get("direction", Vector2i.ZERO)
	var target_speed: float = float(obs.get("speed", 0.0))
	if direction == Vector2i.ZERO or target_speed < 0.1:
		return target.tile_pos
	var path: Dictionary = find_path(state, attacker.tile_pos, target.tile_pos)
	var n: int = maxi(1, int(path.cost))
	var predicted: Vector2i = target.tile_pos + direction * n
	# 檢查 in-map，否則 fallback
	if not state.world.tiles.has(predicted.x * 1000 + predicted.y):
		return target.tile_pos
	return predicted
```

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/path_system.gd scripts/debug/headless_test.gd
git commit -m "feat(path): predict_intercept 自適應 N 步 (Task 1)"
```

---

## Task 2: `ThreatAssessment` 新檔

**Files:**
- Create: `scripts/simulation/threat_assessment.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_threat_score_out_of_sight() -> void:
	print("--- Engagement Task2a: 視野外 score = 0 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var self_team := TeamData.new()
	self_team.team_id = 0; self_team.tile_pos = Vector2i(0, 0)
	state.teams[0] = self_team
	var other := TeamData.new()
	other.team_id = 1; other.tile_pos = Vector2i(5, 0)
	state.teams[1] = other
	# 不加 discovered
	var s = ThreatAssessment.score(state, self_team, other)
	assert(s == 0.0)
	print("Engagement Task2a OK")

func _test_threat_score_high_hostile() -> void:
	# Setup: enemy 朝我來 + rep 0.1 + 強 + 接近
	# Expected: score > 0.5
	# ...
	print("Engagement Task2b OK")

func _test_threat_score_distance_decay() -> void:
	# enemy 遠 (dist 5) vs 近 (dist 1) 同條件 → 近的 score 高
	# ...
	print("Engagement Task2c OK")
```

- [ ] **Step 2: 建檔**

```gdscript
class_name ThreatAssessment

const THREAT_BASE_THRESHOLD: float = 0.3
const REPUTATION_NEUTRAL: float = 0.5
const POWER_BASELINE: float = 1.0

static func score(state: WorldState, self_team: TeamData,
		other: TeamData) -> float:
	if not state.team_discovered.get(self_team.team_id, []).has(other.team_id):
		return 0.0
	var approach: float = _approach_score(state, self_team, other)
	var rep: float = float(self_team.known_reputations.get(other.team_id,
		REPUTATION_NEUTRAL))
	var hostility: float = clampf(1.0 - rep, 0.0, 1.0)
	var power_ratio: float = _power_ratio(state, self_team, other)
	var raw: float = approach * 1.0 + hostility * 1.0 + (power_ratio - 1.0) * 0.5
	var dist: int = _hex_dist(self_team.tile_pos, other.tile_pos)
	var dist_factor: float = clampf(1.0 - float(dist) / 5.0, 0.1, 1.0)
	return maxf(raw * dist_factor, 0.0)

static func _approach_score(state: WorldState, self_team: TeamData,
		other: TeamData) -> float:
	var obs: Dictionary = PathSystem.observe_velocity(state, self_team, other)
	if not obs.get("visible", false): return 0.0
	var dir: Vector2i = obs.get("direction", Vector2i.ZERO)
	if dir == Vector2i.ZERO: return 0.0
	var current_dist: int = _hex_dist(self_team.tile_pos, other.tile_pos)
	var future_pos: Vector2i = other.tile_pos + dir
	var future_dist: int = _hex_dist(self_team.tile_pos, future_pos)
	if current_dist == future_dist: return 0.0
	return clampf(float(current_dist - future_dist), -1.0, 1.0)

static func _power_ratio(state: WorldState, self_team: TeamData,
		other: TeamData) -> float:
	var self_power: float = _team_power(self_team)
	# 對方用 team_intel snapshot（NPC 不全知）
	var intel: Dictionary = state.team_intel.get(self_team.team_id,
		{}).get(other.team_id, {})
	var pop_est: int = int(intel.get("population_est", other.population))
	# 無 combat skill in intel → 用 0.3 baseline 估算
	var other_power: float = float(pop_est) * 0.3
	return other_power / maxf(self_power, 0.1)

static func _team_power(team: TeamData) -> float:
	var combat: float = AnonTierSystem.avg_combat_skill(team)
	return float(team.population) * combat

static func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx: int = b.x - a.x; var dy: int = b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2
```

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/threat_assessment.gd scripts/debug/headless_test.gd
git commit -m "feat(threat): ThreatAssessment static class + score 公式 (Task 2)"
```

---

## Task 3: TeamData 新 task constants + 欄位

**Files:**
- Modify: `scripts/data/team_data.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_task_defend_prepare_const() -> void:
	assert(TeamData.TASK_DEFEND == "迎戰")
	assert(TeamData.TASK_PREPARE == "備戰")
	var t := TeamData.new()
	assert(t.threat_eval_next_tick == 0)
	assert(t.trade_task_start_tick == 0)
	print("Engagement Task3 OK")
```

- [ ] **Step 2: 加 const + 欄位**

```gdscript
const TASK_DEFEND  := "迎戰"
const TASK_PREPARE := "備戰"

var threat_eval_next_tick: int = 0
var trade_task_start_tick: int = 0
```

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/data/team_data.gd scripts/debug/headless_test.gd
git commit -m "feat(team): 加 TASK_DEFEND/PREPARE + threat/trade tick 欄位 (Task 3)"
```

---

## Task 4: `_evaluate_threat` + cadence

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/simulation/sim_runner.gd`（cadence call）
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_evaluate_threat_finds_hostile() -> void:
	# Setup: team + enemy 朝我來 + rep 0.1 + 接近 → threat > threshold
	# Expected: dispatch_threat_response 被呼叫
	# ...
	print("Engagement Task4a OK")

func _test_evaluate_threat_cadence() -> void:
	# Setup: tick 0 evaluate → next = 240
	# tick 120 不評
	# tick 240 評
	# ...
	print("Engagement Task4b OK")
```

- [ ] **Step 2: 加入口函數**

```gdscript
const THREAT_CADENCE: int = 240   # 1 日

func _evaluate_threat(state: WorldState, team: TeamData) -> void:
	if state.world.current_tick < team.threat_eval_next_tick: return
	team.threat_eval_next_tick = state.world.current_tick + THREAT_CADENCE
	if team.combat_target != -1: return
	# 已在反應 task：重評 threat 還在嗎
	if team.current_task in [TeamData.TASK_DEFEND, TeamData.TASK_PREPARE, "逃跑"]:
		if not _has_active_threat(state, team):
			team.current_task = TeamData.TASK_IDLE
			team.move_target = Vector2i(-1, -1)
		return
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return
	var caution: float = float(leader.values.get("慎重", 0.5))
	var threshold: float = ThreatAssessment.THREAT_BASE_THRESHOLD + caution * 0.3
	var best_threat: float = 0.0
	var best_id: int = -1
	for tid in state.team_discovered.get(team.team_id, []):
		if tid == team.team_id: continue
		var other: TeamData = state.teams.get(tid)
		if other == null: continue
		var t: float = ThreatAssessment.score(state, team, other)
		if t > best_threat:
			best_threat = t
			best_id = tid
	if best_threat < threshold: return
	_dispatch_threat_response(state, team, best_id, best_threat)

func _has_active_threat(state: WorldState, team: TeamData) -> bool:
	for tid in state.team_discovered.get(team.team_id, []):
		var other: TeamData = state.teams.get(tid)
		if other == null: continue
		var t: float = ThreatAssessment.score(state, team, other)
		if t > ThreatAssessment.THREAT_BASE_THRESHOLD:
			return true
	return false
```

- [ ] **Step 3: sim_runner cadence call**

於 `evaluate_all` per-team loop 加：

```gdscript
_evaluate_threat(state, team)
```

- [ ] **Step 4: 跑 + Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/simulation/sim_runner.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): _evaluate_threat + cadence + 重評 (Task 4)"
```

---

## Task 5: `_dispatch_threat_response`（4 反應評分）

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_dispatch_flee_high_survival() -> void:
	# leader 求生欲 0.9 → 逃跑
	# ...
	print("Engagement Task5a OK")

func _test_dispatch_defend_high_martial_non_resident() -> void:
	# leader 好戰 0.9 + 非居民 → 迎戰
	# ...
	print("Engagement Task5b OK")

func _test_dispatch_prepare_resident() -> void:
	# leader 好戰 0.9 + 居民團 → 備戰（不可迎戰）
	# ...
	print("Engagement Task5c OK")

func _test_dispatch_tribute_high_business() -> void:
	# leader 商業/貪婪 → 外交 求和
	# ...
	print("Engagement Task5d OK")
```

- [ ] **Step 2: 加函數**

```gdscript
func _dispatch_threat_response(state: WorldState, team: TeamData,
		threat_id: int, threat_score: float) -> void:
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return
	var survival: float = float(leader.values.get("求生欲", 0.5))
	var martial: float = float(leader.values.get("好戰", 0.5))
	var caution: float = float(leader.values.get("慎重", 0.5))
	var greed: float = float(leader.values.get("貪婪", 0.5))
	var honor: float = float(leader.values.get("信義", 0.5))
	var is_resident: bool = _is_resident_team(state, team)
	var scores: Dictionary = {
		"逃跑": survival * 0.8 + (threat_score - 0.5) * 0.3,
		TeamData.TASK_PREPARE: caution * 0.6 + martial * 0.3,
		"求和": greed * 0.5 + honor * 0.3 - martial * 0.3,
	}
	if not is_resident:
		scores[TeamData.TASK_DEFEND] = martial * 0.7 + (1.0 - threat_score) * 0.2
	var best: String = ""
	var best_score: float = -INF
	for action in scores:
		if scores[action] > best_score:
			best_score = scores[action]
			best = action
	var other: TeamData = state.teams.get(threat_id)
	if other == null: return
	match best:
		"逃跑":
			team.current_task = "逃跑"
			team.move_target = _flee_target(state, team, other)
		TeamData.TASK_DEFEND:
			team.current_task = TeamData.TASK_DEFEND
			team.move_target = other.tile_pos
			team.prosperity_target_id = threat_id
		TeamData.TASK_PREPARE:
			team.current_task = TeamData.TASK_PREPARE
			team.move_target = Vector2i(-1, -1)
		"求和":
			team.current_task = "外交"
			team.move_target = other.tile_pos
			team.order_target_id = threat_id
			team.order_task = "tribute_offer"
	print("[ThreatResponse] Team%d → %s (threat=Team%d, score=%.2f)" % [
		team.team_id, best, threat_id, best_score])

func _flee_target(state: WorldState, team: TeamData, threat: TeamData) -> Vector2i:
	# 朝反方向走 BREAKOUT_DIST hex
	var dir: Vector2i = team.tile_pos - threat.tile_pos
	var pos: Vector2i = team.tile_pos + Vector2i(sign(dir.x), sign(dir.y)) * 3
	if state.world.tiles.has(pos.x * 1000 + pos.y):
		return pos
	return team.tile_pos
```

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): _dispatch_threat_response 4 反應 (Task 5)"
```

---

## Task 6: 居民鎖白名單加備戰

**Files:**
- Modify: `scripts/simulation/movement_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_resident_lock_prepare_allowed() -> void:
	# Setup: PRODUCE team on outpost + task=備戰
	# Expected: 不被鎖（process 不 continue）
	# ...
	print("Engagement Task6 OK")
```

- [ ] **Step 2: 改白名單**

```gdscript
# 既有
# if team.current_task not in ["逃跑", "投靠", "起義", "遷徙"]:
# 新
if team.current_task not in ["逃跑", "投靠", "起義", "遷徙", TeamData.TASK_PREPARE]:
	continue
```

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/movement_system.gd scripts/debug/headless_test.gd
git commit -m "feat(movement): 居民鎖白名單加備戰 (Task 6)"
```

---

## Task 7: W2 trade_partner outpost-only + timeout

**Files:**
- Modify: `scripts/simulation/strategic_ai_system.gd`
- Modify: `scripts/simulation/faction_ai_system.gd`（timeout check）
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_find_trade_partner_outpost_only() -> void:
	# Setup: 2 候選 - 1 有 outpost 1 沒 outpost
	# Expected: 回有 outpost 那個
	# ...
	print("Engagement Task7a OK")

func _test_trade_timeout() -> void:
	# Setup: team task=貿易, trade_task_start_tick = 0, current_tick = 1500
	# Expected: > 1440 → idle
	# ...
	print("Engagement Task7b OK")
```

- [ ] **Step 2: 改 `_find_trade_partner`**

```gdscript
func _find_trade_partner(state: WorldState, trader: TeamData) -> int:
	for tid in state.team_discovered.get(trader.team_id, []):
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		if t.faction_id != -1 and t.faction_id == trader.faction_id: continue
		# 必須有 outpost
		var has_outpost: bool = false
		for tile_id in state.world.tiles:
			var tile: HexTileData = state.world.tiles[tile_id]
			if tile.outpost_owner == tid:
				has_outpost = true
				break
		if not has_outpost: continue
		if float(t.resources.get("goods", 0)) > 0 \
				or float(t.resources.get("coin", 0)) > 50:
			return tid
	return -1
```

派 trade task 時記 tick：

```gdscript
trader.current_task = TeamData.TASK_TRADE
trader.move_target = p.tile_pos
trader.trade_task_start_tick = state.world.current_tick
```

- [ ] **Step 3: timeout check 加 faction_ai 評估**

```gdscript
const TRADE_TIMEOUT: int = 1440

# 於 evaluate_all per-team
if team.current_task == TeamData.TASK_TRADE:
	if state.world.current_tick - team.trade_task_start_tick > TRADE_TIMEOUT:
		team.current_task = TeamData.TASK_IDLE
		team.move_target = Vector2i(-1, -1)
```

- [ ] **Step 4: 跑 + Commit**

```powershell
git add scripts/simulation/strategic_ai_system.gd scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(trade): outpost-only partner + timeout 防 zombie (Task 7)"
```

---

## Task 8: C predict 套到 _refresh_attack_pursuit

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 找既有 _refresh_attack_pursuit**

```powershell
grep -n "_refresh_attack_pursuit\|prosperity_target_id" scripts/simulation/faction_ai_system.gd
```

- [ ] **Step 2: 改 move_target 用 predict_intercept**

```gdscript
# 既有
# team.move_target = prey.tile_pos
# 新
team.move_target = PathSystem.predict_intercept(state, team, prey)
```

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): attack pursuit 用 predict_intercept (Task 8)"
```

---

## Task 9: 整合驗證 + handback

**Files:**
- Create: `docs/superpowers/handbacks/2026-06-11-encounter-engagement.md`

- [ ] **Step 1: 跑全測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_multi.gd > godot_multi.log 2>&1
Get-Content godot_multi.log -Encoding UTF8 | Select-String "Combat Start|Market|ThreatResponse|Trade" | Group-Object | Select-Object Count, Name | Sort-Object Count -Descending
```

預期：Combat > 0、Trade 成交 > 0、ThreatResponse 出現各反應、ALL INVARIANTS PASSED。

- [ ] **Step 2: 寫 handback**

`docs/superpowers/handbacks/2026-06-11-encounter-engagement.md`：

```markdown
# Hand Back: Encounter Engagement

## 實作摘要

- ThreatAssessment 新檔：score (朝我來 + reputation + 實力比 + 距離衰減 + intel)
- PathSystem.predict_intercept：自適應 N 步
- faction_ai _evaluate_threat + _dispatch_threat_response 4 反應
- TeamData 加 TASK_DEFEND / TASK_PREPARE + threat_eval_next_tick + trade_task_start_tick
- movement 居民鎖白名單加備戰
- StrategicAi _find_trade_partner outpost-only
- trade task timeout 1440 tick

## 行為變化

- 攻擊方用預測攔截
- 防守方依個性 4 反應（逃/迎戰/備戰/求和）
- 居民團不可迎戰（只能停留備戰 / 逃 / 求和）
- trader 只追靜止 outpost
- trade task 6 日超時自動 idle

## 驗證結果

- headless_test：N/N 過
- game_sim_test：ALL INVARIANTS PASSED
- game_sim_multi 4 config × 90 天：[填數據]

## 待主 session 確認

- threat_score 公式參數 tune
- hysteresis（避免邊緣抖動）
- 求和外交反覆 spam → 加 cooldown？
- 居民團空城（求生欲高 leader 全跑）
```

- [ ] **Step 3: Commit**

```powershell
git add docs/superpowers/handbacks/2026-06-11-encounter-engagement.md
git commit -m "docs: encounter engagement handback (Task 9)"
```
