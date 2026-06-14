# 階段1 Plan 2c：subsistence 改狩獵唯一 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 移除無據點隊的被動覓食食物（量測證實為食物噴泉），改 subsistence = 狩獵唯一（小獵物 `wild_game` + 野獸）。靠 wild_game 有限/枯竭/慢再生天生產生遊牧獵人精準度 + 定居壓力，不破守恆。

**Background:** 2 年量測 FoodLedger 露餡 — 被動覓食 income ~44/天 >> burn ~7 → 無據點小隊累積 300+ 天存糧、零遷徙/定居壓力，違背 spec「減緩餓死不餵飽」。根因：每小時採 ×24/天 + 平原 food regen(8/tick) 回填快過抽取 → 枯竭沒咬到。改狩獵唯一後，食物受限於 `wild_game` 每格有限存量（2-6 隻、月再生 30%），一格獵完即枯 → 必遷。

**Architecture:** 抽掉 `resource_system._forage_from_tile`（被動 tile-food），保留無據點分支的被動小獵（2a 已加）。NPC `_find_forage_tile` 改找 `wild_game` 最多的格（非 food pool）。HuntSystem 維持，數值待重量測 tune。

依據 spec：`docs/superpowers/specs/2026-06-14-stage1-survival-forage-hunt-design.md`（2026-06-14 修訂版 §1/§2）。

---

## 檔案結構

- `scripts/simulation/resource_system.gd`（改）：`collect_resources` 的 `outpost_level==0` 分支移除 `_forage_from_tile` 呼叫（保留被動小獵）；刪 `_forage_from_tile` 函數 + `FORAGE_RATE` const（dead）。
- `scripts/simulation/faction_ai_system.gd`（改）：`_find_forage_tile` 改找 `wild_game` 最多的無 outpost 格（無 game → 回 -1,-1 讓掉去乞食/loot）。
- `scripts/debug/headless_test.gd`（改）：更新受影響測試 + 新測試。

---

## Task 1: 移除被動覓食食物（保留被動小獵）

**Files:**
- Modify: `scripts/simulation/resource_system.gd`
- Test: `scripts/debug/headless_test.gd`（改 `_test_forage_no_outpost` → `_test_no_passive_forage_food`）

- [ ] **Step 1: 改測試（反轉舊預期）**

舊 `_test_forage_no_outpost` 斷言「無 outpost 得食物」現已不成立。改為驗「無 outpost + 無 wild_game → 零食物；有 wild_game → 靠獵得食物」：

```gdscript
func _test_no_passive_forage_food() -> void:
	print("--- 無被動覓食食物（狩獵唯一）---")
	var state := WorldState.new(); state.world = WorldData.new()
	# 無 wild_game 的格 → 應零食物產出
	var tile := HexTileData.new()
	tile.tile_id = 4*1000+4; tile.tile_pos = Vector2i(4,4); tile.terrain = "plains"
	tile.productivity = 1.0; tile.harvest_factor = 1.0; tile.outpost_level = 0
	tile.resources = {"food": 200.0}   # 有 food pool 但無 wild_game
	state.world.tiles[tile.tile_id] = tile
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	leader.skills = {"求生": 0.9}
	state.persons[0] = leader
	var team := TeamData.new()
	team.team_id = 0; team.leader_id = 0; team.population = 3; team.tile_pos = Vector2i(4,4)
	team.resources = {"food": 0.0}
	state.teams[0] = team
	var rs := ResourceSystem.new()
	for _i in range(30):
		rs.collect_resources(state, [0])
	assert(float(team.resources["food"]) == 0.0,
		"無 wild_game 格不應有任何食物產出（被動覓食已移除），實際=%s" % str(team.resources["food"]))
	assert(float(tile.resources["food"]) == 200.0, "food pool 不應被無據點隊動")
	print("no passive forage food OK")
```

- [ ] **Step 2: 跑確認失敗** — 舊碼仍 `_forage_from_tile` 給食物 → food > 0，assert 失敗。

- [ ] **Step 3: 實作**

`resource_system.gd` `collect_resources` 的 `outpost_level == 0` 分支，移除 forage 食物，保留被動小獵：

