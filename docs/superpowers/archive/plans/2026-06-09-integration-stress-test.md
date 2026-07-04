# 跨系統整合壓力測試 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 跑 90 天 game_sim_test + 3 個極端 config（暴君/商業/戰亂）+ multi-config 對比 runner，找跨 spec 整合 bug + 平衡問題。

**Architecture:**
- game_sim_test.gd 改長至 21600 tick (3 月)
- 3 個新 config：tyrant.json / merchant.json / warzone.json
- 新 runner `game_sim_multi.gd` 跑全配置並印對比統計
- 加 cross-spec invariant 檢查（coin 守恆、treasury 不負、起義/攻佔 state 一致）

**沒有 spec — 屬於 QA 任務。**

---

## 檔案結構

| 檔案 | 變更 |
|---|---|
| `scripts/debug/game_sim_test.gd` | max_ticks 7200 → 21600（3 月）|
| `config/tyrant.json` | 新檔，暴君場景 |
| `config/merchant.json` | 新檔，商業場景 |
| `config/warzone.json` | 新檔，戰爭場景 |
| `scripts/debug/game_sim_multi.gd` | 新檔，多 config 對比 runner |
| `docs/integration_test_report.md` | 新檔，最終分析報告 |

---

## Task 1: game_sim_test 改長 3 月

**Files:**
- Modify: `scripts/debug/game_sim_test.gd`

- [ ] **Step 1: 改 max_ticks**

`game_sim_test.gd` 找 `var max_ticks` 或從 config 讀的位置：

```gdscript
# 既有: max_ticks = config.get("max_ticks", 7200)
# config 改: "max_ticks": 21600
```

或直接改 `config/game_sim_test.json` 內 `"max_ticks": 21600`。

