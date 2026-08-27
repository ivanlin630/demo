extends SceneTree
# ★★★盲派修正的【陽性對照】：造一個「私產不足、公庫有料」的局面，
#   驗它 ①走得到公庫路徑 ②真的從公庫扣 ③守恆帳平（實扣 == 應扣）。
#   ★理由：30 日 peaceful 跑出來公庫路徑【零次】——而「零」有兩種：
#     沒有人有公庫材料 / 接線沒接上。★★這張床就是把兩者分開的那把尺。
func _initialize() -> void:
	print("[ctl] 進入 _initialize")
	seed(1337)
	var state := WorldState.new()
	state.world = WorldData.new()
	var pos := Vector2i(2, 0)
	var tile := HexTileData.new()
	tile.tile_id = pos.x * 1000 + pos.y; tile.tile_pos = pos
	tile.terrain = "plains"; tile.outpost_type = "civilian"; tile.outpost_level = 1
	# ★不手抄欄位名（今天踩過 workshop_level 不存在）：從 FACILITY_DEF 拿
	var wk: String = String(OutpostSystem.FACILITY_DEF["workshop"].get("current_level_key", ""))
	if wk != "": tile.set(wk, 1)
	state.world.tiles[tile.tile_id] = tile
	var team := TeamData.new()
	team.team_id = 700; team.tile_pos = pos; team.faction_id = -1
	team.tags.append(TeamData.TAG_PRODUCE)
	var ldr := PersonData.new(); ldr.id = 7000; ldr.team_id = 700
	ldr.skills["統領"] = 0.5
	state.persons[7000] = ldr; team.leader_id = 7000
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 9)
	state.teams[700] = team
	tile.outpost_owner = team.team_id
	# ★關鍵佈局：私產只有一半，另一半在公庫
	team.resources["food"] = 300.0
	team.resources["material"] = 0.0   # ★前一版給 10，而 arrows 的單次用量小到 10 就夠付
	#   ⇒ 公庫路徑永遠不會被逃出來。★★對照組要逆者而行：把私產清零，
	#   它非走公庫不可 ⇒ 這才是【能分辨接線有沒接上】的對照。
	team.resources["tools"] = 5.0
	TileBank.deposit(tile, "material", 400.0, "control_seed")   # ★給多一點：上一版 90 被【建設】吃光，製造都還沒輪到
	Probe.reset(); Probe.enabled = true
	print("=== blindview_control === 私產 material=%.0f｜公庫 material=%.0f"
		% [float(team.resources.get("material", 0)), float(tile.public_storage.get("material", 0))])
	var runner := SimRunner.new()
	for _t in range(1 * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, pos)
	print("結束：私產 material=%.2f｜公庫 material=%.2f"
		% [float(team.resources.get("material", 0)), float(tile.public_storage.get("material", 0))])
	for k in ["manufacture.vault_path.tried", "manufacture.vault_path.ok", "manufacture.debit_mismatch", "manufacture.fired"]:
		print("  %-34s %s" % [k, (str(int(Probe.counts[k])) if Probe.counts.has(k) else "★key 不存在")])
	var vf: float = 0.0
	for ak in Probe.amounts:
		if String(ak).begins_with("manufacture.input_from_vault."):
			vf += float(Probe.amounts[ak])
	print("  ★從公庫實扣總量 = %.2f" % vf)
	print("=== blindview_control DONE ===")
	quit()
