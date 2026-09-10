extends SceneTree
# @bed-kind: guard
# slice: 守衛移位 —— `from_unknown ⇒ 未登記具名紅` 從 `_decide_unified` 移到 `rank_scored` 入口
#
# ★為什麼要這張床：舊守衛守在 `_decide_unified`（母體 733 次），而真母體是 `rank_scored`
#   （1096 次）⇒ 不經 `_decide_unified` 的呼叫端在守衛【外面】⇒ 55.62 s 靜默。
# ★★成對（systems 要求）：不帶 src ⇒ 必須【具名】紅；帶 src ⇒ 必須綠。
#   ★★★只有「會紅」那格 ＝ 證明不了它不會亂紅；只有「不亂紅」那格 ＝ 證明不了它認得出錯。

var fails: int = 0
var sections: int = 0

func _check(name: String, ok: bool, detail: String) -> void:
	sections += 1
	if ok:
		print("  ✅ %s ── %s" % [name, detail])
	else:
		fails += 1
		print("  ❌ [FAIL] %s ── %s" % [name, detail])

func _report_for(src: String) -> String:
	FactionAISystem._fai_ph.clear()
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/warring_states.json"))
	st.player_id = -1
	var team: TeamData = null
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		if t.beast_kind == "" and t.parent_team_id == -1:
			team = t
			break
	if team == null:
		return "★母體塌陷：找不到可用隊 ⇒ 不可判"
	if src == "":
		DecisionEngine.rank_scored(st, team)          # ★不帶 src ＝ 新呼叫端忘了報名
	else:
		DecisionEngine.rank_scored(st, team, src)
	return FactionAISystem.phase_report(FactionAISystem._fai_ph, 1)

func _initialize() -> void:
	print("=== 守衛移位成對對照（rank_scored 入口）===")
	seed(1234)
	SimRunner.phase_timing = true

	var rep_bad: String = _report_for("")
	var rep_ok: String = _report_for("leader")

	# ①會紅：不帶 src ⇒ 鍵是 from_unknown ⇒ 不在 PHASE_PARENT ⇒ 具名列出
	_check("不帶 src ⇒ 具名紅",
		rep_bad.contains("未登記相位") and rep_bad.contains("unified.rank.from_unknown"),
		"報告裡要【點名】那個鍵，不能只說『有未登記』：%s" % rep_bad.split("\n")[0])
	# ②不亂紅：帶 src ⇒ 同一條路必須綠
	_check("帶 src ⇒ 不紅",
		not rep_ok.contains("unified.rank.from_unknown"),
		"同一支床同一條路，只差一個參數：%s" % rep_ok.split("\n")[0])
	# ③★母體地板：兩趟都真的有相位被記到（否則兩格都是「什麼都沒跑」的假綠/假紅）
	_check("母體地板",
		rep_bad.contains("unified.rank.from_unknown") and rep_ok.contains("unified.rank.from_leader"),
		"兩趟各自的鍵都要真的出現在報告裡")

	print("=== DONE === SECTIONS=%d/%d FAILS=%d" % [sections - fails, sections, fails])
	quit(1 if fails > 0 else 0)