- [ ] **Step 2: 跑驗證**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
Get-Content godot_test.log -Encoding UTF8 | Select-String "ALL INVARIANTS|Feature 通|INVARIANTS FAIL" | Select-Object -First 3
```

預期：跑 90 天，可能會發現新問題（記錄但不要立刻修，留到 Task 8）。

- [ ] **Step 3: Commit**

```powershell
git add config/game_sim_test.json
git commit -m "test: extend game_sim_test to 90 days (Task 1)"
```

---

## Task 2: tyrant.json config

**Files:**
- Create: `config/tyrant.json`

- [ ] **Step 1: 寫 config**

複製 `game_sim_test.json`，改：

```json
{
  "seed": 99,
  "mode": "explicit",
  "max_ticks": 21600,
  "map": { "radius": 4, "resource_richness": 5 },
  "teams": [
    {
      "id": 0, "name": "暴君", "tile_pos": [4, 4], "population": 10,
      "tags": ["統領", "軍隊"], "faction_id": 0, "is_faction_leader": true,
      "resources": {
        "food": 100, "material": 200, "coin": 1000, "weapon_melee_low": 15,
        "armor_low": 10, "medicine": 10, "ore_gold": 50
      },
      "leader": {
        "name": "暴君", "age": 35, "loyalty": 0.9,
        "skills": { "統領": 0.8, "戰鬥": 0.6 },
        "values": { "貪婪": 0.95, "殘忍": 0.9, "好戰": 0.8, "義氣": 0.1, "信義": 0.1, "慎重": 0.2 }
      },
      "named_members": [
        { "name": "副官1", "loyalty": 0.6, "salary": 5.0 },
        { "name": "副官2", "loyalty": 0.6, "salary": 5.0 }
      ],
      "outpost": { "type": "military", "level": 2, "tile_food_init": 1000 }
    },
    {
      "id": 1, "name": "受壓村", "tile_pos": [4, 5], "population": 30,
      "tags": ["生產"], "faction_id": 0,
      "resources": { "food": 200, "coin": 50 },
      "leader": {
        "name": "村長", "age": 50, "loyalty": 0.6,
        "skills": { "統領": 0.4, "生產": 0.6 },
        "values": { "義氣": 0.4, "慎重": 0.7 }
      },
      "named_members": [
        { "name": "村民甲", "loyalty": 0.5 },
        { "name": "村民乙", "loyalty": 0.5 }
      ],
      "outpost": { "type": "civilian", "level": 1, "tile_food_init": 500 },
      "tax_rate": 0.8
    },
    {
      "id": 2, "name": "敵對暴君", "tile_pos": [8, 5], "population": 12,
      "tags": ["軍隊"], "faction_id": 1, "is_faction_leader": true,
      "resources": {
        "food": 100, "material": 200, "coin": 800, "weapon_melee_low": 20,
        "armor_low": 10
      },
      "leader": {
        "name": "黑王", "age": 40, "loyalty": 0.9,
        "skills": { "統領": 0.7, "戰鬥": 0.7 },
        "values": { "貪婪": 0.9, "殘忍": 0.85, "好戰": 0.95, "義氣": 0.05 }
      },
      "named_members": [{ "name": "親衛", "loyalty": 0.7 }],
      "outpost": { "type": "military", "level": 1, "tile_food_init": 500 }
    },
    {
      "id": 3, "name": "流民", "tile_pos": [2, 2], "population": 8,
      "tags": ["流亡"], "faction_id": -1,
      "resources": { "food": 30, "coin": 20 },
      "leader": {
        "name": "難民頭", "age": 30, "loyalty": 0.5,
        "values": { "求生欲": 0.9, "義氣": 0.4 }
      },
      "named_members": []
    }
  ],
  "player": { "team_id": 0, "is_leader": true },
  "command_schedule": [
    { "tick": 240, "action": "extract_treasury", "args": { "extract_ratio": 0.5 } },
    { "tick": 1680, "action": "extract_treasury", "args": { "extract_ratio": 0.5 } },
    { "tick": 3360, "action": "attack", "args": { "team_id": 2 } }
  ]
}
```

注意：`tax_rate` 為 PRODUCE team 才用，目前 schema 可能 不接受。需確認 game_setup 處理。

- [ ] **Step 2: Commit**

```powershell
git add config/tyrant.json
git commit -m "test: tyrant.json config (heavy tax + war) (Task 2)"
```

---

## Task 3: merchant.json config

**Files:**
- Create: `config/merchant.json`

- [ ] **Step 1: 寫 config**

```json
{
  "seed": 100,
  "mode": "explicit",
  "max_ticks": 21600,
  "map": { "radius": 4 },
  "teams": [
    {
      "id": 0, "name": "玩家商會", "tile_pos": [4, 4], "population": 8,
      "tags": ["商隊", "統領"], "faction_id": 0, "is_faction_leader": true,
      "resources": { "food": 300, "material": 50, "coin": 500, "goods": 100 },
      "leader": {
        "name": "商會主", "skills": { "統領": 0.7, "商業": 0.8 },
        "values": { "貪婪": 0.7, "慎重": 0.7, "義氣": 0.5, "好戰": 0.1 }
      },
      "named_members": [{ "name": "副手", "skills": { "商業": 0.5 }, "loyalty": 0.7 }],
      "outpost": { "type": "civilian", "level": 2, "tile_food_init": 1500 }
    },
    {
      "id": 1, "name": "貿易夥伴A", "tile_pos": [6, 4], "population": 8,
      "tags": ["商隊"], "faction_id": 1, "is_faction_leader": true,
      "resources": { "food": 200, "coin": 400, "goods": 80 },
      "leader": {
        "name": "夥伴A", "skills": { "商業": 0.6 },
        "values": { "貪婪": 0.6, "信義": 0.7 }
      },
      "named_members": [{ "name": "助手A" }],
      "outpost": { "type": "civilian", "level": 1, "tile_food_init": 800 }
    },
    {
      "id": 2, "name": "貿易夥伴B", "tile_pos": [4, 7], "population": 6,
      "tags": ["商隊"], "faction_id": 2, "is_faction_leader": true,
      "resources": { "food": 150, "coin": 600, "material": 100 },
      "leader": {
        "name": "夥伴B", "skills": { "商業": 0.5 },
        "values": { "貪婪": 0.5, "義氣": 0.6 }
      },
      "named_members": [],
      "outpost": { "type": "civilian", "level": 1 }
    },
    {
      "id": 3, "name": "生產村", "tile_pos": [2, 6], "population": 20,
      "tags": ["生產"], "faction_id": -1,
      "resources": { "food": 500, "coin": 30, "material": 100 },
      "leader": {
        "name": "村長", "skills": { "生產": 0.7 }, "values": { "慎重": 0.8 }
      },
      "named_members": [],
      "outpost": { "type": "civilian", "level": 1, "tile_food_init": 600 }
    },
    {
      "id": 4, "name": "礦工", "tile_pos": [7, 7], "population": 6,
      "tags": ["生產"], "faction_id": -1,
      "resources": { "food": 100, "ore_silver": 30 },
      "leader": { "name": "礦頭", "skills": { "工程": 0.5 } },
      "named_members": [],
      "outpost": { "type": "civilian", "level": 1 }
    }
  ],
  "player": { "team_id": 0, "is_leader": true },
  "command_schedule": []
}
```

- [ ] **Step 2: Commit**

```powershell
git add config/merchant.json
git commit -m "test: merchant.json config (trade-heavy) (Task 3)"
```

---

## Task 4: warzone.json config

**Files:**
- Create: `config/warzone.json`

- [ ] **Step 1: 寫 config**

```json
{
  "seed": 101,
  "mode": "explicit",
  "max_ticks": 21600,
  "map": { "radius": 4 },
  "teams": [
    {
      "id": 0, "name": "玩家軍", "tile_pos": [4, 4], "population": 15,
      "tags": ["軍隊", "統領"], "faction_id": 0, "is_faction_leader": true,
      "resources": {
        "food": 200, "material": 100, "coin": 300, "weapon_melee_low": 20,
        "armor_low": 12
      },
      "leader": {
        "name": "統帥", "skills": { "統領": 0.7, "戰鬥": 0.6, "戰術": 0.5 },
        "values": { "好戰": 0.9, "野心": 0.8, "義氣": 0.6 }
      },
      "named_members": [
        { "name": "將軍A", "skills": { "戰鬥": 0.5 } },
        { "name": "將軍B", "skills": { "戰鬥": 0.5 } }
      ],
      "outpost": { "type": "military", "level": 1, "tile_food_init": 600 }
    },
    {
      "id": 1, "name": "敵軍A", "tile_pos": [7, 4], "population": 12,
      "tags": ["軍隊"], "faction_id": 1, "is_faction_leader": true,
      "resources": { "food": 150, "coin": 200, "weapon_melee_low": 15, "armor_low": 8 },
      "leader": { "name": "敵將A", "values": { "好戰": 0.95, "野心": 0.7 } },
      "named_members": [{ "name": "副將A" }],
      "outpost": { "type": "military", "level": 1 }
    },
    {
      "id": 2, "name": "敵軍B", "tile_pos": [4, 7], "population": 14,
      "tags": ["軍隊"], "faction_id": 2, "is_faction_leader": true,
      "resources": { "food": 150, "coin": 200, "weapon_melee_low": 18 },
      "leader": { "name": "敵將B", "values": { "好戰": 0.85, "殘忍": 0.7 } },
      "named_members": [],
      "outpost": { "type": "military", "level": 1 }
    },
    {
      "id": 3, "name": "流民", "tile_pos": [2, 2], "population": 5,
      "tags": ["流亡"], "faction_id": -1,
      "resources": { "food": 30 },
      "leader": { "name": "難民", "values": { "求生欲": 0.9 } },
      "named_members": []
    },
    {
      "id": 4, "name": "盜匪", "tile_pos": [6, 6], "population": 8,
      "tags": ["流亡"], "faction_id": -1,
      "resources": { "food": 50, "coin": 100, "weapon_melee_low": 5 },
      "leader": {
        "name": "匪首", "skills": { "戰鬥": 0.4 },
        "values": { "貪婪": 0.85, "殘忍": 0.8 }
      },
      "named_members": []
    }
  ],
  "player": { "team_id": 0, "is_leader": true },
  "command_schedule": [
    { "tick": 1000, "action": "attack", "args": { "team_id": 1 } },
    { "tick": 5000, "action": "attack", "args": { "team_id": 2 } }
  ]
}
```

- [ ] **Step 2: Commit**

```powershell
git add config/warzone.json
git commit -m "test: warzone.json config (high combat) (Task 4)"
```

---

## Task 5: `game_sim_multi.gd` runner

**Files:**
- Create: `scripts/debug/game_sim_multi.gd`

- [ ] **Step 1: 寫 runner**

```gdscript
extends SceneTree

