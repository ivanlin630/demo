extends SceneTree
# @bed-kind: acceptance
# slice: 決策 tap 能對準某一隊、某一段時間（spec 2026-10-06 decision-tap-can-target-a-team-and-window）
# ══ 決策 tap 的取樣窗 ════════════════════════════════════════════════════════════════════
# 世界 ＝ 照 `player_death_7day_specimen.gd` 的 `_run_pass`（★但 arm 改在 setup 之前，走 MeasureBedHelper）：default.json、seed 1337、
#   暖身 3 天、照 story_end_not_physics_bed 殺玩家、再推到窗的尾端
# 三輪同 seed：A ＝ Probe 關｜B ＝ Probe 開、不設窗｜C ＝ Probe 開、設窗
# 格：P1 A／B／C 的決策序列 hash 與世界 fp 逐位元組相同｜P2 C 的 raid.composition 全在窗內且 ≥1 筆
#     （★母體地板：印 Team11 在窗內每個 tick 的 current_option）｜P3 窗外擋掉 N > 0｜P4 其他 composition 桶 B ＝ C
# ★這支床重（三輪 × 約 13400 tick），所以是 acceptance、不進註冊表

const SEED: int = 1337
const WARMUP_DAYS: int = 3
const WIN_TEAM: int = 11
const WIN_MIN: int = 13350
const WIN_MAX: int = 13400
const OTHER_BUCKETS: Array = ["attack.composition", "recon.composition", "shelter.composition"]

var _errors: int = 0
var _stall_team: int = -999   # ★B 輪 construct.stall 樣本裡第一個 ct_id ⇒ C 輪對它設窗（team_key 那一格）
var _stall_after: int = 0     # ★C 輪的窗從 B 輪最後一筆之後開始 ⇒ 逼它取 B 沒看到的後段（否則窗什麼都沒做也綠）


