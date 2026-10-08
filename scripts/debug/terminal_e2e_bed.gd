extends SceneTree
# @bed-kind: invariant
# ══ 終端 E2E 床（狀態驅動）：從畫面挑動作、按它印的鍵、驗世界真的照那句話變了 ══════════════════════
# spec：`docs/superpowers/specs/2026-10-06-terminal-e2e-state-driven-HOW.md`
#
# ★送鍵走 `PlayerRepl.press_on`（跟玩家 REPL 同一支；它等推進消化完才回 ⇒ 畫面＝結算後的世界）
# ★世界狀態唯讀走 `node._bridge`；belief 走 `query_memory_panel()`
# 格：P0 解析器｜P10 畫面不落後（開場 x＋反向 Esc）＋常駐（每一鍵）｜WALK 走 N 步（雙世界 A／B）
#     P1 母體地板｜P2 紅一｜P3 紅二｜P4 紅三｜P5 確定性｜P6 分叉 fp 相同｜P7 觀測不改物｜KNOWN 必須再現
# 除錯：E2E_DUMP=<步數> ⇒ 印那一步動作鍵之後與回主畫面之後的整屏
#
# ══ 解析器：畫面上的**三個**鍵位空間（spec 原文寫兩個；實測三個）══════════════════════════════════
#   (i)  目標動作：`─ 動作（` 區塊的 ` [n] 標籤 ▸（不可：原因）`（TextUiView.action_block；ACTION_DIGITS 靜態綁 id）
#   (ii) 強制事件回應：`   [A] 標籤`（text_ui_main 手刻；不變量 #10「按 A 做 B」的血證空間）
#   (iii) 自家隊動作：互動面板 `── 自家隊動作（N 項）` 底下 `[n]標籤` 與 `[n]標籤（不可）`（同一行多個、兩個空白分隔）
#   ★判哪個空間「現在吃數字鍵」：標題帶 `數字鍵在這一側` 的那一側

var _errors: int = 0
var _cells_ran: Array = []
const EXPECTED_CELLS: Array = ["P0", "P10", "WALK", "P1", "P2", "P3", "P4", "P5", "P6", "P7", "P11", "FOOTER", "E2", "E4", "BATTLE",
	"D1A", "D2B", "D3C", "D4D", "BS1", "BS2", "BS3", "V2MAP", "V2TGT", "V2R", "V2TAB", "V2PART", "F1", "F2", "F3", "M1", "M2", "M3", "S1", "S2", "S3", "S4",
	"FR1", "FR2", "FO", "FO2", "RS2", "RC3",
	"R5F1", "R5F2", "R5F3", "R5F4"]

# ══ 四個畫面缺陷（spec 2026-10-07 play-py-real-run-four-screen-defects §1）══════════════════════════
# ★格 a：事件流區也掃英文識別字 —— 抽取器與白名單用終端自驗 (d) 那一份（同一支，不抄）
const SELFCHECK: Script = preload("res://scripts/debug/terminal_selfcheck_bed.gd")
# ★格 b：玩家走法的每一屏不得出現的佔位句／內部備註（字表只在這裡一處）
const PLACEHOLDER_WORDS: Array = ["尚未提供", "尚未分頁", "Tick:"]
# ★格 b 反向：debug 走法下，同一批欄位的 debug 寫法必須出現（儀器不是被刪掉，只是不在玩家那條路上）
const DEBUG_COUNTERPART_WORDS: Array = ["未接出（票B）", "Tick:"]
# ★格 d：全域推進鍵 × 每一種從主畫面一鍵打得開的面板
const GLOBAL_ADVANCE_TOKENS: Array = ["x", "space", "g"]
const PANEL_OPEN_TOKENS: Array = ["t", "i", "p", "f", "o", "k", "u", "v"]
var _scan_a: Dictionary = {}   # 英文識別字 → 第一次看到它的那一行
var _scan_b: Dictionary = {}   # 佔位字 → 第一次看到它的那一行
var _scan_n: int = 0
# ★格 FO（spec 2026-10-07 absorb-at-cap ③）：每一次按鍵回來的那一屏，事件區的時間單調不減
var _fo_n: int = 0
var _fo_bad: Array = []

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
const BATTLE_MAX_KEYS: int = 6
const BATTLE_FIGHT_KEYS: int = 120   # ★投降被拒之後待機打到分出勝負的上限（BS2 打完那一段實測 12 拍）
const PANEL_HEADER: String = "─ 面板（接管畫面）"
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
#   ★這張表是**回報清單的機械形**（交件信逐條列給 systems），不是豁免：不在這裡的紅照紅
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
	_d1a_d2b_d3c(r1)
	await _d2b_reverse_and_boundary()
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
	await _footer_keys_do_what_they_say()
	await _e2_no_faction_alliance()
	await _e4_forced_label_marks(r1)
	await _battle_cells()
	await _d4d_global_keys_in_panels()
	await _bs_cells()
	await _f_cells()
	await _m_cells()
	await _s_cells()
	await _fr_cells()
	await _rs_cells()
	await _fo2_same_pass()
	await _r5_cells()
	_fo_judge()
	for k in KNOWN:
		_check("★已知條目這一輪真的再現：%s（不再現 ⇒ 世界修好了，回來拿掉這一條）" % k, _known_hit.has(k))
	var missing: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(String(c)):
			missing.append(String(c))
	_check("★到場點名：%d／%d（缺：%s）" % [_cells_ran.size(), EXPECTED_CELLS.size(), str(missing)], missing.is_empty())
	# ★★U0（spec 2026-10-07 terminal-ui-fixes，不變量 #11）：判決行要說出它**排除了什麼**
	#   ★KNOWN 是「本來會紅的格被登成已知」⇒ 只印 errors: 0 ＝ 讀卷面的人看到全綠（同 ui-flow「9 跑紅 4」那一病）
	var excluded: Array = _known_hit.keys()
	excluded.sort()
	#   ★名單裡的 `|` 換成 `／`：runner 用 `grep -E` 比 expect，ASCII `|` 在那裡是「或」⇒ expect 會被拆成幾段各自比
	var names: Array = excluded.map(func(x): return String(x).replace("|", "／"))
	print("\n=== terminal_e2e DONE === errors: %d｜已知紅排除: %d（%s）" % [_errors, excluded.size(), "、".join(PackedStringArray(names))])
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
			out["forced"].append({"space": "forced", "key": mf.get_string(1), "label": mf.get_string(2).strip_edges(), "enabled": true})
			continue
		if region == "self":
			for m in re_self.search_all(l):
				var lab: String = m.get_string(2).strip_edges()
				# ★reasons ②（spec 2026-10-07 invite-whole-team-inline-reasons）：不可的項帶原因「（不可：原因）」
				#   ⇒ 舊格式「（不可）」也認（修前那一屏），原因欄空
				var cut: int = lab.find("（不可")
				var en: bool = cut < 0
				var why: String = ""
				if not en:
					why = lab.substr(cut).trim_prefix("（不可").trim_prefix("：").trim_suffix("）")
					lab = lab.substr(0, cut)
				out["self"].append({"space": "self", "key": m.get_string(1),
					"label": lab, "enabled": en, "why": why})
		elif region == "action":
			var ma := re_act.search(l)
			if ma != null:
				out["actions"].append({"space": "action", "key": ma.get_string(1), "label": ma.get_string(2).strip_edges(),
					"enabled": ma.get_string(4) == "", "why": ma.get_string(4)})
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


# ★鍵列會折行（主畫面的鍵列是兩行：第二行以空白縮排開頭）⇒ 收「 鍵：」那一行＋它的續行
#   （第一版只讀第一行 ⇒ `[T]互動` 在第二行 ⇒ 永遠判「不在主畫面」，step 0 就 ABORT）
static func _hint(node: Node) -> String:
	var out: String = ""
	var on: bool = false
	for l in _screen(node).split("\n"):
		if l.begins_with(" 鍵："):
			on = true
			out = l
			continue
		if on and l.begins_with("     "):
			out += " " + l.strip_edges()
			continue
		on = false
	return out


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
	_scan_screen(scr)
	_fo_scan(scr, k)
	var wt: int = w["node"]._bridge.get_current_tick()
	var top: int = _screen_tick(scr)
	var stt: int = _status_tick(scr)
	w["p10_n"] = int(w["p10_n"]) + 1
	# ★★「畫面 tick ＝ 世界 tick」單獨沒有鑑別力（負對照實測：舊版 press_on 不等推進 ⇒ 回來時
	#   畫面與世界**都還在推進前** ⇒ 1240 次按鍵 0 次不等、照綠）⇒ 再加一條：回來那一刻推進必須已消化完
	var pending: bool = w["node"]._bridge.is_advancing()
	if top != wt or (stt != -1 and stt != wt) or pending:
		(w["p10_bad"] as Array).append({"label": String(w.get("label", "")),
			"msg": "key=%s（%s）畫面頂列 %d／狀態列 %d／世界 %d／推進未消化 %s" % [k, String(w.get("label", "")), top, stt, wt, str(pending)]})


# ★格 a／b：每一次按鍵回來的那一屏都掃（玩家走法；debug 走法下不判）
func _scan_screen(scr: String) -> void:
	if TextUiMain.truth_pane_enabled():
		return
	_scan_n += 1
	var ev: Array = _event_lines(scr)
	for x in SELFCHECK._bad_english("\n".join(PackedStringArray(ev))):
		if not _scan_a.has(String(x)):
			for l in ev:
				if String(l).contains(String(x)):
					_scan_a[String(x)] = String(l)
					break
	for wd in PLACEHOLDER_WORDS:
		if _scan_b.has(wd) or not scr.contains(String(wd)):
			continue
		for l in scr.split("\n"):
			if String(l).contains(String(wd)):
				_scan_b[wd] = String(l).strip_edges()
				break


func _press_all(w: Dictionary, keys: Array) -> void:
	for k in keys:
		await _press(w, String(k))


func _new_w(node: Node) -> Dictionary:
	return {"node": node, "keys": [], "p10_n": 0, "p10_bad": []}


# ★「在主畫面」＝ 鍵列是主畫面那一份 **且** 沒有接管畫面的面板
#   ★只看鍵列不夠（實測 step 8）：招募子選單（`── 招募 TeamN ──`）開著時，鍵列印的仍是**主畫面**那一份
#     ⇒ 只看鍵列會判「已回主畫面」，下一步的 [T] 打進招募層 ⇒ 候選集為空
static func _at_main(node: Node) -> bool:
	return _hint(node).contains(MAIN_HINT) and not _screen(node).contains(PANEL_HEADER)


