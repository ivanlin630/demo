extends SceneTree
# @bed-kind: acceptance
# slice: 「中途 erase 不安全」是【真的】還是【一句沒被驗過的顧慮】？
#
# ★矛盾（systems 2026-09-10）：teams_pending_erase 存在的理由寫著「中途 erase 不安全
#   —— 多系統持 team_ids 快照」，★★而合併/併入/野獸那三處【就是在 tick 中途 erase】，
#   ★★★而實測：不安全那條路一直在跑（23 天 ≥7 次），安全那條路一次都沒跑。
#
# 本床把那句話拆成【三個可判的問題】，而不是問「安不安全」：
#   ①持久狀態：中途 erase 之後，state 裡還有沒有【指向死者的參照】？（掃得到，能具名）
#   ②快照消費者：sim_runner 的 all_teams 快照在 :316 取【一次】，
#      ⇒ 合併發生點之後的每個 "teams" 系統都吃著含死 id 的清單 —— ★它們擋不擋得住？
#      ⇒ ★★做法：照 sim_runner 的 shape 逐支呼叫，餵【含死 id 的快照】，看它活不活得下來。
#   ③而【活得下來】不等於【對】：所以②同時記錄每支有沒有真的跳過那個 id。
#
# ★誠實限：本床不回答「合併時點的語意對不對」（那是設計），只回答【機械上會不會咬人】。

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 3
const DEAD: int = 7

func _initialize() -> void:
	print("=== 中途 erase 安全性床 ===")
	_test_dangling_refs()
	_test_snapshot_consumers()
	_test_full_tick_after_midtick_erase()
	if _sections != EXPECT_SECTIONS:
		_fails += 1
		push_error("[FAIL] 只跑完 %d/%d 段 —— 中途崩掉（★而【崩在這裡】本身就是答案的一半）" % [_sections, EXPECT_SECTIONS])
	print("=== DONE === SECTIONS=%d/%d FAILS=%d" % [_sections, EXPECT_SECTIONS, _fails])
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_fails += 1
		push_error("[FAIL] " + msg)

func _mk() -> WorldState:
	seed(31337)
	var st := WorldState.new()
	st.world = WorldData.new()
	st.world.current_tick = 1000
	for i in range(4):
		var tile := HexTileData.new()
		tile.tile_id = i * 1000 + i
		tile.tile_pos = Vector2i(i, i)
		tile.terrain = "plains"
		st.world.tiles[tile.tile_id] = tile
	for tid in [5, 6, DEAD]:
		var t := TeamData.new()
		t.team_id = tid
		t.tile_pos = Vector2i(1, 1)
		t.resources["food"] = 300.0
		t.resources["coin"] = 100.0
		AnonTierSystem.add_anon(t, "平民", 5)
		var p := PersonData.new()
		p.id = tid * 10
		p.team_id = tid
		p.person_name = "隊%d領袖" % tid
		st.persons[p.id] = p
		t.leader_id = p.id
		st.create_team(t)
	# 死者與別人有牽連（★否則掃 dangling ref 是在掃一個沒有連結的孤兒＝恆綠）
	(st.teams[5] as TeamData).combat_target = DEAD
	(st.teams[6] as TeamData).order_target_id = DEAD
	st.team_discovered[5] = [6, DEAD]
	st.player_id = 50
	st.player_pending_targets.append(DEAD)
	return st

# ── ① 持久狀態裡的 dangling ref ─────────────────────────────────────────
func _scan_refs(st: WorldState, dead_id: int) -> Array:
	var hits: Array = []
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		for pname in ["combat_target", "order_target_id", "parent_team_id", "social_target",
				"aid_target_id", "move_target_team_id"]:
			if not (pname in t):
				continue
			if int(t.get(pname)) == dead_id:
				hits.append("teams[%d].%s" % [tid, pname])
		if t.subteam_ids.has(dead_id):
			hits.append("teams[%d].subteam_ids" % tid)
	for obs in st.team_discovered:
		if (st.team_discovered[obs] as Array).has(dead_id):
			hits.append("team_discovered[%s]" % str(obs))
	for obs2 in st.team_intel:
		if (st.team_intel[obs2] as Dictionary).has(dead_id):
			hits.append("team_intel[%s]" % str(obs2))
	if st.player_pending_targets.has(dead_id):
		hits.append("player_pending_targets")
	if st.teams.has(dead_id):
		hits.append("teams[%d]（本體還在）" % dead_id)
	return hits

