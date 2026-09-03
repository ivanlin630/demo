class_name CrossRunReset

# ★★★跨 run 靜態殘留的【單一呼叫點】（systems 裁定 2026-09-03）。
#
# ★背景（血證，不是預防性設計）：
#   ① `goal_resolver.gd::_fall_seen` 去重字典跨輪殘留 ⇒ `observability_path_test` 第二輪
#      `goal.res_fall_distinct.*` 一次都不 bump（on=5/58/54 vs off=0/0/0）⇒ 那張床紅了六週，
#      而紅的理由跟它掛的名字不同（它掛的是「tracer 污染 Probe」）。
#   ② `path_system.gd::_path_cache` 跨世界命中 72 次（同 seed／300 tick／warring 實測）。
#   ⇒ ★★兩個都不是「有人寫錯」，是【同一個結構性缺口】：同一個 process 跑第二個世界時，
#     static 不會跟著新世界重生。
#
# ★★形狀（為什麼是這個形狀，不是別的）：
#   ·【各系統自己清】——`_reset_cross_run()` 住在擁有那份 state 的檔裡。
#     ★一個大函式伸手去清別人的 static ＝ 破壞所有權，改一個系統要改那個大函式。
#   ·【只有一個呼叫點】——`GameSetup.setup()` 開頭。
#     ★★散在各床各 setup 路徑 ⇒ 會變成「有人記得清、有人忘了」，★★★而忘了是【靜默】的。
#
# ★★★分界線：清什麼、印什麼、不碰什麼（systems 裁定；★兩者在 setup 當下長得一模一樣，
#   所以只能用【誰有權設它】分，不能用【它現在是什麼值】分）：
#   ·【清】累積型容器與計數器 —— 沒有人會刻意預填它們，非空＝上一輪的殘骸。
#   ·【印】旗標 —— 它可能是【這一輪故意設的】（床先設旗標再建世界的話，清掉＝殺掉床自己的設定）。
#   ·【不碰】唯讀表 —— 見 §唯讀表 的名單與理由。
#
# ★盲區（明說，因為不說的話下一個人會以為這行涵蓋全部）：
#   本檔只看得見【已經註冊進來的】。有人新加一個可變 static 而沒註冊 ⇒ 這裡永遠不會提到它。
#   ★★那一格【不歸這裡管】，歸「新 static 必須有清除點或白名單」那張機械檢查票（靜態 grep）。
#   ★★★兩條軸、兩個工具：這裡抓【註冊進來的有沒有被清】，靜態閘抓【有沒有東西沒註冊進來】。

# ★上一次 run() 的結果（供床印 `[diag] cross-run:` 那一行）。
#   ★★`checked` 必須跟 `cleared` 一起印 —— 只印 `cleared=none` 的話，
#     ★★★「真的乾淨」與「reset 根本沒跑」長得一模一樣。
static var last_report: Dictionary = {"checked": 0, "cleared": {}, "flags": {}}

# ★唯讀表：production 寫入點＝0，所以【不需要】清除點。
#   ★★這裡寫出名單與理由，否則下一個人會以為是漏了。
#   ·`GoalRegistry.REGISTRY`／`DecisionOptions.REGISTRY`／`FactionAISystem.FACILITY_DEFICIT_DEF`
#     ⇒ 全樹（production＋debug）寫入點 0。
#   ·`SimRunner.SYSTEMS` ⇒ production 寫入 0；唯一寫入在 `seam3_sysreg_test.gd::_test_extensibility_dummy_both`
#     （append 一個 dummy 系統），而同一個函式結尾 `pop_back()` 還原 ⇒ 不需要清除點。
#     ★誠實限：那個 `pop_back()` 在【必經路徑】上（該檔 `_ok()` 不中止、其間無 return/assert/quit），
#       ★★但若未來有人在中間插一個提早 return，它就會漏還原 —— 那是【潛伏風險】不是既有事故。
#   ★★★誠實限（對整份名單）：判準是 grep 寫入形式，抓不到「用區域變數持有參照再改」
#     （`var r = REGISTRY; r[...] = ...` —— Dictionary 是參照型別）。

# ★旗標：只印不清。這裡是名單與【預設值】，非預設才會出現在 `flags=` 欄。
const _FLAG_DEFAULTS: Dictionary = {
	"SimRunner.force_full_hd": false,
	"SimRunner.phase_timing": false,
	"PathSystem.suppress_observe_noise": false,
	"OwnerOutpostIndex.shadow": false,
	"FactionAISystem.trace_infra": false,
	"FactionAISystem._mk_verify": false,
	"WorldState.driver_ledger_enabled": false,
}