const CONFIGS: Array = [
	"game_sim_test", "tyrant", "merchant", "warzone"
]

func _initialize() -> void:
	var summary: Array = []
	for cfg_name in CONFIGS:
		var stats: Dictionary = _run_config(cfg_name)
		summary.append({ "config": cfg_name, "stats": stats })
	_print_comparison(summary)
	quit()

func _run_config(cfg_name: String) -> Dictionary:
	print("\n======== Running config: %s ========" % cfg_name)
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg_name)
	if config.is_empty():
		print("[FAIL] config %s 載入失敗" % cfg_name)
		return {}
	GameSetup.setup(state, config)
	var max_ticks: int = int(config.get("max_ticks", 21600))
	var initial_player_id: int = state.player_id
	var encounters: int = 0
	var uprisings: int = 0
	var captures: int = 0
	var player_died: bool = false
	var max_treasury: float = 0.0
	var min_coin: float = 1e9
	for tick in range(max_ticks):
		var pp: Vector2i = _player_pos(state)
		var result = runner.advance_tick(state, pp)
		if state.encounter_active and result == "player_turn":
			_auto_drive_encounter(state, runner)
		if state.game_over:
			print("[GameOver] %s @ tick=%d 因: %s" % [cfg_name, tick, state.game_over_reason])
			break
		# 統計
		if state.encounter_active:
			# 估計 (避免每 tick 加)
			pass
		for tid in state.teams:
			var t = state.teams[tid]
			max_treasury = maxf(max_treasury, t.anon_treasury)
			min_coin = minf(min_coin, float(t.resources.get("coin", 0)))
	# 蒐集事件統計（從 log 或 state）
	var team_count: int = state.teams.size()
	var alive_persons: int = state.persons.size()
	return {
		"ticks_completed": min(state.world.current_tick, max_ticks),
		"team_count_final": team_count,
		"persons_final": alive_persons,
		"player_died": (state.player_id == -1 or state.game_over),
		"max_treasury": max_treasury,
		"min_coin": min_coin,
		"game_over": state.game_over,
		"game_over_reason": state.game_over_reason,
	}