func _to_main(w: Dictionary) -> bool:
	var battle_keys: int = 0
	for _i in range(TO_MAIN_MAX_ESC + BATTLE_MAX_KEYS + BATTLE_FIGHT_KEYS):
		if _at_main(w["node"]):
			return true
		if _screen(w["node"]).contains(TextUiView.BATTLE_TITLE):
			# ★戰鬥中（終端戰鬥區）：照**畫面上印的**鍵把仗打完 —— 鍵列有「F:投降」就投降，戰後「按任意鍵離開」就按 Space
			# ★票 T（2026-10-07）：多了「休息」⇒ N 21 → 22 ⇒ 走法第一次走到「攻擊」那一步 ⇒ 對方【拒絕投降】時仗還在打
			#   ⇒ 舊版一直按 F 直到鍵數用完 ⇒「按完 攻擊 之後回不到主畫面」ABORT
			#   ⇒ 投降被拒過一次之後改按待機（Space）讓仗分出勝負；鍵數預算放大到 BATTLE_FIGHT_KEYS
			var keys: String = _hint(w["node"])
			var refused: bool = bool(w.get("surrender_refused", false)) or _screen(w["node"]).contains("對方拒絕")
			if refused:
				w["surrender_refused"] = true
			await _press(w, "f" if keys.contains("F:投降") and not refused else "space")
			battle_keys += 1
			if battle_keys > BATTLE_FIGHT_KEYS:
				break
			continue
		await _press(w, "esc")
	return _at_main(w["node"])


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
			"encounter": "%s|%d|%s" % [str(st.encounter_active), st.teams.size(), str(st.last_encounter_outcome)],
			"encounter_result": str(st.last_encounter_result), "roster_self": "", "roster_others": str(others_roster)}
	return {
		"task": "%s|%s" % [pt.current_task, str(pt.move_target)],
		"belief": JSON.stringify(node._bridge.query_memory_panel()),
		"faction": "%d|%d" % [pt.faction_id, st.factions.size()],
		"res_self": str(pt.resources),
		"res_others": str(others_res),
		# ★票 T（2026-10-07）：再加 last_encounter_outcome —— 這一場若在這一步裡就打完，encounter_active 已回 false，
		#   而對象早就在 player_hostile_teams 裡（前面的步打過）⇒ 兩欄都分不出；結算記錄（BS2 唯一寫入點）分得出
		# ★戰鬥區第二輪（2026-10-07）：再加 encounter_initial_pop —— 對方【接受投降】時仗走 cleanup、不經結算（沒有 outcome），
		#   而 init_encounter 開打那一刻在雙方隊上寫了它 ⇒ 「這一步真的開過戰」的持久痕跡
		"encounter": "%s|%d|%s|%s|%d" % [str(st.encounter_active), st.teams.size(), str(st.player_hostile_teams), str(st.last_encounter_outcome), pt.encounter_initial_pop],   # ★攻擊 handler 寫 player_hostile_teams（打完之後 encounter_active 已回 false，這一欄才分得出有沒有打過）
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
	var d3_n: int = 0
	var d3_bad: Array = []
	var n: int = n_fixed
	var step: int = 0
	var dead_end: String = ""
	var dead_end_said: String = ""
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
		wa["label"] = label
		await _press(wa, String(pick["key"]))
		# ★打聽：effect 掛在選題之後那道令 ⇒ 走完子選單（選第 1 題）（systems 裁 2026-10-07）
		var expect_label: String = label
		if _hint(wa["node"]).contains(SUBMENU_INTEL_HINT):
			# ★選第一個**可選**的題目（打聽票 I2 之後問糧源灰掉帶原因 ⇒ 按它是被拒、不是打聽）
			var _tk: String = "1"
			for _ln in _screen(wa["node"]).split("\n"):
				var _mo := RegEx.create_from_string("^\\[(\\d)\\] ").search(_ln)
				if _mo != null and not _ln.contains("（不可："):
					_tk = _mo.get_string(1)
					break
			await _press(wa, _tk)
			# ★走完子選單 ⇒ 下令的是選題之後那一道（confirm_gather_intel）⇒ 結果句該說的是它的名字
			#   （名字取自唯一一份 label 表，不手寫）
			expect_label = PlayerApiMapper.action_label("confirm_gather_intel")
		var adv: int = _tick(wa["node"]) - t0
		var scr1: String = _screen(wa["node"])
		var ev0: Array = _event_lines(scr0)
		var new_ev: Array = _event_lines(scr1).filter(func(e): return not ev0.has(e))
		var result: String = _result_line(scr1)
		# ★格 c（D3 press-is-do）：這一屏若有這一道令的「指令」事件 ⇒ 結果行必須是同一句（不是「已排入」）
		# ★介面自己入列的令（SimBridge.UI_INTERNAL_COMMANDS，同一份表）不是玩家下的 ⇒ 不拿它比
		var internal_heads: Array = SimBridge.UI_INTERNAL_COMMANDS.map(func(nm): return "｜指令｜" + PlayerCommandApi.describe(String(nm), {}))
		var cmd_rows: Array = new_ev.filter(func(e): return String(e).contains("｜指令｜") \
			and internal_heads.filter(func(h): return String(e).contains(String(h))).is_empty())
		if not cmd_rows.is_empty():
			var ev_txt: String = String(cmd_rows[-1]).split("｜指令｜")[1].strip_edges()
			var res_txt: String = result.trim_prefix("✓ ").strip_edges()
			d3_n += 1
			# ★事件列被版面截到寬度（clip_to 不加記號）⇒ 比「結果行以那一截開頭」
			if ev_txt == "" or not res_txt.begins_with(ev_txt):
				d3_bad.append("step %d %s：結果行「%s」／事件流「%s」" % [step, label, result, ev_txt])
		var said: String = result
		if not new_ev.is_empty():
			said += "｜" + "｜".join(PackedStringArray(new_ev))
		if OS.get_environment("E2E_DUMP") == str(step):
			print("[E2E_DUMP] 動作鍵之後：")
			print(scr1)
		wa["label"] = ""
		var ok_main: bool = await _to_main(wa)
		var dead_said: String = _result_line(_screen(wa["node"]))
		if OS.get_environment("E2E_DUMP") == str(step):
			print("[E2E_DUMP] 回主畫面之後：")
			print(_screen(wa["node"]))
		var a_keys: Array = (wa["keys"] as Array).slice(prefix.size())
		var snap_a: Dictionary = _snap(wa["node"])
		# ★打聽那兩個動作：這一步實際問的題目（confirm 讀 player_state 的選題）⇒ 自知題不寫 belief，紅二不適用
		var intel_topic: String = String(wa["node"]._bridge._state.player_state.get("gather_intel_choice", "")) 			if label in [PlayerApiMapper.action_label("gather_intel"), PlayerApiMapper.action_label("confirm_gather_intel")] else ""
		var tick_a: int = _tick(wa["node"])
		p10_n += int(wa["p10_n"])
		p10_bad.append_array(wa["p10_bad"])
		pressed[String(pick["kind"])] = true
		await _drop(wa["node"])
		if not ok_main:
			# ★死路：已知的（KNOWN 裡有 `STUCK|<動作名>`）⇒ 走法在這裡結束、不算 ABORT，但那一條必須再現
			if KNOWN.has("STUCK|" + label):
				dead_end = label
				dead_end_said = dead_said
			else:
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
		# ★補齊量 ＝ A 這一步結束時的 tick − B 此刻的 tick（不是只看動作鍵那一下的 adv）：
		#   關子選單本身也可能是一道令（實測：交易子選單按 Esc ＝ 取消貿易，+1 tick）
		#   ⇒ 第一版只補 adv ⇒ A t7／B t6 ⇒ ABORT。補齊之後兩邊 tick 仍不同（B 已經超過 A）⇒ 照舊 ABORT
		var need: int = tick_a - _tick(wb["node"])
		# ★票 T（2026-10-07）：G 跳 tick 會被事件截斷（實測：攻擊那一步 A 打到 t181，B 按 G 124 停在 t60）
		#   ⇒ 照畫面再按，直到追上（或不再前進 ⇒ 交給下面 tick 不同的 ABORT 判）
		var tries: int = 0
		while need > 0 and tries < 8:
			var gk: Array = ["g"]
			for ch in str(need):
				gk.append(ch)
			gk.append("enter")
			var before_b: int = _tick(wb["node"])
			await _press_all(wb, gk)
			tries += 1
			if _tick(wb["node"]) == before_b:
				break
			need = tick_a - _tick(wb["node"])
		var b_keys: Array = (wb["keys"] as Array).slice(prefix.size())
		var snap_b: Dictionary = _snap(wb["node"])
		var tick_b: int = _tick(wb["node"])
		p10_n += int(wb["p10_n"])
		p10_bad.append_array(wb["p10_bad"])
		await _drop(wb["node"])
		var diff: Array = _diff_fields(snap_a, snap_b)
		var rec: Dictionary = {"step": step, "space": space, "label": label, "kind": String(pick["kind"]),
			"a_keys": a_keys, "b_keys": b_keys, "tick_a": tick_a, "tick_b": tick_b, "adv": adv,
			"result": result, "said": said, "new_ev": new_ev, "diff": diff, "expect_label": expect_label,
			"intel_topic": intel_topic}
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
		"p6_n": steps.size(), "unbound": unbound, "dead_end": dead_end, "dead_end_said": dead_end_said,
		"d3_n": d3_n, "d3_bad": d3_bad}


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
	if String(r["dead_end"]) != "":
		_known("STUCK", String(r["dead_end"]))
		print("   ★走法在已知死路結束（%s）⇒ 只走了 %d／%d 步｜那時結果行：%s" % [String(r["dead_end"]), steps.size(), int(r["n"]), String(r["dead_end_said"])])
	_check("P1 走滿 N 步或停在已知死路（%d／%d）" % [steps.size(), int(r["n"])],
		int(r["n"]) > 0 and (steps.size() == int(r["n"]) or String(r["dead_end"]) != ""))
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
	var p10_unknown: int = 0
	for b in r["p10_bad"]:
		if not _known("P10", String(b["label"])):
			p10_unknown += 1
			print("   ✗ " + String(b["msg"]))
	_check("P10 常駐：%d 次按鍵，畫面時間 ≠ 世界 tick 的 %d 次（已知以外 %d）" % [int(r["p10_n"]), (r["p10_bad"] as Array).size(), p10_unknown],
		int(r["p10_n"]) >= 1 and p10_unknown == 0)
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
		# ★被拒 ＝ 畫面帶可辨識的拒絕字樣 —— 詞表**唯一一份**在 PlayerApiMapper.REFUSAL_WORDS（結果句組字讀同一份）
		#   ★E3：accepted:false（對方不答應）也是被拒，不是成功（U1 之後它的結果句帶 DECLINED_WORD）
		var refused: bool = said.contains("✗") or PlayerApiMapper.REFUSAL_WORDS.any(func(w): return said.contains(String(w)))
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
		var want: String = String(s["expect_label"])
		if queued and not said.contains(want):
			if not _known("P2", label):
				p2_bad += 1
				_check("P2 step %d 按「%s」⇒ 結果句沒有說「%s」（%s）" % [int(s["step"]), label, want, said], false)
		# P3 紅二：說成功 ⇒ effect 那幾欄在 A−B 非空
		var self_knowledge: bool = InquirySystem.SELF_KNOWLEDGE_TOPICS.has(String(s.get("intel_topic", "")))
		if self_knowledge:
			print("   step %02d「%s」問的是自知題（%s）⇒ 不寫 belief、紅二不適用" % [int(s["step"]), label, String(s["intel_topic"])])
		if queued and not refused and eff != "" and not (EFFECT_FIELDS[eff] as Array).is_empty() and not self_knowledge:
			p3_n += 1
			var need: Array = EFFECT_FIELDS[eff]
			if not need.all(func(f): return diff.has(f)):
				if not _known("P3", label):
					p3_bad += 1
					_check("P3 step %d「%s」說成功（%s）而 effect=%s 的 %s 在 A−B 沒變（差異 %s）" % [int(s["step"]), label, said, eff, str(need), str(diff)], false)
		# P4 紅三：A−B 有變 ⇒ 結果句提到那個動作
		if not diff.is_empty() and not said.contains(want):
			if not _known("P4", label):
				p4_bad += 1
				_check("P4 step %d 世界變了（%s）而結果句沒說「%s」（%s）" % [int(s["step"]), str(diff), label, said], false)
		# P11 回報：沒被拒，而畫面只有「已排入」回音、沒有完成句
		#   ★結果行開頭帶 `✓ `（`_feedback_text`；終端 CP950 印不出它，看起來像一格空白）⇒ 先剝掉再比
		if queued and not refused and (s["new_ev"] as Array).is_empty() and String(s["result"]).trim_prefix("✓").strip_edges().begins_with("已排入"):
			p11[label] = true
	_check("P2 紅一：0 步錯（%d）" % p2_bad, p2_bad == 0)
	_check("P3 紅二：判了 %d 步、0 步錯（%d）" % [p3_n, p3_bad], p3_bad == 0)
	_check("P3 母體地板：至少判過 1 步（%d）" % p3_n, p3_n >= 1)
	_check("P4 紅三：0 步錯（%d）" % p4_bad, p4_bad == 0)
	# ★★U0②：P11 升判決格（原本只印不判）—— 不在 KNOWN 的每一個 ⇒ 紅
	var p11_bad: Array = []
	for lab in p11:
		if not _known("P11", String(lab)):
			p11_bad.append(String(lab))
	print("   P11 沒被拒、而畫面只有「已排入」回音、沒有完成句：%s（已知以外 %s）" % [str(p11.keys()), str(p11_bad)])
	_check("P11 每一道沒被拒的令都有完成句（已知以外缺 %d）" % p11_bad.size(), p11_bad.is_empty())
	_cells_ran.append("P11")
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


# ══ FOOTER（U4／E1 的常駐版）：面板頁腳寫的「[鍵]關閉／返回」，按下去就真的關／返回 ═══════════════════
# ★舊版頁腳寫「[T/Esc]關閉」而 T 在互動模式是強制回應的字母鍵 ⇒ 按 T 印「現在沒有要回應的事件」、面板不關
# ★母體 ＝ 畫面上真的印出來的頁腳（不手抄鍵表）；每一個鍵各開一次面板、按一次
func _footer_keys_do_what_they_say() -> void:
	print("\n── FOOTER 面板頁腳寫的鍵 ＝ 按下去會做的事 ──")
	var re := RegEx.new()
	re.compile("^── \\[([^\\]]+)\\](關閉|返回) ──$")
	var w: Dictionary = _new_w(await _build(SEED_A))
	await _press(w, "t")
	var footer: String = ""
	var keys: Array = []
	for l in _screen(w["node"]).split("\n"):
		var m := re.search(l)
		if m != null:
			footer = l
			for k in m.get_string(1).split("/"):
				keys.append(String(k).strip_edges())
	await _drop(w["node"])
	print("   互動面板頁腳：「%s」⇒ 鍵 %s" % [footer, str(keys)])
	_check("★母體地板：互動面板印得出頁腳、至少一個鍵（%d）" % keys.size(), keys.size() >= 1)
	var bad: Array = []
	for k in keys:
		var w2: Dictionary = _new_w(await _build(SEED_A))
		await _press(w2, "t")
		var before: bool = _screen(w2["node"]).contains("── 互動 ──")
		await _press(w2, String(k).to_lower())
		var after: bool = _screen(w2["node"]).contains("── 互動 ──")
		print("   按 %s：面板 %s → %s" % [k, "開" if before else "關", "開" if after else "關"])
		if not before or after:
			bad.append(String(k))
		await _drop(w2["node"])
	_check("FOOTER 頁腳寫的每一個鍵都真的關掉互動面板（沒做到：%s）" % str(bad), bad.is_empty())
	_cells_ran.append("FOOTER")