# ★單一呼叫點呼這一支。回 {checked:int, cleared:{name:清之前的量}, residue:{...}, flags:{name:非預設值}}。
static func run() -> Dictionary:
	var cleared: Dictionary = _sweep()
	# ★★★第二遍 —— 而它不是保險，是【鑑別力】。
	#   ★陽性對照當場證明的事：只印「清之前非空的那些」的話，
	#     把某個系統的 `clear()` 拿掉，這一行【還是照樣印它的名字】
	#     ⇒ ★★那條線報的是【打算清什麼】不是【清掉了什麼】⇒ 它永遠不會變紅 ＝ 裝飾品。
	#   ⇒ ★★★所以再掃一遍：第二遍還報得出來的，就是【真的沒被清掉】。
	#     成本＝對一堆已經空掉的容器再問一次 is_empty()。
	var residue: Dictionary = _sweep()
	var checked: int = int(_LAST_CHECKED)
	var flags: Dictionary = {}
	for k in _FLAG_DEFAULTS:
		var cur = _read_flag(String(k))
		if cur != _FLAG_DEFAULTS[k]:
			flags[String(k)] = cur
	last_report = {"checked": checked, "cleared": cleared, "residue": residue, "flags": flags}
	return last_report

# ★掃一遍所有註冊的系統：各自清自己的，回「清之前非空的那些」。
static var _LAST_CHECKED: int = 0
static func _sweep() -> Dictionary:
	var out: Dictionary = {}
	var n: int = 0
	for d in [
		PathSystem._reset_cross_run(),
		GoalResolver._reset_cross_run(),
		FactionAISystem._reset_cross_run(),
		InteractionSystem._reset_cross_run(),
		NpcCombatSystem._reset_cross_run(),
		OwnerOutpostIndex._reset_cross_run(),
		SimRunner._reset_cross_run(),
		WorldState._reset_cross_run(),
	]:
		n += int(d.get("checked", 0))
		var c: Dictionary = d.get("cleared", {})
		for k in c:
			out[String(k)] = c[k]
	_LAST_CHECKED = n
	return out

# ★旗標讀值（★用字串表而不是 Callable：這張表要能被人一眼讀完，而它就是那份名單本身）
static func _read_flag(name: String):
	match name:
		"SimRunner.force_full_hd": return SimRunner.force_full_hd
		"SimRunner.phase_timing": return SimRunner.phase_timing
		"PathSystem.suppress_observe_noise": return PathSystem.suppress_observe_noise
		"OwnerOutpostIndex.shadow": return OwnerOutpostIndex.shadow
		"FactionAISystem.trace_infra": return FactionAISystem.trace_infra
		"FactionAISystem._mk_verify": return FactionAISystem._mk_verify
		"WorldState.driver_ledger_enabled": return WorldState.driver_ledger_enabled
	return null

# ★給床印的一行。★★`cleared` 非空【不是紅】——第一輪之後本來就有東西可清，
#   ★★★它是「清除點真的在做事」的陽性證據；若它從第一天就恆為 none，那才要懷疑接線。
static func report_line() -> String:
	var r: Dictionary = last_report
	var cl: Dictionary = r.get("cleared", {})
	var fl: Dictionary = r.get("flags", {})
	var cs: String = "none"
	if not cl.is_empty():
		var ks: Array = cl.keys(); ks.sort()
		var parts: Array = []
		for k in ks: parts.append("%s(%s)" % [k, str(cl[k])])
		cs = " ".join(PackedStringArray(parts))
	# ★★★residue 非空 ＝【有東西沒被清掉】＝ 真的紅（跟 cleared 非空完全相反的意義）
	var rd: Dictionary = r.get("residue", {})
	var rs: String = ""
	if not rd.is_empty():
		var rk: Array = rd.keys(); rk.sort()
		var rp: Array = []
		for k in rk: rp.append(String(k))
		rs = " ★RESIDUE(沒清掉)=" + " ".join(PackedStringArray(rp))
	var fs: String = "none"
	if not fl.is_empty():
		var fk: Array = fl.keys(); fk.sort()
		var fp: Array = []
		for k in fk: fp.append("%s=%s" % [k, str(fl[k])])
		fs = " ".join(PackedStringArray(fp))
	return "[diag] cross-run: checked=%d cleared=%s flags=%s%s" % [int(r.get("checked", 0)), cs, fs, rs]
