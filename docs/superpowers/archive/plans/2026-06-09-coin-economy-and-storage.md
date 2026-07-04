# Coin 經濟 + Outpost 公庫獨立 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 合併實作 2 個 spec：
- Coin Economy：mining → mint → coin 真實來源、anon wage → treasury 沉澱、升 named ×3、徵用 / loot / 滅團處理
- Outpost Public Storage：tile.public_storage 公庫結構、特殊資源 + 設施產出 → 公庫、玩家手動 + NPC 自動領存

**Architecture:**
- TeamData 加 `anon_treasury`
- HexTileData 加 `public_storage`、`abandoned_coin`、`mint_level`
- outpost_system 加 mint facility + OUTPOST_STORAGE_CAP + _get_storage_cap
- resource_system._collect_from_tile 改 ore 流向公庫
- manufacturing_system 改產出流向公庫
- salary_system._pay_salary 改 wage 沉澱 treasury
- faction_ai_system 加 _consider_extraction + _evaluate_storage_visit + _on_team_extinct + 滅團處理
- person_generator.generate_for_team 升 anon 帶 ×3 share
- player_command_system 加 extract_treasury + withdraw_from_storage + deposit_to_storage
- encounter_system.resolve_encounter_end 加 loot 比例

**Specs:**
- `docs/superpowers/specs/2026-06-09-coin-economy-design.md`
- `docs/superpowers/specs/2026-06-09-outpost-public-storage-design.md`

---

## 檔案結構

| 檔案 | 變更 |
|---|---|
| `scripts/data/team_data.gd` | 加 `anon_treasury` |
| `scripts/data/hex_tile_data.gd` | 加 `public_storage`、`abandoned_coin`、`mint_level` |
| `scripts/simulation/outpost_system.gd` | FACILITY_DEF 加 mint、_tick_mint、OUTPOST_STORAGE_CAP、_get_storage_cap |
| `scripts/simulation/resource_system.gd` | _collect_from_tile 改 ore 流向 |
| `scripts/simulation/manufacturing_system.gd` | 產出流向公庫 |
| `scripts/simulation/salary_system.gd` | wage → treasury |
| `scripts/simulation/person_generator.gd` | 升 anon 帶 share |
| `scripts/simulation/faction_ai_system.gd` | _consider_extraction、_extract_treasury、_evaluate_storage_visit、_on_team_extinct、_calc_team_need |
| `scripts/simulation/encounter_system.gd` | loot 比例 |
| `scripts/simulation/player_command_system.gd` | 3 個 player actions |
| `scripts/simulation/sim_runner.gd` 或 `movement_system.gd` | abandoned_coin pickup callback |
| `scripts/debug/headless_test.gd` | 多個測試 |

## 測試命令

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
```

---

## Task 1: 新欄位（TeamData + HexTileData）

**Files:**
- Modify: `scripts/data/team_data.gd`、`scripts/data/hex_tile_data.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試**

```gdscript
func _test_coin_storage_fields() -> void:
	print("--- CoinStorage Task1: 新欄位 ---")
	var t := TeamData.new()
	assert(t.anon_treasury == 0.0, "anon_treasury 預設 0")
	var tile := HexTileData.new()
	assert(tile.public_storage == {}, "public_storage 預設空")
	assert(tile.abandoned_coin == 0.0, "abandoned_coin 預設 0")
	assert(tile.mint_level == 0, "mint_level 預設 0")
	print("CoinStorage Task1 OK")
```

- [ ] **Step 2: 加欄位**

`team_data.gd`：

```gdscript
var anon_treasury: float = 0.0   # 匿名兵 wage 沉澱
```

`hex_tile_data.gd`：

```gdscript
var public_storage: Dictionary = {}   # 公庫，所有 resource keys
var abandoned_coin: float = 0.0       # 滅團遺財（無 outpost）
var mint_level: int = 0               # mint 設施等級
```

