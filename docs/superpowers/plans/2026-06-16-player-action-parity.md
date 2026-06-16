# 玩家動作 Parity + 主隊 Task 收口 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 補玩家「訓練/晉升 anon」「紮營」兩個一次性動作 + 玩家主隊不被恐慌橋劫持 task + 顯示 label 誠實化。

**Architecture:** 訓練 = 一次性 command 呼既有 `AnonTierSystem.add_exp`+`try_promote`（玩家版比 NPC 完整,NPC 無 promote tick caller=W4）。紮營 = 玩家發起的限時建造令（複用 construction 機制,免材料/無即時糧/加距離 spacing）。Panic 收口 = reaction 恐慌橋加玩家隊守衛。Label = 玩家隊「任務:」→「狀態:」。

**Tech Stack:** Godot 4.2.2 GDScript；headless + ui_flow harness；`.\tools\godot.ps1`（強制 UTF-8）。

依據 spec：`docs/superpowers/specs/2026-06-16-player-action-parity-design.md`。

**既有可用（不重寫）**：
- `AnonTierSystem.add_exp(team, tier, exp)`（累積 exp,菁英跳過）、`try_promote(state, team, from_tier, count) -> int`（需 exp≥`PROMOTION_EXP_THRESHOLD[tier]`×count + `PROMOTION_COST[tier]`×count 物資 + tier count≥count;消費 exp+物資;回升階數）、`total_pop(team)`、`TIER_ORDER=["平民","新兵","老兵","菁英"]`。
- `OutpostSystem._check_distance(state, pos, type)`（MIN_DIST_ANY=2/MIN_DIST_SAME=11 spacing）、`_tick_construction`（找同格 `current_task==TASK_BUILD` 隊 → 減 `construction_ticks_left` → `_complete_construction`）、`_complete_construction` match `construction_target["action"]`。
- `establish_crude_camp` 後段 tag 邏輯（升軍/生產 tag、erase「流亡」）——參考,不直接呼（要去即時糧）。
- `TaskArbiter.try_set(state, team, task, move_target, prio, src)` / `release(team)`、`PRIO_PLAYER=60`。
- registry：`player_command_system._setup_registry()` dict;`player_query_api` available_actions（`allowed_kinds: ["none"]` = self-action,UI `_interact_action_split` 歸 self）。
- ui_flow harness：`_make_ui()` / `_check(label, ok)` / `_free_ui(node)`。

**常數（TEST VALUE,放各自系統頂）**：
```gdscript
# player_command_system.gd
const TRAIN_COST_COIN: float = 30.0    # 一次訓練固定 coin（sink）
const TRAIN_EXP_GAIN:  float = 20.0    # 一次給最低 tier 的 exp
const CAMP_BUILD_TICKS: int  = 240     # 紮營施工 ticks（約 build_outpost lvl1 一半,待平衡）
const CAMP_FOOD_CAP:    float = 40.0   # 紮營抬 food cap 到此值（非即時糧,沿用 CRUDE_CAMP_FOOD_SEED 尺度）
```

---

## Task 1: Panic 收口（玩家主隊不被恐慌橋劫持 task）

**Files:**
- Modify: `scripts/simulation/reaction_system.gd`（恐慌橋約 :45-56）
- Test: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 寫失敗測試（NPC 對照組——關鍵:確保真的驗到守衛,非假過）** — `headless_test.gd`

