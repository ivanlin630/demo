extends SceneTree
# @bed-kind: acceptance
# slice: 派系 AI 真的吃它拿到的那批隊 —— 驗收② 每派系每小時恰好一次
#
# ★判準（spec §3-②）：Probe.peaks["faction.drive.per_hour_max"] ＝ 1
# ★★它是【回歸柵欄】不是陽性對照：今天不散相位本來就該是 1，
#   它守的是【散相位之後仍然要是 1】。
# ★★★所以它自己要有陽性對照，而對照用【真實樣本】：
#   FD_INJECT=1 ⇒ 在同一個 tick 再驅動一次 evaluate_all ——
#   ★那正是本票要防的危害本身（重複執行），不是去戳計數器。
#   ⇒ 那一格必須【讀到 2】，不是「有紅」。
#
# env：FD_DAYS（預設 2）／FD_SEED（預設 1337）／FD_CONFIG（預設 warring_states）／FD_INJECT=1

const KEY: String = "faction.drive.per_hour_max"

func _initialize() -> void:
	var days: int = int(OS.get_environment("FD_DAYS")) if OS.has_environment("FD_DAYS") else 2
	var sd: int = int(OS.get_environment("FD_SEED")) if OS.has_environment("FD_SEED") else 1337
	var cfg: String = OS.get_environment("FD_CONFIG") if OS.has_environment("FD_CONFIG") else "warring_states"
	var inject: bool = OS.get_environment("FD_INJECT") == "1"
	print("=== 派系驅動柵欄（days=%d seed=%d config=%s inject=%s）===" % [days, sd, cfg, str(inject)])

	seed(sd)
	Probe.reset(); Probe.arm()
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var runner := SimRunner.new()
	var fai := FactionAISystem.new()
	var n_ticks: int = days * WorldState.TICKS_PER_DAY
	for t in range(n_ticks):
		runner.advance_tick(st, Vector2i(-1, -1))
		# ★注射：整點那一 tick 之後再驅動一次 ⇒ 同一小時第二次
		if inject and st.world.current_tick % WorldState.TICKS_PER_HOUR == 0:
			fai.evaluate_all(st, st.teams.keys())

	var peak: int = int(Probe.peaks.get(KEY, 0))
	var total: int = int(Probe.counts.get("faction.drive.total", 0))
	var hours: int = n_ticks / WorldState.TICKS_PER_HOUR
	print("[FACDRIVE] per_hour_max=%d  drives_total=%d  hours=%d  factions_last=%d" % [
		peak, total, hours, st.factions.size()])
	print("[FACDRIVE] ★母體：drives_total 必須 > 0，否則 peak=0 是【沒跑到】不是【沒重複】")

	var fail: int = 0
	if total <= 0:
		push_error("[FACDRIVE][不可判] drives_total=0 ⇒ 母體塌陷（tap 沒接上，不是世界沒派系）")
		quit(2)
		return
	if inject:
		# ★陽性對照臂：判準是【讀到 2】，不是「有紅」
		if peak >= 2:
			print("[FACDRIVE] ★陽性對照：注射後 per_hour_max=%d（>=2）⇒ 這支儀表真的會動 ✔" % peak)
		else:
			push_error("[FACDRIVE][FAIL] 注射後 per_hour_max=%d ⇒ ★儀表沒接上電（注射沒到達或計數不會升）" % peak)
			fail += 1
	else:
		if peak == 1:
			print("[FACDRIVE] ★柵欄：per_hour_max=1 ⇒ 每派系每小時恰好一次 ✔")
		else:
			push_error("[FACDRIVE][FAIL] per_hour_max=%d（應為 1）⇒ 有派系在同一小時被驅動多次" % peak)
			fail += 1
	print("=== faction_drive_once_per_hour DONE（fail=%d｜到場點名 3／3）===" % fail)
	quit(1 if fail > 0 else 0)
