extends SceneTree
# @bed-kind: invariant
#
# 世界指紋快照：固定 seed／config／窗 ⇒ 印一個 fp。
# ★用途：讓「修法前」與「修法後」的 fp 可以【逐字】比對（觀測雜訊決定性化票的 2-f）。
# ★★★【種類改了：diagnostic → invariant】（2026-09-24）——★不是為了讓閘綠，是因為性質變了：
#   ★這一行原本寫「它【只印不判】—— 判在別處，所以它是 diagnostic 不是 gate」。
#     那句話在 `WFP_SELFCTRL=1` 那個模式加進來【之前】是對的。
#   ★★而那個模式給它裝了【判決通道】：`=== world_fp_selfctrl DONE === FAILS=n` ＋ 非零離開碼
#     ⇒ `bed-kind-gate` 當場紅：「宣告 diagnostic 卻有判決彙總行 —— 有判決通道就不是 diagnostic」。
#   ⇒ ★★★而閘是對的，是我把這支床的性質改了而沒有改它的宣告。
#     ★留著那句舊話比刪掉危險：下一個人會以為這支床不會判人。
#   ⇒ 現在：**預設模式只印不判**（`world-fp` 靠 expect 比絕對值）；
#     **`WFP_SELFCTRL=1` 模式自己判**（`world-fp-ctrl` 靠它的 FAILS=0）。
#     ★兩個模式共用同一份建世界／推進邏輯（`_one_run`）—— 那才是它們在同一支床裡的理由。
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
	if OS.get_environment("WFP_STAGGER") == "0":
		WorldState.pass_stagger_enabled = false
		print("[WFP] ★樁關（WFP_STAGGER=0）：所有隊整點一起到期 ⇒ 指紋應與世代 7 逐字相同")
	# ★★★相對對照模式（WFP_SELFCTRL=1）：同一個 process 跑兩趟 ⇒ 斷言兩趟 final_fp 逐字相同。
	#   ★它【不釘任何絕對值】—— 它問的是「這兩次一不一樣」，不是「它等不等於某個常數」。
	#   ★★母體地板：那一輪要【真的有觀測發生】（hits > 0）
	#     —— 否則「兩趟相同」會在【兩趟都沒觀測】時恆真。
	#   ★★★這一格是 invariants 那條「觀測者禁耗 global RNG」的【可執行版本】：
	#     觀測路徑若耗掉一次 randf，整條隨機序列錯位 ⇒ 兩趟必不同 ⇒ 這一格會紅。
	if OS.get_environment("WFP_SELFCTRL") == "1":
		var n_obs: int = int(OS.get_environment("WFP_EXTRA_OBS")) if OS.has_environment("WFP_EXTRA_OBS") else 24
		print("[WFP-CTRL] 相對對照：同一顆種子跑兩趟（extra_obs=0 vs %d），斷言 final_fp 逐字相同" % n_obs)
		var a: Dictionary = _one_run(0, ticks, cfg, sd)
		var b: Dictionary = _one_run(n_obs, ticks, cfg, sd)
		print("[WFP-CTRL] 無觀測：fp=%s teams=%d tick=%d hits=%d" % [String(a["fp"]), int(a["teams"]), int(a["tick"]), int(a["hits"])])
		print("[WFP-CTRL] 有觀測：fp=%s teams=%d tick=%d hits=%d" % [String(b["fp"]), int(b["teams"]), int(b["tick"]), int(b["hits"])])
		var bad: int = 0
		if int(b["hits"]) <= 0:
			bad += 1
			print("[WFP-CTRL] ✗ 母體地板：注射一次都沒到達可見 pair（hits=0）⇒ ★這不是綠，是什麼都沒測到")
		if String(a["fp"]) != String(b["fp"]):
			bad += 1
			print("[WFP-CTRL] ✗ 兩趟 final_fp 不同 ⇒ ★觀測改變了被觀測物")
		if String(a["traj"]) != String(b["traj"]):
			bad += 1
			print("[WFP-CTRL] ✗ 兩趟 traj_fp 不同 ⇒ ★終局相同不代表中途沒分岔又合流")
		print("[WFP-CTRL] 觀測真正到達 %d 次｜traj 取樣 %d 點" % [int(b["hits"]), int(b["traj_n"])])
		print("=== world_fp_selfctrl DONE === FAILS=%d" % bad)
		quit(1 if bad > 0 else 0)
		return
	var extra: int = int(OS.get_environment("WFP_EXTRA_OBS")) if OS.has_environment("WFP_EXTRA_OBS") else 0
	var r: Dictionary = _one_run(extra, ticks, cfg, sd)
	# ★以下輸出【一字未改】—— `world-fp` 還釘著絕對值，它的卷面不能動
	if String(r["pq"]) != "":
		print("[WFP] canon 新增行原文：%s" % String(r["pq"]))
	print("[WFP] final_fp = %s" % String(r["fp"]))
	print("[WFP] traj_fp  = %s   （每 1000 tick 取樣 %d 點，串接後再取指紋）" % [
		String(r["traj"]), int(r["traj_n"])])
	print("[WFP] teams=%d persons=%d tick=%d" % [int(r["teams"]), int(r["persons"]), int(r["tick"])])
	print("[WFP] extra_obs=%d｜★注射真正到達 %d 次（母體：0 ⇒ 不可判，不是綠）" % [extra, int(r["hits"])])
	if extra > 0 and int(r["hits"]) == 0:
		push_error("[WFP][不可判] 注射一次都沒到達可見 pair ⇒ 這一輪什麼都沒測到")
	print("=== world_fp_snapshot DONE ===")
	quit(0)

