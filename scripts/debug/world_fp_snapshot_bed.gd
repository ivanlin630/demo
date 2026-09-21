extends SceneTree
# @bed-kind: diagnostic
#
# 世界指紋快照：固定 seed／config／窗 ⇒ 印一個 fp。
# ★用途：讓「修法前」與「修法後」的 fp 可以【逐字】比對（觀測雜訊決定性化票的 2-f）。
# ★★它【只印不判】—— 判在別處（交件信與驗收床）；所以它是 diagnostic 不是 gate。
# ★★★為什麼要獨立一支：2-f 要的「修法前」必須在【動 code 之前】量到，
#   而驗收床會呼叫修法後才存在的函式 ⇒ 那支床在修法前【編不過】。
#   ⇒ 這一支不碰新函式，所以它在兩邊都跑得起來。
#
# env：WFP_TICKS（預設 20000）／WFP_CONFIG（預設 warring_states）／WFP_SEED（預設 20260922）

func _initialize() -> void:
	var ticks: int = int(OS.get_environment("WFP_TICKS")) if OS.has_environment("WFP_TICKS") else 20000
	var cfg: String = OS.get_environment("WFP_CONFIG") if OS.has_environment("WFP_CONFIG") else "warring_states"
	var sd: int = int(OS.get_environment("WFP_SEED")) if OS.has_environment("WFP_SEED") else 20260922
	print("=== 世界指紋快照（ticks=%d ＝ %.2f 遊戲天｜config=%s｜seed=%d）===" % [
		ticks, float(ticks) / float(WorldState.TICKS_PER_DAY), cfg, sd])
	seed(sd)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/%s.json" % cfg))
	st.player_id = -1
	var runner := SimRunner.new()
	# ★逐 tick 軌跡也取一個摘要：只有終局 fp 相同【不代表】中途沒分岔又合流。
	var traj: PackedStringArray = PackedStringArray()
	for t in range(ticks):
		runner.advance_tick(st, Vector2i(-1, -1))
		if (t + 1) % 1000 == 0:
			traj.append(StateFingerprint.compute(st))
	var fp: String = StateFingerprint.compute(st)
	print("[WFP] final_fp = %s" % fp)
	print("[WFP] traj_fp  = %s   （每 1000 tick 取樣 %d 點，串接後再取指紋）" % [
		("\n".join(traj)).sha256_text(), traj.size()])
	print("[WFP] teams=%d persons=%d tick=%d" % [st.teams.size(), st.persons.size(), st.world.current_tick])
	print("=== world_fp_snapshot DONE ===")
	quit(0)
