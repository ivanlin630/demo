extends SceneTree

# ★F0 regression 快照 worker（spec §3）：跑單床(FP_BED env)×3seed×3tick → 寫 partial(FP_OUT env)。
# 分床平行 invoke（sim 慢=recovery 27s/240tick 超線性；單 process 跑 9 run 超 wrapper timeout）→ 3 worker 平行 → fp_merge 合。
# 純結構 slice 後重跑逐一對 baseline：全同=行為零漂移。純讀零 RNG（StateFingerprint 命門）。

const BEDS: Dictionary = {
	"warring":  "res://config/warring_states.json",              # threat/combat/diplomacy/survival
	"peaceful": "res://config/peaceful_economy.json",            # production/trade/facility/outpost
	"recovery": "res://config/f0_recovery.json",                # side-dispatch/移民/投資/遷村/cohesion/relief（radius15 輕量）
}
const SEEDS: Array = [1337, 42, 7]         # 含硬 seed 1337
const CHECKPOINTS: Array = [240, 1000, 2400]   # 早期分岔 / accumulation / 長程漂移
const DOMAINS: Array = ["teams", "persons", "factions", "belief", "tiles", "world"]

func _initialize() -> void:
	var bed_name: String = OS.get_environment("FP_BED")
	var out_path: String = OS.get_environment("FP_OUT")
	if bed_name == "" or not BEDS.has(bed_name) or out_path == "":
		print("  [worker] 需 FP_BED(%s)+FP_OUT env" % ",".join(PackedStringArray(BEDS.keys())))
		quit(); return
	var out: Dictionary = {}
	var sig: Dictionary = {"relocate": false, "letter": false, "subteam": false, "combat": false}
	# ★FP_SEED env（可選）：單 seed 跑（慢床 radius40 recovery per-seed 平行、免單 process 3 seed 超 timeout）。
	var seed_env: String = OS.get_environment("FP_SEED")
	var run_seeds: Array = [int(seed_env)] if seed_env != "" else SEEDS
	for sd in run_seeds:
		var key: String = "%s:%d" % [bed_name, sd]
		out[key] = _run_bed(String(BEDS[bed_name]), int(sd), sig)
		print("  [bed] %s done" % key)
	out["_signals"] = sig
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(out, "  ", true, true)); f.close()
		print("  [worker] %s partial → %s" % [bed_name, out_path])
	else:
		print("  [worker] WRITE FAIL %s" % out_path)
	print("=== DONE ===")
	quit()

func _run_bed(config_path: String, world_seed: int, sig: Dictionary) -> Dictionary:
	seed(world_seed)
	var state := WorldState.new()
	GameSetup.setup(state, GameSetup.load_config(config_path))
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	var res: Dictionary = {}
	var max_cp: int = int(CHECKPOINTS[CHECKPOINTS.size() - 1])
	for tick in range(1, max_cp + 1):
		runner.advance_tick(state, no_player)
		if state.in_transit_letters.size() > 0: sig["letter"] = true
		if tick in CHECKPOINTS:
			# 域信號 checkpoint 檢（真 exercise、R² 觀察②；checkpoint-only 省 per-tick 開銷）。
			for tid in state.teams:
				var st: TeamData = state.teams[tid]
				if st.task_reason == "relocate": sig["relocate"] = true
				if st.parent_team_id != -1: sig["subteam"] = true
				if st.combat_target != -1: sig["combat"] = true
			var doms: Dictionary = StateFingerprint.compute_domains(state)
			res[str(tick)] = {"full": StateFingerprint.compute(state), "domains": doms}
	return res