# ══ 四缺陷 a／b／c（spec §1）══════════════════════════════════════════════════════════════════════
func _d1a_d2b_d3c(r: Dictionary) -> void:
	print("\n── D1a 事件流區沒有英文識別字（自驗 (d) 同一支抽取器）｜掃了 %d 屏 ──" % _scan_n)
	for x in _scan_a:
		print("   ✗ %s ⇐ %s" % [x, _scan_a[x]])
	_check("★母體地板：格 a／b 掃過的屏數 ≥ 1（%d）" % _scan_n, _scan_n >= 1)
	_check("D1a 事件流區沒有英文識別字（命中 %d：%s）" % [_scan_a.size(), str(_scan_a.keys())], _scan_a.is_empty())
	# ★走法只碰得到一部分 kind ⇒ 全母體（WorldEvents.all_kinds()）逐一驗都有玩家短名（沒有的會被藏掉＝玩家少看一件事）
	var no_label: Array = WorldEvents.all_kinds().filter(func(k): return WorldEvents.kind_label(String(k)) == "")
	_check("D1a 事件 kind 全母體（%d 個）都有玩家短名（缺：%s）" % [WorldEvents.all_kinds().size(), str(no_label)], no_label.is_empty())
	_cells_ran.append("D1A")
	print("\n── D2b 玩家走法沒有佔位句（字表 %s）──" % str(PLACEHOLDER_WORDS))
	for wd in _scan_b:
		print("   ✗ %s ⇐ %s" % [wd, _scan_b[wd]])
	_check("D2b 玩家走法的每一屏都沒有佔位句（命中 %d：%s）" % [_scan_b.size(), str(_scan_b.keys())], _scan_b.is_empty())
	print("\n── D3c 結果行 ＝ 那一道令的完成句／被拒句（逐字比同屏事件流「指令」那一筆）──")
	for b in r["d3_bad"]:
		print("   ✗ " + String(b))
	_check("★母體地板：走法裡有令回來的屏 ≥ 1（%d）" % int(r["d3_n"]), int(r["d3_n"]) >= 1)
	_check("D3c 每一道令回來那一屏，結果行＝事件流那一句（%d／%d 不同）" % [(r["d3_bad"] as Array).size(), int(r["d3_n"])],
		(r["d3_bad"] as Array).is_empty())
	_cells_ran.append("D3C")


# ★格 b 反向＋邊界：①debug 走法下內部備註的 debug 寫法必須出現 ②有寫入者而值為 0 的欄（已知情報 0 個）玩家走法照印
func _d2b_reverse_and_boundary() -> void:
	OS.set_environment(TextUiMain.TRUTH_PANE_ENV, "1")
	var wd: Dictionary = _new_w(await _build(SEED_A))
	var seen: String = ""
	for _i in range(UiPages.PAGE_ORDER.size()):
		seen += _screen(wd["node"]) + "\n"
		await _press(wd, ".")
	await _drop(wd["node"])
	OS.set_environment(TextUiMain.TRUTH_PANE_ENV, "")
	var miss: Array = DEBUG_COUNTERPART_WORDS.filter(func(x): return not seen.contains(String(x)))
	print("\n── D2b【反向】debug 走法翻遍 %d 頁：debug 寫法 %s 缺 %s ──" % [UiPages.PAGE_ORDER.size(), str(DEBUG_COUNTERPART_WORDS), str(miss)])
	_check("D2b【反向】debug 走法下內部備註仍在（缺：%s）" % str(miss), miss.is_empty())
	# 邊界：記憶頁「已知情報：0 個對象」——有寫入者（_build_memory_lines）而值為 0 ⇒ 玩家走法必須照印
	var wp: Dictionary = _new_w(await _build(SEED_A))
	var pages: String = ""
	for _j in range(UiPages.PAGE_ORDER.size()):
		pages += _screen(wp["node"]) + "\n"
		await _press(wp, ".")
	await _drop(wp["node"])
	var zero_line: bool = pages.contains("已知情報：0 個對象")
	print("   邊界：玩家走法翻遍各頁，「已知情報：0 個對象」%s" % ("有印" if zero_line else "沒印"))
	_check("D2b【邊界】有寫入者而值為 0 的欄（已知情報 0 個）玩家走法照印", zero_line)
	_cells_ran.append("D2B")


# ══ 格 d：面板開著時按全域推進鍵 ⇒ 全域語意的句子，不是事件回應的句子（spec §1 D4）══════════════════
#   ★母體 ＝ 從主畫面一鍵打得開的每一種面板 × 每一個全域鍵；面板鍵列上【有列出】那個鍵 ⇒ 歸面板語意，不判
func _d4d_global_keys_in_panels() -> void:
	print("\n── D4d 面板 × 全域推進鍵 ──")
	var bad: Array = []
	var n: int = 0
	for op in PANEL_OPEN_TOKENS:
		for gk in GLOBAL_ADVANCE_TOKENS:
			var w: Dictionary = _new_w(await _build(SEED_A))
			await _press(w, String(op))
			var mode: String = String(w["node"]._current_mode_name())
			if mode == "main":
				await _drop(w["node"])
				continue
			var listed: String = "[%s]" % ("Space" if gk == "space" else String(gk).to_upper())
			if _hint(w["node"]).contains(listed):
				print("   %s 面板（%s）：鍵列有列出 %s ⇒ 面板語意，不判" % [op, mode, listed])
				await _drop(w["node"])
				continue
			var t0: int = _tick(w["node"])
			await _press(w, String(gk))
			var res: String = _result_line(_screen(w["node"]))
			var t1: int = _tick(w["node"])
			n += 1
			var ok: bool = res.contains(TextUiMain.GLOBAL_KEY_IN_PANEL_MSG) or t1 > t0
			print("   %s 面板（%s）按 %s ⇒ 結果「%s」｜tick %d→%d" % [op, mode, gk, res, t0, t1])
			if not ok:
				bad.append("%s／%s／%s：%s" % [op, mode, gk, res])
			await _drop(w["node"])
	_check("★母體地板：面板 × 全域鍵 至少判了 1 格（%d）" % n, n >= 1)
	_check("D4d 面板開著時按全域鍵 ⇒ 照推進或印「%s」（不得是事件回應／無作用句；錯 %d：%s）" % [
		TextUiMain.GLOBAL_KEY_IN_PANEL_MSG, bad.size(), str(bad)], bad.is_empty())
	_cells_ran.append("D4D")


# ══ BS：戰鬥區在打的時候要被看過（spec 2026-10-07 battle-screen-asserted-and-extortion-brake §票 BS）══════
const BS_BEATS: Array = ["space", "w", "space"]        # 進戰後 ≥3 拍不投降：待機／移動／待機
const BS_SIX: Array = ["兵力：", "── 主角狀態 ──", "── 裝備 ──", "── 目標 ──", "── 單位（", "── 戰報 ──", "── 戰場（"]
const BS_FIGHT_MAX: int = 120

# 主動攻擊同格的 NPC_ID（同 BATTLE① 的路）⇒ 回傳 w；進不了戰鬥 ⇒ {}
#   ★BS3 佈置：玩家 體力 1.0、對方領袖 體力 0.0 ⇒ 兩邊速度不同（encounter_system `_base_speed`）⇒ 計時不會同步重置
func _bs_enter(sd: int, uneven_speed: bool) -> Dictionary:
	var w: Dictionary = _new_w(await _build(sd))
	var node: Node = w["node"]
	if uneven_speed:
		var st: WorldState = node._bridge._state
		var pp: PersonData = st.persons.get(st.player_id)
		if pp != null:
			pp.attributes["體力"] = 1.0
		var nt: TeamData = st.teams.get(NPC_ID)
		if nt != null and st.persons.has(nt.leader_id):
			(st.persons[nt.leader_id] as PersonData).attributes["體力"] = 0.0
		# ★BS v2 Tab 格要 ≥ 2 個敵方單位：對方 4 個平民、武裝比例 0 ⇒ 只出領袖一個 ⇒ 比例 0.5 ⇒ 多 2 個匿名兵
		if nt != null:
			nt.armed_anon_ratio = 0.5
	await _press(w, "t")
	if not bool(parse_screen(_screen(node))["targets_active"]):
		await _press(w, "tab")
	await _press(w, "1")
	var atk_key: String = ""
	for a in parse_screen(_screen(node))["actions"]:
		if String(a["label"]) == PlayerApiMapper.action_label("attack") and bool(a["enabled"]):
			atk_key = String(a["key"])
	if atk_key == "":
		await _drop(node)
		return {}
	await _press(w, atk_key)
	if not _screen(node).contains(TextUiView.BATTLE_TITLE):
		await _drop(node)
		return {}
	return w


static func _bs_timers(scr: String) -> Array:
	var re := RegEx.new()
	re.compile("(\\d+) 分鐘後行動")   # ★BS v2 C
	return re.search_all(scr).map(func(m): return int(m.get_string(1)))


# ══ BS v2（spec §票 BS v2）：地圖代號／目標欄／R 一鍵／Tab／部位全名 ═══════════════════════════════
static func _battle_region(scr: String) -> String:
	return scr.split(TextUiView.BATTLE_TITLE)[-1].split("─ 事件（")[0]

static func _section(region: String, head: String) -> Array:
	var out: Array = []
	var on: bool = false
	for l in region.split("\n"):
		if String(l).begins_with(head):
			on = true
			continue
		if on and (String(l).begins_with("── ") or String(l).begins_with("─ ")):
			break
		if on:
			out.append(String(l))
	return out


func _bs_v2_cells(w: Dictionary) -> void:
	var node: Node = w["node"]
	var view = node._encounter_view
	var st: WorldState = node._bridge._state
	print("\n── BS v2 戰鬥區要能玩 ──")
	# V2MAP：地圖上的代號數 ＝ 列表行數 ＝ state 看得到的單位數
	var reg: String = _battle_region(_screen(node))
	var map_lines: Array = _section(reg, "── 戰場（")
	var map_codes: Array = []
	var re_c := RegEx.new()
	re_c.compile("[A-Za-z@]")
	for l in map_lines:
		# ★畫面外那一行帶方向鍵（「a（W 方向 8 格）」）⇒ 只取「代號（」；格線那幾行才逐字取
		if String(l).begins_with("畫面外："):
			for m in RegEx.create_from_string("([A-Za-z@])（").search_all(String(l)):
				map_codes.append(m.get_string(1))
			continue
		for m in re_c.search_all(String(l)):
			map_codes.append(m.get_string(0))
	var list_codes: Array = _section(reg, "── 單位（").filter(func(l): return RegEx.create_from_string("^[A-Za-z@] (我方|敵方) ").search(String(l)) != null) \
		.map(func(l): return String(l).substr(0, 1))
	var n_vis: int = view.visible_unit_indices(st).size()
	map_codes.sort(); list_codes.sort()
	print("   地圖代號 %s｜列表代號 %s｜state 看得到 %d 個" % [str(map_codes), str(list_codes), n_vis])
	print("   地圖：\n      " + "\n      ".join(PackedStringArray(map_lines)))
	_check("V2MAP 地圖代號 ＝ 列表代號 ＝ state 看得到的單位數（%d／%d／%d）" % [map_codes.size(), list_codes.size(), n_vis],
		map_codes == list_codes and map_codes.size() == n_vis and n_vis >= 1)
	_cells_ran.append("V2MAP")
	# 佈置：把敵人（最多兩個）搬到主角旁邊（看得到、在射程內）⇒ 目標欄／R／Tab 都有鑑別力
	var me: Dictionary = view._find_player_unit(st)
	var my_pos: Vector2i = me.get("pos", Vector2i.ZERO)
	var foes: Array = []
	for i in range(st.encounter_units.size()):
		var u: Dictionary = st.encounter_units[i]
		if int(u.get("team_id", -1)) != view._player_team_id(st) and view._unit_present(u, st):
			foes.append(i)
	var spots: Array = [my_pos + Vector2i(1, 0), my_pos + Vector2i(0, 1), my_pos + Vector2i(-1, 1)]
	for k in range(mini(foes.size(), 2)):
		(st.encounter_units[foes[k]] as Dictionary)["pos"] = spots[k]
	view._refresh_ui()
	await _press(w, "up")   # 一個不推進世界的鍵（換部位）⇒ 畫面重組
	var reg2: String = _battle_region(_screen(node))
	var tgt1: String = "\n".join(PackedStringArray(_section(reg2, "── 目標 ──")))
	print("   佈置後目標欄：%s" % tgt1.replace("\n", "｜"))
	_check("V2TGT 看得到敵人時目標欄非空（有代號、距離、瞄準部位）",
		RegEx.create_from_string("目標：[A-Z]（").search(tgt1) != null and tgt1.contains("距離") and tgt1.contains("瞄準："))
	_cells_ran.append("V2TGT")
	# V2TAB：Tab 換目標後目標欄改變（母體：看得到的敵人 ≥ 2）
	var n_foe_vis: int = view._visible_enemies(st).size()
	await _press(w, "tab")
	var tgt2: String = "\n".join(PackedStringArray(_section(_battle_region(_screen(node)), "── 目標 ──")))
	print("   看得到的敵人 %d 個｜Tab 之後目標欄：%s" % [n_foe_vis, tgt2.replace("\n", "｜")])
	_check("★V2TAB 母體地板：看得到的敵人 ≥ 2（%d）" % n_foe_vis, n_foe_vis >= 2)
	_check("V2TAB Tab 之後目標欄改變", tgt2 != tgt1 and tgt2.split("\n")[0] != tgt1.split("\n")[0])
	_cells_ran.append("V2TAB")
	# V2R：R 一鍵 ⇒ 戰報有一句含目標代號
	var code_m := RegEx.create_from_string("目標：([A-Z])（").search(tgt2)
	var tcode: String = code_m.get_string(1) if code_m != null else "?"
	var log0: Array = _section(_battle_region(_screen(node)), "── 戰報 ──")
	await _press(w, "r")
	var scr_r: String = _screen(node)
	var log1: Array = _section(_battle_region(scr_r), "── 戰報 ──") if scr_r.contains(TextUiView.BATTLE_TITLE) else []
	var new_lines: Array = log1.filter(func(l): return not log0.has(l))
	print("   R 打 %s ⇒ 戰報新增：%s" % [tcode, str(new_lines)])
	_check("V2R R 一鍵之後戰報有一句含目標代號 %s（新增 %d 句）" % [tcode, new_lines.size()],
		new_lines.any(func(l): return String(l).contains(tcode + "（")))
	_cells_ran.append("V2R")
	# V2PART：主角狀態每一行 ＝「部位全名：狀態全名」（逐字比名表；不截字）
	var bad: Array = []
	var body: Array = _section(_battle_region(_screen(node)), "── 主角狀態 ──").filter(func(l): return String(l).strip_edges() != "")
	var parts: Array = TeamUiHelper.BODY_PART_NAME.values()
	var stats: Array = TeamUiHelper.BODY_STATUS_NAME.values()
	for l in body:
		var kv: PackedStringArray = String(l).strip_edges().split("：")
		if kv.size() != 2 or not parts.has(kv[0]) or not stats.has(kv[1]):
			bad.append(String(l))
	print("   主角狀態 %d 行：%s" % [body.size(), str(body)])
	_check("V2PART 主角狀態每行逐字＝名表的部位全名：狀態全名（錯：%s）" % str(bad), body.size() >= 6 and bad.is_empty())
	_cells_ran.append("V2PART")


