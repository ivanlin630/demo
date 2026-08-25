extends SceneTree

# ★means-end 接線（acquisition-paths-wire-in）的【故事 specimen】床（systems 派 2026-08-26）。
#
# 要讀出來的故事線（QA 故事稽核用）：
#   ★某支隊【因為缺 tools／weapon】→ means-end 提出【蓋工坊／兵器坊】→ 【後來發生了什麼】。
#
# ★★為什麼要兩趟（pass1 找主角 → pass2 全程 trace）：
#   specimen 名單必須在【跑之前】就設好（tracer 是逐決策捕捉，事後補不回來），
#   但「哪支隊會提出 means-end 候選」要跑過才知道 ⇒ 先跑一趟【只讀 Probe sample】找主角，
#   再用同一個 seed 重跑一次、指名 specimen 全程 trace。
#   ★兩趟世界完全一致的根據：seeded + specimen 選取是【確定性 strided】且觀測零耗 RNG
#     （invariants §觀測者禁耗 global RNG；SpecimenDumpHelper 本體註解有 bisect 坐實）。
#
# ★零 production 改（本檔純 runner）。本床非 @observe-pure：它自己呼 seed() 建世界（合法世界設置）。
#
# env：
#   LW_CONFIG     預設 peaceful_economy（★與 measurer 的 §8 世界層那輪同床）
#   PERF_SEED     預設 1337（★同 seed）
#   ADHOC_DAYS    預設 90（★同窗）
#   SPECIMEN_OUT  預設 docs/measurements/2026-08-26-wire-in-means-end-story.specimen.jsonl
#   SPECIMEN_TEAM_ID  ★若手動指定（逗號分隔）則跳過 pass1，直接用你給的名單
#   SPECIMEN_N    pass1 最多挑幾支主角（預設 3；specimen 越多 entries 越多）

const STORY_RES: Array = ["tools", "weapon"]   # ★故事指定的兩種缺料（其餘資源當 fallback）

func _initialize() -> void:
	_run()
	quit()

func _run() -> void:
	var cfg: String = _env("LW_CONFIG", "peaceful_economy")
	var days: int = int(_env("ADHOC_DAYS", "90"))
	var sd: int = int(_env("PERF_SEED", "1337"))
	var want: int = int(_env("SPECIMEN_N", "3"))
	var out_path: String = _env("SPECIMEN_OUT",
		"docs/measurements/2026-08-26-wire-in-means-end-story.specimen.jsonl")
	print("=== means-end 故事 specimen 床：config=%s days=%d seed=%d out=%s ===" % [cfg, days, sd, out_path])

	# ── pass1：找主角（誰真的提出了 means-end 候選、為了哪個資源）──
	var manual: String = _env("SPECIMEN_TEAM_ID", "")
	var ids: Array[int] = []
	if manual != "":
		for part in manual.split(","):
			var s: String = part.strip_edges()
			if s.is_valid_int(): ids.append(int(s))
		print("[pass1] 跳過（手動指定 SPECIMEN_TEAM_ID=%s）" % str(ids))
	else:
		ids = _pass1_find_actors(cfg, sd, days, want)
	if ids.is_empty():
		print("[FAIL] pass1 找不到任何提出 means-end 候選的隊 → 沒有故事可 trace（★這本身是個結果，回報 systems）")
		return

	# ── pass2：同 seed 重跑，指名 specimen，全程 trace → jsonl ──
	_pass2_trace(cfg, sd, days, ids, out_path)
	print("=== means-end 故事 specimen 床 DONE ===")

# ────────── pass1：只讀 Probe sample，找出「誰在提 means-end」──────────
func _pass1_find_actors(cfg: String, sd: int, days: int, want: int) -> Array[int]:
	print("\n───────── pass1：找主角（跑到湊滿 %d 支或跑完 %d 天）─────────" % [want, days])
	var state: WorldState = _fresh_world(cfg, sd)
	if state == null: return [] as Array[int]
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	var picked: Array[int] = []
	var why: Dictionary = {}   # team_id → 第一次看到它提 means-end 的資源
	for day in range(days):
		for _t in range(WorldState.TICKS_PER_DAY):
			runner.advance_tick(state, no_player)
			if state.encounter_active and state.encounter_tick > 800:
				runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty():
			print("[pass1] day%d 世界空了，停" % day); break
		picked = _scan_actors(why, want)
		# ★不在 day0 就收工：`means_end.util_vs_winner` 是 first-N(200) 取樣，
		#   太早停 ⇒ 只看得到「開局那幾筆」，挑不到【贏過 argmax】的主角（故事會沒有「後來」）。
		#   ⇒ 等取樣池滿（再跑也不會有新樣本）或至少跑 10 天，才允許停。
		var _n: int = (Probe.samples["means_end.util_vs_winner"] as Array).size() \
			if Probe.samples.has("means_end.util_vs_winner") else 0
		if picked.size() >= want and (_n >= 200 or day >= 9):
			print("[pass1] day%d 湊滿 %d 支（sample 池 %d）→ 停" % [day, picked.size(), _n]); break
	if picked.is_empty():
		picked = _scan_actors(why, want)
	for tid in picked:
		print("[pass1] 主角 Team%d（第一次提 means-end 是為了：%s）" % [tid, String(why.get(tid, "?"))])
	return picked

