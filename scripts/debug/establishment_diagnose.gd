extends SceneTree

# (a) measure-first 探真因（藍圖 2026-06-29「default 世界無征服者=核心 gap，別猜」）。
# 量：為何 8 派系 2yr 只 1 立國。立國 gate = 統領≥0.4(-野心折扣) + 野心≥0.7-0.1 + readiness≥0.7 + member≥2。
# 對 warring_states seed，setup(t0) + 跑數百 tick，逐 faction log leader 統領/野心/readiness/member + 哪 gate component fail。
# 純量測，不改邏輯。

func _initialize() -> void:
	_run(); quit()

func _diag(state: WorldState, label: String) -> void:
	print("--- %s ---" % label)
	var pass_all: int = 0
	for fid in state.factions:
		var f = state.factions[fid]
		var lt: TeamData = state.teams.get(f.leader_team_id)
		if lt == null:
			print("  F%d: leader_team null" % fid); continue
		var lp: PersonData = state.persons.get(lt.leader_id)
		var cmd: float = float(lp.skills.get("統領", 0.0)) if lp else 0.0
		var amb: float = float(lp.values.get("野心", 0.0)) if lp else 0.0
		var rdy: float = lt.readiness
		var nmem: int = f.member_team_ids.size()
		# gate components（faction_ai ESTABLISH_COMMAND 0.4 / AMBITION 0.7 / READINESS 0.7）
		var amb_disc: float = (amb - 0.5) * 0.2
		var g_cmd: bool = cmd >= 0.4 - amb_disc
		var g_amb: bool = amb >= 0.7 - 0.1
		var g_rdy: bool = rdy >= 0.7
		var g_mem: bool = nmem >= 2
		var g_est: bool = f.is_established
		var ok: bool = g_cmd and g_amb and g_rdy and g_mem
		if ok or g_est: pass_all += 1
		var fail: String = ""
		if not g_cmd: fail += "統領(%.2f<%.2f) " % [cmd, 0.4 - amb_disc]
		if not g_amb: fail += "野心(%.2f<0.6) " % amb
		if not g_rdy: fail += "readiness(%.2f<0.7) " % rdy
		if not g_mem: fail += "member(%d<2) " % nmem
		print("  F%d: 統領=%.2f 野心=%.2f rdy=%.2f mem=%d est=%s | gate=%s %s" % [
			fid, cmd, amb, rdy, nmem, g_est, "PASS" if ok else "FAIL", "" if ok else ("← " + fail)])
	print("  → 過 gate(或已 est) faction 數 = %d / %d" % [pass_all, state.factions.size()])

func _run() -> void:
	print("=== establishment diagnose: 為何派系不立國 (a) ===")
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config := GameSetup.load_config("res://config/warring_states.json")
	if config.is_empty(): print("[FAIL] config"); return
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	_diag(state, "t=0 (setup 當下)")
	# 跑 60 天看 readiness/member 演化
	for tick in range(240 * 60):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
	_diag(state, "t=60天 (readiness/attrition 演化後)")
	# 統計 leader 統領/野心 分布（看程序生成是否夠強）
	print("--- 全 faction leader 值分布 ---")
	var cmd_hi: int = 0; var amb_hi: int = 0; var both_hi: int = 0; var n: int = 0
	for fid in state.factions:
		var f = state.factions[fid]
		var lt: TeamData = state.teams.get(f.leader_team_id)
		if lt == null: continue
		var lp: PersonData = state.persons.get(lt.leader_id)
		if lp == null: continue
		n += 1
		var c: bool = float(lp.skills.get("統領", 0.0)) >= 0.4
		var a: bool = float(lp.values.get("野心", 0.0)) >= 0.6
		if c: cmd_hi += 1
		if a: amb_hi += 1
		if c and a: both_hi += 1
	print("  faction leader %d 個：統領≥0.4=%d 野心≥0.6=%d 兩者皆=%d" % [n, cmd_hi, amb_hi, both_hi])
	print("=== establishment diagnose DONE ===")