- [ ] **Step 3: 跑測試 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/data/team_data.gd scripts/data/hex_tile_data.gd scripts/debug/headless_test.gd
git commit -m "feat(data): anon_treasury + public_storage + abandoned_coin + mint_level fields (Task 1)"
```

---

## Task 2: OUTPOST_STORAGE_CAP + `_get_storage_cap` helper

**Files:**
- Modify: `scripts/simulation/outpost_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_storage_cap() -> void:
	print("--- CoinStorage Task2: storage cap ---")
	var tile := HexTileData.new()
	tile.outpost_type = "civilian"; tile.outpost_level = 1
	var os := OutpostSystem.new()
	assert(os._get_storage_cap(tile, "food") == 200.0, "civilian L1 應 200")
	tile.outpost_level = 3
	assert(os._get_storage_cap(tile, "food") == 1500.0, "civilian L3 應 1500")
	tile.outpost_type = "military"; tile.outpost_level = 2
	assert(os._get_storage_cap(tile, "food") == 800.0, "military L2 應 800")
	print("CoinStorage Task2 OK")
```

- [ ] **Step 2: 加常數 + helper**

`outpost_system.gd`：

```gdscript
const OUTPOST_STORAGE_CAP: Dictionary = {
	"civilian": [200.0, 500.0, 1500.0],
	"military": [300.0, 800.0, 2500.0],
}

func _get_storage_cap(tile: HexTileData, _res: String) -> float:
	var arr: Array = OUTPOST_STORAGE_CAP.get(tile.outpost_type, [100.0, 300.0, 800.0])
	return float(arr[clampi(tile.outpost_level - 1, 0, 2)])
```

- [ ] **Step 3: 跑測試 + Commit**

```powershell
git add scripts/simulation/outpost_system.gd scripts/debug/headless_test.gd
git commit -m "feat(outpost): OUTPOST_STORAGE_CAP + _get_storage_cap (Task 2)"
```

---

## Task 3: `_collect_from_tile` ore 流向公庫

**Files:**
- Modify: `scripts/simulation/resource_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_collect_ore_to_storage() -> void:
	print("--- CoinStorage Task3: ore 進公庫 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var src_tile := HexTileData.new()
	src_tile.tile_pos = Vector2i(0, 0)
	src_tile.outpost_type = "civilian"; src_tile.outpost_level = 1
	src_tile.outpost_owner = 0
	src_tile.resources["ore_gold"] = 100.0
	src_tile.resources["food"] = 100.0
	src_tile.productivity = 1.0
	state.world.tiles[0] = src_tile
	var team := TeamData.new()
	team.team_id = 0; team.tile_pos = Vector2i(0, 0); team.population = 10
	state.teams[0] = team
	var rs := ResourceSystem.new()
	rs.collect_resources(state, [0])
	# 食物進居民團，礦進公庫
	assert(float(team.resources.get("food", 0)) > 0, "food 應進 team")
	assert(float(src_tile.public_storage.get("ore_gold", 0)) > 0, "ore 應進公庫")
	assert(float(team.resources.get("ore_gold", 0)) == 0, "ore 不應進 team")
	print("CoinStorage Task3 OK")
```

- [ ] **Step 2: 改 `_collect_from_tile`**

`resource_system.gd._collect_from_tile` 內，先定 const：

```gdscript
const PUBLIC_RESOURCES: Array = ["ore_gold", "ore_silver", "ore_iron", "ore_steel"]
```

修改 gain 寫入邏輯：

```gdscript
# 既有 gain 計算後
if res in PUBLIC_RESOURCES:
	# 進公庫
	var dst_tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	if dst_tile != null and dst_tile.outpost_level > 0:
		var cap: float = OutpostSystem.new()._get_storage_cap(dst_tile, res)
		var current: float = float(dst_tile.public_storage.get(res, 0))
		dst_tile.public_storage[res] = minf(current + gain, cap)
	else:
		# 無 outpost fallback 進 team
		team.resources[res] = float(team.resources.get(res, 0)) + gain
else:
	team.resources[res] = float(team.resources.get(res, 0)) + gain
src_tile.resources[res] = maxf(current_tile_qty - gain, 0.0)
```

注意：resource_system._collect_from_tile 簽名沒 `state` 參數。需加。Caller 改。

- [ ] **Step 3: 跑測試 + Commit**

```powershell
git add scripts/simulation/resource_system.gd scripts/debug/headless_test.gd
git commit -m "feat(resource): ore_* collected to public_storage (Task 3)"
```

---

## Task 4: Mint facility + `_tick_mint`

**Files:**
- Modify: `scripts/simulation/outpost_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_mint_facility() -> void:
	print("--- CoinStorage Task4: mint facility ---")
	assert(OutpostSystem.FACILITY_DEF.has("mint"), "FACILITY_DEF 應有 mint")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0, 0)
	tile.outpost_type = "civilian"; tile.outpost_level = 3
	tile.outpost_owner = 0
	tile.mint_level = 1
	tile.public_storage["ore_gold"] = 10.0
	state.world.tiles[0] = tile
	var team := TeamData.new()
	team.team_id = 0; team.tile_pos = Vector2i(0, 0)
	state.teams[0] = team
	var os := OutpostSystem.new()
	os._tick_mint(state, tile, team)
	# ore_gold 應減，coin 應增
	assert(float(tile.public_storage["ore_gold"]) < 10.0, "ore 應減")
	assert(float(tile.public_storage.get("coin", 0)) > 0, "coin 應增")
	print("CoinStorage Task4 OK")
