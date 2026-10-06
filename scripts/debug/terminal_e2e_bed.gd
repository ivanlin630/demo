extends SceneTree
# @bed-kind: invariant
# ══ 終端 E2E 床（狀態驅動）：從畫面挑動作、按它印的鍵、驗世界真的照那句話變了 ══════════════════════
# spec：`docs/superpowers/specs/2026-10-06-terminal-e2e-state-driven-HOW.md`
#
# ★本檔目前只有**解析器**＋它的自驗（R² 回來之前先做的、不依賴架構裁定的那一件）
#
# ══ 解析器：畫面上的**三個**鍵位空間（spec 原文寫兩個；實測三個）══════════════════════════════════
#   (i)  目標動作：`─ 動作（` 區塊的 ` [n] 標籤 ▸（不可：原因）`（TextUiView.action_block；ACTION_DIGITS 靜態綁 id）
#   (ii) 強制事件回應：`   [A] 標籤`（text_ui_main 手刻；不變量 #10「按 A 做 B」的血證空間）
#   (iii) 自家隊動作：互動面板 `── 自家隊動作（N 項）` 底下 `[n]標籤` 與 `[n]標籤（不可）`（同一行多個、兩個空白分隔）
#   ★判哪個空間「現在吃數字鍵」：標題帶 `數字鍵在這一側` 的那一側

var _errors: int = 0
var _cells_ran: Array = []
const EXPECTED_CELLS: Array = ["P0", "P10", "WALK", "P1", "P2", "P3", "P4", "P5", "P6", "P7"]

const SEED_A: int = 1337
const SEED_B: int = 4242
# ★佈置一支同格 NPC ＋ 一個強制事件（照 `forced_event_panel_bed._npc_at_player` 的手法）——
#   ★理由（spec P1）：字母鍵空間要等 NPC 來提案，30 步內等不到 ⇒ 不佈置的話那一欄印 0 還綠
#   ★它同時給出「可互動目標」⇒ 目標動作那個鍵位空間（(i)）也走得到
const NPC_ID: int = 7320
const FORCED_PROPOSAL: String = "propose_alliance"   # diplomatic_ai_system 真的會寫的值（同 forced_event_panel_bed P7）
const MAIN_HINT: String = "[T]互動"   # MODE_KEYMAP["main"] 的一段 ⇒ 判「回到主畫面了」
const SUBMENU_INTEL_HINT: String = "選題"   # MODE_KEYMAP["intel"] ⇒ 打聽要走完子選單（systems 裁 2026-10-07）
const TO_MAIN_MAX_ESC: int = 6
# ★effect → 快照裡要變的那幾塊（單一來源是 ACTION_SHAPE 的 effect 值；這裡只是「那個值讀哪幾欄」）
const EFFECT_FIELDS: Dictionary = {
	"task": ["task"], "belief": ["belief"], "faction": ["faction"],
	"resources_self": ["res_self"], "resources_both": ["res_self", "res_others"],
	"encounter": ["encounter"], "encounter_result": ["encounter_result"],
	"roster": ["roster_self"], "roster_other": ["roster_others"], "menu": [],
}

# ══ 已知（第一次跑抓到、spec §6「列清單、回報，不在本票修」）════════════════════════════════════
# ★每一條必須**這一輪真的再現**，否則紅（世界修好之後這一句就不成立 ⇒ 要回來拿掉，不能讓它變成恆綠的豁免）
#   key ＝ "<格>|<動作名>"
var KNOWN: Dictionary = {}
var _known_hit: Dictionary = {}