# ★★★抽成可重入的一趟（systems 派工 2026-09-24）——
#   ★原本這支床一個 process 只跑一趟，而 `world-fp-ctrl` 是【另一支閘、另一個 process】，
#     兩支各自釘【同一個絕對雜湊】⇒ canon 每加一行兩支都要改。
#   ★★而 ctrl 要證明的是「多觀測【不改變】世界」—— 那是一個【相對】的性質
#     ⇒ 它不需要基準，它需要的是【同一個 process 裡跑兩趟然後比】。
#   ★★★成本不變（今天本來就是兩跑），而要維護的絕對基準從 2 個變 1 個。
#
# ★★★實測（2026-09-24，origin/main 46911ba6d 之上）——★寫在這裡因為它是【下一個人要的數】：
#   `WFP_SELFCTRL=1`（預設 20000 tick × 2 趟）⇒ **484s**、FAILS=0
#     無觀測 fp=2510037eac95007854848e289501b87a  teams=111 tick=20000 hits=0
#     有觀測 fp=2510037eac95007854848e289501b87a  teams=111 tick=20000 ★hits=1110
#   ★★而無觀測那一趟的 fp【就是 `world-fp` 釘的那個絕對基準】⇒ 順手交叉驗了一次
#   ★★★逾時要 ≥900（484s 距 600 太近，而電池會跟別的閘搶機器）
# ★負對照（已跑，跑完還原）：在 `PathSystem.observed_speed()` 開頭注射一次 `randf()`
#   ⇒ FAILS=2、兩趟 fp 不同（81320ddb… vs 3cf29db1…）、★連隊數都分岔（71 vs 67）
#   ⇒ ★★那是 invariants「觀測者禁耗 global RNG」的【可執行版本】——
#     它不是在檢查誰寫了 randf，是在量【世界有沒有因為被看而不一樣】。
# ★★（前一顆 commit 的訊息寫「一次都沒跑過」—— 那句話到這一顆為止【已過期】，
#   而留著過期的字比刪掉危險，所以在這裡註明而不是讓它繼續站著。）
func _one_run(extra: int, ticks: int, cfg: String, sd: int) -> Dictionary:
	_inject_hits = 0   # ★每一趟重置 —— 不重置的話第二趟的母體地板會吃到第一趟的數
	seed(sd)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/%s.json" % cfg))
	st.player_id = -1
	var runner := SimRunner.new()
	# ★2-e 用：每 tick 額外呼叫 observed_speed N 次（同一 tick、同一組 pair）。
	#   ★★舊 code 每次呼叫抽一次 randf() ⇒ N 一變，整條隨機序列錯位 ⇒ fp 變
	#   ★★★新 code 不抽 ⇒ N 無論多少，fp 必須【逐字相同】
	# ★錯開票 P5 的【樁臂】：沿用 WFP_EXTRA_OBS 的形狀（env 開的對照臂，預設 no-op）。
	#   ★★WFP_STAGGER=0 ⇒ 所有隊在整點一起到期 ⇒ 那一趟 pass 與今天逐字相同
	#   ⇒ ★★★指紋必須與世代 7 【逐字相同】—— 它把【我重構壞了】
	#     與【錯開改變了世界】分成兩個可以各自判的問題。
	#   ★不設時完全不碰這個 static ⇒ 指紋閘本身的行為一字未變。
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
	var pq: String = ""
	for _pl in StateFingerprint.player_section(st).split(String.chr(10)):
		if _pl.begins_with("PQ|"):
			pq = _pl
	return {"fp": fp, "traj": ("
".join(traj)).sha256_text(), "traj_n": traj.size(),
		"hits": _inject_hits, "teams": st.teams.size(), "persons": st.persons.size(),
		"tick": st.world.current_tick, "pq": pq}