# ══ 戰鬥區第二輪（spec 2026-10-07 battle-start-visibility-and-r-feedback §1）══════════════════════════
static func _top_clock(scr: String) -> String:
	return String(scr.split("\n")[0]).split(" ｜ ")[0].strip_edges()


# ══ 移動指令（spec 2026-10-07 move-command-is-one-tick）══════════════════════════════════════════════
#   M ＝ 設目標＋一顆 tick；「走到抵達」另給一個明確的推進鍵（ARRIVE_TOKEN）
const ARRIVE_TOKEN: String = "l"

# 主畫面把游標往右移一格、按 M ⇒ 回傳 {w, target}
func _m_start(sd: int) -> Dictionary:
	var w: Dictionary = _new_w(await _build(sd))
	var node: Node = w["node"]
	var st: WorldState = node._bridge._state
	var pt: TeamData = st.teams[st.get_player_team_id()]
	var start: Vector2i = pt.tile_pos
	# ★_arrange 佈置了一個強制事件 ⇒ 第一顆 tick 之後互動面板會自動接管（那是對的行為），之後的推進鍵都會被擋成「面板開著」
	#   ⇒ 移動這幾格量的是「沒有事的時候」：先清掉；「途中有事」那一格自己再佈置一個
	st.set_player_forced_event({}, "")
	await _press(w, "d")
	var t0: int = _tick(node)
	await _press(w, "m")
	return {"w": w, "start": start, "target": pt.move_target, "t0": t0}


# ══ M 票 §2（藍圖 fda4636f1）：推進停點＝玩家相關事件（讀 WorldEvents 具名集合）＋休息兩段確認 ══════════════
# 佈置：E2E 那支 NPC 隊放到玩家旁邊一格、列進玩家的敵對名單、清掉強制事件
func _s_hostile_next_to_player(sd: int) -> Dictionary:
	var w: Dictionary = _new_w(await _build(sd))
	var st: WorldState = w["node"]._bridge._state
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = st.teams[ptid]
	st.set_player_forced_event({}, "")
	pt.fatigue = 0.6   # ★休息有前置檢查（不累就不給休息）⇒ 佈置一點疲勞
	var npc: TeamData = st.teams.get(NPC_ID)
	npc.tile_pos = pt.tile_pos + Vector2i(1, 0)
	npc.move_target = Vector2i(-1, -1)
	if not st.player_hostile_teams.has(NPC_ID):
		st.player_hostile_teams.append(NPC_ID)
	return {"w": w, "st": st, "pt": pt}


func _s_cells() -> void:
	print("\n── S1 停點清單裡每一種 kind 都會讓推進停下（讀 WorldEvents 具名集合，不手抄）──")
	var w0: Dictionary = _new_w(await _build(SEED_A))
	var st0: WorldState = w0["node"]._bridge._state
	var ptid0: int = st0.get_player_team_id()
	# ★動態讀（修前那個常數／函式還不存在 ⇒ 靜態引用會讓整支床 parse 失敗，紅就不是紅在這一格）
	var we_sc: Script = load("res://scripts/simulation/world_events.gd")
	var kinds: Array = we_sc.get_script_constant_map().get("ADVANCE_STOP_KINDS", [])
	var missed: Array = []
	for k in kinds:
		var seq0: int = st0.player_event_seq
		WorldEvents.emit(st0, String(k), [ptid0], false, {})
		var hit: Dictionary = we_sc.call("stop_event_since", st0, seq0)
		if hit.is_empty():
			missed.append(String(k))
	print("   停點 kind %s｜沒停的 %s" % [str(kinds), str(missed)])
	_check("★S1 母體地板：停點清單非空且含敵對逼近（%d）" % kinds.size(), kinds.size() >= 5 and kinds.has("hostile_adjacent"))
	_check("S1 清單裡每一種 kind 寫進玩家事件 ⇒ 推進停點認得（沒認得：%s）" % str(missed), missed.is_empty() and not kinds.is_empty())
	_check("S1【反向】看到新的隊伍不是停點", not kinds.has("new_team_spotted"))
	await _drop(w0["node"])
	# 整合：敵對隊就在旁邊 ⇒ Space 停在牠逼近那一刻、結果句有主詞
	var a: Dictionary = await _s_hostile_next_to_player(SEED_A)
	var wa: Dictionary = a["w"]
	var t0: int = _tick(wa["node"])
	await _press(wa, "space")
	var adv: int = _tick(wa["node"]) - t0
	var res: String = _result_line(_screen(wa["node"]))
	print("   敵對 Team%d 在旁邊、按 Space ⇒ 前進 %d tick（到隔日要 %d）｜結果「%s」" % [NPC_ID, adv, WorldState.TICKS_PER_DAY - t0 % WorldState.TICKS_PER_DAY, res])
	_check("S1 Space 停在敵對逼近那一刻（沒推到隔日）、結果句「停下：」有主詞（Team%d、格）" % NPC_ID,
		adv < WorldState.TICKS_PER_DAY - t0 % WorldState.TICKS_PER_DAY and res.contains("停下：") and res.contains("Team%d" % NPC_ID) and res.contains("格"))
	_cells_ran.append("S1")
	await _drop(wa["node"])
	print("\n── S2 沒有事件 ⇒ 推進照原長度 ──")
	var wb: Dictionary = _new_w(await _build(SEED_A))
	wb["node"]._bridge._state.set_player_forced_event({}, "")
	var tb0: int = _tick(wb["node"])
	await _press(wb, "x")
	var advb: int = _tick(wb["node"]) - tb0
	var want: int = WorldState.TICKS_PER_HOUR - tb0 % WorldState.TICKS_PER_HOUR
	print("   按 X ⇒ 前進 %d tick（到整點要 %d）" % [advb, want])
	_check("S2 沒有玩家相關事件 ⇒ X 推滿到整點（%d／%d）" % [advb, want], advb == want)
	_cells_ran.append("S2")
	await _drop(wb["node"])
	print("\n── S3 旁邊有敵對時按休息：第一次只警告、時間不動；第二次才執行 ──")
	var c: Dictionary = await _s_hostile_next_to_player(SEED_A)
	var wc: Dictionary = c["w"]
	var ptc: TeamData = c["pt"]
	await _press(wc, "t")
	var p: Dictionary = parse_screen(_screen(wc["node"]))
	if not bool(p["self_active"]):
		await _press(wc, "tab")
		p = parse_screen(_screen(wc["node"]))
	var rest_key: String = ""
	for s0 in p["self"]:
		if String(s0["label"]) == PlayerApiMapper.action_label("rest"):
			rest_key = String(s0["key"])
	_check("★S3 母體地板：自家隊動作區有「休息」（鍵 %s）" % rest_key, rest_key != "")
	if rest_key != "":
		var tc0: int = _tick(wc["node"])
		await _press(wc, rest_key)
		var r1: String = _result_line(_screen(wc["node"]))
		var tc1: int = _tick(wc["node"])
		await _press(wc, rest_key)
		var tc2: int = _tick(wc["node"])
		print("   第一次按休息 ⇒ 結果「%s」｜tick %d→%d｜第二次 ⇒ tick %d｜task %s" % [r1, tc0, tc1, tc2, ptc.current_task])
		_check("S3 第一次只有警告（「確定要休息」、帶主詞）、時間不動", r1.contains("確定要休息") and r1.contains("Team%d" % NPC_ID) and tc1 == tc0)
		_check("S3 第二次才執行（時間前進、隊伍在休息）", tc2 > tc1 and ptc.current_task == TeamData.TASK_REST)
		_cells_ran.append("S3")
		print("\n── S4 休息中敵對逼近 ⇒ 推進停下、結果句有主詞、不自動取消休息 ──")
		await _to_main(wc)
		var td0: int = _tick(wc["node"])
		await _press(wc, "space")
		var r4: String = _result_line(_screen(wc["node"]))
		print("   休息中按 Space ⇒ 前進 %d tick｜結果「%s」｜task %s" % [_tick(wc["node"]) - td0, r4, ptc.current_task])
		_check("S4 休息中敵對逼近 ⇒ 停下帶主詞、休息沒被取消", r4.contains("停下：") and r4.contains("Team%d" % NPC_ID) and ptc.current_task == TeamData.TASK_REST)
		_cells_ran.append("S4")
	else:
		_cells_ran.append_array(["S3", "S4"])
	await _drop(wc["node"])


# ══ 用戶第二手（spec 2026-10-07 absorb-at-cap）③：事件流按 tick 排序（同 tick 照寫入序）═════════════════
# ★事件區每一行「第 D 天 HH:MM｜來源｜句子」⇒ 由上到下時間不得倒退
static func _feed_ticks(screen: String) -> Array:
	var re := RegEx.create_from_string("^第 (\\d+) 天 (\\d\\d):(\\d\\d)｜")
	var out: Array = []
	for l in _event_lines(screen):
		var m := re.search(String(l))
		if m != null:
			out.append((int(m.get_string(1)) - 1) * WorldState.TICKS_PER_DAY 				+ int(m.get_string(2)) * WorldState.TICKS_PER_HOUR + int(m.get_string(3)) * WorldState.TICKS_PER_HOUR / PlayerApiMapper.MINUTES_PER_HOUR)
	return out


func _fo_scan(screen: String, k: String) -> void:
	var ts: Array = _feed_ticks(screen)
	if ts.size() < 2:
		return
	_fo_n += 1
	for i in range(1, ts.size()):
		if int(ts[i]) < int(ts[i - 1]):
			if _fo_bad.size() < 5:
				_fo_bad.append("key=%s：%s" % [k, "／".join(PackedStringArray(_event_lines(screen)))])
			else:
				_fo_bad.append("…")
			return


func _fo_judge() -> void:
	print("\n── FO 事件流時間單調不減（每一次按鍵回來的那一屏；事件區 ≥2 行才算）──")
	for b in _fo_bad.slice(0, 5):
		print("   倒退：" + String(b))
	_check("★FO 母體地板：驗過的屏數 > 0（%d）" % _fo_n, _fo_n > 0)
	_check("FO 事件區由上到下時間不倒退（%d 屏倒退／%d 屏）" % [_fo_bad.size(), _fo_n], _fo_bad.is_empty())
	_cells_ran.append("FO")