```

- [ ] **Step 2: 加 FACILITY_DEF entry + tick**

```gdscript
# FACILITY_DEF 加：
"mint": {
	"cost":             { "material": 100, "coin": 50, "ticks": 200 },
	"cap_by_outpost":   { "civilian": [0, 1, 2], "military": [0, 0, 0] },
	"category":         "經濟",
	"trigger_check":    "_check_ore_surplus",
	"leader_pref":      { "貪婪": 0.4, "野心": 0.2 },
	"current_level_key": "mint_level",
}

const MINT_BASE_RATE: float = 10.0
const GOLD_TO_COIN_RATIO: float = 20.0
const SILVER_TO_COIN_RATIO: float = 5.0

func _tick_mint(state: WorldState, tile: HexTileData, team: TeamData) -> void:
	if tile.mint_level == 0: return
	var rate: float = float(tile.mint_level) * MINT_BASE_RATE
	var gold_qty: float = float(tile.public_storage.get("ore_gold", 0))
	if gold_qty > 0.0:
		var convert: float = minf(gold_qty, rate / GOLD_TO_COIN_RATIO)
		tile.public_storage["ore_gold"] = gold_qty - convert
		var coin_added: float = convert * GOLD_TO_COIN_RATIO
		var cap: float = _get_storage_cap(tile, "coin")
		var cur_coin: float = float(tile.public_storage.get("coin", 0))
		tile.public_storage["coin"] = minf(cur_coin + coin_added, cap)
		return
	var silver_qty: float = float(tile.public_storage.get("ore_silver", 0))
	if silver_qty > 0.0:
		var convert: float = minf(silver_qty, rate / SILVER_TO_COIN_RATIO)
		tile.public_storage["ore_silver"] = silver_qty - convert
		var coin_added: float = convert * SILVER_TO_COIN_RATIO
		var cap: float = _get_storage_cap(tile, "coin")
		var cur_coin: float = float(tile.public_storage.get("coin", 0))
		tile.public_storage["coin"] = minf(cur_coin + coin_added, cap)
```

整合 `tick_all` 內呼叫 `_tick_mint`（hourly cadence）。

加 `_check_ore_surplus` 於 faction_ai_system 給 FACILITY_DEF.trigger_check 用：

```gdscript
func _check_ore_surplus(state: WorldState, faction: FactionData) -> float:
	var total: float = 0.0
	for tid in faction.member_team_ids:
		for tile_id in state.world.tiles:
			var tile = state.world.tiles[tile_id]
			if tile.outpost_owner != tid: continue
			total += float(tile.public_storage.get("ore_gold", 0)) * 5.0
			total += float(tile.public_storage.get("ore_silver", 0))
	return 80.0 if total > 50.0 else 0.0
```

- [ ] **Step 3: 跑測試 + Commit**

```powershell
git add scripts/simulation/outpost_system.gd scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(mint): facility def + _tick_mint converts ore to coin in public_storage (Task 4)"
```

---

## Task 5: Manufacturing 產出 → 公庫

**Files:**
- Modify: `scripts/simulation/manufacturing_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 找產出位置 + 改流向**

```bash
grep -n "team.resources\|goods\|weapon_" scripts/simulation/manufacturing_system.gd | head -10
```

找產出寫入點，改為 `tile.public_storage[res]`（先確認 tile == 自家 outpost）。

