extends SceneTree
# settlement §4c TDD — 選址結果反饋迴路。
# ①同團第二次選址該地 util 降 ②別團不受影響（非全域）③過期後回復 ④leader 換人不繼承
# ⑤write_site_memory 不碰 p.relations ⑥camp_team_id 進 fingerprint。

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _init() -> void:
	print("=== settlement S4c test ===")
	_t1_same_team_avoids_failed_site()
	_t2_other_team_unaffected()
	_t3_expiry_restores()
	_t4_leader_change_no_inherit()
	_t5_no_relations_pollution()
	_t6_camp_team_in_fp()
	_t7_floor_and_taps()
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
	quit()

func _mk(state: WorldState, tid: int, pos: Vector2i) -> TeamData:
	var t := HexTileData.new(); t.tile_id = pos.x*1000+pos.y; t.tile_pos = pos
	t.terrain = "plains"; t.productivity = 1.0; t.camp_level = 1
	t.camp_ticks_left = 100; t.outpost_owner = -1
	if not state.world.tiles.has(t.tile_id): state.world.tiles[t.tile_id] = t
	var ldr := PersonData.new(); ldr.id = 500 + tid; ldr.values = {"野心": 0.5}
	state.persons[ldr.id] = ldr
	var team := TeamData.new(); team.team_id = tid; team.leader_id = ldr.id
	ldr.team_id = tid
	team.tile_pos = pos; team.faction_id = -1
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 5)
	team.resources = {"food": 100.0}
	state.teams[tid] = team
	return team

func _world() -> WorldState:
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	s.world.current_tick = 10000
	return s

# ① 失敗記憶 → 同團該地選址品質乘子 < 1（util 降）
func _t1_same_team_avoids_failed_site() -> void:
	print("--- ① 同團第二次選址該地 util 降 ---")
	var s := _world()
	var team := _mk(s, 1, Vector2i(3,3))
	var tile: HexTileData = s.world.tiles[3003]
	var before: float = SettlementMemory.quality_multiplier(s, team, tile.tile_id)
	_ok(absf(before - 1.0) < 1e-6, "無記憶→乘子 1.0（%.3f）" % before)
	SettlementMemory.record_site_outcome(s, team, tile, SettlementMemory.SITE_FAILED)
	var after: float = SettlementMemory.quality_multiplier(s, team, tile.tile_id)
	_ok(after < before, "失敗記憶→乘子降（%.3f < %.3f）＝同地 util 降" % [after, before])
	# 興旺相反向
	var s2 := _world(); var t2 := _mk(s2, 1, Vector2i(4,4))
	SettlementMemory.record_site_outcome(s2, t2, s2.world.tiles[4004], SettlementMemory.SITE_THRIVED)
	_ok(SettlementMemory.quality_multiplier(s2, t2, 4004) > 1.0, "興旺記憶→乘子升（好地更值得）")

# ② 別團不受影響（self-knowledge、非全域黑名單）
func _t2_other_team_unaffected() -> void:
	print("--- ② 非全域 ---")
	var s := _world()
	var a := _mk(s, 1, Vector2i(5,5))
	var b := _mk(s, 2, Vector2i(6,5))
	SettlementMemory.record_site_outcome(s, a, s.world.tiles[5005], SettlementMemory.SITE_FAILED)
	_ok(SettlementMemory.quality_multiplier(s, a, 5005) < 1.0, "A 隊記得（乘子<1）")
	_ok(absf(SettlementMemory.quality_multiplier(s, b, 5005) - 1.0) < 1e-6, "B 隊不受影響（乘子=1.0、非全域黑名單）")

# ③ 過期後回復（線性衰減、非永久黑名單）
func _t3_expiry_restores() -> void:
	print("--- ③ 過期回復 ---")
	var s := _world()
	var team := _mk(s, 1, Vector2i(7,7))
	SettlementMemory.record_site_outcome(s, team, s.world.tiles[7007], SettlementMemory.SITE_FAILED)
	var fresh: float = SettlementMemory.quality_multiplier(s, team, 7007)
	s.world.current_tick += int(SettlementMemory.SITE_MEMORY_TTL_DAYS * 0.5) * WorldState.TICKS_PER_DAY
	var half: float = SettlementMemory.quality_multiplier(s, team, 7007)
	_ok(half > fresh and half < 1.0, "半個 TTL→衰減但仍有效（%.3f，介於 %.3f 與 1.0）" % [half, fresh])
	s.world.current_tick += int(SettlementMemory.SITE_MEMORY_TTL_DAYS) * WorldState.TICKS_PER_DAY
	_ok(absf(SettlementMemory.quality_multiplier(s, team, 7007) - 1.0) < 1e-6, "超過 TTL→歸零回復 1.0（非永久黑名單）")

