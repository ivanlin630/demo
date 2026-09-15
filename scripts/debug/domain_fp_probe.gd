extends SceneTree
# @bed-kind: diagnostic
# ★逐域指紋：同 seed 同窗跑一段，印 `compute_domains()` 的每一域
#   ⇒ ★★用途是把「fp 變了」拆成「哪一域變了」——
#   ★★★而它本身**不下判決**：兩棵樹的比對在交件上做（這支只負責產數字）。
# env：DFP_TICKS（預設 1440）／DFP_SEED（預設 1337）
func _init() -> void:
	var ticks: int = int(OS.get_environment("DFP_TICKS")) if OS.has_environment("DFP_TICKS") else 1440
	var sd: int = int(OS.get_environment("DFP_SEED")) if OS.has_environment("DFP_SEED") else 1337
	seed(sd)
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/warring_states.json")
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	for _t in range(ticks):
		runner.advance_tick(st, no_player)
	var d: Dictionary = StateFingerprint.compute_domains(st)
	var keys: Array = d.keys()
	keys.sort()
	print("-- 逐域指紋（seed %d／%d tick）--" % [sd, ticks])
	for k in keys:
		print("DOMAIN\t%s\t%s" % [String(k), String(d[k])])
	print("DOMAIN\t__all__\t%s" % StateFingerprint.compute(st))
	# ★★★收窄用：`teams` 域裡有很多欄位 ⇒ 「只有 teams 變」還不夠精
	#   ⇒ ★直接數【每支隊的 goal 筆數】：若兩棵樹差恰好是【隊數】，
	#     ★★就與「每支隊少了一筆 `maintain_coin`」逐字對得上。
	var _gs_total: int = 0
	var _gs_teams: int = 0
	for tid in st.teams:
		var _t: TeamData = st.teams[tid]
		if _t == null: continue
		_gs_teams += 1
		_gs_total += (_t.goal_state as Array).size()
	print("GOALSTATE\tteams\t%d" % _gs_teams)
	print("GOALSTATE\tentries\t%d" % _gs_total)
	print("-- 量測完成（本床不下判決） --")
	quit()