```gdscript
# 對照組設計:玩家隊(0) 與 NPC 隊(1) 同樣 panic 條件。加守衛前兩者都被設逃跑（測 FAIL）;
# 加守衛後 NPC 仍逃跑（證 panic 條件成立、測有效）、玩家隊不逃跑（證守衛生效）。
func _test_panic_skips_player_team() -> void:
	print("--- 恐慌橋跳過玩家主隊（NPC 對照）---")
	var state := WorldState.new(); state.world = WorldData.new()
	# 共用:在 (4,4) 放高 flee 傾向成員的兩隊 + 鄰格強敵
	var enemy := TeamData.new(); enemy.team_id = 9; enemy.leader_id = 90
	enemy.tile_pos = Vector2i(5,4); enemy.population = 50
	state.teams[9] = enemy
	state.persons[90] = PersonData.new(); state.persons[90].id = 90; state.persons[90].team_id = 9
	enemy.named_members.append(90)
	# 造一隊高 flee 傾向（stress 高/loyalty 低/fear 高 → N1_flee 勝出）
	var mk_team = func(tid: int) -> TeamData:
		var t := TeamData.new(); t.team_id = tid; t.tile_pos = Vector2i(4,4); t.population = 5
		var ld := PersonData.new(); ld.id = tid*100; ld.team_id = tid
		ld.loyalty = 0.05; ld.stress = 0.95; ld.fear = 0.95
		state.persons[ld.id] = ld; t.leader_id = ld.id
		for i in range(4):
			var m := PersonData.new(); m.id = tid*100 + 1 + i; m.team_id = tid
			m.loyalty = 0.05; m.stress = 0.95; m.fear = 0.95
			state.persons[m.id] = m; t.named_members.append(m.id)
		state.teams[tid] = t
		state.team_discovered[tid] = [9]
		return t
	var pt: TeamData = mk_team.call(0)    # 玩家隊
	var nt: TeamData = mk_team.call(1)    # NPC 對照隊
	state.player_id = 0
	var rs := ReactionSystem.new()
	rs.evaluate_all(state, [0, 1, 9])
	# NPC 對照:證 panic 條件成立（否則測無效——若此 assert 掛,調高 stress/fear/敵強度直到 NPC 觸發）
	assert(nt.current_task == "逃跑", "NPC 對照隊應觸發恐慌逃跑(測有效性前提),實際=%s" % nt.current_task)
	# 玩家隊:守衛生效,不被劫持
	assert(pt.current_task != "逃跑", "玩家主隊不該被設逃跑 task,實際=%s" % pt.current_task)
	print("恐慌橋跳過玩家主隊 OK")
```
（`PersonData` 若無 `stress`/`fear` 欄位,以現碼實名為準調整;flee 評分驅動欄位查 `reaction_system._score_flee`。對照組是關鍵:NPC assert 確保 panic 真觸發,玩家 assert 才有意義。）

- [ ] **Step 2: 跑確認失敗** — 加守衛前玩家隊與 NPC 隊同被設逃跑 → 玩家 assert FAIL。若 NPC assert 先掛 = panic 沒觸發,調高 stress/fear/loyalty 反向/敵強度直到 NPC 組 panic fires,再續。

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL「玩家主隊不該被設逃跑」（NPC 對照已逃跑證條件成立）

- [ ] **Step 3: 加守衛** — `reaction_system.gd` 恐慌橋（約 :45）：

```gdscript
		if flee_count > 0 and float(flee_count) / maxf(team.population, 1) >= 0.3 \
				and team.leader_id != state.player_id:   # 玩家主隊直接控,不被恐慌劫持 task（move_target）
			if team.current_task not in ["逃跑", "護衛"]:
```
（只加 `and team.leader_id != state.player_id` 到既有 `if flee_count...` 條件。其餘恐慌效果——work_morale（:44 之前已算）、per-person loyalty/defect（上層 loop）、戰場潰逃（encounter_system 獨立）——全不動,玩家隊照吃。）

- [ ] **Step 4: 跑確認通過** — `恐慌橋跳過玩家主隊 OK`，且既有 reaction 測（`[ReactionBridge]` / known_reputations 等）不退。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/reaction_system.gd scripts/debug/headless_test.gd
git commit -m "fix(player): 玩家主隊不被恐慌橋劫持 task（reaction 加 leader_id!=player_id 守衛;其餘恐慌效果保留）"
```

---

## Task 2: 顯示 label（玩家隊「任務:」→「狀態:」）

**Files:**
- Modify: `scripts/ui/text_ui_main.gd:654`
- Test: `scripts/debug/ui_flow_test.gd`

- [ ] **Step 1: 寫失敗測試** — `ui_flow_test.gd`

```gdscript
func _test_player_status_label() -> void:
	print("\n── 玩家隊狀態 label（非任務）──")
	var node = await _make_ui()
	node._refresh()
	var s: String = node._state_label.text
	_check("狀態列用「狀態:」不用「任務:」", s.contains("狀態:") and not s.contains("任務:"))
	await _free_ui(node)