# ★FO2：用戶那一屏的形狀 ——「13:00 找上門」排在「12:08 移動到」前面
#   ★機制：一次推進步（tick_step）最多吃一小時 ⇒ 同一個讀取回合裡，世界事件先寫、指令結果後寫；
#     指令結果的 tick＝它被消費的那一顆（較早）⇒ 照寫入順序排就倒退
#   ★走法每道令只推一顆 ⇒ 走不到這個形狀（FO 修前 7040 屏 0 倒退）⇒ 這一格在【讀者層】佈置：
#     放一筆「較早被消費、還沒被讀」的指令結果 ＋ 一筆現在的世界事件，按 X 讓同一個讀取回合讀到兩者
func _fo2_same_pass() -> void:
	print("\n── FO2 同一個讀取回合讀到「較早的指令結果」與「較晚的世界事件」⇒ 事件區仍按時間排 ──")
	var w: Dictionary = _new_w(await _build(SEED_A))
	var node: Node = w["node"]
	var st: WorldState = node._bridge._state
	st.set_player_forced_event({}, "")
	var ptid: int = st.get_player_team_id()
	await _press(w, "x")   # 先推一點時間，讓「較早」有地方放
	var t: int = st.world.current_tick
	st.command_results.append({"tick": t - 1, "seq": 1 << 30, "ok": true, "name": "move_to",
		"text": "FO2 較早被消費的指令結果"})
	WorldEvents.emit(st, "hostile_adjacent", [NPC_ID, ptid], false, {"dist": 1})
	# ★推 5 顆（G 5）不推整點：結果句壽命 RESULT_TTL_TICKS（60）⇒ 推滿一小時的話 t−1 那一筆在讀到之前就過期被清掉
	await _press_all(w, ["g", "5", "enter"])
	var ev: Array = _event_lines(_screen(node))
	var ts: Array = _feed_ticks(_screen(node))
	var mono: bool = true
	for i in range(1, ts.size()):
		if int(ts[i]) < int(ts[i - 1]):
			mono = false
	print("   事件區：\n      " + "\n      ".join(PackedStringArray(ev)))
	var both: bool = "\n".join(PackedStringArray(ev)).contains("FO2 較早") and "\n".join(PackedStringArray(ev)).contains("逼近")
	_check("★FO2 母體地板：兩筆都上了事件區", both)
	_check("FO2 事件區由上到下時間不倒退", mono and both)
	_cells_ran.append("FO2")
	await _drop(node)


# ══ 用戶第二手 ①（藍圖 fda4636f1：只留驗證格）：強制事件回應結算後結果行＝真結果句 ═══════════════════
# ★每一種強制事件 × 畫面上印的每一個回應字母：按下 ⇒ 結果行＝這一道令在 command_results 的那一句（含被拒原因），不是「已排入」
const FR_KINDS: Array = ["diplomacy", "extort", "join_request", "aid_request"]

func _fr_arm(st: WorldState, kind: String) -> void:
	var pt: TeamData = st.teams[st.get_player_team_id()]
	var evt: Dictionary = {"action": kind, "from_id": NPC_ID, "team_id": pt.team_id}
	match kind:
		"diplomacy": evt["proposal"] = FORCED_PROPOSAL
		"extort": evt["amount"] = 10.0
		"aid_request": evt["amount"] = 5.0
	st.set_player_forced_event(evt, "fr_%s" % kind)


# 開互動面板、回傳畫面上的強制回應清單
func _fr_open(w: Dictionary) -> Array:
	await _press(w, "t")
	return parse_screen(_screen(w["node"]))["forced"]


# 按那一個字母 ⇒ 回 [結果行, 這一道令的真結果句]
func _fr_press(w: Dictionary, key: String) -> Array:
	var st: WorldState = w["node"]._bridge._state
	var seq0: int = 0
	for row in st.command_results:
		seq0 = maxi(seq0, int(row.get("seq", 0)))
	await _press(w, key)
	var truth: String = ""
	for row in st.command_results:
		if int(row.get("seq", 0)) > seq0 and String(row.get("name", "")) == "respond_to_forced":
			truth = String(row.get("text", ""))
	return [_result_line(_screen(w["node"])), truth]


static func _fr_same(res: String, truth: String) -> bool:
	var r: String = res.trim_prefix("✓ ").trim_prefix("✗ ").strip_edges()
	if r == "" or truth == "" or r.begins_with("已排入"):
		return false
	return r == truth or truth.begins_with(r.trim_suffix("…"))


func _fr_cells() -> void:
	print("\n── FR1 每一種強制事件 × 每一個回應：按下之後結果行＝那一道令的真結果句（不是「已排入」）──")
	var total: int = 0
	var bad: Array = []
	for kind in FR_KINDS:
		var w0: Dictionary = _new_w(await _build(SEED_A))
		_fr_arm(w0["node"]._bridge._state, String(kind))
		var opts: Array = await _fr_open(w0)
		await _drop(w0["node"])
		for i in range(opts.size()):
			var w: Dictionary = _new_w(await _build(SEED_A))
			_fr_arm(w["node"]._bridge._state, String(kind))
			var fs: Array = await _fr_open(w)
			var pair: Array = await _fr_press(w, String(fs[i]["key"]))
			total += 1
			print("   %s [%s]%s ⇒ 結果行「%s」｜真結果「%s」" % [kind, fs[i]["key"], fs[i]["label"], pair[0], pair[1]])
			if not _fr_same(String(pair[0]), String(pair[1])):
				bad.append("%s [%s]%s" % [kind, fs[i]["key"], fs[i]["label"]])
			await _drop(w["node"])
	_check("★FR1 母體地板：四種強制事件都有回應可按（共 %d 個）" % total, total >= FR_KINDS.size() * 2)
	_check("FR1 每一個回應按下之後結果行＝真結果句（不對：%s）" % str(bad), bad.is_empty() and total > 0)
	_cells_ran.append("FR1")
	print("\n── FR2 人口滿上限、接受求投靠 ⇒ 結果行說「隊伍已滿，無法收留」、人口不變 ──")
	var wf: Dictionary = _new_w(await _build(SEED_A))
	var stf: WorldState = wf["node"]._bridge._state
	var ptf: TeamData = stf.teams[stf.get_player_team_id()]
	var cap: int = FactionAISystem.effective_pop_cap(stf, ptf)
	if cap - ptf.population + 1 > 0:
		AnonTierSystem.add_anon(ptf, AnonCohort.TIER_PLEB, cap - ptf.population + 1)
	var pop0: int = ptf.population
	_check("★FR2 母體地板：隊伍真的滿了（%d／%d）" % [pop0, FactionAISystem.effective_pop_cap(stf, ptf)], pop0 >= FactionAISystem.effective_pop_cap(stf, ptf))
	_fr_arm(stf, "join_request")
	var ff: Array = await _fr_open(wf)
	var acc: String = ""
	for f in ff:
		if String(f["label"]).contains("收留"):
			acc = String(f["key"])
			break
	_check("★FR2 母體地板：畫面有「收留」那個回應（鍵 %s）" % acc, acc != "")
	if acc != "":
		var pr: Array = await _fr_press(wf, acc)
		print("   按收留 ⇒ 結果行「%s」｜人口 %d → %d" % [pr[0], pop0, ptf.population])
		_check("FR2 結果行說「隊伍已滿，無法收留」、人口不變", String(pr[0]).contains("隊伍已滿") and ptf.population == pop0)
	_cells_ran.append("FR2")
	await _drop(wf["node"])


# ══ reasons ②（spec 2026-10-07 invite-whole-team-inline-reasons-stress-visible）：動作清單（不可）後印引擎短原因 ══════
# ★原因逐字＝引擎 disabled_reason（放不下時以「…」結尾、是它的前綴）；按下去結果行印完整原因
static func _why_ok(why: String, reason: String) -> bool:
	if why == "" or reason == "":
		return false
	return why == reason or (why.ends_with("…") and reason.begins_with(why.trim_suffix("…")))


func _rs_cells() -> void:
	print("\n── RS2 自家隊動作每一個（不可）都帶引擎原因；按下去結果行印完整原因 ──")
	var w: Dictionary = _new_w(await _build(SEED_A))
	var node: Node = w["node"]
	await _press(w, "t")
	await _press(w, "?")   # ★F2 之後不可的項預設折疊 ⇒ 展開再看
	var p: Dictionary = parse_screen(_screen(node))
	var eng: Dictionary = {}
	for sa in node._interact_action_split()["self"]:
		eng[String(sa.get("label", sa.get("action_id", "")))] = String(sa.get("disabled_reason", ""))
	var dis: Array = (p["self"] as Array).filter(func(x): return not bool(x["enabled"]))
	var bad: Array = []
	for d in dis:
		var reason: String = String(eng.get(String(d["label"]), ""))
		print("   [%s]%s ⇒ 畫面原因「%s」｜引擎「%s」" % [d["key"], d["label"], d["why"], reason])
		if not _why_ok(String(d["why"]), reason):
			bad.append(String(d["label"]))
	_check("★RS2 母體地板：自家隊動作有（不可）的項（%d）" % dis.size(), dis.size() > 0)
	_check("RS2 每一個（不可）都帶原因、逐字＝引擎 disabled_reason（不對：%s）" % str(bad), bad.is_empty() and dis.size() > 0)
	if dis.size() > 0:
		if not bool(p["self_active"]):
			await _press(w, "tab")
		var d0: Dictionary = dis[0]
		await _press(w, String(d0["key"]))
		var res: String = _result_line(_screen(node))
		var full: String = String(eng.get(String(d0["label"]), ""))
		print("   按 [%s]%s ⇒ 結果行「%s」" % [d0["key"], d0["label"], res])
		_check("RS2 按下（不可）的項 ⇒ 結果行印完整原因", full != "" and res.contains(full))
	_cells_ran.append("RS2")
	await _drop(node)
	print("\n── RC3 招募空集合說為什麼：對象只有領袖一人 ⇒「TeamN 只有領袖一人，招募挖不到人」──")
	var wr: Dictionary = _new_w(await _build(SEED_A))
	var str_: WorldState = wr["node"]._bridge._state
	str_.set_player_forced_event({}, "")
	var npc: TeamData = str_.teams[NPC_ID]
	AnonTierSystem.remove_anon(npc, AnonCohort.TIER_PLEB, AnonTierSystem.tier_count(npc, AnonCohort.TIER_PLEB))
	print("   佈置：Team%d 人口 %d" % [NPC_ID, npc.population])
	await _press(wr, "t")
	var pr: Dictionary = parse_screen(_screen(wr["node"]))
	var tk: String = ""
	for t in pr["targets"]:
		if String(t["label"]).contains("Team%d" % NPC_ID):
			tk = String(t["key"])
	_check("★RC3 母體地板：可互動目標有 Team%d（鍵 %s），人口 1" % [NPC_ID, tk], tk != "" and npc.population == 1)
	if tk != "":
		if not bool(pr["targets_active"]):
			await _press(wr, "tab")
		await _press(wr, tk)
		await _press(wr, TextUiView.key_for("recruit"))
		var scr: String = _screen(wr["node"])
		var hit: String = ""
		for l in scr.split("\n"):
			if String(l).contains("招募"):
				hit += String(l).strip_edges() + "／"
		print("   按招募 ⇒ %s" % hit)
		_check("RC3 畫面說出對象與原因（Team%d 只有領袖一人）、不是「無可招募對象」" % NPC_ID,
			scr.contains("Team%d 只有領袖一人" % NPC_ID) and not scr.contains("無可招募對象"))
	_cells_ran.append("RC3")
	await _drop(wr["node"])


# ══ 友善度 F1–F4（spec 2026-10-07 round5-friendliness-convergence）══════════════════════════════════════
static var LETTER_NO_RESPONSE: String = String(load("res://scripts/ui/text_ui_main.gd").get_script_constant_map().get("LETTER_NO_RESPONSE_MSG", "現在沒有要回應的事件"))   # 讀 UI 那一份
const R5_FIRST3_ANCHOR: String = "─ 你現在能做的"
const R5_FOLD_HEAD: String = "另有 "
const R5_FOLD_TAIL: String = " 個暫時不能做（按 ? 展開看原因）"


static func _r5_first3(screen: String) -> Array:
	var out: Array = []
	var on: bool = false
	var re := RegEx.create_from_string("^ \\[([^\\]]+)\\] (.+)$")
	for l in screen.split("\n"):
		if l.begins_with(R5_FIRST3_ANCHOR):
			on = true
			continue
		if on:
			var m := re.search(l)
			if m == null:
				break
			out.append({"key": m.get_string(1), "text": m.get_string(2)})
	return out


static func _r5_self_lines(screen: String) -> Array:
	var out: Array = []
	var on: bool = false
	for l in screen.split("\n"):
		if l.begins_with("── 自家隊動作"):
			on = true
			continue
		if on and (l.begins_with("── ") or l.begins_with("─ ")):
			break
		if on:
			out.append(l)
	return out


func _r5_open_self(w: Dictionary) -> void:
	await _press(w, "t")
	if not bool(parse_screen(_screen(w["node"]))["self_active"]):
		await _press(w, "tab")


