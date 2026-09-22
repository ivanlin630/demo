extends SceneTree
# @bed-kind: diagnostic
# slice: 派工② 三計數 —— 隊的【生／滅】逐日 × 逐因（★純量測，不動行為）
#
# ★★★既有 CSV 已經回答了「生與死兩端同時變多」；★這一床回答 CSV 分不出的三件事：
#   ①消失端拆【滅團】vs【子隊併回】vs【encounter 收編】vs【野獸】——
#     ★`world_state.gd` 自己的註解寫著：「四條路全被讀成『死了』，
#       而【被吸納】跟【餓死】在任何驗收裡都是相反的結論」
#   ②滅團端拆【因】（餓／戰／其他）逐日
#   ③新生端拆來源（world_gen／分裂／子隊／人力／人口／反應…）
# ★★tap 掛在【咽喉點】（`create_team` / `erase_teams`）不照呼叫點名單掛：
#   名單會漏，而漏掉的那一支【不會紅】—— ★所以 reason 預設 "unknown"，漏的會現形。
# ★★★守恆格：`birth.all − gone.all` 必須等於 `末隊數 − 初隊數`。
#   ★它是對「有路徑繞過咽喉點」的唯一檢查 —— 沒有它，這張表漏了也照樣印得很漂亮。
#
# env：TL_DAYS（預設 12）／TL_SEED（預設 1337）／TL_CONFIG（預設 warring_states）