```gdscript
# 既有: team.resources["goods"] += amt
# 改: 
var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
if tile != null and tile.outpost_level > 0:
	var cap: float = OutpostSystem.new()._get_storage_cap(tile, "goods")
	var current: float = float(tile.public_storage.get("goods", 0))
	tile.public_storage["goods"] = minf(current + amt, cap)
else:
	team.resources["goods"] = float(team.resources.get("goods", 0)) + amt
```

- [ ] **Step 2: 跑測試 + Commit**

```gdscript
func _test_manufacturing_to_storage() -> void:
	# manufacturing 產出 → public_storage
	# ...
```

```powershell
git add scripts/simulation/manufacturing_system.gd scripts/debug/headless_test.gd
git commit -m "feat(mfg): manufacturing outputs flow to public_storage (Task 5)"
```

---

## Task 6: Salary wage → treasury

**Files:**
- Modify: `scripts/simulation/salary_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_salary_to_treasury() -> void:
	print("--- CoinStorage Task6: wage → treasury ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var team := TeamData.new()
	team.team_id = 0; team.population = 10; team.named_members = [101]
	team.anon_wage = 1.0; team.resources["coin"] = 100.0
	team.leader_id = 100
	state.teams[0] = team
	var leader := PersonData.new(); leader.id = 100
	state.persons[100] = leader
	var member := PersonData.new(); member.id = 101
	state.persons[101] = member
	var ss := SalarySystem.new()
	ss._pay_salary(state, team)
	# anon_count = 10 - 1 - 1 = 8, wage = 1.0, total = 8
	# treasury 應 += 8
	assert(float(team.anon_treasury) == 8.0, "treasury 應 8，實際=%s" % team.anon_treasury)
	# resources["coin"] -= 8
	assert(float(team.resources["coin"]) < 100.0, "coin 應被扣")
	print("CoinStorage Task6 OK")
```

- [ ] **Step 2: 改 `_pay_salary`**

找既有 anon 段：

```gdscript
# 既有:
team.resources["coin"] = float(team.resources.get("coin", 0)) - anon_total
# 改加:
team.anon_treasury += anon_total
```

(coin 扣保持，treasury 加是新增)

- [ ] **Step 3: 跑測試 + Commit**

```powershell
git add scripts/simulation/salary_system.gd scripts/debug/headless_test.gd
git commit -m "feat(salary): anon_wage sinks into anon_treasury (Task 6)"
```

---

## Task 7: PersonGenerator 升 anon 帶 ×3 share

**Files:**
- Modify: `scripts/simulation/person_generator.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_promote_anon_takes_share() -> void:
	print("--- CoinStorage Task7: 升 anon 帶 ×3 share ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var team := TeamData.new()
	team.team_id = 0; team.population = 11; team.named_members = []
	team.leader_id = -1
	team.anon_treasury = 100.0
	state.teams[0] = team
	var promoted := PersonGenerator.generate_for_team(state, team, "member")
	# anon_count = 11 - 0 - 1 = 10（calc 後 named_count = 1 if leader_id != -1）
	# per_share = 100 / 10 = 10
	# new_person.coin = 30 (×3)
	# treasury -= 30 = 70
	assert(promoted != null, "應產生 named NPC")
	assert(promoted.coin > 0, "新 NPC 應有 coin (升階加成)")
	assert(team.anon_treasury < 100.0, "treasury 應扣")
	print("CoinStorage Task7 OK (新 NPC coin=%.0f, 剩 treasury=%.0f)" % [promoted.coin, team.anon_treasury])
```

- [ ] **Step 2: 改 generate_for_team**

`person_generator.gd.generate_for_team` 內，產生新 person 後加：

```gdscript
# 升 anon → named 帶 treasury share ×3
var anon_count: int = team.population - team.named_members.size() - (1 if team.leader_id != -1 else 0)
if anon_count > 0 and team.anon_treasury > 0.0:
	var per_share: float = team.anon_treasury / float(anon_count)
	var bonus: float = per_share * 3.0
	bonus = minf(bonus, team.anon_treasury)   # 不超出
	new_person.coin = bonus
	team.anon_treasury -= bonus
```

- [ ] **Step 3: 跑測試 + Commit**