func _r5_cells() -> void:
	print("\n── R5F1 主畫面最上方三行「你現在能做的」：每行一鍵一句、每個鍵按下有效 ──")
	var w1: Dictionary = _new_w(await _build(SEED_A))
	w1["node"]._bridge._state.set_player_forced_event({}, "")
	await _to_main(w1)
	var f3: Array = _r5_first3(_screen(w1["node"]))
	print("   三行：%s" % str(f3))
	await _drop(w1["node"])
	_check("R5F1 首屏有「你現在能做的」三行（%d）" % f3.size(), f3.size() == 3)
	var dead: Array = []
	for row in f3:
		var w1b: Dictionary = _new_w(await _build(SEED_A))
		w1b["node"]._bridge._state.set_player_forced_event({}, "")
		await _to_main(w1b)
		var scr0: String = _screen(w1b["node"])
		await _press(w1b, String(row["key"]).to_lower())
		var res: String = _result_line(_screen(w1b["node"]))
		if res.contains("無作用") or res.contains(LETTER_NO_RESPONSE) or _screen(w1b["node"]) == scr0:
			dead.append("%s（%s）" % [row["key"], res])
		await _drop(w1b["node"])
	_check("R5F1 三行的每個鍵按下去都有效（無效：%s）" % str(dead), dead.is_empty() and f3.size() == 3)
	_cells_ran.append("R5F1")

	print("\n── R5F2 自家隊動作：能做的排前、不可的折疊成一行、鍵號不漂移、按 ? 展開帶原因 ──")
	var w2: Dictionary = _new_w(await _build(SEED_A))
	var node2: Node = w2["node"]
	await _r5_open_self(w2)
	var eng: Array = node2._interact_action_split()["self"]
	# ★折疊以【這一頁】為單位：鍵號是頁內位置（靜態，不變量 #10），超過 9 項分頁 ⇒ 第一頁＝引擎前 9 項
	var n_dis: int = 0
	for a in eng.slice(0, 9):
		if not bool(a.get("enabled", true)):
			n_dis += 1
	var sl: Array = _r5_self_lines(_screen(node2))
	var items: Array = parse_screen(_screen(node2))["self"]
	var first_dis: int = -1
	var last_en: int = -1
	for i in range(items.size()):
		if bool(items[i]["enabled"]):
			last_en = i
		elif first_dis < 0:
			first_dis = i
	var fold_line: String = ""
	for l in sl:
		if String(l).contains(R5_FOLD_TAIL):
			fold_line = String(l).strip_edges()
	var keys_ok: bool = true
	for it in items:
		var k: int = int(it["key"]) - 1
		if k < 0 or k >= eng.size() or String(eng[k].get("label", "")) != String(it["label"]):
			keys_ok = false
	print("   引擎 %d 項（不可 %d）｜畫面 %s｜折疊行「%s」" % [eng.size(), n_dis, str(items.map(func(x): return "%s%s%s" % [x["key"], x["label"], "" if x["enabled"] else "×"])), fold_line])
	_check("★R5F2 母體地板：這一頁有可做也有不可的項", n_dis > 0 and n_dis < mini(9, eng.size()))
	_check("R5F2 收起時畫面上沒有不可的項（全折進一行）", first_dis < 0)
	_check("R5F2 折疊行「另有 %d 個暫時不能做（按 ? 展開看原因）」" % n_dis, fold_line == R5_FOLD_HEAD + str(n_dis) + R5_FOLD_TAIL)
	_check("R5F2 鍵號＝引擎那一項（不因排序折疊漂移）", keys_ok and items.size() > 0)
	await _press(w2, "?")
	var items2: Array = parse_screen(_screen(node2))["self"]
	var en_seen_after_dis: bool = false
	var seen_dis: bool = false
	var dis_n2: int = 0
	var dis_with_why: int = 0
	for it2 in items2:
		if not bool(it2["enabled"]):
			seen_dis = true
			dis_n2 += 1
			if String(it2.get("why", "")) != "":
				dis_with_why += 1
		elif seen_dis:
			en_seen_after_dis = true
	print("   按 ? 之後：%s" % str(items2.map(func(x): return "%s%s%s" % [x["key"], x["label"], "" if x["enabled"] else "×"])))
	_check("R5F2 展開後不可的項全出現（%d／%d）、都帶原因（%d）、仍排在可做的後面" % [dis_n2, n_dis, dis_with_why],
		dis_n2 == n_dis and dis_with_why == n_dis and not en_seen_after_dis)
	_cells_ran.append("R5F2")

	print("\n── R5F3 拒絕句帶主詞與（有則）下一步：「<動作>不行：<原因>；可以先做 <動作>」──")
	var bad3: Array = []
	var n_hint: int = 0
	for it3 in items2:
		if bool(it3["enabled"]):
			continue
		var a3: Dictionary = eng[int(it3["key"]) - 1]
		var hint: String = String(a3.get("hint", ""))
		if hint != "":
			n_hint += 1
		var w3: Dictionary = _new_w(await _build(SEED_A))
		await _r5_open_self(w3)
		await _press(w3, String(it3["key"]))
		var res3: String = _result_line(_screen(w3["node"])).trim_prefix("✗ ").trim_prefix("✓ ")
		var want: String = "%s不行：%s" % [a3.get("label", ""), a3.get("disabled_reason", "")]
		if hint != "":
			want += "；可以先做 %s" % PlayerApiMapper.action_label(hint)
		print("   按 [%s]%s ⇒「%s」" % [it3["key"], it3["label"], res3])
		if res3 != want:
			bad3.append("%s：「%s」≠「%s」" % [it3["label"], res3, want])
		await _drop(w3["node"])
	_check("R5F3 每個不可的項按下去，結果行＝主詞＋原因＋（有則）下一步（不對：%s）" % str(bad3), bad3.is_empty() and dis_n2 > 0)
	print("   （其中引擎給了下一步的 %d 項）" % n_hint)
	_cells_ran.append("R5F3")
	await _drop(node2)

	print("\n── R5F4 鍵列只印當下有效的鍵：互動面板沒有找上門的事 ⇒ 不印回應字母；有 ⇒ 印 ──")
	var w4: Dictionary = _new_w(await _build(SEED_A))
	w4["node"]._bridge._state.set_player_forced_event({}, "")
	await _press(w4, "t")
	var hint4: String = _hint(w4["node"])
	await _drop(w4["node"])
	var w4b: Dictionary = _new_w(await _build(SEED_A))
	await _press(w4b, "t")
	var hint4b: String = _hint(w4b["node"])
	await _drop(w4b["node"])
	print("   沒事：%s\n   有事：%s" % [hint4, hint4b])
	_check("R5F4 沒有找上門的事 ⇒ 鍵列不印回應字母那一項", not hint4.contains("回應"))
	_check("R5F4 有找上門的事 ⇒ 鍵列印回應字母那一項", hint4b.contains("回應"))
	_cells_ran.append("R5F4")


func _m_cells() -> void:
	print("\n── M1 M ＝ 設目標＋一顆 tick（不是一路推到抵達）──")
	var a: Dictionary = await _m_start(SEED_A)
	var w: Dictionary = a["w"]
	var node: Node = w["node"]
	var st: WorldState = node._bridge._state
	var pt: TeamData = st.teams[st.get_player_team_id()]
	var adv: int = _tick(node) - int(a["t0"])
	var res: String = _result_line(_screen(node))
	print("   目標 %s｜按 M 之後世界前進 %d tick｜人在 %s｜結果「%s」" % [str(a["target"]), adv, str(pt.tile_pos), res])
	_check("★M 母體地板：按 M 之後真的有目標（%s）" % str(a["target"]), a["target"] != Vector2i(-1, -1))
	_check("M1 按 M 世界只前進 1 tick（%d）" % adv, adv == 1)
	_check("M1 結果行說預計多久（「預計 N 分鐘」）", res.contains("預計") and res.contains("分鐘"))
	_cells_ran.append("M1")
	print("\n── M2 新鍵（%s）一路走到抵達；★途中有強制事件 ⇒ 停在事件那一刻 ──" % ARRIVE_TOKEN.to_upper())
	var keys_listed: bool = _hint(node).contains("[%s]" % ARRIVE_TOKEN.to_upper())
	var tgt: Vector2i = a["target"]
	# ★途中遇到既有的停點（看到新的隊伍／事件）就停 ⇒ 每一次停都要說原因（「途中：…」）；再按一次繼續，直到抵達
	var mid_bad: Array = []
	var res2: String = ""
	for _k in range(8):
		await _press(w, ARRIVE_TOKEN)
		res2 = _result_line(_screen(node))
		print("   按 %s ⇒ 人在 %s（目標 %s）｜結果「%s」" % [ARRIVE_TOKEN.to_upper(), str(pt.tile_pos), str(tgt), res2])
		if pt.tile_pos == tgt:
			break
		if not res2.contains("途中："):
			mid_bad.append(res2)
	print("   鍵列有 [%s]：%s" % [ARRIVE_TOKEN.to_upper(), str(keys_listed)])
	_check("M2 鍵位說明列出走到抵達那一鍵 [%s]" % ARRIVE_TOKEN.to_upper(), keys_listed)
	_check("M2 途中每一次停下都說原因（「途中：…」；錯 %s）" % str(mid_bad), mid_bad.is_empty())
	_check("M2 一路走到抵達、結果行「抵達 (q,r)」", pt.tile_pos == tgt and res2.contains("抵達 (%d,%d)" % [tgt.x, tgt.y]))
	# 停點來源：強制事件【到達】是推進的停點（快照 → 到達 → 比對出 forced_event_arrived）
	#   ★不在床裡從按鍵佈置：按鍵之前佈置的事件已經在快照裡（不是「途中到達」），而一步 60 tick 內它會逾時
	# ★M §2：停點改讀玩家事件匯流排（_diff_events 那兩段已退場）⇒ 強制事件經 setter 寫入匯流排 ⇒ stop_event_since 認得
	var seq_m2: int = st.player_event_seq
	st.set_player_forced_event({"action": "diplomacy", "from_id": NPC_ID, "proposal": FORCED_PROPOSAL}, "fe_m2")
	var hit_m2: Dictionary = WorldEvents.stop_event_since(st, seq_m2)
	var evs: Array = [String(hit_m2.get("kind", ""))] if not hit_m2.is_empty() else []
	print("   強制事件到達之後 ⇒ 推進停點認出 %s" % str(evs))
	_check("M2【途中事件】強制事件到達是推進的停點（forced_event_arrived）", evs.has("forced_event_arrived"))
	_cells_ran.append("M2")
	await _drop(node)
	print("\n── M3 用 X 推到抵達 ⇒ 抵達那一 tick 出現抵達句；★取消目標 ⇒ 不出現 ──")
	var c: Dictionary = await _m_start(SEED_A)
	var wc: Dictionary = c["w"]
	var stc: WorldState = wc["node"]._bridge._state
	var ptc: TeamData = stc.teams[stc.get_player_team_id()]
	var tgt_c: Vector2i = c["target"]
	var said_at: int = -1
	var arrived_at: int = -1
	for _i in range(12):
		await _press(wc, "x")
		var scr: String = _screen(wc["node"])
		if arrived_at == -1 and ptc.tile_pos == tgt_c:
			arrived_at = _i
		if said_at == -1 and scr.contains("抵達 (%d,%d)" % [tgt_c.x, tgt_c.y]):
			said_at = _i
		if arrived_at != -1:
			break
	print("   第幾次 X 到了：%d｜第幾次 X 畫面出現抵達句：%d" % [arrived_at, said_at])
	_check("M3 用 X 推到抵達 ⇒ 抵達句出現在抵達那一次", arrived_at != -1 and said_at == arrived_at)
	await _drop(wc["node"])
	var d: Dictionary = await _m_start(SEED_A)
	var wd: Dictionary = d["w"]
	var std: WorldState = wd["node"]._bridge._state
	var ptd: TeamData = std.teams[std.get_player_team_id()]
	ptd.move_target = Vector2i(-1, -1)   # 換任務／取消 ⇒ 目標被清掉而人不在那格
	var any_said: bool = false
	for _j in range(6):
		await _press(wd, "x")
		if _screen(wd["node"]).contains("抵達 ("):
			any_said = true
	print("   取消目標後推 6 小時 ⇒ 出現抵達句：%s（人在 %s）" % [str(any_said), str(ptd.tile_pos)])
	_check("M3【反向】目標被取消、人不在那格 ⇒ 不出現抵達句", not any_said)
	_cells_ran.append("M3")
	await _drop(wd["node"])


