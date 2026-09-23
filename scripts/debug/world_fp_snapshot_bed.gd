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

var _inject_hits: int = 0

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
	# ★2-e 用：每 tick 額外呼叫 observed_speed N 次（同一 tick、同一組 pair）。
	#   ★★舊 code 每次呼叫抽一次 randf() ⇒ N 一變，整條隨機序列錯位 ⇒ fp 變
	#   ★★★新 code 不抽 ⇒ N 無論多少，fp 必須【逐字相同】
	var extra: int = int(OS.get_environment("WFP_EXTRA_OBS")) if OS.has_environment("WFP_EXTRA_OBS") else 0
	# ★錯開票 P5 的【樁臂】：沿用 WFP_EXTRA_OBS 的形狀（env 開的對照臂，預設 no-op）。
	#   ★★WFP_STAGGER=0 ⇒ 所有隊在整點一起到期 ⇒ 那一趟 pass 與今天逐字相同
	#   ⇒ ★★★指紋必須與世代 7 【逐字相同】—— 它把【我重構壞了】
	#     與【錯開改變了世界】分成兩個可以各自判的問題。
	#   ★不設時完全不碰這個 static ⇒ 指紋閘本身的行為一字未變。
	if OS.get_environment("WFP_STAGGER") == "0":
		WorldState.pass_stagger_enabled = false
		print("[WFP] ★樁關（WFP_STAGGER=0）：所有隊整點一起到期 ⇒ 指紋應與世代 7 逐字相同")
	# ★逐 tick 軌跡也取一個摘要：只有終局 fp 相同【不代表】中途沒分岔又合流。
	var traj: PackedStringArray = PackedStringArray()
	for t in range(ticks):
		runner.advance_tick(st, Vector2i(-1, -1))
		if extra > 0:
			# ★★★第一版注射【沒打中】：observed_speed 開頭是 `if not visible: return 0.0`
			#   ⇒ 對互相看不見的兩隊注射，連 randf 那一行都到不了 ⇒ 舊 code 的 fp 也不變
			#   ⇒ ★陽性對照不點火，而那個綠讀起來就是「這裡沒有問題」。
			# ★★第二版【掃全部 pair】找可見的 ⇒ 每 tick O(N²)（110 隊 × 20000 tick）⇒ 撞 900s 逾時
			#   ⇒ ★★★守衛不能貴到跑不完：候選改成 team_discovered（小得多）＋ 每 tick 掃描預算上限。
			var done: int = 0
			var budget: int = 24
			for ia in st.teams.keys():
				if done >= extra or budget <= 0: break
				var ta: TeamData = st.teams[ia]
				for ib in st.team_discovered.get(ia, []):
					if done >= extra or budget <= 0: break
					budget -= 1
					if not st.teams.has(ib): continue
					var tb: TeamData = st.teams[ib]
					if not bool(PathSystem.observe_velocity(st, ta, tb).get("visible", false)): continue
					PathSystem.observed_speed(st, ta, tb)
					done += 1
					_inject_hits += 1
		if (t + 1) % 1000 == 0:
			traj.append(StateFingerprint.compute(st))
	var fp: String = StateFingerprint.compute(st)
	# ★★★把 canon 新增的那一行【原文印出來】（systems 裁 2026-09-24）——
	#   P6 要求「無人世界：新增的行恰好是 PQ|、其值全為 0」，而在印出來之前那是【推論】。
	#   ★★把一個【沒被看過的值】釘成基準，等於把「未知」升格成「真理」，
	#     而它之後每一次綠都在替那個未知背書。
	#   ★這一行不進 fp（它只是把 fp 裡已經有的東西印出來給人看）。
	for _pl in StateFingerprint.player_section(st).split(String.chr(10)):
		if _pl.begins_with("PQ|"):
			print("[WFP] canon 新增行原文：%s" % _pl)
	print("[WFP] final_fp = %s" % fp)
	print("[WFP] traj_fp  = %s   （每 1000 tick 取樣 %d 點，串接後再取指紋）" % [
		("\n".join(traj)).sha256_text(), traj.size()])
	print("[WFP] teams=%d persons=%d tick=%d" % [st.teams.size(), st.persons.size(), st.world.current_tick])
	print("[WFP] extra_obs=%d｜★注射真正到達 %d 次（母體：0 ⇒ 不可判，不是綠）" % [extra, _inject_hits])
	if extra > 0 and _inject_hits == 0:
		push_error("[WFP][不可判] 注射一次都沒到達可見 pair ⇒ 這一輪什麼都沒測到")
	print("=== world_fp_snapshot DONE ===")
	quit(0)