```
註冊進 `_initialize()`（在現有 ui_flow 測序列末加 `await _test_player_status_label()`）。

- [ ] **Step 2: 跑確認失敗** — 現為「任務:」→ FAIL。

Run: `.\tools\godot.ps1 --headless --script scripts/debug/ui_flow_test.gd`
Expected: FAIL「狀態列用「狀態:」」

- [ ] **Step 3: 改 label** — `text_ui_main.gd:654`：

```gdscript
	lines.append("狀態: %s  疲勞: %d%%" % [ct.get("task_summary", ""), ct.get("fatigue_pct", 0)])
```
（只把「任務:」字面改「狀態:」。其餘不動。）

- [ ] **Step 4: 跑確認通過** — `狀態列用「狀態:」` PASS，ui_flow errors 不增。

- [ ] **Step 5: Commit**

```bash
git add scripts/ui/text_ui_main.gd scripts/debug/ui_flow_test.gd
git commit -m "fix(ui): 玩家隊狀態列「任務:」→「狀態:」（顯系統自動狀態非玩家令,誠實化）"
```

---

## Task 3: 訓練/晉升動作（C-4）

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`（常數 + registry + `_action_train`）
- Modify: `scripts/simulation/player_query_api.gd`（available_actions 加 train self-action）
- Test: `scripts/debug/headless_test.gd`, `scripts/debug/ui_flow_test.gd`

- [ ] **Step 1: 寫失敗測試（exp + 升階 + coin sink）** — `headless_test.gd`

```gdscript
func _test_player_train() -> void:
	print("--- 玩家訓練/晉升 anon ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	state.persons[0] = leader; state.player_id = 0
	var pt := TeamData.new(); pt.team_id = 0; pt.leader_id = 0
	pt.tile_pos = Vector2i(4,4)
	pt.resources = {"coin": 1000.0, "food": 200.0, "material": 50.0}   # coin 足多次訓練 + 升階 PROMOTION_COST(coin/food/material)
	state.teams[0] = pt
	AnonTierSystem.add_anon(pt, "平民", 4)   # 4 個平民
	var cs := PlayerCommandSystem.new()
	# 一次訓練：coin 扣 TRAIN_COST、平民 exp 增
	var exp_before: float = float(pt.anon_exp.get("平民", 0.0))
	var coin_before: float = float(pt.resources.get("coin", 0))
	var r: Dictionary = cs._action_train(state, -1, pt, 0)
	assert(r.get("ok", false), "訓練應成功:%s" % str(r))
	assert(abs(coin_before - float(pt.resources.get("coin",0)) - PlayerCommandSystem.TRAIN_COST_COIN) < 0.01, "coin 扣 TRAIN_COST")
	assert(float(pt.anon_exp.get("平民", 0.0)) > exp_before, "平民 exp 應增")
	# 連訓到升階：累積 exp 後應有平民→新兵
	for _i in range(20):
		cs._action_train(state, -1, pt, 0)
	assert(int(pt.anon_tiers.get("新兵", 0)) > 0, "連訓後應有平民升新兵,新兵=%d" % int(pt.anon_tiers.get("新兵",0)))
	print("玩家訓練/晉升 anon OK")
```

- [ ] **Step 2: 跑確認失敗** — `_action_train` 未定義。

- [ ] **Step 3: 實作** — `player_command_system.gd`：

頂部常數（與其他 const 同區）：
```gdscript
const TRAIN_COST_COIN: float = 30.0
const TRAIN_EXP_GAIN:  float = 20.0
```

registry（`_setup_registry()` dict 內加一行）：
```gdscript
		"train":                  _action_train,
```

