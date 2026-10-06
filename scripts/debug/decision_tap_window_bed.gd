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


func _initialize() -> void:
	print("=== decision_tap_window：決策 tap 的取樣窗 ===")
	var a: Dictionary = _run(false, false)
	var b: Dictionary = _run(true, false)
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
			Probe.sample_window = {"raid.composition": {"team": WIN_TEAM, "tick_min": WIN_MIN, "tick_max": WIN_MAX}}
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
		"buckets": buckets, "t11_opts": t11_opts}
	if probe_on:
		Probe.summary()
	Probe.sample_window = {}
	return out
