extends SceneTree
# 命令戳記誠實化 TDD。
# ①★重申不喚醒：連續兩輪產出完全相同 → 第二輪不蓋戳記、成員不被 directive_fresh 喚醒
# ②★真變化仍喚醒：任一語意欄（goals 集合 / intent / why / mode）變 → 蓋、成員當輪喚醒
# ③★玩家 override 改變時會蓋戳記（新 gate：該路完全不經 _emit_goal，今天是「玩家下令沒人理」）
# ④T0 事件瞬醒不受影響（兩路獨立）

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _initialize() -> void:
	_run(); quit()

func _mk() -> Array:
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	s.world.current_tick = 5000
	var t := HexTileData.new(); t.tile_id = 0; t.tile_pos = Vector2i(0,0); t.terrain = "plains"
	t.resources = {"food": 60.0}; t.resource_cap = {"food": 200.0}
	s.world.tiles[0] = t
	var ldr := PersonData.new(); ldr.id = 700; ldr.team_id = 7
	ldr.values = {"野心": 0.6, "求生欲": 0.5, "義氣": 0.5}; ldr.skills = {"統領": 0.6}
	s.persons[700] = ldr
	var lead := TeamData.new(); lead.team_id = 7; lead.leader_id = 700; lead.tile_pos = Vector2i(0,0)
	AnonCohort.add(lead.anon_cohorts, "平民", "healthy", 10)
	lead.resources = {"food": 80.0}
	s.teams[7] = lead
	s.create_faction(7)
	var fid: int = lead.faction_id
	var m := TeamData.new(); m.team_id = 8; m.tile_pos = Vector2i(0,0)
	var m_ldr := PersonData.new(); m_ldr.id = 800; m_ldr.team_id = 8; s.persons[800] = m_ldr
	m.leader_id = 800
	AnonCohort.add(m.anon_cohorts, "平民", "healthy", 6)
	m.resources = {"food": 40.0}
	s.teams[8] = m
	s.set_team_faction(m, fid)
	return [s, s.factions[fid], m]

func _run() -> void:
	print("=== directive stamp honesty test ===")
	var fai := FactionAISystem.new()
	# ① 重申不喚醒
	var w := _mk(); var s: WorldState = w[0]; var f = w[1]; var mem: TeamData = w[2]
	fai._update_goals(s, f)
	var first_stamp: int = f.directive_change_tick
	s.world.current_tick += 100
	fai._update_goals(s, f)      # 世界沒變 → 應產出相同命令
	_ok(f.directive_change_tick == first_stamp,
		"★純重申不蓋戳記（stamp 仍 %d、未跳到 %d）" % [f.directive_change_tick, s.world.current_tick])
	mem.last_decision_tick = first_stamp + 1   # 成員已在首次之後決策過
	_ok(not fai._directive_fresh(s, mem), "★成員不被喚醒（directive_fresh=false）")
	# ② 真變化仍喚醒（改語意欄：換 driver 內容）
	s.world.current_tick += 100
	f.goal_drivers["攻擊"] = {"intent": "征服", "why": "假造的舊值", "mode": "test"}
	if not ("攻擊" in f.goals): f.goals.append("攻擊")
	fai._update_goals(s, f)      # 重建後 goals/drivers 應與被我改過的前值不同 → 蓋
	_ok(f.directive_change_tick == s.world.current_tick,
		"★真變化蓋戳記（stamp=%d＝當前 tick）" % f.directive_change_tick)
	_ok(fai._directive_fresh(s, mem), "★成員當輪被喚醒（directive_fresh=true）")
	# ③ 玩家 override 改變 → 蓋戳記（該路不經 _emit_goal）
	var w3 := _mk(); var s3: WorldState = w3[0]; var f3 = w3[1]; var mem3: TeamData = w3[2]
	f3.player_goal_override = "防衛"
	fai._update_goals(s3, f3)
	var st3: int = f3.directive_change_tick
	_ok(st3 == s3.world.current_tick, "★玩家 override 首次設定 → 蓋戳記（今天這條路完全不蓋＝下令沒人理）")
	s3.world.current_tick += 100
	fai._update_goals(s3, f3)   # override 沒變 → 不蓋
	_ok(f3.directive_change_tick == st3, "玩家 override 未變 → 不重蓋（重申不喚醒一致）")
	s3.world.current_tick += 100
	f3.player_goal_override = "擴張"
	fai._update_goals(s3, f3)
	_ok(f3.directive_change_tick == s3.world.current_tick, "★玩家 override 改變 → 蓋戳記")
	mem3.last_decision_tick = st3
	_ok(fai._directive_fresh(s3, mem3), "★玩家改令 → 成員被喚醒")
	# ④ T0 事件瞬醒不受影響
	var w4 := _mk(); var s4: WorldState = w4[0]; var mem4: TeamData = w4[2]
	mem4.current_task = TeamData.TASK_PRODUCE
	mem4.decision_eval_next_tick = s4.world.current_tick + 9999
	mem4.last_decision_tick = s4.world.current_tick
	_ok(not fai._should_reeval(s4, mem4), "對照：無事件、cadence 未到 → 不重評")
	WorldEvents.emit(s4, "combat_engaged", [mem4.team_id])
	_ok(fai._should_reeval(s4, mem4), "★T0 事件瞬醒不受本刀影響（兩路獨立）")
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