新函式（放 `_action_hunt` 附近的 self-action 區）：
```gdscript
# 訓練/晉升：一次性花 coin → 給最低非菁英 tier 一批 exp → 立即嘗試升階（reuse AnonTierSystem,玩家版比 NPC 完整:NPC 無 promote tick caller=W4）
# coin = 消耗 sink（訓練開銷）。升階另消耗 PROMOTION_COST 物資（既有規則）。
func _action_train(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	if AnonTierSystem.total_pop(pt) <= 0:
		return { "ok": false, "msg": "無匿名人口可訓練" }
	if float(pt.resources.get("coin", 0)) < TRAIN_COST_COIN:
		return { "ok": false, "msg": "coin 不足訓練（需 %.0f）" % TRAIN_COST_COIN }
	pt.resources["coin"] = float(pt.resources.get("coin", 0)) - TRAIN_COST_COIN   # 消耗 sink
	# 給最低非菁英 tier exp
	var target_tier: String = ""
	for tier in AnonTierSystem.TIER_ORDER:
		if tier == "菁英": break
		if int(pt.anon_tiers.get(tier, 0)) > 0:
			target_tier = tier; break
	if target_tier == "":
		return { "ok": true, "msg": "訓練（-%.0f coin,無可升階對象）" % TRAIN_COST_COIN }
	AnonTierSystem.add_exp(pt, target_tier, TRAIN_EXP_GAIN)
	# 立即嘗試升階（各非菁英 tier 盡量升,受 exp/物資/count 限）
	var promoted: int = 0
	for tier in AnonTierSystem.TIER_ORDER:
		if tier == "菁英": break
		var n: int = int(pt.anon_tiers.get(tier, 0))
		if n > 0:
			promoted += AnonTierSystem.try_promote(state, pt, tier, n)
	var msg: String = "訓練（-%.0f coin → %s +exp" % [TRAIN_COST_COIN, target_tier]
	if promoted > 0:
		msg += "，升階 %d 人" % promoted
	msg += "）"
	return { "ok": true, "msg": msg, "payload": {"promoted": promoted} }
```
（註：`try_promote(state, pt, tier, n)` 內部自帶 exp/物資/count 不足則回 0 不升,安全。連訓累積 exp 直到某 tier 達 threshold 才實升。）

- [ ] **Step 4: 跑確認通過** — `玩家訓練/晉升 anon OK`

- [ ] **Step 5: available_actions 加 train（self-action）** — `player_query_api.gd`：在現有 hunt（`allowed_kinds: ["none"]`,約 :305）那組 self-action 區加：
```gdscript
			{
				"action_id": "train",
				"label": "訓練（-%d coin）" % int(PlayerCommandSystem.TRAIN_COST_COIN),
				"allowed_kinds": PackedStringArray(["none"]),
			},
```
（對齊現行 available_actions 組法與條件:有 anon 才列——加 `if AnonTierSystem.total_pop(controlled_team) > 0` gate,參考 hunt 的列出條件。實名 dict key 與既有條目一致。）

- [ ] **Step 6: 寫 ui_flow 失敗測** — `ui_flow_test.gd`

```gdscript
func _test_train_action_reachable() -> void:
	print("\n── 訓練 self-action 可達 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var pt = st.teams[st.persons[st.player_id].team_id]
	pt.resources["coin"] = 100.0
	AnonTierSystem.add_anon(pt, "平民", 4)
	node._interact_mode = true; node._interact_target = -1
	node._refresh()
	var self_ids: Array = []
	for a in node._interact_action_split()["self"]: self_ids.append(a.get("action_id",""))
	_check("train 在 self-actions", "train" in self_ids)
	await _free_ui(node)
```
註冊進 `_initialize()`。

- [ ] **Step 7: 跑確認失敗 → 已實作 query 則通過** — 若 Step 5 已做,此測應 PASS;否則補 query。

- [ ] **Step 8: 跑全綠** — headless + ui_flow。

- [ ] **Step 9: Commit**

```bash
git add scripts/simulation/player_command_system.gd scripts/simulation/player_query_api.gd scripts/debug/headless_test.gd scripts/debug/ui_flow_test.gd
git commit -m "feat(player): 訓練/晉升動作（C-4）一次性 coin→add_exp+try_promote,self-action 可達"
```

---