```gdscript
		if tile.outpost_level == 0:
			# 無據點隊零被動食物；食物唯一來源 = 狩獵（小獵物 + 野獸）
			if int(tile.resources.get("wild_game", 0)) > 0:
				HuntSystem.new().hunt_small_game(state, team, tile, false)   # 被動小獵
			continue
```

刪除 `_forage_from_tile` 函數定義 + `const FORAGE_RATE`（已無引用）。

- [ ] **Step 4: 跑確認通過** — `no passive forage food OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/resource_system.gd scripts/debug/headless_test.gd
git commit -m "feat: 移除被動覓食食物（量測證實噴泉）→ subsistence 改狩獵唯一"
```

---

## Task 2: 確認被動小獵仍供食（靠 wild_game）

**Files:**
- Test: `scripts/debug/headless_test.gd`（`_test_passive_hunt_on_forage` 已存在，確認仍綠 + 補枯竭斷言）

2a 的 `_test_passive_hunt_on_forage` 驗「有 wild_game 的格被動小獵枯竭」。本 task 確認移除被動覓食後它仍成立，並補「得到食物」斷言。

- [ ] **Step 1: 補斷言**

在 `_test_passive_hunt_on_forage` 末尾加：
```gdscript
	assert(float(team.resources.get("food", 0)) > 0.0, "有 wild_game 應靠被動小獵得食物")
```

- [ ] **Step 2: 跑** — 仍 `passive hunt OK` 且新斷言過（高求生隊在 wild_game 格被動獵得食物）。若被動命中率太低致 0 → 記錄，Task 4 量測時 tune `PASSIVE_BASE_CHANCE`。

- [ ] **Step 3: Commit**

```bash
git add scripts/debug/headless_test.gd
git commit -m "test: 被動小獵仍供食（狩獵唯一後）"
```

---

## Task 3: NPC forage path 改找 wild_game 格

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（`_find_forage_tile`）
- Test: `scripts/debug/headless_test.gd`（新 `_test_find_game_tile`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_find_game_tile() -> void:
	print("--- forage path 找 wild_game 格 ---")
	var fai := FactionAISystem.new()
	var state := WorldState.new(); state.world = WorldData.new()
	# 本格無 game、鄰格 (5,4) 有 game → 應選鄰格
	for p in [Vector2i(4,4), Vector2i(5,4)]:
		var tile := HexTileData.new()
		tile.tile_id = p.x*1000+p.y; tile.tile_pos = p; tile.terrain = "plains"
		tile.outpost_level = 0
		tile.resources = {"food": 100.0, "wild_game": (5 if p == Vector2i(5,4) else 0)}
		state.world.tiles[tile.tile_id] = tile
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	state.persons[0] = leader
	var team := TeamData.new(); team.team_id = 0; team.leader_id = 0; team.tile_pos = Vector2i(4,4)
	state.teams[0] = team
	var pos: Vector2i = fai._find_forage_tile(state, team)
	assert(pos == Vector2i(5,4), "應選有 wild_game 的鄰格，實際=%s" % str(pos))
	# 周圍全無 game → 回 -1,-1（掉去乞食/loot）
	state.world.tiles[5*1000+4].resources["wild_game"] = 0
	var pos2: Vector2i = fai._find_forage_tile(state, team)
	assert(pos2 == Vector2i(-1,-1), "周圍無 game 應回 (-1,-1)，實際=%s" % str(pos2))
	print("find game tile OK")
```

- [ ] **Step 2: 跑確認失敗** — 舊 `_find_forage_tile` 找 food pool，選 (4,4) 或本格 → assert 失敗。

- [ ] **Step 3: 實作**

`faction_ai_system.gd` `_find_forage_tile` 改找 `wild_game` 最多的無 outpost 格；無 game → 回 -1,-1：

```gdscript
# 找最佳狩獵格：本格+鄰格 wild_game 最多的無 outpost tile；皆無 game → (-1,-1)（掉去乞食/loot）。
func _find_forage_tile(state: WorldState, team: TeamData) -> Vector2i:
	var best_pos: Vector2i = Vector2i(-1, -1)
	var best_game: int = 0
	var dirs: Array = [Vector2i.ZERO, Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1),
		Vector2i(0,-1), Vector2i(1,-1), Vector2i(-1,1)]
	for d in dirs:
		var p: Vector2i = team.tile_pos + d
		var tile: HexTileData = state.world.tiles.get(p.x*1000 + p.y)
		if tile == null or tile.outpost_level > 0:
			continue
		var g: int = int(tile.resources.get("wild_game", 0))
		if g > best_game:
			best_game = g
			best_pos = p
	return best_pos