# ④ leader 換人不繼承（記憶隨人、intended）
func _t4_leader_change_no_inherit() -> void:
	print("--- ④ 記憶隨人 ---")
	var s := _world()
	var team := _mk(s, 1, Vector2i(8,8))
	SettlementMemory.record_site_outcome(s, team, s.world.tiles[8008], SettlementMemory.SITE_FAILED)
	_ok(SettlementMemory.quality_multiplier(s, team, 8008) < 1.0, "原 leader 記得")
	var heir := PersonData.new(); heir.id = 9999; heir.team_id = 1; s.persons[9999] = heir
	team.leader_id = 9999
	_ok(absf(SettlementMemory.quality_multiplier(s, team, 8008) - 1.0) < 1e-6, "換 leader→不繼承（記憶隨人非隨團、intended）")

# ⑤ write_site_memory 不碰 p.relations（R² 必查項①）
func _t5_no_relations_pollution() -> void:
	print("--- ⑤ 不汙染 relations ---")
	var s := _world()
	var team := _mk(s, 1, Vector2i(9,9))
	var ldr: PersonData = s.persons[team.leader_id]
	var rel_before: int = ldr.relations.size()
	SettlementMemory.record_site_outcome(s, team, s.world.tiles[9009], SettlementMemory.SITE_FAILED)
	_ok(ldr.relations.size() == rel_before, "relations 數量未變（%d）＝沒塞「跟一塊地的交情」" % ldr.relations.size())
	_ok(not ldr.relations.has(9009), "relations 無 tile_id key（9009）")
	_ok(ldr.memory.size() > 0 and String(ldr.memory[-1].get("type","")) == SettlementMemory.SITE_FAILED,
		"memory 有寫入（type=site_failed、subject=tile_id）")

# ⑥ camp_team_id 進 fingerprint（否則 L0 歸屬變化＝determinism 盲點）
func _t6_camp_team_in_fp() -> void:
	print("--- ⑥ camp_team_id 進 fp ---")
	var s := _world()
	var team := _mk(s, 1, Vector2i(2,2))
	var tile: HexTileData = s.world.tiles[2002]
	tile.camp_team_id = -1
	var fp0: String = StateFingerprint.compute(s)
	tile.camp_team_id = team.team_id
	var fp1: String = StateFingerprint.compute(s)
	_ok(fp0 != fp1, "camp_team_id 改變→fp 改變（非盲點）")

# ⑦ merge-gate 訂正 B/C：折價下界不歸零（禁絕對門檻）+ 讀寫端 tap
func _t7_floor_and_taps() -> void:
	print("--- ⑦ 折價下界 + tap ---")
	var s := _world()
	var team := _mk(s, 1, Vector2i(11,11))
	Probe.enabled = true
	Probe.reset()
	# 連兩次同地失敗 → bias=-1.0（0.5+0.5）→ 若無下界會歸零＝硬門檻
	SettlementMemory.record_site_outcome(s, team, s.world.tiles[11011], SettlementMemory.SITE_FAILED)
	SettlementMemory.record_site_outcome(s, team, s.world.tiles[11011], SettlementMemory.SITE_FAILED)
	var mult: float = SettlementMemory.quality_multiplier(s, team, 11011)
	_ok(mult >= SettlementMemory.QUALITY_FLOOR - 1e-6 and mult > 0.0,
		"★兩次失敗→乘子=%.2f ≥ 下界 %.2f（非 0＝不成絕對門檻、瀕餓仍可被絕境秤贏）" % [mult, SettlementMemory.QUALITY_FLOOR])
	_ok(mult < 0.5, "但確實重度折價（%.2f）" % mult)
	_ok(int(Probe.counts.get("site_memory.write", 0)) == 2, "寫端 tap=2（site_memory.write）")
	_ok(int(Probe.counts.get("site_memory.write.site_failed", 0)) == 2, "寫端分型 tap（write.site_failed=2）")
	_ok(int(Probe.counts.get("site_memory.applied", 0)) >= 1, "讀端 tap（applied，乘子!=1.0 才記）")
	# 無記憶 → 乘子 1.0 且不記 applied
	Probe.reset()
	var _m2: float = SettlementMemory.quality_multiplier(s, team, 9999)
	_ok(absf(_m2 - 1.0) < 1e-6 and int(Probe.counts.get("site_memory.applied", 0)) == 0,
		"無記憶→乘子 1.0 且不記 applied（tap 只在真作用時計）")
	Probe.enabled = false