## Task 4: 紮營動作（C-2，Y 版）

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`（registry + `_action_camp` + 常數）
- Modify: `scripts/simulation/outpost_system.gd`（`_complete_construction` 加 "crude_camp" 分支）
- Modify: `scripts/simulation/player_query_api.gd`（available_actions 加 camp self-action）
- Test: `scripts/debug/headless_test.gd`, `scripts/debug/ui_flow_test.gd`

**設計註（玩家發起的限時令 ≠ AI auto-task）**：`_tick_construction` 需同格隊 `current_task==TASK_BUILD` 才推進。故 `_action_camp` **由玩家明確發起**時設玩家隊 `current_task=TASK_BUILD`（PRIO_PLAYER）→ 限時建造 → 完工 `_complete_construction` 釋放回 idle。這是**玩家自選的有時長命令**（如 RTS 下建造令）,非 AI 強加;Task 1 的恐慌守衛確保 AI 不覆蓋。

- [ ] **Step 1: 寫失敗測試（紮營建 outpost + 抬 cap 不送即時糧 + 免材料）** — `headless_test.gd`

```gdscript
func _test_player_camp() -> void:
	print("--- 玩家紮營（Y 版:免材料/無即時糧/抬cap）---")
	var state := WorldState.new(); state.world = WorldData.new()
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	state.persons[0] = leader; state.player_id = 0
	var pt := TeamData.new(); pt.team_id = 0; pt.leader_id = 0; pt.population = 4
	pt.tile_pos = Vector2i(4,4); pt.resources = {}   # 免材料:刻意空
	pt.tags = ["流亡"]
	state.teams[0] = pt
	# 腳下空地（非山地、無主）
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(4,4); tile.terrain = "plains"
	tile.outpost_level = 0; tile.outpost_owner = -1
	state.world.tiles[4*1000+4] = tile
	state.player_state["build_type"] = "civilian"
	var cs := PlayerCommandSystem.new()
	var food_before: float = float(tile.resources.get("food", 0))
	var r: Dictionary = cs._action_camp(state, -1, pt, 0)
	assert(r.get("ok", false), "紮營應成功（免材料）:%s" % str(r))
	assert(pt.current_task == TeamData.TASK_BUILD, "紮營中玩家隊 task=建設,實際=%s" % pt.current_task)
	assert(tile.construction_ticks_left > 0, "應設施工 ticks")
	# 推進施工到完工
	var os := OutpostSystem.new()
	for _i in range(50):
		os._tick_construction(state, tile)
		if tile.outpost_level > 0: break
	assert(tile.outpost_level == 1, "完工應 lvl1,實際=%d" % tile.outpost_level)
	assert(tile.outpost_owner == 0, "owner=玩家隊")
	# 關鍵:抬 cap 但不送即時糧
	assert(float(tile.resource_cap.get("food",0)) >= PlayerCommandSystem.CAMP_FOOD_CAP - 0.01, "food cap 應抬到 CAMP_FOOD_CAP")
	assert(float(tile.resources.get("food",0)) <= food_before + 0.01, "不送即時糧（resources.food 不增）")
	assert(not pt.tags.has("流亡"), "完工脫流亡")
	print("玩家紮營 OK")
```

- [ ] **Step 2: 跑確認失敗** — `_action_camp` 未定義。

- [ ] **Step 3: 實作 `_action_camp`** — `player_command_system.gd`：

頂部常數：
```gdscript
const CAMP_BUILD_TICKS: int  = 240
const CAMP_FOOD_CAP:    float = 40.0
```
registry 加：
```gdscript
		"camp":                   _action_camp,