```

注意：回 (-1,-1) 時 `_trigger_survival` Path 3.5 的 `if forage_pos != Vector2i(-1,-1)` 守衛會放行掉到乞食/idle（已是該邏輯）。`TASK_FORAGE`（覓食）語意現為「赴獵物格狩獵」，名稱沿用。

- [ ] **Step 4: 跑確認通過** — `find game tile OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat: NPC forage path 改找 wild_game 格（狩獵唯一）"
```

---

## Task 4: 註冊 + 重量測（關鍵）

**Files:**
- Modify: `scripts/debug/headless_test.gd`（`_initialize` 加 `_test_no_passive_forage_food` / `_test_find_game_tile`；移除舊 `_test_forage_no_outpost` 註冊與定義；保留 `_test_forage_scale_cap`？— 該測試驗被動覓食 scale，已無意義 → 一併移除）

- [ ] **Step 1: 更新註冊**

`_initialize`：移除 `_test_forage_no_outpost()` / `_test_forage_scale_cap()`（被動覓食已無）；加 `_test_no_passive_forage_food()` / `_test_find_game_tile()`。刪對應舊函數定義（`_test_forage_no_outpost` / `_test_forage_scale_cap`）。

- [ ] **Step 2: 全測試** — `--import` 後跑，無新增 SCRIPT ERROR、受影響測試全綠。

- [ ] **Step 3: 重量測 2 年 ×3**

```bash
$env:SIM_CONFIGS = "survival_start,tyrant,warzone"; .\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd *> godot_hunt_subsist.log
iconv -f UTF-16LE -t UTF-8 godot_hunt_subsist.log > godot_hunt_subsist_u8.log
grep -a "多配置對比\|CoinAudit\|SCRIPT ERROR" godot_hunt_subsist_u8.log
grep -a "FoodLedger.*survival_start" godot_hunt_subsist_u8.log | tail -10
```

**驗收（核心：噴泉消失但不餓死潮）：**
- 三 config `died=no`、`coin_eq delta=0.00`、無新增 SCRIPT ERROR
- **FoodLedger 無據點隊不再囤 300+ 天糧**（income 應 ≲ burn 或溫和正，days 數十而非數百）→ 噴泉解除
- survival_start 不崩（小隊靠狩獵活，pop 不歸零）；Famine 數可能升（precarity 上升）但非全滅
- **無據點隊 days 分佈**：理想是「數天～數十天」遊牧獵人區間，非數百

- [ ] **Step 4: 判斷 + tune**

| 觀測 | 動作 |
|---|---|
| 仍囤大量糧 | 被動小獵命中/產量仍太高 → 降 `HuntSystem.PASSIVE_BASE_CHANCE` / `FOOD_PER_GAME` |
| 餓死潮 / survival_start 崩 | 太硬 → 升 wild_game 密度（`world_generator.WILD_GAME_*`）/ 再生率 / 命中率 |
| 剛好遊牧獵人 precarity | 收手，記錄定值 |

**先量測再 tune，一次調一個變因，重跑。** 勿一次猜多個（避免鑽牛角尖）。

- [ ] **Step 5: handback** — `docs/superpowers/handbacks/2026-06-14-stage1-2c-hunting-subsistence.md`，附量測前後 FoodLedger 對比。

---

## 注意事項（給實作者）

- 本 plan **改動已 merge 的覓食碼**（Plan 1/2a），屬量測驅動的正常迭代。
- `forage_today` / episode 管道**保留**（狩獵得肉照走日彙整）。
- `TASK_FORAGE`（覓食）名稱沿用，語意改為「赴獵物格狩獵」。
- **守恆**：Task 4 coin_eq delta=0（肉=food 非審計項）。
- 野獸戰鬥 / 伏擊（2b-1/2b-2）不動，本 plan 只改 subsistence 食物源。
- 量測是本 plan 的交付重點 — 數值對不對由 2 年資料說話，非寫死。