func _initialize() -> void:
	print("=== terminal_e2e：從畫面挑動作、按它印的鍵、驗世界真的照那句話變了 ===")
	_p0_parser()
	await _p10_not_lagging()
	print("\n── WALK seed=%d ──" % SEED_A)
	var r1: Dictionary = await _walk(SEED_A, -1, true)
	_cells_ran.append("WALK")
	_judge(r1)
	print("\n── P5 確定性：同 seed 再走一次 ⇒ 逐字相同；換 seed ⇒ 必須不同 ──")
	var r2: Dictionary = await _walk(SEED_A, int(r1["n"]), false)
	var same: bool = (r1["lines"] as Array) == (r2["lines"] as Array)
	if not same:
		for i in range(mini((r1["lines"] as Array).size(), (r2["lines"] as Array).size())):
			if String(r1["lines"][i]) != String(r2["lines"][i]):
				print("   第一處不同（第 %d 行）：\n     %s\n     %s" % [i, r1["lines"][i], r2["lines"][i]])
				break
	_check("P5 同 seed（%d）兩次走法輸出逐字相同（%d 行／%d 行）" % [SEED_A, (r1["lines"] as Array).size(), (r2["lines"] as Array).size()], same)
	var r3: Dictionary = await _walk(SEED_B, int(r1["n"]), false)
	_check("P5【反向】換 seed（%d）⇒ 輸出必須不同（否則正規化器過寬、恆穩）" % SEED_B,
		(r1["lines"] as Array) != (r3["lines"] as Array))
	_cells_ran.append("P5")
	await _p7_observation(r1)
	for k in KNOWN:
		_check("★已知條目這一輪真的再現：%s（不再現 ⇒ 世界修好了，回來拿掉這一條）" % k, _known_hit.has(k))
	var missing: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(String(c)):
			missing.append(String(c))
	_check("★到場點名：%d／%d（缺：%s）" % [_cells_ran.size(), EXPECTED_CELLS.size(), str(missing)], missing.is_empty())
	print("\n=== terminal_e2e DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)


# 回 {"self": [...], "self_active": bool, "targets_active": bool, "actions": [...], "forced": [...]}
#   每一項 {"space": "self"|"action"|"forced", "key": String, "label": String, "enabled": bool}
static func parse_screen(screen: String) -> Dictionary:
	var out: Dictionary = {"self": [], "actions": [], "forced": [], "targets": [], "unbound": [],
		"self_active": false, "targets_active": false}
	var lines: PackedStringArray = screen.split("\n")
	var region: String = ""
	var re_self := RegEx.new()
	re_self.compile("\\[(\\d)\\]([^\\[]+?)(?=\\s{2,}\\[|\\s*$)")
	var re_act := RegEx.new()
	re_act.compile("^ \\[(\\d)\\] (.+?)\\s*(▸)?\\s*(（不可：.*）)?\\s*$")
	var re_target := RegEx.new()
	re_target.compile("^\\[(\\d)\\] (.+?)\\s*$")
	var re_unbound := RegEx.new()
	re_unbound.compile("^ （未綁鍵） (.+?)\\s*(（不可：.*）)?\\s*$")
	var re_forced := RegEx.new()
	re_forced.compile("^\\s{3}\\[([A-Z])\\] (.+?)\\s*$")
	for l in lines:
		if l.begins_with("── 自家隊動作"):
			region = "self"
			out["self_active"] = l.contains("數字鍵在這一側")
			continue
		if l.begins_with("── 可互動目標"):
			region = "targets"
			out["targets_active"] = l.contains("數字鍵在這一側")
			continue
		if l.begins_with("─ 動作（"):
			region = "action"
			continue
		# 其他區塊標題（`─ 事件（`、`── 互動 ──`、`── [T/Esc]關閉 ──`…）⇒ 離開目前區塊
		if l.begins_with("─ ") or l.begins_with("── "):
			region = ""
			continue
		var mf := re_forced.search(l)
		if mf != null:
			out["forced"].append({"space": "forced", "key": mf.get_string(1), "label": mf.get_string(2), "enabled": true})
			continue
		if region == "self":
			for m in re_self.search_all(l):
				var lab: String = m.get_string(2).strip_edges()
				var en: bool = not lab.ends_with("（不可）")
				out["self"].append({"space": "self", "key": m.get_string(1),
					"label": lab.trim_suffix("（不可）"), "enabled": en})
		elif region == "action":
			var ma := re_act.search(l)
			if ma != null:
				out["actions"].append({"space": "action", "key": ma.get_string(1), "label": ma.get_string(2).strip_edges(),
					"enabled": ma.get_string(4) == ""})
			else:
				var mu := re_unbound.search(l)
				if mu != null:
					out["unbound"].append(mu.get_string(1).strip_edges())
		elif region == "targets":
			var mt := re_target.search(l)
			if mt != null:
				out["targets"].append({"space": "target", "key": mt.get_string(1), "label": mt.get_string(2).strip_edges(),
					"enabled": true})
	return out


func _p0_parser() -> void:
	print("\n── P0 解析器（三個鍵位空間）──")
	var self_screen: String = "\n".join([
		"第 1 天 00:00 ｜ Team15（人口 10） ｜ 家：（無） ｜ 糧撐 6.3 天 ｜ 威脅：（無） ｜ 待執行 1 道",
		"─ 面板（接管畫面）──────",
		"── 互動 ──",
		"⚠ Team3 要求你繳貢",
		"   拒絕會惡化關係",
		"   [A] 接受",
		"   [B] 拒絕",
		"── 自家隊動作（10 項） 數字鍵在這一側 ──",
		"[1]紮營（不可）  [2]確認打聽（不可）  [3]建立勢力",
		"[4]狩獵（不可）  [5]獵猛獸（不可）  [6]放棄戰利品（不可）",
		"[7]拔擢匿名→記名  [8]收編敗者（不可）  [9]收割戰利品（不可）",
		"第 1/2 頁 [,]上 [.]下",
		"── 可互動目標 （按 [Tab] 切過來） ──",
		"（無可互動目標）",
		"── [T/Esc]關閉 ──",
		"─ 動作（2／3 可做，未綁鍵 0）──────",
		" [1] 貿易 ▸",
		" [2] 提議結盟 ",
		" [6] 攻擊 （不可：不在同格）",
		"─ 事件（最近 8 條）──────",
		" 結果：",
	])
	var p: Dictionary = parse_screen(self_screen)
	print("   自家隊 %d 項（可做 %s）｜目標動作 %s｜強制 %s｜數字鍵在自家隊 ＝ %s" % [(p["self"] as Array).size(),
		str((p["self"] as Array).filter(func(x): return x["enabled"]).map(func(x): return x["key"] + x["label"])),
		str((p["actions"] as Array).map(func(x): return [x["key"], x["label"], x["enabled"]])),
		str((p["forced"] as Array).map(func(x): return x["key"] + x["label"])), str(p["self_active"])])
	_check("P0 自家隊 9 項、可做的是 [3]建立勢力 與 [7]拔擢匿名→記名",
		(p["self"] as Array).size() == 9 and (p["self"] as Array).filter(func(x): return x["enabled"]).map(func(x): return x["key"]) == ["3", "7"])
	_check("P0 自家隊那一側吃數字鍵", bool(p["self_active"]) and not bool(p["targets_active"]))
	_check("P0 強制事件兩個字母鍵 [A]接受 [B]拒絕",
		(p["forced"] as Array).map(func(x): return x["key"] + x["label"]) == ["A接受", "B拒絕"])
	_check("P0 目標動作 3 列：[1]貿易 可、[2]提議結盟 可、[6]攻擊 不可",
		(p["actions"] as Array).map(func(x): return [x["key"], x["label"], x["enabled"]]) == [["1", "貿易", true], ["2", "提議結盟", true], ["6", "攻擊", false]])
	# ★反向：沒有任何鍵位的畫面 ⇒ 三個空間都空（解析器不能憑空生出項目）
	var empty: Dictionary = parse_screen("第 1 天 00:00 ｜ …\n─ 動作（0／0 可做，未綁鍵 0）──\n （沒有可做的動作）\n 結果：")
	_check("P0【反向】空畫面 ⇒ 三個空間都是 0",
		(empty["self"] as Array).is_empty() and (empty["actions"] as Array).is_empty() and (empty["forced"] as Array).is_empty())
	_cells_ran.append("P0")


# ══ 世界：每一份都從頭建（同 seed）——★全站零 WorldState clone（spec §2 寫死）⇒ 分叉 ＝ 重建＋重放前綴 ══════════
# ★★而且**一次只活一份**：`GameSetup.setup` 會叫 `CrossRunReset`（類級 static 歸零）
#   ⇒ 兩份世界交錯推進的話，建第二份那一刻就改了第一份的 static ⇒ 第一份不再是「它自己」
#   ⇒ 所以 A、B 都是「建 → 重放 → 量 → 丟」，前綴只以**按鍵序列**的形式活著
func _build(sd: int) -> Node:
	seed(sd)
	var node: Node = load("res://scenes/TextUI.tscn").instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame
	_arrange(node)
	node._refresh()
	return node


func _drop(node: Node) -> void:
	node.queue_free()
	await process_frame


func _arrange(node: Node) -> void:
	var st: WorldState = node._bridge._state
	var ptid: int = st.get_player_team_id()
	var t := TeamData.new()
	t.team_id = NPC_ID
	t.faction_id = -1
	t.tile_pos = st.teams[ptid].tile_pos
	AnonTierSystem.add_anon(t, AnonCohort.TIER_PLEB, 4)
	var l := PersonData.new()
	l.id = NPC_ID * 10 + 1
	l.team_id = NPC_ID
	l.person_name = "首領%d" % NPC_ID
	st.persons[l.id] = l
	t.leader_id = l.id
	st.teams[NPC_ID] = t
	st.set_player_forced_event({"action": "diplomacy", "from_id": NPC_ID, "proposal": FORCED_PROPOSAL}, "fe_e2e")


static func _screen(node: Node) -> String:
	return String(node._screen_label.text)


static func _line_starting(screen: String, prefix: String) -> String:
	for l in screen.split("\n"):
		if l.begins_with(prefix):
			return l
	return ""


static func _hint(node: Node) -> String:
	return _line_starting(_screen(node), " 鍵：")


static func _result_line(screen: String) -> String:
	return _line_starting(screen, " 結果：").trim_prefix(" 結果：").strip_edges()


static func _event_lines(screen: String) -> Array:
	var out: Array = []
	var on: bool = false
	for l in screen.split("\n"):
		if l.begins_with("─ 事件（"):
			on = true
			continue
		if on and (l.begins_with("─") or l.begins_with(" 結果：")):
			break
		if on:
			out.append(l)
	return out


# 頂列「第 D 天 HH:MM」→ tick
static func _screen_tick(screen: String) -> int:
	var re := RegEx.new()
	re.compile("^第 (\\d+) 天 (\\d\\d):(\\d\\d)")
	var m := re.search(screen.split("\n")[0])
	if m == null:
		return -1
	return (int(m.get_string(1)) - 1) * WorldState.TICKS_PER_DAY + int(m.get_string(2)) * WorldState.TICKS_PER_HOUR + int(m.get_string(3))


# 狀態列「Tick: N」（只在主畫面印）→ N；沒有 ⇒ -1
static func _status_tick(screen: String) -> int:
	var re := RegEx.new()
	re.compile("Tick: (\\d+)")
	var m := re.search(screen)
	return int(m.get_string(1)) if m != null else -1


# ★按一個鍵 ＝ PlayerRepl.press_on（跟玩家同一條路）＋記錄 ＋ P10 常駐那一欄
func _press(w: Dictionary, k: String) -> void:
	var kc: int = PlayerRepl.keycode_for(k)
	if kc == -1:
		_check("鍵打不出來：%s" % k, false)
		return
	await PlayerRepl.press_on(w["node"], kc)
	(w["keys"] as Array).append(k)
	var scr: String = _screen(w["node"])
	var wt: int = w["node"]._bridge.get_current_tick()
	var top: int = _screen_tick(scr)
	var stt: int = _status_tick(scr)
	w["p10_n"] = int(w["p10_n"]) + 1
	if top != wt or (stt != -1 and stt != wt):
		(w["p10_bad"] as Array).append("key=%s 畫面頂列 %d／狀態列 %d／世界 %d" % [k, top, stt, wt])


func _press_all(w: Dictionary, keys: Array) -> void:
	for k in keys:
		await _press(w, String(k))


func _new_w(node: Node) -> Dictionary:
	return {"node": node, "keys": [], "p10_n": 0, "p10_bad": []}


func _to_main(w: Dictionary) -> bool:
	for _i in range(TO_MAIN_MAX_ESC):
		if _hint(w["node"]).contains(MAIN_HINT):
			return true
		await _press(w, "esc")
	return _hint(w["node"]).contains(MAIN_HINT)


static func _fp(node: Node) -> String:
	return StateFingerprint.compute(node._bridge._state)


static func _tick(node: Node) -> int:
	return int(node._bridge.get_current_tick())


# ══ 世界狀態快照（唯讀、零 RNG）══════════════════════════════════════════════════════════════════
# ★belief 走既有唯讀讀口 `query_memory_panel()`（spec §3：不在主快照開第二個 belief 入口）
static func _snap(node: Node) -> Dictionary:
	var st: WorldState = node._bridge._state
	var pid: int = st.get_player_team_id()
	var pt: TeamData = st.teams.get(pid)
	var others_res: Array = []
	var others_roster: Array = []
	var ids: Array = st.teams.keys()
	ids.sort()
	for tid in ids:
		if int(tid) == pid:
			continue
		var t: TeamData = st.teams[tid]
		others_res.append("%d:%s" % [int(tid), str(t.resources)])
		others_roster.append("%d:%d/%d/%d@%s" % [int(tid), t.population, t.named_members.size(), t.faction_id, str(t.tile_pos)])
	if pt == null:
		return {"task": "dead", "belief": "", "faction": "", "res_self": "", "res_others": str(others_res),
			"encounter": "%s|%d" % [str(st.encounter_active), st.teams.size()],
			"encounter_result": str(st.last_encounter_result), "roster_self": "", "roster_others": str(others_roster)}
	return {
		"task": "%s|%s" % [pt.current_task, str(pt.move_target)],
		"belief": JSON.stringify(node._bridge.query_memory_panel()),
		"faction": "%d|%d" % [pt.faction_id, st.factions.size()],
		"res_self": str(pt.resources),
		"res_others": str(others_res),
		"encounter": "%s|%d" % [str(st.encounter_active), st.teams.size()],
		"encounter_result": str(st.last_encounter_result),
		"roster_self": "%d|%s|%d" % [pt.leader_id, str(pt.named_members), pt.population],
		"roster_others": str(others_roster),
	}


static func _diff_fields(a: Dictionary, b: Dictionary) -> Array:
	var out: Array = []
	for k in a:
		if String(a[k]) != String(b.get(k, "")):
			out.append(String(k))
	out.sort()
	return out


# 畫面上的動作名 → action id：**反查** `PlayerApiMapper.action_label`（唯一一份 label 表），不另抄
static func _label_to_id(label: String) -> String:
	var hit: Array = []
	for aid in PlayerCommandSystem.ACTION_SHAPE:
		if PlayerApiMapper.action_label(String(aid)) == label:
			hit.append(String(aid))
	if hit.size() == 1:
		return String(hit[0])
	return ("?多個:%s" % str(hit)) if hit.size() > 1 else ""


# ★挑法：確定性（seed 與步數），不用 randf；沒按過的優先（涵蓋率）
static func _pick(cands: Array, pressed: Dictionary, sd: int, step: int) -> Dictionary:
	var fresh: Array = cands.filter(func(c): return not pressed.has(String(c["kind"])))
	var pool: Array = fresh if not fresh.is_empty() else cands
	return pool[(sd * 31 + step * 17) % pool.size()]


# ══ 走法 ══════════════════════════════════════════════════════════════════════════════════════════
func _walk(sd: int, n_fixed: int, verbose: bool) -> Dictionary:
	var prefix: Array = []
	var lines: Array = []
	var steps: Array = []
	var offered: Dictionary = {}
	var pressed: Dictionary = {}
	var unbound: Dictionary = {}
	var aborts: Array = []
	var p6_bad: Array = []
	var p10_n: int = 0
	var p10_bad: Array = []
	var n: int = n_fixed
	var step: int = 0
	while n < 0 or step < n:
		# ── A：建 → 重放前綴 → 這一步
		var wa: Dictionary = _new_w(await _build(sd))
		await _press_all(wa, prefix)
		var fork_fp: String = _fp(wa["node"])
		if not await _to_main(wa):
			aborts.append("step %d：回不到主畫面（鍵列：%s）" % [step, _hint(wa["node"])])
			await _drop(wa["node"])
			break
		await _press(wa, "t")
		var p: Dictionary = parse_screen(_screen(wa["node"]))
		if n < 0:
			# ★N 從畫面推導（不寫死）：自家隊動作區標題的項數 × 2
			var re := RegEx.new()
			re.compile("── 自家隊動作（(\\d+) 項）")
			var m := re.search(_screen(wa["node"]))
			n = (int(m.get_string(1)) if m != null else 0) * 2
			if verbose:
				print("   N ＝ 自家隊動作 %s 項 × 2 ＝ %d 步" % [m.get_string(1) if m != null else "?", n])
		var cands: Array = []
		for f in p["forced"]:
			offered["字母:" + String(f["label"])] = true
			cands.append({"space": "forced", "key": f["key"], "label": f["label"], "kind": "字母:" + String(f["label"])})
		for s in p["self"]:
			offered["數字:" + String(s["label"])] = true
			if bool(s["enabled"]):
				cands.append({"space": "self", "key": s["key"], "label": s["label"], "kind": "數字:" + String(s["label"])})
		for t in p["targets"]:
			cands.append({"space": "target", "key": t["key"], "label": t["label"], "kind": "目標:" + String(t["label"])})
		if cands.is_empty():
			aborts.append("step %d：候選集為空" % step)
			await _drop(wa["node"])
			break
		var pick: Dictionary = _pick(cands, pressed, sd, step)
		var open_keys: Array = ["t"]
		var label: String = String(pick["label"])
		var space: String = String(pick["space"])
		if space == "self" and not bool(p["self_active"]):
			await _press(wa, "tab")
			open_keys.append("tab")
		if space == "target":
			if not bool(p["targets_active"]):
				await _press(wa, "tab")
				open_keys.append("tab")
			await _press(wa, String(pick["key"]))
			open_keys.append(String(pick["key"]))
			var pa: Dictionary = parse_screen(_screen(wa["node"]))
			for u in pa["unbound"]:
				unbound[String(u)] = true
			var acts: Array = []
			for a in pa["actions"]:
				offered["目標動作:" + String(a["label"])] = true
				if bool(a["enabled"]):
					acts.append({"space": "action", "key": a["key"], "label": a["label"], "kind": "目標動作:" + String(a["label"])})
			if acts.is_empty():
				aborts.append("step %d：目標 %s 沒有可做的動作" % [step, label])
				await _drop(wa["node"])
				break
			pressed[String(pick["kind"])] = true
			pick = _pick(acts, pressed, sd, step)
			label = String(pick["label"])
			space = "action"
		var scr0: String = _screen(wa["node"])
		var t0: int = _tick(wa["node"])
		await _press(wa, String(pick["key"]))
		# ★打聽：effect 掛在選題之後那道令 ⇒ 走完子選單（選第 1 題）（systems 裁 2026-10-07）
		if _hint(wa["node"]).contains(SUBMENU_INTEL_HINT):
			await _press(wa, "1")
		var adv: int = _tick(wa["node"]) - t0
		var scr1: String = _screen(wa["node"])
		var ev0: Array = _event_lines(scr0)
		var new_ev: Array = _event_lines(scr1).filter(func(e): return not ev0.has(e))
		var result: String = _result_line(scr1)
		var said: String = result
		if not new_ev.is_empty():
			said += "｜" + "｜".join(PackedStringArray(new_ev))
		var ok_main: bool = await _to_main(wa)
		var a_keys: Array = (wa["keys"] as Array).slice(prefix.size())
		var snap_a: Dictionary = _snap(wa["node"])
		var tick_a: int = _tick(wa["node"])
		p10_n += int(wa["p10_n"])
		p10_bad.append_array(wa["p10_bad"])
		pressed[String(pick["kind"])] = true
		await _drop(wa["node"])
		if not ok_main:
			aborts.append("step %d：按完 %s 之後回不到主畫面" % [step, label])
			break
		# ── B：建 → 重放同一個前綴 → 同樣打開、不按動作鍵 → 用推進鍵補齊同樣的 tick 數
		var wb: Dictionary = _new_w(await _build(sd))
		await _press_all(wb, prefix)
		var fork_fp_b: String = _fp(wb["node"])
		if fork_fp_b != fork_fp:
			p6_bad.append("step %d：A %s ／ B %s" % [step, fork_fp.substr(0, 8), fork_fp_b.substr(0, 8)])
		await _to_main(wb)
		await _press_all(wb, open_keys)
		await _to_main(wb)
		if adv > 0:
			var gk: Array = ["g"]
			for ch in str(adv):
				gk.append(ch)
			gk.append("enter")
			await _press_all(wb, gk)
		var b_keys: Array = (wb["keys"] as Array).slice(prefix.size())
		var snap_b: Dictionary = _snap(wb["node"])
		var tick_b: int = _tick(wb["node"])
		p10_n += int(wb["p10_n"])
		p10_bad.append_array(wb["p10_bad"])
		await _drop(wb["node"])
		var diff: Array = _diff_fields(snap_a, snap_b)
		var rec: Dictionary = {"step": step, "space": space, "label": label, "kind": String(pick["kind"]),
			"a_keys": a_keys, "b_keys": b_keys, "tick_a": tick_a, "tick_b": tick_b, "adv": adv,
			"result": result, "said": said, "new_ev": new_ev, "diff": diff}
		steps.append(rec)
		var sp_name: String = {"forced": "字母", "self": "數字", "action": "目標動作"}.get(space, space)
		var line: String = "step %02d｜%s %s｜A %s（t%d）｜B %s（t%d）｜結果：%s｜差異：%s" % [step, sp_name, label,
			" ".join(PackedStringArray(a_keys)), tick_a, " ".join(PackedStringArray(b_keys)), tick_b, said, str(diff)]
		lines.append(line)
		if verbose:
			print("   " + line)
		if tick_a != tick_b:
			aborts.append("step %d：兩邊 tick 數不同（A t%d／B t%d）⇒ 不可判" % [step, tick_a, tick_b])
			break
		prefix.append_array(a_keys)
		step += 1
	# 終局 fp（P7 用）：走完的整串按鍵重放一次、觀測一次
	var wz: Dictionary = _new_w(await _build(sd))
	await _press_all(wz, prefix)
	var _s: Dictionary = _snap(wz["node"])
	var fp_end: String = _fp(wz["node"])
	await _drop(wz["node"])
	return {"lines": lines, "n": n, "keys": prefix, "fp_end": fp_end, "steps": steps, "offered": offered,
		"pressed": pressed, "p10_n": p10_n, "p10_bad": p10_bad, "aborts": aborts, "p6_bad": p6_bad,
		"p6_n": steps.size(), "unbound": unbound}


# ══ 判 ══════════════════════════════════════════════════════════════════════════════════════════
func _known(cell: String, label: String) -> bool:
	var k: String = "%s|%s" % [cell, label]
	if KNOWN.has(k):
		_known_hit[k] = true
		print("   ⚑ 已知（%s）：%s" % [k, String(KNOWN[k])])
		return true
	return false


func _judge(r: Dictionary) -> void:
	var steps: Array = r["steps"]
	print("\n── ABORT／不可判 ──")
	for a in r["aborts"]:
		print("   ✗ " + String(a))
	_check("走法沒有 ABORT（%d 條）" % (r["aborts"] as Array).size(), (r["aborts"] as Array).is_empty())
	# ── P1 母體地板
	print("\n── P1 母體地板 ──")
	var n_action: int = steps.filter(func(s): return String(s["space"]) == "action").size()
	var n_self: int = steps.filter(func(s): return String(s["space"]) == "self").size()
	var n_letter: int = steps.filter(func(s): return String(s["space"]) == "forced").size()
	var never: Array = (r["offered"] as Dictionary).keys().filter(func(k): return not (r["pressed"] as Dictionary).has(k))
	print("   步數 %d（N ＝ %d）｜數字鍵：自家隊 %d 步、目標動作 %d 步｜字母鍵 %d 步" % [steps.size(), int(r["n"]), n_self, n_action, n_letter])
	print("   畫面提供過 %d 種／本輪按過 %d 種" % [(r["offered"] as Dictionary).size(), (r["pressed"] as Dictionary).size()])
	print("   提供過而沒按到（含不可做的）：%s" % str(never))
	print("   列出卻沒綁鍵（不判，回報）：%s" % str((r["unbound"] as Dictionary).keys()))
	_check("P1 走滿 N 步（%d／%d）" % [steps.size(), int(r["n"])], steps.size() == int(r["n"]) and int(r["n"]) > 0)
	_check("P1 字母鍵 ≥ 1（%d）—— 否則 §0 那個鍵位空間沒被走過" % n_letter, n_letter >= 1)
	_check("P1 自家隊數字鍵 ≥ 1（%d）" % n_self, n_self >= 1)
	_check("P1 目標動作數字鍵 ≥ 1（%d）" % n_action, n_action >= 1)
	_cells_ran.append("P1")
	# ── P6 雙世界前提
	print("\n── P6 每次分叉兩份 fp 相同 ──")
	for b in r["p6_bad"]:
		print("   ✗ " + String(b))
	_check("P6 分叉點 fp 相同（%d 次分叉，不同 %d）" % [int(r["p6_n"]), (r["p6_bad"] as Array).size()],
		int(r["p6_n"]) >= 1 and (r["p6_bad"] as Array).is_empty())
	_cells_ran.append("P6")
	# ── P10 常駐：每一鍵回來那一屏的時間 ＝ 世界 tick
	print("\n── P10 常駐：每一鍵回來的那一屏 ＝ 結算後的世界 ──")
	for b in (r["p10_bad"] as Array).slice(0, 8):
		print("   ✗ " + String(b))
	_check("P10 常駐：%d 次按鍵，畫面時間 ≠ 世界 tick 的 %d 次" % [int(r["p10_n"]), (r["p10_bad"] as Array).size()],
		int(r["p10_n"]) >= 1 and (r["p10_bad"] as Array).is_empty())
	# ── P2／P3／P4 逐步
	print("\n── P2 紅一／P3 紅二／P4 紅三（逐步）──")
	var p2_bad: int = 0
	var p3_bad: int = 0
	var p4_bad: int = 0
	var p3_n: int = 0
	var p11: Dictionary = {}
	for s in steps:
		var label: String = String(s["label"])
		var said: String = String(s["said"])
		var queued: bool = int(s["adv"]) > 0
		var refused: bool = said.contains("被拒絕") or said.contains("✗")
		var diff: Array = s["diff"]
		var eff: String = ""
		if String(s["space"]) != "forced":
			var aid: String = _label_to_id(label)
			var shape: Dictionary = PlayerCommandSystem.ACTION_SHAPE.get(aid, {})
			eff = String(shape.get("effect", ""))
			if aid == "" or aid.begins_with("?") or eff == "" or not EFFECT_FIELDS.has(eff):
				_check("★反向掃：畫面上按到的「%s」在 ACTION_SHAPE 有合法 effect（id=%s effect=%s）" % [label, aid, eff], false)
				continue
		# P2 紅一：下了令 ⇒ 結果句要說出按下那一行的動作名
		if queued and not said.contains(label):
			if not _known("P2", label):
				p2_bad += 1
				_check("P2 step %d 按「%s」⇒ 結果句沒有說它（%s）" % [int(s["step"]), label, said], false)
		# P3 紅二：說成功 ⇒ effect 那幾欄在 A−B 非空
		if queued and not refused and eff != "" and not (EFFECT_FIELDS[eff] as Array).is_empty():
			p3_n += 1
			var need: Array = EFFECT_FIELDS[eff]
			if not need.all(func(f): return diff.has(f)):
				if not _known("P3", label):
					p3_bad += 1
					_check("P3 step %d「%s」說成功（%s）而 effect=%s 的 %s 在 A−B 沒變（差異 %s）" % [int(s["step"]), label, said, eff, str(need), str(diff)], false)
		# P4 紅三：A−B 有變 ⇒ 結果句提到那個動作
		if not diff.is_empty() and not said.contains(label):
			if not _known("P4", label):
				p4_bad += 1
				_check("P4 step %d 世界變了（%s）而結果句沒說「%s」（%s）" % [int(s["step"]), str(diff), label, said], false)
		# P11 回報：沒被拒，而畫面只有「已排入」回音、沒有完成句
		if queued and not refused and (s["new_ev"] as Array).is_empty() and String(s["result"]).begins_with("已排入"):
			p11[label] = true
	_check("P2 紅一：0 步錯（%d）" % p2_bad, p2_bad == 0)
	_check("P3 紅二：判了 %d 步、0 步錯（%d）" % [p3_n, p3_bad], p3_bad == 0)
	_check("P3 母體地板：至少判過 1 步（%d）" % p3_n, p3_n >= 1)
	_check("P4 紅三：0 步錯（%d）" % p4_bad, p4_bad == 0)
	print("   P11 回報（不判）：沒被拒、而畫面只有「已排入」回音、沒有完成句：%s" % str(p11.keys()))
	_cells_ran.append("P2")
	_cells_ran.append("P3")
	_cells_ran.append("P4")


# ══ P10：畫面不落後一步（開場那一個 x）＋反向（Esc 不等）══════════════════════════════════════════
# ★紅基線 ＝ 實作端 origin/main `6a5b56c7e` 用 play.py 實測：送 x 立刻回的一屏仍是「第 1 天 00:00」
func _p10_not_lagging() -> void:
	print("\n── P10 畫面不落後：送 x ⇒ 回來那一屏 ＝ 推進後 ──")
	var w: Dictionary = _new_w(await _build(SEED_A))
	var f0: int = Engine.get_process_frames()
	await _press(w, "esc")
	var f_esc: int = Engine.get_process_frames() - f0
	f0 = Engine.get_process_frames()
	await _press(w, "x")
	var f_x: int = Engine.get_process_frames() - f0
	var scr: String = _screen(w["node"])
	print("   Esc：等了 %d 幀｜x：等了 %d 幀、畫面頂列「%s」＝ tick %d／世界 %d" % [f_esc, f_x,
		scr.split("\n")[0].substr(0, 12), _screen_tick(scr), _tick(w["node"])])
	_check("P10 x 回來那一屏 ＝ 推進後（畫面 tick %d ＝ TICKS_PER_HOUR ＝ 世界 %d）" % [_screen_tick(scr), _tick(w["node"])],
		_screen_tick(scr) == WorldState.TICKS_PER_HOUR and _tick(w["node"]) == WorldState.TICKS_PER_HOUR)
	_check("P10【反向】Esc（不推進）⇒ 立刻回、一幀都不等（%d）" % f_esc, f_esc == 0)
	await _drop(w["node"])
	_cells_ran.append("P10")


# ══ P7：觀測不改物 ⇒ 同一串按鍵，**完全不讀世界**重放一次，終局 fp 相同 ══════════════════════════════
func _p7_observation(r: Dictionary) -> void:
	print("\n── P7 觀測不改物 ──")
	var node: Node = await _build(SEED_A)
	for k in r["keys"]:
		await PlayerRepl.press_on(node, PlayerRepl.keycode_for(String(k)))
	var fp_plain: String = _fp(node)
	await _drop(node)
	print("   觀測過的走法 fp %s｜不觀測重放 fp %s（%d 鍵）" % [String(r["fp_end"]).substr(0, 12), fp_plain.substr(0, 12), (r["keys"] as Array).size()])
	_check("P7 跑不跑 E2E 的觀測，同 seed 同按鍵 ⇒ fp 相同", fp_plain == String(r["fp_end"]) and fp_plain != "")
	_cells_ran.append("P7")