# 掃 means_end.util_vs_winner sample（decision_engine 既有 tap，本票補了 team 欄）。
# ★優先挑「為了 tools／weapon」的隊（那是 systems 指定的故事線），不足才用其他資源補。
func _scan_actors(why: Dictionary, want: int) -> Array[int]:
	# ★三級優先（故事價值由高到低）：
	#   ①【贏了 argmax 且是故事資源】= 提案真的變成行動 ⇒ 才讀得到「後來發生了什麼」
	#   ②【故事資源但沒贏】       = 提了卻輸／不可派（本身也是一種結局，但故事短）
	#   ③【其他資源】             = 保底，免得一支都挑不到
	var facility: Array[int] = []   # ★①' 提出【蓋設施】的隊 —— systems 指定的故事線就是這條
	var won: Array[int] = []
	var storyish: Array[int] = []
	var fallback: Array[int] = []
	# ★最高優先：真的提出「為了取得 X 先蓋 Y」的隊（`means_end.facility_proposed` tap）。
	#   先前只看 util_vs_winner ⇒ 挑到的三隊全走【買原料】那條，設施提案在別的隊身上 ⇒ 故事缺一半。
	if Probe.samples.has("means_end.facility_proposed"):
		for fs in (Probe.samples["means_end.facility_proposed"] as Array):
			var ftid: int = int(fs.get("team", -1))
			if ftid < 0: continue
			if not why.has(ftid):
				why[ftid] = "%s（提議蓋 %s）" % [String(fs.get("res", "")), String(fs.get("facility", ""))]
			if not facility.has(ftid): facility.append(ftid)
	if not Probe.samples.has("means_end.util_vs_winner"):
		var only_fac: Array[int] = []
		for t in facility:
			if only_fac.size() < want: only_fac.append(int(t))
		return only_fac
	for smp in (Probe.samples["means_end.util_vs_winner"] as Array):
		var tid: int = int(smp.get("team", -1))
		if tid < 0: continue
		var res: String = String(smp.get("res", ""))
		if not why.has(tid): why[tid] = res
		var is_story: bool = false
		for sr in STORY_RES:
			if res.begins_with(String(sr)): is_story = true   # weapon_melee_low 等變體也算
		if is_story and bool(smp.get("me_won", false)):
			if not won.has(tid): won.append(tid)
		elif is_story:
			if not storyish.has(tid): storyish.append(tid)
		elif not fallback.has(tid):
			fallback.append(tid)
	var out: Array[int] = []
	for bucket in [facility, won, storyish, fallback]:
		for tid in (bucket as Array):
			if out.size() >= want: break
			if not out.has(tid): out.append(int(tid))
	return out

# ────────── pass2：同 seed 重跑 + specimen 全程 trace ──────────
func _pass2_trace(cfg: String, sd: int, days: int, ids: Array[int], out_path: String) -> void:
	print("\n───────── pass2：同 seed 重跑，specimen=%s，全程 trace ─────────" % str(ids))
	var state: WorldState = _fresh_world(cfg, sd)
	if state == null: return
	# ★specimen 上場（鏡射 SpecimenDumpHelper.setup_from_env 的三步；名單來自 pass1 而非 env）
	state.specimen_team_ids = ids
	SpecimenTracer.reset()
	SpecimenTracer.enabled = true
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	for _t in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty(): break
	SpecimenTracer.summary()
	SpecimenDumpHelper.dump(state, out_path)   # ★落地（flush 殘餘 + write_jsonl 全量 _archive）
	_story_index(ids, out_path)

# ★故事索引（給 QA 一個入口，不是取代 jsonl）：means-end 候選出現在哪些 tick、贏了沒、之後 task 是什麼。
func _story_index(ids: Array[int], out_path: String) -> void:
	print("\n───────── ★故事索引（詳情讀 %s）─────────" % out_path)
	print("[索引] specimen=%s  決策 entry 總數=%d" % [str(ids), SpecimenTracer.decision_count])
	print("[索引] means-end 候選出現次數（Probe）=%d｜其中贏得 argmax=%d" % [
		int(Probe.counts.get("means_end.candidates_emitted", 0)),
		int(Probe.counts.get("means_end.won_argmax", 0))])
	print("[索引] 既有機制沉默處補上的（unique_no_existing）=%d｜與既有重複的=%d" % [
		int(Probe.counts.get("means_end.unique_no_existing", 0)),
		int(Probe.counts.get("means_end.dup_existing_present", 0))])
	for k in Probe.counts:
		var ks: String = String(k)
		if ks.begins_with("means_end.unique_no_existing.") or ks.begins_with("means_end.candidates_emitted."):
			print("[索引]   %s=%d" % [ks, int(Probe.counts[k])])

# ────────── 共用 ──────────
func _fresh_world(cfg: String, sd: int) -> WorldState:
	seed(sd)
	Probe.enabled = true
	Probe.reset()
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	if config.is_empty():
		print("[FAIL] config 載入失敗：res://config/%s.json" % cfg)
		return null
	config["seed"] = sd
	GameSetup.setup(state, config)
	return state

func _env(key: String, dflt: String) -> String:
	var v: String = OS.get_environment(key)
	return v if v != "" else dflt