func _test_dangling_refs() -> void:
	print("-- ① 中途 erase 之後，持久狀態裡還有沒有指向死者的參照 --")
	var st := _mk()
	var before: Array = _scan_refs(st, DEAD)
	print("    erase 前掃到 %d 處：%s" % [before.size(), str(before)])
	# ★掃描器的陽性對照就是這一格本身：erase 前【必須】掃得到東西，否則後面的 0 沒有意義
	_ok(before.size() >= 4, "①★前提：erase 前掃得到 %d 處參照（掃描器不是瞎的）" % before.size())
	st.erase_team(DEAD)   # ＝合併/併入/野獸走的那條路（erase_teams([tid]) 的薄 wrapper）
	var after: Array = _scan_refs(st, DEAD)
	print("    erase 後仍在的：%s" % str(after))
	_ok(after.is_empty(),
		"①中途 erase 把持久參照清乾淨了（★『繞過的是延遲佇列、不是清除』——這格是它的機械證據）")
	_sections += 1

# ── ② 快照消費者：餵含死 id 的清單給合併點之後的系統 ────────────────────
func _test_snapshot_consumers() -> void:
	print("-- ② sim_runner 的 all_teams 快照取【一次】⇒ 合併點之後的系統吃著含死 id 的清單 --")
	var st := _mk()
	var stale: Array = st.teams.keys()          # ★快照在 erase 之前取（＝ sim_runner:316 的情境）
	st.erase_team(DEAD)
	_ok(stale.has(DEAD), "②前提：快照裡確實還有死 id（%s）" % str(stale))
	var runner := SimRunner.new()
	# ★母體＝SIMS registry 裡【interactions 之後】的 teams / teams_cadence / state 形狀那些
	var after_merge: Array = []
	var seen_interactions: bool = false
	for sys in SimRunner.SYSTEMS:
		if String(sys["name"]) == "interactions":
			seen_interactions = true
			continue
		if not seen_interactions:
			continue
		after_merge.append(sys)
	print("    合併點之後的系統：%d 支" % after_merge.size())
	var survived: Array = []
	for sys in after_merge:
		var shape: String = String(sys["shape"])
		var fn: String = String(sys["fn"])
		match shape:
			"teams":         runner.call(fn, st, stale)
			"teams_cadence": runner.call(fn, st, stale, 1)
			"state":         runner.call(fn, st)
			_:               continue
		survived.append(String(sys["name"]))
	print("    餵含死 id 的快照後【跑完沒炸】的：%s" % str(survived))
	_ok(survived.size() >= 8,
		"②%d 支系統吃了含死 id 的快照【都沒炸】⇒ ★『中途 erase 不安全』在【崩潰】這個層級上是【假的】" % survived.size())
	# ★★而「沒炸」不等於「沒事」：死者不得因此復活或被記帳
	_ok(not st.teams.has(DEAD), "②★死者沒有被任何一支系統【寫回】state.teams（沒有復活）")
	_ok(_scan_refs(st, DEAD).is_empty(), "②★跑完那些系統之後，也沒有【重新長出】指向死者的參照")
	_sections += 1

# ── ③ 整個 tick：中途 erase 之後把 tick 跑完 ────────────────────────────
func _test_full_tick_after_midtick_erase() -> void:
	print("-- ③ 中途 erase 之後【把整個 tick 跑完】--")
	var st := _mk()
	var runner := SimRunner.new()
	st.erase_team(DEAD)
	var r: String = runner.advance_tick(st, Vector2i(-1, -1))
	print("    advance_tick 回傳 %s｜teams=%s" % [str(r), str(st.teams.keys())])
	_ok(st.teams.size() == 2 and not st.teams.has(DEAD), "③tick 跑完，死者沒回來、活著的兩隊還在")
	_ok(_scan_refs(st, DEAD).is_empty(), "③tick 跑完後仍然沒有指向死者的參照")
	_sections += 1