```powershell
git add scripts/simulation/person_generator.gd scripts/debug/headless_test.gd
git commit -m "feat(generator): promoted anon takes 3x treasury share (Task 7)"
```

---

## Task 8: 徵用機制（_extract_treasury + NPC auto + 飢餓）

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/simulation/resource_system.gd`（飢餓觸發）
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_extraction() -> void:
	print("--- CoinStorage Task8: 徵用機制 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var team := TeamData.new()
	team.team_id = 0; team.population = 10
	team.anon_treasury = 100.0; team.resources["coin"] = 0.0
	var leader := PersonData.new(); leader.id = 100
	leader.values = { "貪婪": 0.8, "慎重": 0.2 }
	state.persons[100] = leader; team.leader_id = 100
	state.teams[0] = team
	var fai := FactionAISystem.new()
	fai._extract_treasury(state, team, 0.3, "貪婪驅動")
	# treasury → 70, coin += 30
	assert(float(team.anon_treasury) == 70.0, "treasury 應 70")
	assert(float(team.resources["coin"]) == 30.0, "coin 應 30")
	# named stress 應增
	# 沒 named_members 跳過 stress check
	# unrest_turns +=1 (非緊急)
	assert(team.unrest_turns == 1, "unrest_turns 應 +1")
	print("CoinStorage Task8 OK")
```

- [ ] **Step 2: 加 `_extract_treasury` + `_consider_extraction`**

```gdscript
func _extract_treasury(state: WorldState, team: TeamData, ratio: float, reason: String) -> void:
	if team.anon_treasury <= 0.0 or ratio <= 0.0: return
	ratio = clampf(ratio, 0.0, 1.0)
	var amt: float = team.anon_treasury * ratio
	team.anon_treasury -= amt
	team.resources["coin"] = float(team.resources.get("coin", 0)) + amt
	var is_emergency: bool = (reason == "飢餓緊急")
	var stress_pen: float = (0.05 if is_emergency else 0.15) * ratio
	var loyalty_pen: float = (0.02 if is_emergency else 0.08) * ratio
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		p.stress = minf(p.stress + stress_pen, 1.0)
		p.loyalty = maxf(p.loyalty - loyalty_pen, 0.0)
	if not is_emergency:
		team.unrest_turns += 1
	print("[Extract] Team%d 徵用 %.0f coin (%s)" % [team.team_id, amt, reason])

func _consider_extraction(state: WorldState, team: TeamData) -> void:
	if team.anon_treasury <= 0.0: return
	if team.leader_id == state.player_id: return   # 玩家手動
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return
	var greed: float = float(leader.values.get("貪婪", 0.5))
	var prudence: float = float(leader.values.get("慎重", 0.5))
	var extract_score: float = greed - prudence * 0.5
	if extract_score > 0.4:
		var ratio: float = greed * 0.3
		_extract_treasury(state, team, ratio, "貪婪驅動")
```

整合到 `faction_ai_system.evaluate_all` 內 team loop（per 月 cadence）。

- [ ] **Step 3: 飢餓徵用整合**

`scripts/simulation/resource_system.gd.resolve_consumption` 結尾加：

```gdscript
# 飢餓徵用：food < 1 天份 + treasury > 0
var food_after: float = float(team.resources.get("food", 0))
if food_after < float(team.population) * 2.4 * 1.0 and team.anon_treasury > 0:
	FactionAISystem.new()._extract_treasury(state, team, 0.3, "飢餓緊急")
```

- [ ] **Step 4: 跑測試 + Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/simulation/resource_system.gd scripts/debug/headless_test.gd
git commit -m "feat(extraction): _extract_treasury + NPC auto + 飢餓 emergency (Task 8)"
```

---

## Task 9: Player `extract_treasury` action

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加 action**

```gdscript
"extract_treasury": _action_extract_treasury,