func _initialize() -> void:
	print("=== decision_tap_window：決策 tap 的取樣窗 ===")
	_p5_team_key_synthetic()
	var a: Dictionary = _run(false, false)
	var b: Dictionary = _run(true, false)
	var b_stall: Array = b["stall"]
	if not b_stall.is_empty():
		_stall_team = int((b_stall[0] as Dictionary).get("ct_id", -999))
		_stall_after = int((b_stall[b_stall.size() - 1] as Dictionary).get("tick", 0)) + 1
	var c: Dictionary = _run(true, true)
	print("\n── P1 觀測不改世界 ──")
	for r in [a, b, c]:
		print("   %s：decision_hash=%s｜fp=%s" % [String(r["name"]), String(r["dhash"]).substr(0, 16), String(r["fp"])])
	_check("★★★P1 A／B／C 決策序列 hash 相同", a["dhash"] == b["dhash"] and b["dhash"] == c["dhash"])
	_check("★★★P1 A／B／C 世界 fp 相同", a["fp"] == b["fp"] and b["fp"] == c["fp"])
	print("\n── P2 設窗之後 raid.composition 全在窗內 ──")
	var opts: Array = c["t11_opts"]
	print("   ★母體地板：Team%d 在 tick %d–%d 的 current_option（%d 個 tick，去重後 %s）" % [WIN_TEAM, WIN_MIN, WIN_MAX,
		opts.size(), str(_uniq(opts))])
	_check("★母體地板：Team%d 在窗內真的評估過掠奪（current_option 含「掠奪」）" % WIN_TEAM, opts.has("掠奪"))
	var rs: Array = c["raid"]
	var bad: Array = []
	for row in rs:
		var d: Dictionary = row
		if int(d.get("team", -1)) != WIN_TEAM or int(d.get("tick", -1)) < WIN_MIN or int(d.get("tick", -1)) > WIN_MAX:
			bad.append([d.get("team", -1), d.get("tick", -1)])
	print("   C 的 raid.composition：%d 筆｜窗外的 ＝ %s" % [rs.size(), str(bad)])
	if not rs.is_empty():
		print("   第一筆 ＝ %s" % str(rs[0]))
	_check("★★★P2 至少 1 筆（%d）" % rs.size(), rs.size() >= 1)
	_check("★★★P2 全部 team ＝ %d 且 tick 在 [%d, %d]（窗外 %d 筆）" % [WIN_TEAM, WIN_MIN, WIN_MAX, bad.size()], bad.is_empty())
	# ★反向：B（不設窗）的 raid 桶是 first-N ⇒ 必須有窗外的筆（否則「全在窗內」可能只是剛好）
	var b_out: int = 0
	for row2 in b["raid"]:
		var d2: Dictionary = row2
		if int(d2.get("team", -1)) != WIN_TEAM or int(d2.get("tick", -1)) < WIN_MIN or int(d2.get("tick", -1)) > WIN_MAX:
			b_out += 1
	print("   ★對照 B（不設窗）：raid.composition %d 筆，其中窗外 %d 筆" % [(b["raid"] as Array).size(), b_out])
	_check("★★【反向】不設窗時桶裡有窗外的筆（%d）—— 否則 P2 的「全在窗內」沒有鑑別力" % b_out, b_out > 0)
	print("\n── P3 窗外擋掉的筆數 ──")
	print("   C：窗外擋掉 %d 筆" % int(c["dropped"]))
	_check("★★★P3 擋掉 N > 0（%d）" % int(c["dropped"]), int(c["dropped"]) > 0)
	print("\n── P4 沒設窗的桶照舊 ──")
	for k in OTHER_BUCKETS:
		var nb: int = (b["buckets"][k] as Array).size()
		var nc: int = (c["buckets"][k] as Array).size()
		print("   %s：B %d 筆｜C %d 筆｜內容相同 ＝ %s" % [k, nb, nc, str(str(b["buckets"][k]) == str(c["buckets"][k]))])
		_check("★★P4 %s 在 B／C 逐筆相同" % k, str(b["buckets"][k]) == str(c["buckets"][k]))
	print("\n── P5b team_key（真世界）：construct.stall 的隊伍鍵是 ct_id ──")
	print("   B（不設窗）construct.stall %d 筆，ct_id ＝ %s" % [b_stall.size(), str(_uniq(b_stall.map(func(r): return int((r as Dictionary).get("ct_id", -1)))))])
	_check("★母體地板：B 輪真的有 construct.stall 樣本、取得目標隊（Team%d）" % _stall_team, _stall_team != -999)
	var cs: Array = c["stall"]
	var cs_teams: Array = _uniq(cs.map(func(r): return int((r as Dictionary).get("ct_id", -1))))
	print("   C（設窗 team %d、team_key ct_id）construct.stall %d 筆，ct_id ＝ %s｜擋掉 %d 筆" % [_stall_team, cs.size(), str(cs_teams), int(c["stall_dropped"])])
	_check("★★★P5b 設 team_key ct_id ⇒ construct.stall 樣本 ≥1 且全是 Team%d" % _stall_team, cs.size() >= 1 and cs_teams == [_stall_team])
	# ★★鑑別力地板（第一版沒有這格 ⇒ B 的 8 筆剛好全是同一隊、窗擋掉 0 筆也綠 ＝ 窗什麼都沒做）
	# ★★★誠實限（2026-10-06 實測）：這一輪看到的停滯全是 team 4 ⇒ 擋掉的那幾筆是被 **tick** 篩掉的，
	#   不是被隊伍篩掉 ⇒ 「篩掉別隊」在真世界沒被展示（由 P5a 合成那格證）；
	#   這一格真正證的是**鍵讀對了**：construct.stall 樣本沒有 "team" 鍵 ⇒ 不給 team_key 會一筆都收不到
	_check("★★P5b 鑑別力：窗真的擋掉了東西（擋掉 %d 筆；0 ⇒ 這一輪全世界的停滯都是同一隊或都在窗外，這一格證明不了篩法，篩法由 P5a 證）" % int(c["stall_dropped"]),
		int(c["stall_dropped"]) > 0)
	print("\n=== decision_tap_window DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)


static func _uniq(arr: Array) -> Array:
	var o: Array = []
	for x in arr:
		if not o.has(x):
			o.append(x)
	return o


func _run(probe_on: bool, windowed: bool) -> Dictionary:
	var name: String = ("C（Probe 開、設窗）" if windowed else "B（Probe 開、不設窗）") if probe_on else "A（Probe 關）"
	seed(SEED)
	Probe.sample_window = {}
	# ★arm 順序照 bed-arm 閘：一律走 helper（arm → setup，順序寫死）；strip_player=false（要殺的就是玩家）
	#   ★誠實限：A 輪也是 arm 之後才 setup，然後才把 Probe 關掉 ⇒ 三輪的 **setup 期** Probe 都是開的，
	#     「Probe 關／開」的差別只在**模擬期**（P1 比的是模擬期有沒有被觀測改變）
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	if probe_on:
		if windowed:
			Probe.sample_window = {"raid.composition": {"team": WIN_TEAM, "tick_min": WIN_MIN, "tick_max": WIN_MAX},
				"construct.stall": {"team": _stall_team, "team_key": "ct_id", "tick_min": _stall_after, "tick_max": WIN_MAX}}
	else:
		Probe.enabled = false
		Probe.reset()
	var hasher := HashingContext.new()
	hasher.start(HashingContext.HASH_SHA256)
	var t11_opts: Array = []
	var killed: bool = false
	while ws.world.current_tick <= WIN_MAX:
		if not killed and ws.world.current_tick >= WARMUP_DAYS * WorldState.TICKS_PER_DAY:
			# ★逐字照 story_end_not_physics_bed.gd:67-73（與 specimen 床同一個殺法）
			var pid: int = ws.player_id
			var pt: TeamData = ws.teams[ws.persons[pid].team_id]
			for m in pt.named_members.duplicate():
				ws.remove_member(pt, int(m), false)
				if int(m) == pid:
					ws.persons.erase(pid)
			EventSystem.new().handle_player_succession(ws, pt)
			killed = true
		runner.advance_tick(ws, Vector2i(-1, -1))
		var ids: Array = ws.teams.keys()
		ids.sort()
		var line: String = "%d" % ws.world.current_tick
		for tid in ids:
			line += "|%d:%s" % [int(tid), String(ws.teams[tid].current_option)]
		hasher.update(line.to_utf8_buffer())
		var k: int = ws.world.current_tick
		if k >= WIN_MIN and k <= WIN_MAX and ws.teams.has(WIN_TEAM):
			t11_opts.append(String(ws.teams[WIN_TEAM].current_option))
	var buckets: Dictionary = {}
	for kk in OTHER_BUCKETS:
		buckets[kk] = (Probe.samples.get(kk, []) as Array).duplicate(true)
	var out: Dictionary = {"name": name, "dhash": hasher.finish().hex_encode(), "fp": StateFingerprint.compute(ws),
		"raid": (Probe.samples.get("raid.composition", []) as Array).duplicate(true),
		"dropped": int(Probe.sample_window_dropped.get("raid.composition", 0)),
		"buckets": buckets, "t11_opts": t11_opts,
		"stall": (Probe.samples.get("construct.stall", []) as Array).duplicate(true),
		"stall_dropped": int(Probe.sample_window_dropped.get("construct.stall", 0))}
	if probe_on:
		Probe.summary()
	Probe.sample_window = {}
	return out


# ══ P5a team_key（合成，不跑世界）：直接餵 bump_sample，驗篩法本身 ═════════════════════════
func _p5_team_key_synthetic() -> void:
	print("\n── P5a team_key（合成）──")
	var was: bool = Probe.enabled
	Probe.enabled = true
	Probe.reset()
	Probe.sample_window = {"construct.stall": {"team": 3, "team_key": "ct_id", "tick_min": 0, "tick_max": 100}}
	Probe.bump_sample("construct.stall", {"tick": 5, "ct_id": 3})
	Probe.bump_sample("construct.stall", {"tick": 5, "ct_id": 4})
	Probe.bump_sample("construct.stall", {"tick": 5, "team": 3})
	var got: Array = Probe.samples.get("construct.stall", [])
	var dropped: int = int(Probe.sample_window_dropped.get("construct.stall", 0))
	print("   team_key ct_id、team 3：收 %s｜擋掉 %d" % [str(got), dropped])
	_check("★★P5a 有 team_key ⇒ 只收 ct_id ＝ 3 那一筆、擋掉 2（別隊／只帶 team 鍵的）",
		got.size() == 1 and int((got[0] as Dictionary).get("ct_id", -1)) == 3 and dropped == 2)
	# ★反向：不給 team_key（預設 "team"）⇒ 只帶 ct_id 的兩筆都被擋、只帶 team 3 的那筆留下
	Probe.reset()
	Probe.sample_window = {"construct.stall": {"team": 3, "tick_min": 0, "tick_max": 100}}
	Probe.bump_sample("construct.stall", {"tick": 5, "ct_id": 3})
	Probe.bump_sample("construct.stall", {"tick": 5, "ct_id": 4})
	Probe.bump_sample("construct.stall", {"tick": 5, "team": 3})
	var got2: Array = Probe.samples.get("construct.stall", [])
	var dropped2: int = int(Probe.sample_window_dropped.get("construct.stall", 0))
	print("   不給 team_key：收 %s｜擋掉 %d" % [str(got2), dropped2])
	_check("★★P5a【反向】預設 team 鍵 ⇒ 只收 team ＝ 3 那一筆、ct_id 那兩筆擋掉",
		got2.size() == 1 and (got2[0] as Dictionary).has("team") and dropped2 == 2)
	Probe.sample_window = {}
	Probe.reset()
	Probe.enabled = was