func _f_cells() -> void:
	print("\n── F1／F2 開戰那一屏：看得到敵人＋R 的回應只有一個出口（結果行）──")
	var w: Dictionary = await _bs_enter(SEED_A, false)
	_check("★F 母體地板：進得了戰鬥", not w.is_empty())
	if w.is_empty():
		_cells_ran.append_array(["F1", "F2"])
	else:
		var node: Node = w["node"]
		var view = node._encounter_view
		var st: WorldState = node._bridge._state
		var reg: String = _battle_region(_screen(node))
		var tgt: String = "\n".join(PackedStringArray(_section(reg, "── 目標 ──")))
		var codes: Dictionary = view.unit_codes(st)
		var enemy_codes: Array = []
		for i in codes:
			if int((st.encounter_units[i] as Dictionary).get("team_id", -1)) != view._player_team_id(st):
				enemy_codes.append(String(codes[i]))
		var map_txt: String = "\n".join(PackedStringArray(_section(reg, "── 戰場（")))
		var placed: Array = enemy_codes.filter(func(c): return RegEx.create_from_string("(^|\\s)%s(\\s|$)" % c).search(map_txt) != null \
			or RegEx.create_from_string("%s（[QWEASD] 方向 \\d+ 格）" % c).search(map_txt) != null)
		print("   開戰第一屏目標欄：%s｜敵方代號 %s，在地圖或畫面外（帶方向距離）的 %s" % [tgt.replace("\n", "｜"), str(enemy_codes), str(placed)])
		_check("F2 開戰第一屏目標欄非空（遭遇＝同格對峙，雙方互見）", RegEx.create_from_string("目標：[A-Z]（").search(tgt) != null)
		_check("F2 每一個敵方代號都在地圖上或畫面外清單（帶方向＋格數）（%d／%d）" % [placed.size(), enemy_codes.size()],
			not enemy_codes.is_empty() and placed.size() == enemy_codes.size())
		# F1：打不到（開戰時彼此相距遠）⇒ R 的原因句出現在結果行
		await _press(w, "r")
		var res1: String = _result_line(_screen(node))
		print("   R（打不到）⇒ 結果行「%s」" % res1)
		_check("F1 R 打不到 ⇒ 結果行出現原因句「%s」" % view.NO_TARGET_IN_RANGE_MSG, res1.contains(view.NO_TARGET_IN_RANGE_MSG))
		# F1 反向：把目標搬到旁邊 ⇒ R ⇒ 結果行是攻擊結果句（含目標代號）
		var me: Vector2i = view._find_player_unit(st).get("pos", Vector2i.ZERO)
		view._ensure_target(st)
		var ti: int = int(view._target_idx)
		if ti >= 0:
			(st.encounter_units[ti] as Dictionary)["pos"] = me + Vector2i(1, 0)
		await _press(w, "up")
		await _press(w, "r")
		var res2: String = _result_line(_screen(node)) if _screen(node).contains(TextUiView.BATTLE_TITLE) else ""
		var tcode: String = String(codes.get(ti, "?"))
		print("   R（目標 %s 在旁邊）⇒ 結果行「%s」" % [tcode, res2])
		_check("F1【反向】打得到 ⇒ 結果行是攻擊結果句（含 %s（）" % tcode, res2.contains(tcode + "（") and res2.contains("@（你）"))
		_cells_ran.append("F1")
		# F2 反向：一個敵人走出視野（搬到看不到的格）⇒ 之後不在地圖／目標欄
		var vis: Dictionary = view._player_visible_hexes(st, view._player_team_id(st))
		var hide_i: int = -1
		for i in codes:
			var u: Dictionary = st.encounter_units[i]
			if int(u.get("team_id", -1)) != view._player_team_id(st) and view._unit_present(u, st) and i != ti:
				hide_i = i
				break
		if hide_i == -1:
			hide_i = ti
		var far: Vector2i = Vector2i(-99, -99)
		for q in range(-12, 13):
			for r in range(-12, 13):
				var h := Vector2i(q, r)
				if view._is_in_map(h) and not vis.has(h) and far == Vector2i(-99, -99):
					far = h
		# ★「走出視野」＝先進過視野、再離開：先搬到主角旁邊刷新一次，再搬到看不到的格
		(st.encounter_units[hide_i] as Dictionary)["pos"] = me + Vector2i(0, 1)
		await _press(w, "up")
		(st.encounter_units[hide_i] as Dictionary)["pos"] = far
		await _press(w, "up")
		var reg3: String = _battle_region(_screen(node))
		var hc: String = String(codes[hide_i])
		var map3: String = "\n".join(PackedStringArray(_section(reg3, "── 戰場（")))
		var tgt3: String = "\n".join(PackedStringArray(_section(reg3, "── 目標 ──")))
		var still: bool = RegEx.create_from_string("(^|\\s)%s(\\s|（)" % hc).search(map3) != null or tgt3.contains(hc + "（")
		print("   %s 走到看不到的格 %s ⇒ 地圖／目標欄還有它：%s" % [hc, str(far), str(still)])
		_check("F2【反向】走出視野的敵人 %s 不再出現在地圖／目標欄" % hc, far != Vector2i(-99, -99) and not still)
		_cells_ran.append("F2")
		await _drop(node)
	print("\n── F3 推進鍵之後結果行＝推進句（時間與頂列一致）──")
	var wx: Dictionary = _new_w(await _build(SEED_A))
	var bad3: Array = []
	for k in ["x", "x", "space", "x"]:
		await _press(wx, k)
		var scr: String = _screen(wx["node"])
		var res: String = _result_line(scr)
		var clk: String = _top_clock(scr)
		var ok: bool = (res.contains("推進到 " + clk)) or res.contains("推進停在 " + clk)
		print("   按 %s ⇒ 頂列「%s」｜結果「%s」" % [k, clk, res])
		if not ok:
			bad3.append("%s：%s／%s" % [k, clk, res])
	_check("F3 每一次推進鍵之後結果行是推進句、時間＝頂列（錯：%s）" % str(bad3), bad3.is_empty())
	_cells_ran.append("F3")
	await _drop(wx["node"])


func _bs_cells() -> void:
	print("\n── BS1／BS3 進戰後 %d 拍不投降：每拍六欄＋單位列表＋畫面 tick＝世界 tick｜計時會變 ──" % BS_BEATS.size())
	var w: Dictionary = await _bs_enter(SEED_A, true)
	_check("★BS 母體地板：進得了戰鬥（主動攻擊同格隊）", not w.is_empty())
	if w.is_empty():
		_cells_ran.append_array(["BS1", "BS2", "BS3"])
		return
	var node: Node = w["node"]
	var bad1: Array = []
	var timer_sets: Dictionary = {str(_bs_timers(_screen(node))): true}
	var beats: int = 0
	var p10_before: int = (w["p10_bad"] as Array).size()
	for k in BS_BEATS:
		await _press(w, String(k))
		var scr: String = _screen(node)
		if not scr.contains(TextUiView.BATTLE_TITLE):
			bad1.append("第 %d 拍（%s）之後戰鬥區不見了" % [beats + 1, k])
			break
		beats += 1
		var miss: Array = BS_SIX.filter(func(x): return not scr.contains(String(x)))
		var units: int = _bs_timers(scr).size()
		var keys_ok: bool = _hint(node).replace(" ", "").contains(String(node._encounter_view.terminal_keys()).replace(" ", ""))
		print("   第 %d 拍（%s）：六欄缺 %s｜單位 %d 行｜鍵列 %s｜計時 %s｜tick %d" % [beats, k, str(miss), units,
			"對" if keys_ok else "錯", str(_bs_timers(scr)), _tick(node)])
		if not miss.is_empty() or units < 2 or not keys_ok:
			bad1.append("第 %d 拍：六欄缺 %s／單位 %d 行／鍵列 %s" % [beats, str(miss), units, str(keys_ok)])
		timer_sets[str(_bs_timers(scr))] = true
	var p10_new: Array = (w["p10_bad"] as Array).slice(p10_before)
	_check("★BS1 母體地板：戰鬥中按了 %d 拍（%d）" % [BS_BEATS.size(), beats], beats == BS_BEATS.size())
	_check("BS1 每拍六欄齊＋單位列表 ≥ 2 行＋鍵列＝戰鬥鍵（錯：%s）" % str(bad1), bad1.is_empty())
	_check("BS1 每拍回來那一屏的時間 ＝ 世界 tick（不同 %d：%s）" % [p10_new.size(), str(p10_new)], p10_new.is_empty())
	_cells_ran.append("BS1")
	print("   BS3 每次輪到玩家時看到的計時組合：%s" % str(timer_sets.keys()))
	_check("BS3 不同速的單位 ⇒ %d 拍內單位計時至少變一次（看到 %d 種組合）" % [BS_BEATS.size(), timer_sets.size()], timer_sets.size() >= 2)
	_cells_ran.append("BS3")
	await _bs_v2_cells(w)
	await _drop(node)

	print("\n── BS2 三種結束各一步：打完／撤出／投降 ⇒ 回到主畫面、結果句說出是哪一種 ──")
	var ends: Array = []
	# ①打完：一直待機（敵方會打過來）直到分出勝負
	var wf: Dictionary = await _bs_enter(SEED_A, false)
	if not wf.is_empty():
		var st_f: WorldState = wf["node"]._bridge._state
		var n_f: int = 0
		var en_battle: Dictionary = {}
		while st_f.encounter_active and n_f < BS_FIGHT_MAX and _screen(wf["node"]).contains(TextUiView.BATTLE_TITLE):
			await _press(wf, "space")
			n_f += 1
			# ★打到底的那一段有命中／落空 ⇒ 戰報真的有字 ⇒ 戰鬥區也掃英文識別字（自驗 (d) 同一支抽取器）
			for x in SELFCHECK._bad_english(_screen(wf["node"]).split(TextUiView.BATTLE_TITLE)[-1].split("─ 事件（")[0]):
				en_battle[String(x)] = true
		print("   ①打完：戰鬥區英文識別字 %s" % str(en_battle.keys()))
		_check("BS 打到底那一段的戰鬥區沒有英文識別字（命中：%s）" % str(en_battle.keys()), en_battle.is_empty())
		var back_f: bool = await _to_main(wf)
		var res_f: String = _result_line(_screen(wf["node"]))
		print("   ①打完：待機 %d 拍｜回主畫面 %s｜結果「%s」" % [n_f, str(back_f), res_f])
		ends.append({"kind": "打完", "ok": back_f and res_f.contains("戰鬥結束"), "res": res_f})
		await _drop(wf["node"])
	# ②撤出：被伏擊 ⇒ 往邊界外走（同 BATTLE② 的路）
	var we: Dictionary = _new_w(await _build(SEED_A))
	var st_e: WorldState = we["node"]._bridge._state
	EncounterSystem.new().init_encounter(st_e, NPC_ID, st_e.get_player_team_id(), "ambush")
	await _press(we, "x")
	var dir_key: String = ""
	for k in ["w", "q", "e", "a", "s", "d"]:
		if _hint(we["node"]).to_lower().contains(k):
			dir_key = k
			break
	for _i in range(30):
		if not _screen(we["node"]).contains(TextUiView.BATTLE_TITLE) or not st_e.encounter_active:
			break
		await _press(we, dir_key)
	var back_e: bool = await _to_main(we)
	var res_e: String = _result_line(_screen(we["node"]))
	print("   ②撤出：回主畫面 %s｜結果「%s」" % [str(back_e), res_e])
	ends.append({"kind": "撤出", "ok": back_e and res_e.contains("撤出"), "res": res_e})
	await _drop(we["node"])
	# ③投降：戰鬥區印的 F
	var ws: Dictionary = await _bs_enter(SEED_A, false)
	if not ws.is_empty():
		await _press(ws, "f")
		var back_s: bool = await _to_main(ws)
		var res_s: String = _result_line(_screen(ws["node"]))
		print("   ③投降：回主畫面 %s｜結果「%s」" % [str(back_s), res_s])
		ends.append({"kind": "投降", "ok": back_s and res_s.contains("投降"), "res": res_s})
		await _drop(ws["node"])
	var bad2: Array = ends.filter(func(e): return not bool(e["ok"])).map(func(e): return "%s：%s" % [e["kind"], e["res"]])
	_check("★BS2 母體地板：三種結束都走到（%d）" % ends.size(), ends.size() == 3)
	_check("BS2 每種結束都回到主畫面、結果句說出是哪一種（錯：%s）" % str(bad2), bad2.is_empty())
	_cells_ran.append("BS2")


