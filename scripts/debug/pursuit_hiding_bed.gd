extends SceneTree

func _initialize() -> void:
	_run(); quit()

# Tier1 控制場景床：god-view pursuit 逃脫故事驗證（blueprint 授權建，2026-07-15）。
# 純量測 debug script，零 production 邏輯改動——手構最小 WorldState 呼叫既有 API 觀察。
# 復用設計：場景 spec（spawn prey+pursuer）與斷言（撲空率）分離，供未來 story-central 稀有行為復用。
#
# 故事：pursuer 已 engage prey（combat_target 設）。prey 曾在 A 位被看到（belief last_tick=近期，
# 未過 staleness），但已經悄悄移到 B 位（live tile_pos）。
#   - 若 pursuer 的移動目標鎖 belief last-seen(A) → 撲空（prey 真身在 B，非 A）→ 逃脫故事成立。
#   - 若 pursuer 移動目標鎖 live(B) → god-view，精準攔截，無逃脫可能（fix 對此路徑 inert）。

func _new_state() -> WorldState:
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	return s

func _tile(s: WorldState, pos: Vector2i) -> HexTileData:
	var key: int = pos.x * 1000 + pos.y
	if not s.world.tiles.has(key):
		var t := HexTileData.new(); t.tile_pos = pos; t.terrain = "plains"
		s.world.tiles[key] = t
	return s.world.tiles[key]

func _fill(s: WorldState, r: int) -> void:
	for x in range(-r, r + 1):
		for y in range(-r, r + 1):
			_tile(s, Vector2i(x, y))

func _seed(team: TeamData, n: int) -> void:
	var named: int = team.named_members.size() + (1 if team.leader_id != -1 else 0)
	if n - named > 0:
		AnonCohort.add(team.anon_cohorts, "平民", "healthy", n - named)

const POS_LAST_SEEN := Vector2i(0, 0)   # A：pursuer 上次見到 prey 的位置（belief 內容）
const POS_LIVE      := Vector2i(8, 0)   # B：prey 現在真正的位置（已悄悄移動，斷視線）

func _run() -> void:
	print("=== pursuit-hiding bed：god-view 逃脫故事驗證 ===")
	var s := _new_state()
	_fill(s, 12)

	# prey：現在真身在 B（POS_LIVE）
	var prey := TeamData.new(); prey.team_id = 1; prey.tile_pos = POS_LIVE
	prey.faction_id = -1
	var p_ldr := PersonData.new(); p_ldr.id = 10; p_ldr.team_id = 1
	s.persons[10] = p_ldr; prey.leader_id = 10
	_seed(prey, 3)
	s.teams[1] = prey

	# pursuer：已 engage（combat_target=1, current_task=TASK_LOOT），起點在 A 附近
	var pursuer := TeamData.new(); pursuer.team_id = 0; pursuer.tile_pos = Vector2i(1, 0)
	pursuer.faction_id = -1
	var u_ldr := PersonData.new(); u_ldr.id = 20; u_ldr.team_id = 0
	s.persons[20] = u_ldr; pursuer.leader_id = 20
	_seed(pursuer, 5)
	pursuer.current_task = TeamData.TASK_LOOT
	pursuer.combat_target = 1
	pursuer.prosperity_target_id = 1
	s.teams[0] = pursuer

	# ★belief：pursuer 對 prey 的信念仍停在 A（last_tick=近期，未過 3 天 staleness），
	# 但 prey 真身已在 B（tile_pos 已改，pursuer 沒「看到」這次移動）。
	s.world.current_tick = WorldState.TICKS_PER_DAY   # day1，belief 1 tick 前=極新鮮
	s.team_intel[0] = {1: {
		"tile_pos": POS_LAST_SEEN, "last_tick": s.world.current_tick - 1,
		"population_est": 3, "confidence": 1.0,
	}}
	s.team_discovered[0] = [1]

	# ── 測 1：BeliefSystem.belief_pos 本體（stale-aware last-seen）──
	var bpos: Vector2i = BeliefSystem.belief_pos(s, 0, 1)
	print("\n--- 測1：belief_pos（新鮮 belief，prey 已偷偷移動）---")
	print("  belief last-seen(A) = %s" % str(POS_LAST_SEEN))
	print("  prey 真身 live(B)   = %s" % str(POS_LIVE))
	print("  BeliefSystem.belief_pos() 回傳 = %s" % str(bpos))
	print("  → %s" % ("★belief_pos 正確鎖 last-seen(A)，非 live(B)——本體函式正確" if bpos == POS_LAST_SEEN else "✗belief_pos 沒鎖 last-seen，跟 live 一樣或錯值"))

	# ── 測 2：movement_system 的追蹤 refresh（combat_target 隊會被排除，見 movement_system.gd:77-79）──
	var runner := SimRunner.new()
	pursuer.move_target = POS_LAST_SEEN   # 模擬先前 dispatch 時鎖定 last-seen
	runner._movement_system.process(s, [0, 1])
	print("\n--- 測2：movement_system 逐 tick 追蹤 refresh（pursuer.combat_target=1 已設）---")
	print("  move_teams 後 pursuer.move_target = %s" % str(pursuer.move_target))
	print("  → %s" % ("★combat_target 隊被 movement_system belief 刷新排除(見 :77-79 continue)——不受這條路影響，維持先前 move_target" if pursuer.move_target == POS_LAST_SEEN else "movement_system 動了 move_target"))

	# ── 測 3：_refresh_attack_pursuit（faction_ai_system 內、TASK_ATTACK/LOOT 專用逐-tick 追擊微調）──
	var fai := FactionAISystem.new()
	fai._refresh_attack_pursuit(s, pursuer)
	print("\n--- 測3：_refresh_attack_pursuit（TASK_LOOT 專用追擊，god-view 疑點）---")
	print("  呼叫後 pursuer.move_target = %s" % str(pursuer.move_target))
	if pursuer.move_target == POS_LIVE:
		print("  → ★★確認 inert：_refresh_attack_pursuit 讀 prey.tile_pos 活值，直接鎖真身(B)——god-view 未修，逃脫故事在『已engage的loot/attack追擊』這條路完全不生效")
	elif pursuer.move_target == POS_LAST_SEEN:
		print("  → 鎖 last-seen(A)，逃脫故事在此路成立（撲空）")
	else:
		print("  → 非A非B，另一機制（如 predict_intercept 攔截預測），需再查")

	print("\n=== pursuit-hiding bed DONE ===")
