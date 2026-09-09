extends SceneTree
# @bed-kind: acceptance
# slice: 普查批一② MATERIAL_SHORTFALL_FULL → 自己的 need_keep 當分母
#
# 驗收（HOW spec §4）：①需求大/小的隊在【相同絕對缺口】下 drive 要分開
#   ②跨隊 _msf 相異值增加（分布不是單點） ③結構檢查：need_keep 只呼叫一次（成對對照）
#   ④_msf ∈ (0,1]（量到 >1 ⇒ 分母母體選錯）

const CTX_SRC: String = "res://scripts/simulation/decision/decision_context.gd"
const NEED_CALL: String = 'NeedOracle.need_keep(state, team, "material"'

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 3

func _initialize() -> void:
	print("=== MATERIAL SHORTFALL SCALE ===")
	_test_single_call_structure()
	_test_drive_separates_by_need()
	_test_world_distribution()
	if _sections != EXPECT_SECTIONS:
		_fails += 1
		push_error("[FAIL] 只跑完 %d/%d 段 —— 中途崩掉" % [_sections, EXPECT_SECTIONS])
	print("=== DONE === SECTIONS=%d/%d FAILS=%d" % [_sections, EXPECT_SECTIONS, _fails])
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_fails += 1
		push_error("[FAIL] " + msg)

func _count(hay: String, needle: String) -> int:
	var n: int = 0
	var from: int = 0
	while true:
		var i: int = hay.find(needle, from)
		if i == -1:
			break
		n += 1
		from = i + 1
	return n

func _test_single_call_structure() -> void:
	print("-- ③ 結構：need_keep(material) 在 decision_context 裡只呼叫一次 --")
	# ★★★成對對照先跑：對一段【自己造的、含兩次呼叫】的字串計數 ⇒ 必須是 2
	#   缺了這格，「真檔數到 1」在計數器壞掉時也會成立（恆真）。
	var fake: String = "\tvar a = %s, lv)\n\tvar b = %s, lv2)\n" % [NEED_CALL, NEED_CALL]
	var got_fake: int = _count(fake, NEED_CALL)
	_ok(got_fake == 2, "③對照：合成的兩次呼叫要數到 2（實得 %d）" % got_fake)
	var f := FileAccess.open(CTX_SRC, FileAccess.READ)
	if f == null:
		_fails += 1
		push_error("[FAIL] 讀不到 %s —— 這格什麼都沒驗到" % CTX_SRC)
		_sections += 1
		return
	var src: String = f.get_as_text()
	f.close()
	var got: int = _count(src, NEED_CALL)
	_ok(got == 1, "③真檔只呼叫一次（實得 %d）⇒ 分子分母不可能來自兩次呼叫" % got)
	_sections += 1

func _mk(shortfall: float, need_total: float, urgency: float) -> DecisionContext:
	var c := DecisionContext.new()
	c.material_shortfall = shortfall
	c.material_need_total = need_total
	c.material_build_urgency = urgency
	c.has_material_market = true
	c.has_specie = true
	return c

func _test_drive_separates_by_need() -> void:
	print("-- ① 相同絕對缺口、需求規模不同 ⇒ drive 要分開 --")
	var small := _mk(40.0, 50.0, 0.8)    # 只想補柵欄：缺 40 是天大的事（0.8）
	var big := _mk(40.0, 400.0, 0.8)     # 想蓋大設施：缺 40 是小事（0.1）
	var d_small: float = DecisionTerms.eval("buymaterial_drive", small, "買料")
	var d_big: float = DecisionTerms.eval("buymaterial_drive", big, "買料")
	print("  缺口都是 40｜need_total 50 ⇒ drive=%.4f｜need_total 400 ⇒ drive=%.4f" % [d_small, d_big])
	_ok(d_small > d_big, "①小需求隊的 drive(%.4f) > 大需求隊(%.4f)" % [d_small, d_big])
	# ★反向對照：舊寫法（分母固定 80）下這兩隊【會拿到同一個數】——這格證明差異真的來自分母
	var old_small: float = clampf(40.0 / 80.0, 0.0, 1.0) * 0.8
	var old_big: float = clampf(40.0 / 80.0, 0.0, 1.0) * 0.8
	_ok(is_equal_approx(old_small, old_big) and not is_equal_approx(d_small, d_big),
		"①反向對照：舊固定分母下兩隊同值(%.4f)，新分母下分開" % old_small)
	_sections += 1

func _test_world_distribution() -> void:
	print("-- ②④ 跨隊分布 + 值域 --")
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "res://config/warring_states.json"
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 3
	seed(1337)
	Probe.arm()
	var state: WorldState = MeasureBedHelper.arm_and_setup(cfg, true)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	var first_stall: int = -1
	var stall_reason: String = ""
	for tick in range(days * WorldState.TICKS_PER_DAY):
		var r: String = runner.advance_tick(state, no_player)
		if r != "" and first_stall == -1:
			first_stall = tick
			stall_reason = r
	print("  [有效窗] 請求 %d ticks｜首次非推進：%s" % [
		days * WorldState.TICKS_PER_DAY,
		("無" if first_stall == -1 else "tick %d（%s）" % [first_stall, stall_reason])])
	var msf: Array = []
	var over_one: int = 0
	var with_shortfall: int = 0
	for tid in state.teams:
		var ctx: DecisionContext = DecisionContext.gather(state, state.teams[tid])
		if ctx.material_shortfall <= 0.0:
			continue
		with_shortfall += 1
		var v: float = ctx.material_shortfall / maxf(ctx.material_need_total, 0.01)
		msf.append(v)
		if v > 1.0 + 0.0001:
			over_one += 1
	msf.sort()
	var distinct := {}
	for v in msf:
		distinct[snappedf(float(v), 0.001)] = true
	if msf.size() == 0:
		_fails += 1
		push_error("[FAIL] 母體為空（沒有任何隊有 material 缺口）⇒ 這格什麼都沒驗到")
		_sections += 1
		return
	print("  母體 %d 隊有缺口｜min=%.3f median=%.3f max=%.3f｜相異值 %d" % [
		msf.size(), float(msf[0]), float(msf[msf.size() / 2]), float(msf[msf.size() - 1]), distinct.size()])
	# ★★★2026-09-09 陰性對照揭：只看 _msf 的相異值【抓不到分母被換回常數】——
	#   分子（缺口）本來就跨隊變異 ⇒ 固定分母照樣生出一堆相異值。
	#   ⇒ 要斷言的是【分母本身跨隊變異】，那才是本票改的東西。
	var dens := {}
	for tid2 in state.teams:
		var c2: DecisionContext = DecisionContext.gather(state, state.teams[tid2])
		if c2.material_shortfall > 0.0:
			dens[snappedf(c2.material_need_total, 0.001)] = true
	print("  分母 material_need_total 相異值 %d（★舊版是【一個常數】⇒ 相異 1）" % dens.size())
	_ok(dens.size() > 1, "②【分母】跨隊有變異（相異值 %d > 1）—— 陰性對照：分母換回常數時這格必紅" % dens.size())
	_ok(distinct.size() > 1, "②跨隊 _msf 有變異（相異值 %d > 1）" % distinct.size())
	_ok(over_one == 0, "④_msf 全部 ≤ 1（>1 的隊 %d ⇒ 分母母體選錯）" % over_one)
	_ok(float(msf[0]) > 0.0, "④有缺口的隊 _msf > 0（下界，值域 (0,1]）")
	_sections += 1