```
新函式：
```gdscript
# 紮營（Y 版,生存落腳）：免材料 + 無即時糧（只抬 cap）+ 距離 spacing + 限時施工。玩家發起的限時建造令（task=建設,完工釋放）。
func _action_camp(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var camp_type: String = str(state.player_state.get("build_type", "civilian"))
	if camp_type not in ["civilian", "military"]:
		return { "ok": false, "msg": "無效紮營類型" }
	var tile: HexTileData = state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
	if tile == null:
		return { "ok": false, "msg": "格子不存在" }
	if tile.outpost_level > 0 or tile.outpost_owner != -1:
		return { "ok": false, "msg": "此地已有據點" }
	if tile.terrain == "mountain":
		return { "ok": false, "msg": "山地無法紮營" }
	var os := OutpostSystem.new()
	if not os._check_distance(state, tile.tile_pos, camp_type):
		return { "ok": false, "msg": "離既有據點太近,無法紮營" }
	# 設限時建造（免材料）+ 玩家隊 task=建設（玩家發起的限時令,完工釋放）
	tile.construction_target = { "action": "crude_camp", "type": camp_type, "level": 1, "owner": pt.team_id }
	tile.construction_ticks_left = CAMP_BUILD_TICKS
	tile.construction_started_tick = -1
	TaskArbiter.try_set(state, pt, TeamData.TASK_BUILD, pt.tile_pos, TaskArbiter.PRIO_PLAYER, "player_camp")
	return { "ok": true, "msg": "開始紮營 %s（%d ticks,免材料）" % [camp_type, CAMP_BUILD_TICKS] }
```

- [ ] **Step 4: 實作 `_complete_construction` 的 "crude_camp" 分支** — `outpost_system.gd`（`_complete_construction` match 內加 case，仿既有 "build" 分支但**免材料已扣、只抬 cap 不送即時糧**）：

```gdscript
		"crude_camp":
			tile.outpost_type  = str(tile.construction_target.get("type", "civilian"))
			tile.outpost_level = 1
			tile.outpost_owner = int(tile.construction_target.get("owner", team.team_id))
			# 只抬 food cap（regen 才能產糧）,不送即時糧（去剝削;與 NPC establish_crude_camp 差異）
			tile.resource_cap["food"] = maxf(float(tile.resource_cap.get("food", 0)), 40.0)
			# 身分躍遷:升軍/生產 tag、脫流亡（仿 establish_crude_camp 後段）
			var camp_tag: String = TeamData.TAG_MILITARY if tile.outpost_type == "military" else TeamData.TAG_PRODUCE
			if not team.tags.has(camp_tag):
				team.tags.append(camp_tag)
			team.tags.erase("流亡")
			TaskArbiter.release(team)   # 紮營完工 → 釋放玩家隊回 idle
			print("[CrudeCamp] Team%d 玩家紮營完工 @(%d,%d) → %s" % [
				team.team_id, tile.tile_pos.x, tile.tile_pos.y, tile.outpost_type])
```
（`40.0` 對齊 `PlayerCommandSystem.CAMP_FOOD_CAP`;若要單一來源,可改引用該常數,但 outpost_system 無依賴 player_command 較乾淨 → 留字面 + 註解「= CAMP_FOOD_CAP」。確認 `_complete_construction` 尾段 `construction_ticks_left=0` / `construction_target={}` 對所有分支統一清,crude_camp 分支不需自清。）

- [ ] **Step 5: 跑確認通過** — `玩家紮營 OK`

- [ ] **Step 6: available_actions 加 camp（self-action）** — `player_query_api.gd`：仿 train，加：
```gdscript
			{
				"action_id": "camp",
				"label": "紮營（免材料,限時）",
				"allowed_kinds": PackedStringArray(["none"]),
			},
```
（gate:腳下 tile 無主、非山地、未開發才列——參考既有 build_outpost 的列出條件;若條件不符可仍列但執行回 ok=false feedback。對齊現行組法。）

- [ ] **Step 7: 寫 ui_flow 測（camp self-action 可達）** — `ui_flow_test.gd`

```gdscript
func _test_camp_action_reachable() -> void:
	print("\n── 紮營 self-action 可達 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var pt = st.teams[st.persons[st.player_id].team_id]
	var tile = st.world.tiles.get(pt.tile_pos.x*1000 + pt.tile_pos.y)
	if tile != null:
		tile.outpost_level = 0; tile.outpost_owner = -1; tile.terrain = "plains"
	node._interact_mode = true; node._interact_target = -1
	node._refresh()
	var self_ids: Array = []
	for a in node._interact_action_split()["self"]: self_ids.append(a.get("action_id",""))
	_check("camp 在 self-actions", "camp" in self_ids)
	await _free_ui(node)
```
註冊進 `_initialize()`。

- [ ] **Step 8: 跑全綠** — headless + ui_flow。

- [ ] **Step 9: Commit**

```bash
git add scripts/simulation/player_command_system.gd scripts/simulation/outpost_system.gd scripts/simulation/player_query_api.gd scripts/debug/headless_test.gd scripts/debug/ui_flow_test.gd
git commit -m "feat(player): 紮營動作（C-2 Y版）免材料/無即時糧/距離spacing/限時施工,reuse construction 機制"
```

---

## Task 5: 註冊 + 整合 + sanity

- [ ] **Step 1: 確認新測全註冊** — headless：`_test_panic_skips_player_team`、`_test_player_train`、`_test_player_camp`;ui_flow：`_test_player_status_label`、`_test_train_action_reachable`、`_test_camp_action_reachable`。（在各 `_initialize()` 測序列加 `await`。）

- [ ] **Step 2: 動作 UI 覆蓋審計** — 確認既有 `_test_action_ui_coverage`（headless）對新增 `train`/`camp` registry 仍綠（兩者皆有 query available_actions 入口）。若審計遍歷 registry 要求每個有 UI 路徑,確認 train/camp 被涵蓋。

- [ ] **Step 3: 全跑** — 殺孤兒 godot →
```powershell
$env:GODOT_TIMEOUT='360'
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd   # === DONE ===,無 SCRIPT ERROR,新測全綠
.\tools\godot.ps1 --headless --script scripts/debug/ui_logic_test.gd   # errors: 0
.\tools\godot.ps1 --headless --script scripts/debug/ui_flow_test.gd    # errors: 0
```

- [ ] **Step 4: 守恆 sanity** — `SIM_CONFIGS=survival_start` multi：
```powershell
$env:SIM_CONFIGS='survival_start'
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
驗 `died=no`、`[CoinAudit] ... delta=0.00`（多 sim 無玩家 → 訓練 coin sink 不觸發,coin_eq 應仍 0;紮營/panic 守衛不影響 NPC 路徑）、無 SCRIPT ERROR。

- [ ] **Step 5: handback** — 寫 `docs/superpowers/handbacks/2026-06-16-player-action-parity.md`：實作摘要每檔一行 + 與 spec 差異 + 連動風險（panic 守衛只動玩家隊 / 紮營複用 construction / 訓練比 NPC 完整因 W4）+ 待主 session 確認的真視覺項（訓練/紮營 self-action 選單觀感、紮營施工中 status 顯「狀態:建設」、label「狀態:」版面）。

---

## 注意事項（給實作者）

- **DRY**：訓練 reuse `AnonTierSystem.add_exp`+`try_promote`（勿自寫升階）;紮營 reuse `_check_distance`+construction 機制+`establish_crude_camp` 後段 tag 邏輯（勿複製,但**去即時糧**——只抬 cap）。
- **去剝削是紮營核心**：`_complete_construction` "crude_camp" 分支**只動 `resource_cap["food"]`,絕不動 `resources["food"]`**（送即時糧 = 剝削點,spec 明禁）。
- **訓練 coin = 消耗 sink**：coin 直接從玩家隊扣掉（離開經濟）。多 sim 無玩家不觸發,coin_eq 維持 0;勿把訓練 coin 轉到別處（那才破守恆）。
- **panic 守衛只加一行**：`and team.leader_id != state.player_id`,勿改 reaction 其餘路徑（NPC 恐慌不變）。其餘恐慌效果（work_morale/loyalty/defect/戰場潰逃）**不准動**。
- **紮營 task=建設 是玩家發起的限時令**,非 AI auto-task;完工 `TaskArbiter.release`。與「玩家不要 AI auto-task」不衝突（玩家自選有時長命令）。
- **名稱核對**：`AnonTierSystem`/`OutpostSystem`/`TaskArbiter`/`PlayerCommandSystem` class_name、`_check_distance`/`_complete_construction`/`_tick_construction` 簽名、`TeamData.TASK_BUILD`/`TAG_MILITARY`/`TAG_PRODUCE`、player_query_api available_actions 組法、`_interact_action_split` self 分類以現碼為準。
- godot 跑前殺孤兒進程（import lock）;headless `assert` 失敗會卡 quit() 前 → 寫測先 print 再 assert。
- **不做**：覓食/pacify/settle/C-1 設持續 task;**不動 NPC `establish_crude_camp`**（即時糧軟化絕境屬獨立量測 task,見 roadmap）。
```