# ══ E2：兩支都沒有勢力的隊，「提議同盟」不得因「同一個勢力」而不可 ══════════════════════════════
# ★舊版：faction_id −1 == −1 被當成同勢力（S1）
func _e2_no_faction_alliance() -> void:
	print("\n── E2 無勢力 vs 無勢力：提議同盟不得被判「同一個勢力」──")
	var w: Dictionary = _new_w(await _build(SEED_A))
	var st: WorldState = w["node"]._bridge._state
	var pf: int = st.teams[st.get_player_team_id()].faction_id
	var nf: int = st.teams[NPC_ID].faction_id
	await _press(w, "t")
	var p: Dictionary = parse_screen(_screen(w["node"]))
	if not bool(p["targets_active"]):
		await _press(w, "tab")
	await _press(w, "1")
	var pa: Dictionary = parse_screen(_screen(w["node"]))
	await _drop(w["node"])
	var lab: String = PlayerApiMapper.action_label("propose_alliance")
	var row: Dictionary = {}
	for a in pa["actions"]:
		if String(a["label"]) == lab:
			row = a
	print("   玩家勢力 %d｜NPC 勢力 %d｜「%s」列：%s" % [pf, nf, lab, str(row)])
	_check("★母體地板：兩邊都是 −1、且畫面上有「%s」那一列" % lab, pf == -1 and nf == -1 and not row.is_empty())
	var wrong: bool = not row.is_empty() and String(row.get("why", "")).contains("同一個勢力")
	if wrong and _known("E2", lab):
		pass
	else:
		_check("E2「%s」沒有因「同一個勢力」被判不可（%s）" % [lab, String(row.get("why", ""))], not wrong)
	# ★反向（spec P3）：真的同勢力 ⇒ 仍然不可（佈置：兩邊設成同一個 faction_id）——否則上一格對「判斷整個拿掉」也綠
	var w2: Dictionary = _new_w(await _build(SEED_A))
	var st2: WorldState = w2["node"]._bridge._state
	var fid: int = int(st2.factions.keys()[0]) if not st2.factions.is_empty() else 0
	st2.teams[st2.get_player_team_id()].faction_id = fid
	st2.teams[NPC_ID].faction_id = fid
	await _press(w2, "t")
	var p2: Dictionary = parse_screen(_screen(w2["node"]))
	if not bool(p2["targets_active"]):
		await _press(w2, "tab")
	await _press(w2, "1")
	await _press(w2, "?")   # ★F2 之後不可的項預設折疊 ⇒ 展開再看
	var pa2: Dictionary = parse_screen(_screen(w2["node"]))
	await _drop(w2["node"])
	var row2: Dictionary = {}
	for a in pa2["actions"]:
		if String(a["label"]) == lab:
			row2 = a
	print("   【反向】兩邊都設成勢力 %d ⇒「%s」列：%s" % [fid, lab, str(row2)])
	_check("E2【反向】真的同勢力 ⇒「%s」不可且原因是同一個勢力（%s）" % [lab, String(row2.get("why", ""))],
		not row2.is_empty() and not bool(row2.get("enabled", true)) and String(row2.get("why", "")).contains("同一個勢力"))
	# ★S1 母體（spec P4：印在卷面）：裸比較 `faction_id ==/!= x.faction_id` 剩幾行、共用函式被呼幾處（數字報掃描的數）
	var raw: Array = []
	var helper: int = 0
	var re_raw := RegEx.new()
	re_raw.compile("faction_id (==|!=) [a-z_0-9]*\\.faction_id")
	for root in ["res://scripts/simulation", "res://scripts/ui"]:
		for f in _gd_files(root):
			var i: int = 0
			for l in FileAccess.get_file_as_string(f).split("\n"):
				i += 1
				var code: String = String(l).split("#")[0]
				if re_raw.search(code) != null:
					raw.append("%s:%d" % [String(f).trim_prefix("res://scripts/"), i])
				helper += code.count("TeamData.same_faction(")
	print("   S1 母體：裸比較剩 %d 行（非註解）｜TeamData.same_faction( 呼叫 %d 處" % [raw.size(), helper])
	print("   裸比較清單：%s" % str(raw))
	_check("★S1 母體地板：共用函式真的被呼（%d）" % helper, helper >= 1)
	_cells_ran.append("E2")


static func _gd_files(root: String) -> Array:
	var out: Array = []
	var d := DirAccess.open(root)
	if d == null:
		return out
	for f in d.get_files():
		if String(f).ends_with(".gd"):
			out.append(root + "/" + String(f))
	for sub in d.get_directories():
		out.append_array(_gd_files(root + "/" + String(sub)))
	return out


# ══ E4：強制回應的標籤不帶前綴記號 ═══════════════════════════════════════════════════════════════
# ★實測（U5 查出）：多出來的那個字元是 `forced_label` 自己加的 ✓／✗（`player_api_mapper.gd` diplomacy 那一支）
#   ⇒ 終端 CP950 印不出來，看起來像一格空白；事件句「回應了「✓ 接受」」也帶著它
func _e4_forced_label_marks(r: Dictionary) -> void:
	print("\n── E4 強制回應標籤不帶 ✓／✗ 記號 ──")
	var labels: Dictionary = {}
	for k in r["offered"]:
		if String(k).begins_with("字母:"):
			labels[String(k).trim_prefix("字母:")] = true
	var marked: Array = labels.keys().filter(func(x): return String(x).begins_with("✓") or String(x).begins_with("✗"))
	print("   走法看過的強制回應標籤：%s｜帶記號：%s" % [str(labels.keys()), str(marked)])
	_check("★母體地板：走法看過 ≥ 1 個強制回應標籤（%d）" % labels.size(), labels.size() >= 1)
	if not marked.is_empty() and _known("E4", "記號"):
		pass
	else:
		_check("E4 強制回應標籤不帶 ✓／✗（%s）" % str(marked), marked.is_empty())
	_cells_ran.append("E4")


# ══ BATTLE（終端戰鬥區 spec 2026-10-07 terminal-battle-screen §2）════════════════════════════════════
#   ①主動攻擊 ⇒ 進戰鬥 ⇒ 用畫面印的鍵打到結束 ⇒ 回主畫面（P1）
#   ②被伏擊 ⇒ 進戰鬥 ⇒ 用 QWEASD 往邊界外走 ⇒ 撤出（P2）
#   ③戰鬥區六欄逐字 ＝ 那六個 Label 的 .text（P3）④無作用鍵說為什麼（P4）⑤單位行動倒數可見且會變（P5）
#   ⑥GUI 廣播一次按鍵 ⇒ _handle_key 只被呼一次（P10b）
func _battle_cells() -> void:
	print("\n── BATTLE 終端戰鬥區 ──")
	# ── ①主動攻擊：t → (tab) → 目標 → 攻擊鍵
	var w: Dictionary = _new_w(await _build(SEED_A))
	var node: Node = w["node"]
	var view = node._encounter_view
	await _press(w, "t")
	var p: Dictionary = parse_screen(_screen(node))
	if not bool(p["targets_active"]):
		await _press(w, "tab")
	await _press(w, "1")
	var atk_key: String = ""
	for a in parse_screen(_screen(node))["actions"]:
		if String(a["label"]) == PlayerApiMapper.action_label("attack") and bool(a["enabled"]):
			atk_key = String(a["key"])
	_check("★BATTLE 母體地板：畫面上有可按的「攻擊」（鍵 %s）" % atk_key, atk_key != "")
	if atk_key == "":
		await _drop(node)
		_cells_ran.append("BATTLE")
		return
	await _press(w, atk_key)
	var scr: String = _screen(node)
	var in_battle: bool = scr.contains(TextUiView.BATTLE_TITLE)
	print("   ①按攻擊 ⇒ 戰鬥區 %s｜世界 tick %d｜交戰中 %s" % [str(in_battle), _tick(node), str(node._bridge._state.encounter_active)])
	_check("BATTLE① 按攻擊之後畫面是戰鬥區（終端看得到戰鬥）", in_battle)
	# ③六欄逐字
	var bad3: Array = []
	for lbl in [view._lbl_count, view._lbl_health, view._lbl_equip, view._lbl_cursor_info, view._lbl_log]:
		for line in String(lbl.text).split("\n"):
			if String(line).strip_edges() != "" and not scr.contains(String(line)):
				bad3.append(String(line))
	# ★比對前去掉空白：頁腳折行／併空白會改空白數，字不會變
	var keys_ok: bool = _hint(node).replace(" ", "").contains(String(view._lbl_actions.text).replace(" ", "").replace("\n", ""))
	print("   ③六欄裡畫面上找不到的行：%s｜鍵列含 _lbl_actions 第一行 %s" % [str(bad3), str(keys_ok)])
	_check("BATTLE③ 戰鬥區六欄逐字 ＝ 那六個 Label 的 .text（缺 %d 行），鍵列 ＝ _lbl_actions" % bad3.size(), bad3.is_empty() and keys_ok)
	# ⑤單位行動倒數
	var re_t := RegEx.new()
	re_t.compile("(\\d+) 分鐘後行動")   # ★BS v2 C：倒數帶單位
	var t0: Array = re_t.search_all(scr).map(func(m): return m.get_string(1))
	# ④無作用鍵（主畫面的數字鍵）⇒ 說為什麼
	await _press(w, "1")
	var said4: String = _screen(node)
	_check("BATTLE④ 戰鬥中按無作用的鍵 ⇒ 戰鬥區印為什麼（「無作用」）", said4.contains("無作用"))
	# 推進幾步 ⇒ 收集每次輪到玩家時的倒數（★只在輪到玩家時看得到：press_on 等到那一刻才回畫面）
	var seen: Dictionary = {str(t0): true}
	for k in ["space", "w", "space", "d"]:
		await _press(w, k)
		if not _screen(node).contains(TextUiView.BATTLE_TITLE):
			break
		seen[str(re_t.search_all(_screen(node)).map(func(m): return m.get_string(1)))] = true
	# ★「推進後會變」在這一場看不到：全部單位同速 ⇒ 計時同步重置，每次輪到玩家都讀到同一組（玩家 0、其他 1 ——
	#   encounter_system 的單位迴圈裡玩家排第一，一到 0 就回 player_turn，其他單位那一 tick 還沒減）⇒ 回報，不硬判
	#   ⇒ 這一格判的是：倒數印在畫面上、且**逐單位 ＝ state 的 action_timer**（畫面沒有自己編一個數）
	var want: Array = []
	if _screen(node).contains(TextUiView.BATTLE_TITLE):
		# ★BS v2：列表只列看得到的單位（感知鐵律）⇒ state 那一側取同一個母體（view.visible_unit_indices）
		for _vi in view.visible_unit_indices(node._bridge._state):
			want.append(str(int((node._bridge._state.encounter_units[_vi] as Dictionary).get("action_timer", 0))))
	var shown: Array = re_t.search_all(_screen(node)).map(func(m): return m.get_string(1)) if _screen(node).contains(TextUiView.BATTLE_TITLE) else []
	print("   ⑤行動倒數（每次輪到玩家時看過的組合）：%s｜此刻畫面 %s／state %s" % [str(seen.keys()), str(shown), str(want)])
	_check("BATTLE⑤ 單位行動倒數印在畫面上（%d 個）且逐單位 ＝ state 的 action_timer" % t0.size(), t0.size() >= 2 and shown == want and not shown.is_empty())
	# ⑥P10b：模擬引擎廣播一次按鍵 ⇒ _handle_key 只被呼一次
	var ev := InputEventKey.new()
	ev.keycode = KEY_X
	ev.pressed = true
	var c0: int = int(view.handle_key_calls)
	node._input(ev)
	view._input(ev)
	var c1: int = int(view.handle_key_calls)
	print("   ⑥GUI 廣播一次按鍵（主節點 _input ＋ encounter_view _input）⇒ _handle_key 被呼 %d 次" % (c1 - c0))
	_check("BATTLE⑥ GUI 一次按鍵 ⇒ 戰鬥分派只被呼一次（%d）" % (c1 - c0), c1 - c0 == 1)
	# ⑦Z 命令選單（spec §1④）：終端看不到 GUI 彈窗 ⇒ 項目要印進戰鬥區（或說出「沒有可下令的隊友」），Esc 收起
	if _screen(node).contains(TextUiView.BATTLE_TITLE):
		await _press(w, "z")
		var zs: String = _screen(node)
		var z_ok: bool = zs.contains("── 命令（按數字選；Esc 取消）──") or zs.contains("沒有可下令的隊友")
		await _press(w, "esc")
		var z_closed: bool = not _screen(node).contains("── 命令（按數字選；Esc 取消）──")
		print("   ⑦Z ⇒ 選單印出或說明 %s｜Esc 後收起 %s" % [str(z_ok), str(z_closed)])
		_check("BATTLE⑦ Z 命令選單：項目印進戰鬥區（或說明沒有隊友），Esc 收起", z_ok and z_closed)
	# ①續：用畫面印的鍵打完 ⇒ 回主畫面
	var back: bool = await _to_main(w)
	print("   ①打完之後回主畫面 %s｜交戰中 %s" % [str(back), str(node._bridge._state.encounter_active)])
	_check("BATTLE① 用畫面上印的鍵打到結束並回到主畫面", back and not node._bridge._state.encounter_active)
	_check("BATTLE P6【反向】回到主畫面後沒有戰鬥區", not _screen(node).contains(TextUiView.BATTLE_TITLE))
	await _drop(node)
	# ── ②被伏擊 ⇒ 往邊界外撤出
	var w2: Dictionary = _new_w(await _build(SEED_A))
	var n2: Node = w2["node"]
	var st2: WorldState = n2._bridge._state
	EncounterSystem.new().init_encounter(st2, NPC_ID, st2.get_player_team_id(), "ambush")
	await _press(w2, "x")   # 推進一步 ⇒ _process 進戰鬥（同真實被伏擊：世界推進時發生）
	var in2: bool = _screen(n2).contains(TextUiView.BATTLE_TITLE)
	var dir_key: String = ""
	for k in ["w", "q", "e", "a", "s", "d"]:
		if _hint(n2).to_lower().contains(k):
			dir_key = k
			break
	var exited: bool = false
	for _i in range(30):
		if not _screen(n2).contains(TextUiView.BATTLE_TITLE) or not st2.encounter_active:
			break
		await _press(w2, dir_key)
		if _screen(n2).contains("離開戰場"):
			exited = true
	print("   ②伏擊 ⇒ 戰鬥區 %s｜撤出方向鍵 %s｜畫面說離開戰場 %s｜交戰中 %s" % [str(in2), dir_key, str(exited), str(st2.encounter_active)])
	_check("BATTLE② 被伏擊進戰鬥、用 QWEASD 往邊界外走 ⇒ 撤出（畫面說「離開戰場」、戰鬥結束）", in2 and exited and not st2.encounter_active)
	var back2: bool = await _to_main(w2)
	_check("BATTLE② 撤出之後回到主畫面", back2)
	await _drop(n2)
	_cells_ran.append("BATTLE")