func _player_pos(state: WorldState) -> Vector2i:
	var p: PersonData = state.persons.get(state.player_id)
	if p == null: return Vector2i(-1, -1)
	var t: TeamData = state.teams.get(p.team_id)
	return t.tile_pos if t else Vector2i(-1, -1)

func _auto_drive_encounter(state: WorldState, runner: SimRunner) -> void:
	# 同 game_sim_test 的 auto drive
	var enc = runner._encounter_system
	for u in state.encounter_units:
		if u.get("person_id", -1) == state.player_id:
			if not u.get("pending_action", {}).is_empty(): continue
			var enemy_idx = enc._get_nearest_enemy_index(u, state)
			if enemy_idx == -1:
				u["pending_action"] = { "type": "idle", "target_idx": -1,
					"move_to": u["pos"], "attack_part": "" }
			else:
				var enemy = state.encounter_units[enemy_idx]
				var dist = enc.hex_dist(u["pos"], enemy["pos"])
				if dist <= 1:
					u["pending_action"] = { "type": "attack",
						"target_idx": enemy_idx, "attack_part": "torso" }
				else:
					u["pending_action"] = { "type": "move", "target_idx": -1,
						"move_to": enc._calc_next_step(u["pos"], enemy["pos"]),
						"attack_part": "" }
			break

func _print_comparison(summary: Array) -> void:
	print("\n========== 多配置對比 ==========")
	print("%-20s %10s %12s %10s %10s %12s %10s" % [
		"config", "ticks", "teams", "persons", "died", "max_treas", "min_coin"])
	for entry in summary:
		var s = entry.stats
		print("%-20s %10d %12d %10d %10s %12.0f %10.0f" % [
			entry.config,
			int(s.get("ticks_completed", 0)),
			int(s.get("team_count_final", 0)),
			int(s.get("persons_final", 0)),
			"yes" if s.get("player_died", false) else "no",
			float(s.get("max_treasury", 0)),
			float(s.get("min_coin", 0))
		])
		if s.get("game_over", false):
			print("    > game_over: %s" % s.get("game_over_reason", "?"))
```

- [ ] **Step 2: 跑 + 修錯**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_multi.gd > godot_multi_test.log 2>&1
```

可能會跑很久（4 個 config × 21600 tick = ~5-15 分鐘）。預期會發現 bug，記錄但不立刻修。

- [ ] **Step 3: Commit**

```powershell
git add scripts/debug/game_sim_multi.gd
git commit -m "test: game_sim_multi.gd runner for 4 configs (Task 5)"
```

---

## Task 6: 分析結果 + 寫報告

**Files:**
- Create: `docs/integration_test_report.md`

- [ ] **Step 1: 跑全配置**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_multi.gd > godot_multi_test.log 2>&1
Get-Content godot_multi_test.log -Encoding UTF8 -Tail 100
```

- [ ] **Step 2: 寫報告**

`docs/integration_test_report.md`：

```markdown
# 跨系統整合測試報告

> 2026-06-09 跑 4 個 config × 90 天

## 配置對比表

[從 multi runner 輸出貼上]

## 發現的問題

### Bug 1: ...
- 配置：tyrant.json @ tick N
- 症狀：...
- 根因：...
- 嚴重度：高/中/低
- 建議修法：...

### Bug 2: ...
（重複）

## 平衡問題

- treasury 累積過快/過慢
- coin 守恆檢查
- encounter 觸發頻率
- 起義發生比例

## 建議後續

- 修哪些 bug
- 平衡調整
```

- [ ] **Step 3: Commit + 後續處理**

```powershell
git add docs/integration_test_report.md
git commit -m "docs: integration test report (Task 6)"
```

對找到的高優先 bug 開新 spec 修。低優先記入 known_issues.md。