func _action_extract_treasury(state: WorldState, _target: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var ratio: float = float(state.player_state.get("extract_ratio", 0.0))
	if ratio <= 0.0 or ratio > 1.0:
		return { "ok": false, "msg": "extract_ratio 必須 (0, 1]" }
	FactionAISystem.new()._extract_treasury(state, pt, ratio, "玩家主動")
	return { "ok": true, "msg": "徵用 %.0f%%" % (ratio * 100) }
```

- [ ] **Step 2: 測試 + Commit**

```gdscript
func _test_player_extract_treasury() -> void:
	# 玩家 ratio=0.5 → treasury 抽 50%
	# ...
```

```powershell
git add scripts/simulation/player_command_system.gd scripts/debug/headless_test.gd
git commit -m "feat(player_cmd): extract_treasury action (Task 9)"
```

---

## Task 10: Encounter loot 按比例

**Files:**
- Modify: `scripts/simulation/encounter_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_encounter_treasury_loot() -> void:
	print("--- CoinStorage Task10: encounter loot 比例 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var loser := TeamData.new()
	loser.team_id = 0; loser.population = 15
	loser.anon_treasury = 100.0
	state.teams[0] = loser
	var winner := TeamData.new()
	winner.team_id = 1
	winner.anon_treasury = 0.0
	state.teams[1] = winner
	state.encounter_attacker_id = 1
	state.encounter_defender_id = 0
	# 模擬戰前 anon=20、戰後 5 死 + 0 俘 = 5 lost
	# loot_ratio = 5/20 = 0.25
	# winner 拿 25, loser 剩 75
	# 暫時無 encounter context，直接呼叫 hypothetical helper
	var enc := EncounterSystem.new()
	enc._loot_treasury_share(state, loser, winner, 5, 20)
	assert(float(winner.anon_treasury) == 25.0, "winner 應拿 25，實際=%s" % winner.anon_treasury)
	assert(float(loser.anon_treasury) == 75.0, "loser 剩 75")
	print("CoinStorage Task10 OK")
```

- [ ] **Step 2: 加 helper + 整合**

`encounter_system.gd`：

```gdscript
func _loot_treasury_share(state: WorldState, loser: TeamData, winner: TeamData,
		anon_lost: int, original_anon: int) -> void:
	if loser.anon_treasury <= 0: return
	if original_anon <= 0:
		# 全給 winner
		winner.anon_treasury += loser.anon_treasury
		loser.anon_treasury = 0.0
		return
	var ratio: float = clampf(float(anon_lost) / float(original_anon), 0.0, 1.0)
	var amt: float = loser.anon_treasury * ratio
	loser.anon_treasury -= amt
	winner.anon_treasury += amt
	# 全滅補拿剩餘
	if loser.population == 0:
		winner.anon_treasury += loser.anon_treasury
		loser.anon_treasury = 0.0
```

於 `resolve_encounter_end` 結算 anon_killed/captured 後呼叫。

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/encounter_system.gd scripts/debug/headless_test.gd
git commit -m "feat(encounter): treasury loot by anon loss ratio (Task 10)"
```

---

## Task 11: 滅團 + abandoned_coin pickup

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd` 或新 `team_lifecycle_system.gd`
- Modify: `scripts/simulation/movement_system.gd` 或 `sim_runner.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試 + 加函數**

```gdscript
func _test_on_team_extinct_to_storage() -> void:
	print("--- CoinStorage Task11a: 滅團 → 公庫 ---")
	# ...
	
func _test_pickup_abandoned_coin() -> void:
	print("--- CoinStorage Task11b: 撿 abandoned_coin ---")
	# ...
```

加 `_on_team_extinct`（faction_ai or new system）：

```gdscript
func _on_team_extinct(state: WorldState, team: TeamData) -> void:
	var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	if tile == null: return
	if tile.outpost_level > 0:
		# 全 resources + treasury → 公庫
		var os := OutpostSystem.new()
		for res in team.resources:
			var amt: float = float(team.resources[res])
			var cap: float = os._get_storage_cap(tile, res)
			var stored: float = float(tile.public_storage.get(res, 0))
			tile.public_storage[res] = minf(stored + amt, cap)
		# treasury 進 coin slot
		var coin_cap: float = os._get_storage_cap(tile, "coin")
		var cur_coin: float = float(tile.public_storage.get("coin", 0))
		tile.public_storage["coin"] = minf(cur_coin + team.anon_treasury, coin_cap)
	else:
		# 無 outpost → abandoned_coin (僅 coin/treasury)
		tile.abandoned_coin += team.anon_treasury
		# resources 其他直接消失（無 tile 容器）
	team.anon_treasury = 0.0
	team.resources.clear()
```

整合：team.population 變 0 時呼叫（在哪？需找既有 team 滅亡點）。

加 abandoned_coin pickup：

```gdscript
# movement_system arrival 或 sim_runner tick 內，team 抵達新 tile：
if tile.abandoned_coin > 0.0:
	# 若 tile 有 outpost_owner → 只 owner 可撿
	if tile.outpost_owner != -1 and tile.outpost_owner != team.team_id:
		pass   # 非 owner 不撿
	else:
		team.anon_treasury += tile.abandoned_coin
		print("[Coin] Team%d 撿 %.0f 遺財" % [team.team_id, tile.abandoned_coin])
		tile.abandoned_coin = 0.0
```

- [ ] **Step 2: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/simulation/movement_system.gd scripts/debug/headless_test.gd
git commit -m "feat(extinct): _on_team_extinct → public_storage / abandoned_coin pickup (Task 11)"
```

---

## Task 12: Subteam treasury split（dispatch / merge / recruit）

**Files:**
- Modify: `scripts/simulation/subteam_system.gd`
- Modify: `scripts/simulation/player_command_system.gd`（recruit_anon）
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試 + 改 dispatch**

```gdscript
func _test_subteam_treasury_split() -> void:
	print("--- CoinStorage Task12: 子隊帶 treasury ---")
	# parent treasury=100, 派 3/10 子隊 → sub treasury=30, parent 剩 70
	# ...
```

`subteam_system.dispatch` 既有 `frac` 比例：

```gdscript
# 加入 treasury 比例
sub.anon_treasury = parent.anon_treasury * frac
parent.anon_treasury -= sub.anon_treasury
```

merge / recruit 類似改動。

- [ ] **Step 2: Commit**

```powershell
git add scripts/simulation/subteam_system.gd scripts/simulation/player_command_system.gd scripts/debug/headless_test.gd
git commit -m "feat(treasury): split by frac in dispatch/merge/recruit (Task 12)"
```

---

## Task 13: NPC `_evaluate_storage_visit`（自動領存）

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試 + 加函數**

```gdscript
func _test_npc_auto_withdraw() -> void:
	# NPC 缺 food → 自家 outpost 自動領
	# ...

func _test_npc_auto_deposit() -> void:
	# NPC 超量 food → 自動存
	# ...
```

```gdscript
func _calc_team_need(team: TeamData, res: String) -> float:
	match res:
		"food": return float(team.population) * 14.0
		"material": return 50.0 + float(team.population) * 2.0
		"coin": return float(team.population) * 10.0
		"weapon_melee_low", "weapon_melee_high", "weapon_ranged_low", "weapon_ranged_high":
			return float(team.named_members.size()) * 2.0
		"armor_low", "armor_high":
			return float(team.named_members.size())
		_:
			return 0.0

func _evaluate_storage_visit(state: WorldState, team: TeamData, tile: HexTileData) -> void:
	if tile.outpost_owner != team.team_id: return
	if tile.public_storage.is_empty(): return
	var os := OutpostSystem.new()
	for res in tile.public_storage:
		var stored: float = float(tile.public_storage[res])
		var team_have: float = float(team.resources.get(res, 0))
		var needed: float = _calc_team_need(team, res)
		if team_have < needed:
			var take: float = minf(stored, needed - team_have)
			if take > 0.0:
				tile.public_storage[res] = stored - take
				team.resources[res] = team_have + take
		elif team_have > needed * 2.0:
			var cap: float = os._get_storage_cap(tile, res)
			var deposit_max: float = cap - stored
			var deposit: float = minf(team_have - needed, deposit_max)
			if deposit > 0.0:
				tile.public_storage[res] = stored + deposit
				team.resources[res] = team_have - deposit
```

整合：team 抵達 tile callback（movement arrival）。

- [ ] **Step 2: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): _evaluate_storage_visit NPC auto withdraw/deposit (Task 13)"
```

---

## Task 14: Player `withdraw_from_storage` + `deposit_to_storage` actions + 整合驗證 + handback

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`
- Modify: `scripts/debug/headless_test.gd`
- Create: `docs/superpowers/handbacks/2026-06-09-coin-economy-and-storage.md`

- [ ] **Step 1: 加 actions**

```gdscript
"withdraw_from_storage": _action_withdraw_from_storage,
"deposit_to_storage": _action_deposit_to_storage,

func _action_withdraw_from_storage(state, _target, pt, pt_id):
	var res: String = state.player_state.get("storage_res", "")
	var amount: float = float(state.player_state.get("storage_amount", 0.0))
	if res == "" or amount <= 0: return { "ok": false, "msg": "未指定 res/amount" }
	var tile: HexTileData = state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
	if tile == null or tile.outpost_owner != pt_id: return { "ok": false, "msg": "非自家 outpost" }
	var stored: float = float(tile.public_storage.get(res, 0))
	if stored < amount: return { "ok": false, "msg": "公庫不足" }
	tile.public_storage[res] = stored - amount
	pt.resources[res] = float(pt.resources.get(res, 0)) + amount
	return { "ok": true, "msg": "取 %s × %.0f" % [res, amount] }

func _action_deposit_to_storage(state, _target, pt, pt_id):
	var res: String = state.player_state.get("storage_res", "")
	var amount: float = float(state.player_state.get("storage_amount", 0.0))
	if res == "" or amount <= 0: return { "ok": false, "msg": "未指定 res/amount" }
	var tile: HexTileData = state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
	if tile == null or tile.outpost_owner != pt_id: return { "ok": false, "msg": "非自家 outpost" }
	var have: float = float(pt.resources.get(res, 0))
	if have < amount: return { "ok": false, "msg": "team 資源不足" }
	var cap: float = OutpostSystem.new()._get_storage_cap(tile, res)
	var stored: float = float(tile.public_storage.get(res, 0))
	if stored + amount > cap: return { "ok": false, "msg": "公庫已滿" }
	tile.public_storage[res] = stored + amount
	pt.resources[res] = have - amount
	return { "ok": true, "msg": "存 %s × %.0f" % [res, amount] }
```

- [ ] **Step 2: 測試**

```gdscript
func _test_player_withdraw_deposit() -> void:
	# ...
```

- [ ] **Step 3: 跑全 game_sim_test 確認**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
```

- [ ] **Step 4: 寫 handback**

```markdown
# Hand Back: Coin Economy + Outpost Public Storage

## 實作摘要

- TeamData：anon_treasury
- HexTileData：public_storage, abandoned_coin, mint_level
- outpost_system：FACILITY_DEF.mint, _tick_mint, OUTPOST_STORAGE_CAP, _get_storage_cap
- resource_system：collect 礦進公庫
- manufacturing_system：產出進公庫
- salary_system：wage → treasury
- person_generator：升 anon 帶 ×3 share
- faction_ai_system：_extract_treasury, _consider_extraction, _calc_team_need, _evaluate_storage_visit, _on_team_extinct, _check_ore_surplus
- encounter_system：_loot_treasury_share
- player_command_system：extract_treasury, withdraw_from_storage, deposit_to_storage
- movement_system or sim_runner：abandoned_coin pickup

## 行為變化

- 採礦自動進公庫（非居民團）
- mint facility 把公庫的 ore 轉 coin
- manufacturing 產品進公庫
- 匿名薪水沉澱 treasury（非消失）
- NPC 抵達自家 outpost 自動領存
- 升 anon 帶 ×3 treasury share
- 飢餓自動徵用 treasury（罰較輕）
- 平時徵用罰較重（stress/loyalty/unrest）
- 戰敗 loot 按 anon 損失比例
- 滅團物資進公庫 / abandoned_coin

## 連動風險

- collect_resources 簽名加 state 參數→所有呼叫端更新
- manufacturing 既有產出寫入位置需仔細審視
- _on_team_extinct 觸發點需找 team.population==0 時機（既有可能多處）
- subteam treasury split 多處（dispatch/merge/recruit_anon），易遺漏

## 待主 session 確認

- 上交皇糧（居民食物部分自動流公庫）獨立 spec
- 公庫 UI 顯示
- 慶典/賑災事件 sink
- 賭博/賄賂 person.coin 用途
```

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/player_command_system.gd scripts/debug/headless_test.gd docs/superpowers/handbacks/2026-06-09-coin-economy-and-storage.md
git commit -m "feat(storage): player withdraw/deposit actions + handback (Task 14)"
```