func _initialize() -> void:
	var days: int = int(OS.get_environment("TL_DAYS")) if OS.has_environment("TL_DAYS") else 12
	var sd: int = int(OS.get_environment("TL_SEED")) if OS.has_environment("TL_SEED") else 1337
	var cfg: String = OS.get_environment("TL_CONFIG") if OS.has_environment("TL_CONFIG") else "warring_states"
	print("=== 隊生滅逐日×逐因（days=%d seed=%d config=%s）===" % [days, sd, cfg])
	var fail: int = 0
	var cells: int = 0

	seed(sd)
	Probe.reset(); Probe.arm()
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var n0: int = st.teams.size()
	var runner := SimRunner.new()
	for _t in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(st, Vector2i(-1, -1))
	var n1: int = st.teams.size()

	var birth: int = int(Probe.counts.get("teamlife.birth.all", 0))
	var gone: int = int(Probe.counts.get("teamlife.gone.all", 0))
	# ★★★守恆的【起點是 0】不是 n0：tap 在 `Probe.arm()` 就開始數，而那時世界【還沒生成】
	#   ⇒ 世界生成的那批隊【也被 tap 數到】。★我第一版拿 n1 − n0 去比 ⇒ 分母不同源，
	#   而它紅了 —— ★★那一格紅得對，錯的是我寫的比較對象。
	print("\n[TL] 生成後隊數=%d 末隊數=%d｜tap：新生=%d 消失=%d（淨 %+d）" % [n0, n1, birth, gone, birth - gone])
	if birth - gone == n1:
		print("[TL] ★守恆 ✔（起點 0）：tap 淨 %+d ＝ 末隊數 %d ⇒ tap 看得到【全部】的生與滅" % [birth - gone, n1])
	else:
		push_error("[TL][FAIL] ★守恆破了：tap 淨 %+d ≠ 末隊數 %d ⇒ 有路徑繞過 create_team／erase_teams" % [
			birth - gone, n1])
		fail += 1
	if birth == 0 and gone == 0:
		push_error("[TL][不可判] 生與滅都是 0 ⇒ 母體塌陷（tap 沒接上，不是世界沒動）")
		fail += 1
	cells += 1

	# ★unknown 殘渣：有人新增建隊／滅團路徑而沒給 reason ⇒ 這裡現形
	var ub: int = int(Probe.counts.get("teamlife.birth.reason.unknown", 0))
	var ug: int = int(Probe.counts.get("teamlife.gone.reason.unknown", 0))
	print("[TL] ★reason=unknown 殘渣：新生 %d／消失 %d（★非 0 ＝ 有呼叫點沒帶 reason，不是世界的事）" % [ub, ug])
	cells += 1

	_table("新生", "teamlife.birth.reason.", days)
	_table("消失", "teamlife.gone.reason.", days)
	cells += 1

	# ── ★★★野獸不是隊：`state.teams.size()` 把野獸算進去,而「野獸刷出／被獵殺」
	#   與「一支隊餓死」在任何驗收裡都是相反的結論。
	#   ★我先前用 FT 的 `alive` 欄（＝ state.teams.size()）做上下行分解 ⇒ **母體含野獸**。
	var b_beast: int = int(Probe.counts.get("teamlife.birth.reason.beast", 0))
	var g_beast: int = int(Probe.counts.get("teamlife.gone.reason.beast", 0))
	print("\n[TL] ★★母體拆解：")
	print("[TL]   含野獸：新生 %d／消失 %d" % [birth, gone])
	print("[TL]   ★野獸：新生 %d／消失 %d（佔消失端 %.1f%%）" % [
		b_beast, g_beast, 100.0 * float(g_beast) / float(maxi(gone, 1))])
	print("[TL]   ★★真隊（扣掉野獸）：新生 %d／消失 %d" % [birth - b_beast, gone - g_beast])
	print("[TL]   ★★★世界生成那 %d 隊也在【新生】的 d0 裡（tap 從 0 開始數）" % n0)
	cells += 1

	# ★滅團死因逐日（沿用既有 extinct.* 分類，只加了逐日維度）
	print("\n[TL] 滅團死因逐日（★只涵蓋【真滅團】那條路，野獸已被既有守衛排除）")
	print("[TL] %-10s %6s ｜ 逐日" % ["因", "合計"])
	for c in ["starve", "combat", "other"]:
		var tot: int = int(Probe.counts.get("extinct." + ("starve" if c == "starve" else c), 0))
		var row: String = ""
		for d in range(days):
			row += "%d:%d " % [d, int(Probe.counts.get("extinct.cause.%s.d%04d" % [c, d], 0))]
		print("[TL] %-10s %6d ｜ %s" % [c, tot, row])
	cells += 1

	print("\n[誠實限] ①`extinct.*` 的分類是既有的「盡力分類」（無標記 ⇒ other 兜底），我沒改它的判準")
	print("[誠實限] ②本床是【單臂】：before／after 的比較要跑兩次同參數再比，這支不自己比")
	print("=== team_turnover_by_cause DONE（fail=%d｜到場點名 %d／5）===" % [fail, cells])
	if cells != 5:
		push_error("[FAIL] 到場點名 %d／5 ⇒ 有格沒跑到" % cells)
		fail += 1
	quit(1 if fail > 0 else 0)

func _table(title: String, prefix: String, days: int) -> void:
	# ★reason 清單從 Probe.counts 現場掃出來（★不手抄）⇒ 新增的 reason 自動出現
	var reasons: Dictionary = {}
	for k in Probe.counts.keys():
		var s: String = String(k)
		if not s.begins_with(prefix): continue
		var rest: String = s.substr(prefix.length())
		var di: int = rest.find(".d")
		if di >= 0: rest = rest.substr(0, di)
		reasons[rest] = true
	var rk: Array = reasons.keys()
	rk.sort()
	print("\n[TL] %s 端（reason 清單從 Probe.counts 現場掃，不手抄 ⇒ %d 種）" % [title, rk.size()])
	print("[TL] %-18s %6s ｜ 逐日" % ["reason", "合計"])
	for r in rk:
		var tot: int = int(Probe.counts.get(prefix + String(r), 0))
		var row: String = ""
		for d in range(days):
			row += "%d:%d " % [d, int(Probe.counts.get("%s%s.d%04d" % [prefix, String(r), d], 0))]
		print("[TL] %-18s %6d ｜ %s" % [String(r), tot, row])
